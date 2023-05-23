# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  describe 'validations' do
    let(:ingredient) { build(:ingredient) }

    it 'is invalid without a name' do
      ingredient.name = nil
      ingredient.validate
      expect(ingredient.errors[:name]).to include "can't be blank"
    end

    context 'when there are multiple matching canonical ingredients' do
      before do
        create_list(:canonical_ingredient, 3, name: ingredient.name)
      end

      it 'is valid' do
        expect(ingredient).to be_valid
      end
    end

    context 'when there is one matching canonical ingredient' do
      before do
        create(:canonical_ingredient, name: ingredient.name)
      end

      it 'is valid' do
        expect(ingredient).to be_valid
      end
    end

    context 'when there are no matching canonical ingredients' do
      it 'is invalid' do
        ingredient.validate
        expect(ingredient.errors[:base]).to include "doesn't match an ingredient that exists in Skyrim"
      end
    end
  end

  describe '::before_validation' do
    let(:ingredient) { build(:ingredient) }

    context 'when there is a matching canonical ingredient' do
      let!(:matching_canonical) { create(:canonical_ingredient, name: ingredient.name) }

      it 'sets the canonical_ingredient' do
        ingredient.validate
        expect(ingredient.canonical_ingredient).to eq matching_canonical
      end
    end

    context 'when there are multiple matching canonical ingredients' do
      let!(:matching_canonicals) { create_list(:canonical_ingredient, 2, name: ingredient.name) }

      it "doesn't set the canonical ingredient" do
        ingredient.validate
        expect(ingredient.canonical_ingredient).to be_nil
      end
    end

    context 'when there is no matching canonical ingredient' do
      it "doesn't set the canonical ingredient" do
        ingredient.validate
        expect(ingredient.canonical_ingredient).to be_nil
      end
    end
  end
end
