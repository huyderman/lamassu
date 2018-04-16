# frozen_string_literal: true

require 'dry/monads/result'
require 'lamassu/policy_container'

RSpec.describe Lamassu::PolicyContainer do
  class MyClass; end

  let(:container) { described_class.new }

  let(:my_policy) { proc { Dry::Monads::Result::Success.new(true) } }

  describe '#policy' do
    before do
      container.policy :read, my_policy
    end

    it 'registers a policy in the container' do
      expect(container.resolve(:read)).to eq my_policy
    end
  end

  describe '#check' do
    let(:policy_object) { proc { true } }
    before { container.check :check, policy_object }

    subject { container.resolve(:check) }

    it { is_expected.to be_a Lamassu::PolicyAdapters::Check }
    it 'should wrap the proc in `#policy`' do
      is_expected.to have_attributes policy: an_instance_of(Proc)
    end
  end

  describe '#map' do
    let(:policy_object) { proc { 42 } }
    before { container.map :map, policy_object }

    subject { container.resolve(:map) }

    it { is_expected.to be_a Lamassu::PolicyAdapters::Map }
    it 'should wrap the proc in `#policy`' do
      is_expected.to have_attributes policy: an_instance_of(Proc)
    end
  end

  describe '#for' do
    context 'with class as namespace' do
      before do
        pol = my_policy
        container.for(MyClass) { policy :read, pol }
      end

      it 'registers policy with underscored name as namespace' do
        expect(container.resolve('my_class.read')).to eq my_policy
      end
    end

    context 'with string as namespace' do
      before do
        pol = my_policy
        container.for('foo') { policy :read, pol }
      end

      it 'registers policy with underscored name as namespace' do
        expect(container.resolve('foo.read')).to eq my_policy
      end
    end
  end
end
