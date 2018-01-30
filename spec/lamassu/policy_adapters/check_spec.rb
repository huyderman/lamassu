# frozen_string_literal: true

require 'dry/monads/result'
require 'lamassu/policy_adapters/check'

RSpec.describe Lamassu::PolicyAdapters::Check do
  describe '#call' do
    context 'initialized with a proc always returning true' do
      let(:check) { described_class.new(proc { true }) }

      context 'the return value' do
        subject { check.call }

        it { is_expected.to be_a Dry::Monads::Result::Success }
      end
    end

    context 'initialized with a proc always returning false' do
      let(:check) { described_class.new(proc { false }) }

      context 'the return value' do
        subject { check.call }

        it { is_expected.to be_a Dry::Monads::Result::Failure }
      end
    end
  end
end
