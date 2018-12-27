module StepAdapters
  # Adds a "merge" step that expects the input to the step to be a hash,
  # and then merges the successful result of the step into the input hash.
  # If the step results in a Failure then that Failure is returned instead.
  #
  # If the return value of the step is not a hash, then the return value is
  # merged into the input hash using the step name as the key.
  #
  # Usage:
  #
  # merge :user
  # merge :lookup_metadata
  #
  # # input: { user_id: 42, name: "Chuck" }
  # def user(user_id:, **)
  #   User.find(user_id)
  # end
  # # output: { user_id: 42, name: "Chuck", user: #<User id:42> }
  #
  # def lookup_metadata(user:,.**)
  #   resp = APIClient.get_email(user.client_id)
  #   { email: resp["user_email"], fists: resp["fists"]["items"].size }
  # end
  #
  # # output: { user_id: 42, name: "Chuck", user: #<User id:42>, email: "chuck@example", fists: 2 }
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
