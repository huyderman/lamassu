# frozen_string_literal: true

require 'dry/inflector'
require 'lamassu/policy_container'

module Lamassu
  # Guardian object for authorizing a subject
  class Guardian
    include Dry::Monads::Result::Mixin

    attr_reader :container

    def initialize(container: PolicyContainer.new, **_)
      @container = container
    end

    alias_method :policies, :container

    # Check authorization for subject on target for one or more policies
    #
    # If more than one policy is specified, it will return the last Success if
    # all policies are successful. Otherwise, it will return the first Failure
    #
    # :reek:LongParameterList
    # @param [Object] subject Subject for authorization check
    # @param [Object,Module] target Target for authorization check
    # @param [Symbol,String] policies Policy or policies to check
    # @param [Hash] opts Additional options passed to policy object
    # @param [Proc] block
    # @return [Dry::Result]
    def authorize(subject, target, *policies, **opts, &block)
      namespace = target_namespace(target)

      policies.reduce(Success(nil)) do |result, action|
        result.bind do
          policy = container.resolve("#{namespace}.#{action}")

          if opts.empty?
            policy.call(subject, target, &block)
          else
            policy.call(subject, target, **opts, &block)
          end
        end
      end
    end

    private

    # :reek:FeatureEnvy
    # @param [Object,Module] target
    def target_namespace(target)
      inflector = Dry::Inflector.new
      case target
      when Module
        inflector.underscore(target)
      when String, Symbol
        target
      else
        inflector.underscore(target.class)
      end
    end
  end
end
