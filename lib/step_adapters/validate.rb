module StepAdapters
  # Adds a "validation" step that expects the method to return a
  # Dry::Validation validator. It runs the validator on the input
  # arguments, and returns Success on the validation output when the
  # validator passes, or Failure with the result containing the validation
  # errors.
  #
  # Also adds a DSL method `validate` that allows you do define the
  # validator inline and will then run it as the step.
  #
  # You'll need the register the `valid` before using the mixin:
  # Dry::Transaction::StepAdapters.register(:valid, ::StepAdapters::Validate.new)
  #
  # In a transaction, you'll have to include the mixin
  #
  # class MyTransaction
  #   include Dry::Transaction
  #   include StepAdapters::Validate::Mixin
  # end
  #
  # Usage with a schema class:
  #
  # MySchema = Dry::Validation.Params do
  #   require(:name).filled
  #   optional(:age).maybe(:int?)
  # end
  #
  #
  # input_validation MySchema
  # step :next_thing
  #
  # Usage with an explicit validation step:
  #
  # valid :my_validation
  # step :next_thing
  #
  # def my_validation(params)
  #   Dry::Validation.Params do
  #     require(:name).filled
  #     optional(:age).maybe(:int?)
  #   end
  # end
  #
  # def next_thing(name:, age:)
  # end
  #
  # Usage with an implicit validator:
  #
  # input_validation do
  #   require(:name).filled
  #   optional(:age).maybe(:int?)
  # end
  #
  # step :next_thing
  #
  # def next_thing(name:, age:)
  # end
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
