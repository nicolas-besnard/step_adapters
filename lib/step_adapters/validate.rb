module StepAdapters
  class Validate
    include Dry::Monads::Result::Mixin

    module Mixin
      def self.included(base)
        base.send :extend, ClassMethods
        base.send :extend, Dry::Core::ClassAttributes
        base.defines :schema
      end

      module ClassMethods
        def input_validation(schema = nil, &block)
          if block_given?
            schema(Dry::Validation.Params(&block))
          else
            schema(schema)
          end

          valid :validate

          define_method :validate do |params|
            self.class.schema.call(params)
          end
        end
      end
    end

    def call(operation, _options, input)
      result = operation.call(*input)

      if result.success?
        Success(result.output)
      else
        Failure(result)
      end
    end
  end
end
