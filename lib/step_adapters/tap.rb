module StepAdapters
  # Add a "tap" step that works similarly to the built-in "tee" step in
  # that if the step is successful it ignores the output and returns the
  # input.  However, if the step returns a Failure, then that failure is
  # not ignored as it is with "tee", but is instead returned directly.
  #
  # Usage:
  #
  # tap :update_metadata
  #
  # def update_metadata(user:, **)
  #   resp = APIClient.update_data(name: user.name)
  #   return Failure(resp) if resp.code != 200
  #   # on success this will implicitly return `nil`, but subsequent steps will
  #   # still have access to `user:` and other kwargs
  # end
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
