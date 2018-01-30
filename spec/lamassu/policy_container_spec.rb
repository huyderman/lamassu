# frozen_string_literal: true

require 'dry/monads/result'
require 'lamassu/policy_container'

RSpec.describe Lamassu::PolicyContainer do
  let(:container) { described_class.new }

  let(:my_policy) { ->(**_) { Dry::Monads::Result::Success.new(true) } }

  describe '#policy' do
    before do
      container.policy :read, my_policy
    end

    it 'registers a policy in the container' do
      expect(container.resolve(:read)).to eq my_policy
    end
  end

  describe '#check' do
    before do
      container.check :check, (proc { true })
    end

    it 'wraps a proc with the check adapter' do
      expect(container.resolve(:check)).to be_a Lamassu::PolicyAdapters::Check
    end
  end

  describe '#map' do
    before do
      container.map :map, (proc { 42 })
    end

    it 'wraps a proc with the map adapter' do
      expect(container.resolve(:map)).to be_a Lamassu::PolicyAdapters::Map
    end
  end

  describe '#for' do
    context 'with String as namespace' do
      before do
        pol = my_policy
        container.for(String) do
          policy :read, pol
        end
      end

      it 'registers policy with `string` as namespace' do
        expect(container.resolve('string.read')).to eq my_policy
      end
    end
  end
end
