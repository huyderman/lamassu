# frozen_string_literal: true

require 'dry/monads/result'
require 'dry-matcher'
require 'dry/matcher/result_matcher'

module Lamassu
  # Base module to be included in policy objects
  module Policy
    def self.included(klass)
      klass.class_eval do
        include Dry::Monads::Result::Mixin
        include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)
      end
    end
  end
end
