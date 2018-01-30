# frozen_string_literal: true

require 'dry/monads/result'
require 'lamassu/policy_adapters/check'

RSpec.describe Lamassu::PolicyAdapters::Map do
  describe '#call' do
    context 'initialized with a proc returning a value' do
      let(:check) { described_class.new(proc { 42 }) }

      context 'the return value' do
        subject { check.call }

        it { is_expected.to be_a Dry::Monads::Result::Success }
      end
    end
  end
end
