# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Armor, type: :model do
  describe 'validations' do
    let(:armor) { build(:armor) }

    it 'is invalid without a name' do
      armor.name = nil
      armor.validate
      expect(armor.errors[:name]).to include "can't be blank"
    end

    it 'is invalid with an invalid weight value' do
      armor.weight = 'medium armor'
      armor.validate
      expect(armor.errors[:weight]).to include 'must be "light armor" or "heavy armor"'
    end

    it 'is invalid with a negative unit weight' do
      armor.unit_weight = -2.5
      armor.validate
      expect(armor.errors[:unit_weight]).to include 'must be greater than or equal to 0'
    end
  end

  describe '#canonical_armors' do
    subject(:canonical_armors) { armor.canonical_armors }

    context 'when the item has an association defined' do
      let(:armor) { create(:armor, name: canonical_armor.name, canonical_armor:) }
      let(:canonical_armor) { create(:canonical_armor) }

      it 'returns the associated model in an array' do
        expect(canonical_armors).to eq [canonical_armor]
      end
    end

    context 'when the item does not have an association defined' do
      before do
        create(:canonical_armor, name: 'Something Else')
      end

      context 'when only the name has to match' do
        let!(:matching_canonicals) { create_list(:canonical_armor, 3, name: armor.name, unit_weight: 2.5) }

        let(:armor) { create(:armor, unit_weight: nil) }

        it 'returns all matching items' do
          expect(canonical_armors).to eq matching_canonicals
        end
      end

      context 'when multiple attributes have to match' do
        let!(:matching_canonicals) { create_list(:canonical_armor, 3, name: armor.name, unit_weight: 2.5) }

        let(:armor) { create(:armor, unit_weight: 2.5) }

        before do
          create(:canonical_armor, name: armor.name, unit_weight: 1)
        end

        it 'returns only the items for which all values match' do
          expect(canonical_armors).to eq matching_canonicals
        end
      end
    end
  end
end
