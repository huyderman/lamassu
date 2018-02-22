# frozen_string_literal: true

require 'dry-container'
require 'dry/monads/result'
require 'lamassu/policy_adapters/check'
require 'lamassu/policy_adapters/map'

module Lamassu
  # Dry::Container with convenience methods when registering policy objects
  class PolicyContainer
    include Dry::Container::Mixin
    include Dry::Monads::Result::Mixin

    # @param [Module] klazz
    # @param [Proc] block
    # @return [PolicyContainer]
    def for(klazz, &block)
      container = PolicyContainer.new
      container.instance_eval(&block)

      namespace = case klazz
                  when Module
                    Dry::Inflector.new.underscore(klazz)
                  else
                    klazz.to_s
                  end
      merge(container, namespace: namespace)
    end

    alias_method :policy, :register

    # @param [String,Symbol] key
    # @param [#call] policy_object
    def check(key, policy_object)
      register(key, PolicyAdapters::Check.new(policy_object))
    end

    # @param [String,Symbol] key
    # @param [#call] policy_object
    def map(key, policy_object)
      register(key, PolicyAdapters::Map.new(policy_object))
    end
  end
end
