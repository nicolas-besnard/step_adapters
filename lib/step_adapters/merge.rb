module StepAdapters
  class Merge
    include Dry::Monads::Result::Mixin

    def call(operation, options, args)
      result = operation.call(*args)

      if result.respond_to?(:failure) && result.failure?
        return result
      end

      if result.respond_to?(:value!)
        result = result.value!
      end

      initial_args = args[0]

      if result.is_a?(Hash)
        return Success(initial_args.merge(result))
      end

      key_to_add = (options[:key] || options[:step_name]).to_sym

      Success(initial_args.merge(key_to_add => result))
    end
  end
end
