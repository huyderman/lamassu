# frozen_string_literal: true

require 'dry/monads/result'
require 'dry-matcher'
require 'dry/matcher/result_matcher'

module Lamassu
  module PolicyAdapters
    # Policy Adapter for a callable wrapping returned value to Success on true
    # and Failure on false
    class Check
      extend Dry::Initializer

      include Dry::Monads::Result::Mixin
      include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

      param :policy

      def call(*args)
        value = policy.call(*args)

        if value
          Success(value)
        else
          Failure(value)
        end
      end
    end
  end
end
