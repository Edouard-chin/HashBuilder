require 'active_support/callbacks'

module HashBuilder
  class ContextDelegator < SimpleDelegator
    include ActiveSupport::Callbacks
    class UnsatisfiedCondition < StandardError; end

    attr_accessor :called_method

    define_callbacks :transform, terminator: ->(target, result) { result == false }

    def halted_callback_hook(*)
      raise UnsatisfiedCondition
    end
  end
end