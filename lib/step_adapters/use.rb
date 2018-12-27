module StepAdapters
  # Adds a "use" step that will call other transactions. If that
  # transaction returns a Hash, it will be merged with the input hash and
  # returned, otherwise the step returns the result of the transaction. If
  # the transaction results in a Failure, that failure is returned.
  #
  # Usage:
  #
  #   use MyTransaction
  #
  class Use
    module Mixin
      def self.included(base)
        base.send :extend, ClassMethods
      end

      module ClassMethods
        def use(transaction, **kwargs)
          method_name = (transaction.is_a?(Class) ? transaction : transaction.class).name.intern
          step method_name

          define_method method_name do |params|
            params_with_kwargs = params.merge(kwargs)

            result = transaction.call(params_with_kwargs)

            result.fmap do |value|
              value.is_a?(Hash) ? params_with_kwargs.merge(value) : params
            end
          end
        end
      end
    end
  end
end

