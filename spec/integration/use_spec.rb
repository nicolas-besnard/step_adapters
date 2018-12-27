RSpec.describe "Validate include", :adapter do
  before do
    if !Dry::Transaction::StepAdapters.key?(:valid)
      Dry::Transaction::StepAdapters.register(:valid, StepAdapters::Validate.new)
    end
  end

  let(:transaction) do
    class OtherTransaction
      include Dry::Transaction

      step :will_succeed

      def will_succeed(input)
        Success(foo: :bar)
      end
    end

    Class.new do
      include Dry::Transaction
      include StepAdapters::Use::Mixin

      use OtherTransaction.new
    end
  end

  it 'merges the result of the other transaction with the initial input' do
    result = transaction.new.call(name: "filled")

    expect(result.value!).to eql({name: "filled", foo: :bar})
  end

  context "with option" do
    let(:transaction) do
      class OtherTransaction
        include Dry::Transaction

        step :will_succeed_2

        def will_succeed_2(input)
          Success(foo: :bar)
        end
      end

      Class.new do
        include Dry::Transaction
        include StepAdapters::Use::Mixin

        use OtherTransaction.new, bar: :bar
      end
    end

    it 'merges the options with the result' do
      result = transaction.new.call(name: "filled")

      expect(result.value!).to eql({name: "filled", foo: :bar, bar: :bar})
    end
  end
end
