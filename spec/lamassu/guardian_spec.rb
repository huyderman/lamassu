# frozen_string_literal: true

require 'dry/monads/result'
require 'lamassu/policy_container'

RSpec.describe Lamassu::Guardian do
  let(:guardian) { described_class.new }

  Article = Struct.new(:author, :published)
  User    = Struct.new(:id)

  let(:read_policy_class) do
    Class.new do
      include Lamassu::Policy

      def call(subject, target)
        if target.published || target.author == subject.id
          Success(:allowed)
        else
          Failure(:disallowed)
        end
      end
    end
  end

  before do
    read_policy = read_policy_class.new
    guardian.policies.for Article do
      policy :read, read_policy
      check :update, ->(subject, target) { target.author == subject.id }
      check :list, (proc { true })
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

        it 'resolves to success in block' do
          result = nil
          guardian.authorize user, article, :read do |r|
            r.success { result = :success }
            r.failure { result = :failure }
          end
          expect(result).to eq :success
        end
      end

      context 'and unauthorized subject' do
        let(:article) { Article.new(:bob, false) }
        let(:user) { User.new(:fred) }

        context 'the result' do
          subject { guardian.authorize user, article, :read }

          it { is_expected.to be_a Dry::Monads::Result::Failure }
        end

        it 'resolves to failure in block' do
          result = nil
          guardian.authorize user, article, :read do |r|
            r.success { result = :success }
            r.failure { result = :failure }
          end
          expect(result).to eq :failure
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
          subject do
            guardian.authorize unauthorized_user, article, :update, :list
          end

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
