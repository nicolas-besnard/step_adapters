module StepAdapters
  class Tap
    include Dry::Monads::Result::Mixin

    def call(operation, _options, args)
      result = operation.call(*args)

      if result.respond_to?(:failure?) && result.failure?
        return result
      end

      Success(args[0])
    end
  end
end
