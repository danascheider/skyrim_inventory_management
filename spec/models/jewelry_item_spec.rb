# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JewelryItem, type: :model do
  describe 'validations' do
    let(:item) { build(:jewelry_item) }

    describe '#name' do
      it 'is invalid without a name' do
        item.name = nil
        item.validate
        expect(item.errors[:name]).to include "can't be blank"
      end
    end

    describe '#jewelry_type' do
      it 'is invalid with an invalid value' do
        item.jewelry_type = 'necklace'
        item.validate
        expect(item.errors[:jewelry_type]).to include 'must be "ring", "circlet", or "amulet"'
      end

      it 'can be blank' do
        item.jewelry_type = nil
        expect(item).to be_valid
      end
    end

    describe '#unit_weight' do
      it 'is invalid if less than 0' do
        item.unit_weight = -5
        item.validate
        expect(item.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end

      it 'can be blank' do
        item.unit_weight = nil
        expect(item).to be_valid
      end
    end
  end

  describe '#crafting_materials' do
    subject(:crafting_materials) { item.crafting_materials }

    context 'when canonical_jewelry_item is set' do
      let!(:canonical_jewelry_item) { create(:canonical_jewelry_item, :with_crafting_materials, name: 'Gold Diamond Ring') }
      let(:item) { create(:jewelry_item, name: 'Gold Diamond Ring', canonical_jewelry_item:) }

      it 'uses the values from the canonical model' do
        expect(crafting_materials).to eq canonical_jewelry_item.crafting_materials
      end
    end

    context 'when canonical_jewelry_item is not set' do
      let!(:canonical_models) do
        create_list(
          :canonical_jewelry_item,
          2,
          :with_crafting_materials,
          name: 'Gold Diamond Ring',
        )
      end

      let(:item) { create(:jewelry_item, name: 'Gold Diamond Ring') }

      it 'returns nil' do
        expect(crafting_materials).to be_nil
      end
    end
  end
end
