RSpec.describe StepAdapters::Tap, :adapter do
  subject { described_class.new }

  let(:operation) {
    -> (input) { input }
  }
  let(:options) { { step_name: "unit" } }

  describe "#call" do
    it 'returns the input unchanged' do
      input = { foo: :bar }
      expect(subject.(operation, options, [input])).to eql(Success(input))
    end

    it 'returns a Failure when the result is a failure' do
      operation = -> (_input) { Failure(:a_failure) }
      expect(subject.(operation, options, [{ foo: :bar }])).to eql(Failure(:a_failure))
    end
  end
end
