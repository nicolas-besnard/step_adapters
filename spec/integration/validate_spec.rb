RSpec.describe "Validate include", :adapter do
  before do
    if !Dry::Transaction::StepAdapters.key?(:valid)
      Dry::Transaction::StepAdapters.register(:valid, StepAdapters::Validate.new)
    end
  end

  let(:transaction) do
    schema = Dry::Validation.Schema do
      required(:name, :string).filled(:str?)
    end

    Class.new do
      include Dry::Transaction
      include StepAdapters::Validate::Mixin

      input_validation schema
    end
  end

  it 'failed when the schema can not be validated' do
    result = transaction.new.call({})

    expect(result).to be_a(Dry::Monads::Failure)
    expect(result.failure).to be_a(Dry::Validation::Result)
  end

  it 'succeed when the schema is valid' do
    result = transaction.new.call(name: "filled")

    expect(result).to be_a(Dry::Monads::Success)
    expect(result.value!).to eql(name: "filled")
  end

  context "when a block is provided" do
    let(:transaction) do
      Class.new do
        include Dry::Transaction
        include StepAdapters::Validate::Mixin

        input_validation do
          required(:name, :string).filled(:str?)
        end
      end
    end

    it 'failed when the schema can not be validated' do
      result = transaction.new.call({})

      expect(result).to be_a(Dry::Monads::Failure)
      expect(result.failure).to be_a(Dry::Validation::Result)
    end

    it 'succeed when the schema is valid' do
      result = transaction.new.call(name: "filled")

      expect(result).to be_a(Dry::Monads::Success)
      expect(result.value!).to eql(name: "filled")
    end
  end
end
