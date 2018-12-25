module StepAdapters
  class Merge
    include Dry::Monads::Result::Mixin

    def call(operation, options, args)
      result = operation.call(*args)

      if result.respond_to?(:failure?) && result.failure?
        return result
      end

      value = (result.respond_to?(:value!) && result.value!) || result || {}

      key = (options[:key] || options[:step_name]).to_sym

      if !value.is_a?(Hash)
        value = { key => value }
      end

      Success(args[0].merge(value))
    end
  end
end
