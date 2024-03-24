# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::RawMaterial, type: :model do
  describe 'validations' do
    it 'is valid with a valid name, item code, and unit weight' do
      material = build(:canonical_raw_material, item_code: 'foo', unit_weight: 7.0, name: 'bear pelt')

      expect(material).to be_valid
    end

    describe 'name' do
      it 'is invalid without a name' do
        material = described_class.new(item_code: 'foo', unit_weight: 4.2)

        material.validate
        expect(material.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item_code' do
      it 'is invalid without an item code' do
        material = described_class.new(name: 'foo', unit_weight: 1.5)

        material.validate
        expect(material.errors[:item_code]).to include "can't be blank"
      end

      it 'is invalid with a duplicate item code' do
        create(:canonical_raw_material, item_code: 'foo')
        material = build(:canonical_raw_material, item_code: 'foo')

        material.validate
        expect(material.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'unit_weight' do
      it 'is invalid without a unit weight' do
        material = described_class.new(name: 'foo')

        material.validate
        expect(material.errors[:unit_weight]).to include "can't be blank"
      end

      it 'is invalid with a non-numeric unit weight' do
        material = described_class.new(name: 'foo', unit_weight: 'bar')

        material.validate
        expect(material.errors[:unit_weight]).to include 'is not a number'
      end

      it 'is invalid without a negative unit weight' do
        material = described_class.new(name: 'foo', unit_weight: -4.0)

        material.validate
        expect(material.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end
  end

  describe 'default behavior' do
    it 'upcases item codes' do
      material = create(:canonical_raw_material, item_code: 'abc123')
      expect(material.reload.item_code).to eq 'ABC123'
    end
  end

  describe 'associations' do
    describe '#craftable_weapons' do
      subject(:craftable_weapons) { raw_material.craftable_weapons }

      let!(:raw_material) { create(:canonical_raw_material) }
      let!(:craftable1) { create(:canonical_weapon) }
      let!(:craftable2) { create(:canonical_weapon) }

      before do
        create(:canonical_material, craftable: craftable1, source_material: raw_material)
        create(:canonical_material, craftable: craftable2, source_material: raw_material)
        create(:canonical_material, temperable: create(:canonical_weapon), source_material: raw_material)
        raw_material.reload
      end

      it 'returns only associated craftable weapons' do
        expect(craftable_weapons).to contain_exactly(craftable1, craftable2)
      end
    end

    describe '#temperable_weapons' do
      subject(:temperable_weapons) { raw_material.temperable_weapons }

      let!(:raw_material) { create(:canonical_raw_material) }
      let!(:temperable1) { create(:canonical_weapon) }
      let!(:temperable2) { create(:canonical_weapon) }

      before do
        create(:canonical_material, temperable: temperable1, source_material: raw_material)
        create(:canonical_material, temperable: temperable2, source_material: raw_material)
        create(
          :canonical_material,
          craftable: create(:canonical_weapon),
          source_material: raw_material,
        )

        raw_material.reload
      end

      it 'returns only associated temperable weapons' do
        expect(temperable_weapons).to contain_exactly(temperable1, temperable2)
      end
    end

    describe '#craftable_armors' do
      subject(:craftable_armors) { raw_material.craftable_armors }

      let!(:raw_material) { create(:canonical_raw_material) }
      let!(:craftable1) { create(:canonical_armor) }
      let!(:craftable2) { create(:canonical_armor) }

      before do
        create(:canonical_material, craftable: craftable1, source_material: raw_material)
        create(:canonical_material, craftable: craftable2, source_material: raw_material)
        create(:canonical_material, temperable: create(:canonical_armor), source_material: raw_material)
        raw_material.reload
      end

      it 'returns only associated craftable armors' do
        expect(craftable_armors).to contain_exactly(craftable1, craftable2)
      end
    end

    describe '#temperable_armors' do
      subject(:temperable_armors) { raw_material.temperable_armors }

      let!(:raw_material) { create(:canonical_raw_material) }
      let!(:temperable1) { create(:canonical_armor) }
      let!(:temperable2) { create(:canonical_armor) }

      before do
        create(:canonical_material, temperable: temperable1, source_material: raw_material)
        create(:canonical_material, temperable: temperable2, source_material: raw_material)
        create(:canonical_material, craftable: create(:canonical_armor), source_material: raw_material)
        raw_material.reload
      end

      it 'returns only associated temperable armors' do
        expect(temperable_armors).to contain_exactly(temperable1, temperable2)
      end
    end

    describe '#jewelry_items' do
      subject(:jewelry_items) { raw_material.jewelry_items }

      let!(:raw_material) { create(:canonical_raw_material) }
      let!(:craftable1) { create(:canonical_jewelry_item) }
      let!(:craftable2) { create(:canonical_jewelry_item) }

      before do
        create(:canonical_material, craftable: craftable1, source_material: raw_material)
        create(:canonical_material, craftable: craftable2, source_material: raw_material)
        raw_material.reload
      end

      it 'returns only associated craftable jewelry items' do
        expect(jewelry_items).to contain_exactly(craftable1, craftable2)
      end
    end
  end

  describe 'class methods' do
    describe '::unique_identifier' do
      it 'returns :item_code' do
        expect(described_class.unique_identifier).to eq :item_code
      end
    end
  end
end
