# frozen_string_literal: true

require 'dry/monads/result'
require 'lamassu/policy_container'

RSpec.describe Lamassu::Guardian do
  let(:guardian) { described_class.new }

  Article = Struct.new(:author, :published)
  User    = Struct.new(:id)

  before do
    guardian.policies.for Article do
      check :read, (lambda do |subject:, target:|
        target.published || target.author == subject.id
      end)
      check :update, ->(subject:, target:) { target.author == subject.id }
      check :list, ->(**_) { true }
    end
  end

  describe '#authorize' do
    context 'with instance target' do
      context 'and authorized subject' do
        let(:article) { Article.new(:bob, true) }
        let(:user) { User.new(:bob) }

        context 'the result' do
          subject { guardian.authorize user, article, :read }

          it { is_expected.to be_a Dry::Monads::Result::Success }
        end
      end

      context 'and unauthorized subject' do
        let(:article) { Article.new(:bob, false) }
        let(:user) { User.new(:fred) }

        context 'the result' do
          subject { guardian.authorize user, article, :read }

          it { is_expected.to be_a Dry::Monads::Result::Failure }
        end
      end

      context 'with multiple policies' do
        let(:article) { Article.new(:bob, true) }
        let(:authorized_user) { User.new(:bob) }
        let(:unauthorized_user) { User.new(:fred) }

        context 'the result for user passing all policies' do
          subject { guardian.authorize authorized_user, article, :read, :update }

          it { is_expected.to be_a Dry::Monads::Result::Success }
        end

        context 'the result for user failing one policy' do
          subject { guardian.authorize unauthorized_user, article, :read, :update }

          it { is_expected.to be_a Dry::Monads::Result::Failure }
        end
      end
    end

    context 'with module target' do
      context 'and authorized subject' do
        let(:user) { User.new(:bob) }

        context 'the result' do
          subject { guardian.authorize user, Article, :list }

          it { is_expected.to be_a Dry::Monads::Result::Success }
        end
      end
    end

    context 'with string target' do
      context 'and authorized subject' do
        let(:user) { User.new(:bob) }

        context 'the result' do
          subject { guardian.authorize user, 'article', :list }

          it { is_expected.to be_a Dry::Monads::Result::Success }
        end
      end
    end

    context 'with symbol target' do
      context 'and authorized subject' do
        let(:user) { User.new(:bob) }

        context 'the result' do
          subject { guardian.authorize user, :article, :list }

          it { is_expected.to be_a Dry::Monads::Result::Success }
        end
      end
    end

    context 'with invalid context' do
      let(:article) { Article.new(:bob, true) }
      let(:user) { User.new(:bob) }

      it do
        expect { guardian.authorize user, :foo, :read }
          .to raise_error 'Nothing registered with the key "foo.read"'
      end
    end
  end
end
