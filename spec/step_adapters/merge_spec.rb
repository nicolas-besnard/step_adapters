RSpec.describe StepAdapters::Merge, :adapter do
  subject { described_class.new }

  let(:options) { { step_name: "unit" } }
  let(:operation) {
    -> (_input) { 'return_value' }
  }
  let(:input) { {} }

  describe "#call" do
    it 'returns the input with the step name as key and the operation value as value' do
      expect(subject.(operation, options, [input])).to eql(Success(unit: 'return_value'))
    end

    it 'returns the input with the specified step name when provided' do
      options = { step_name: "unit", key: :new_key }
      expect(subject.(operation, options, [input])).to eql(Success(new_key: 'return_value'))
    end

    it 'symbolizes the key to add' do
      options = { step_name: "unit", key: 'new_key' }
      expect(subject.(operation, options, [input])).to eql(Success(new_key: 'return_value'))
    end

    it 'returns a Failure when the result is a failure' do
      operation = -> (_input) { Failure(:a_failure) }
      expect(subject.(operation, options, [input])).to eql(Failure(:a_failure))
    end

    it 'merges the result if it is a hash' do
      operation = -> (_input) { { foo: :bar, bar: :baz } }
      input     = { user: 1 }
      expect(subject.(operation, options, [input])).to eql(Success(user: 1, foo: :bar, bar: :baz))
    end

    it "unwrap the value if it's a monad" do
      operation = -> (_input) { Success(foo: :bar) }
      expect(subject.(operation, options, [input])).to eql(Success(foo: :bar))
    end
  end
end
