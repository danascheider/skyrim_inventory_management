# frozen_string_literal: true

RSpec.describe Titlecase do
  describe '#titleize' do
    context 'when there are prepositions and conjunctions' do
      it 'capitalises everything but excluded words' do
        string = 'lORd of the rIngs'
        expect(Titlecase.titleize(string)).to eq 'Lord of the Rings'
      end

      it 'capitalises the first word no matter what' do
        string = 'in the jungle'
        expect(Titlecase.titleize(string)).to eq 'In the Jungle'
      end

      it 'capitalises the last word do matter what' do
        string = 'what were you thinking of?'
        expect(Titlecase.titleize(string)).to eq 'What Were You Thinking Of?'
      end
    end
  end
end
