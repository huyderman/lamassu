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

    # @param [Module] scope
    # @param [Proc] block
    # @return [PolicyContainer]
    def for(scope, &block)
      container = PolicyContainer.new
      container.instance_eval(&block)

      namespace = case scope
                  when Module
                    Dry::Inflector.new.underscore(scope)
                  else
                    scope
                  end
      merge(container, namespace: namespace)
    end

    # @param [String,Symbol] key
    # @param [#call] policy_object
    def policy(key, policy_object)
      register(key, policy_object, call: false)
    end

    # @param [String,Symbol] key
    # @param [#call] policy_object
    def check(key, policy_object)
      policy(key, PolicyAdapters::Check.new(policy_object))
    end

    # @param [String,Symbol] key
    # @param [#call] policy_object
    def map(key, policy_object)
      policy(key, PolicyAdapters::Map.new(policy_object))
    end
  end
end
