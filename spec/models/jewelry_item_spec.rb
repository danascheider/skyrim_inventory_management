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
        item.validate
        expect(item.errors[:jewelry_type]).to be_blank
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
        item.validate
        expect(item.errors[:unit_weight]).to be_blank
      end
    end

    describe '#canonical_jewelry_items' do
      context 'when there is a single matching canonical jewelry item' do
        let(:item) { build(:jewelry_item, :with_matching_canonical) }

        it 'is valid' do
          expect(item).to be_valid
        end
      end

      context 'when there are multiple matching canonical jewelry items' do
        before do
          create_list(
            :canonical_jewelry_item,
            2,
            name: item.name,
          )
        end

        it 'is valid' do
          expect(item).to be_valid
        end
      end

      context 'when there are no matching canonical jewelry items' do
        let(:item) { build(:jewelry_item) }

        it 'adds errors' do
          item.validate
          expect(item.errors[:base]).to include "doesn't match any jewelry item that exists in Skyrim"
        end
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

  describe '#canonical_jewelry_items' do
    subject(:canonical_jewelry_items) { item.canonical_jewelry_items }

    context 'when the item has an association defined' do
      let(:item) { create(:jewelry_item, :with_matching_canonical) }

      before do
        create(:canonical_jewelry_item, name: item.name)
      end

      it 'includes only the associated model' do
        expect(canonical_jewelry_items).to contain_exactly(item.canonical_jewelry_item)
      end
    end

    context 'when the item does not have an association defined' do
      let(:item) { create(:jewelry_item, name: 'Gold diamond ring') }

      context 'when only the name has to match' do
        let!(:matching_canonicals) do
          create_list(
            :canonical_jewelry_item,
            3,
            name: 'Gold Diamond Ring',
          )
        end

        it 'matches case-insensitively' do
          expect(canonical_jewelry_items).to contain_exactly(*matching_canonicals)
        end
      end

      context 'when multiple attributes have to match' do
        let!(:matching_canonicals) do
          create_list(
            :canonical_jewelry_item,
            2,
            name: 'Gold Diamond Ring',
            unit_weight: 0.2,
          )
        end

        let(:item) { create(:jewelry_item, name: 'Gold diamond ring', unit_weight: 0.2) }

        before do
          create(:canonical_jewelry_item, name: 'Gold Diamond Ring', unit_weight: 3)
        end

        it 'returns the matching models' do
          expect(canonical_jewelry_items).to contain_exactly(*matching_canonicals)
        end
      end
    end
  end

  describe '::before_validation' do
    context 'when there is a single matching canonical model' do
      let!(:matching_canonical) do
        create(
          :canonical_jewelry_item,
          :with_enchantments,
          name: 'Gold Diamond Ring',
          unit_weight: 0.2,
          jewelry_type: 'ring',
          magical_effects: 'Some magical effects to differentiate',
        )
      end

      let(:item) do
        build(
          :jewelry_item,
          name: 'Gold diamond ring',
          unit_weight: 0.2,
        )
      end

      before do
        create(:canonical_jewelry_item, name: 'Gold Diamond Ring', unit_weight: 1)
      end

      it 'assigns the canonical jewelry item' do
        item.validate
        expect(item.canonical_jewelry_item).to eq matching_canonical
      end

      it 'sets the attributes', :aggregate_failures do
        item.validate
        expect(item.name).to eq 'Gold Diamond Ring'
        expect(item.unit_weight).to eq 0.2
        expect(item.jewelry_type).to eq 'ring'
        expect(item.magical_effects).to eq 'Some magical effects to differentiate'
      end

      it 'adds enchantments if persisted' do
        item.save!

        # This realistically won't happen but in the interest of thoroughness...
        item.enchantables_enchantments.each(&:destroy)

        expect { item.validate }
          .to change(item.enchantables_enchantments.reload, :length).from(0).to(2)
      end
    end

    context 'when there are multiple matching canonical models' do
      let!(:matching_canonicals) do
        create_list(
          :canonical_jewelry_item,
          2,
          :with_enchantments,
          name: 'Gold Diamond Ring',
          unit_weight: 0.2,
        )
      end

      let(:item) { create(:jewelry_item, name: 'Gold Diamond Ring', unit_weight: 0.2) }

      it "doesn't add enchantments" do
        expect(item.enchantables_enchantments).to be_blank
      end
    end
  end

  describe '::after_create' do
    let(:item) { create(:jewelry_item, name: 'Gold Diamond Ring') }

    context 'when there is a single matching canonical model' do
      before do
        create(
          :canonical_jewelry_item,
          :with_enchantments,
          name: 'Gold Diamond Ring',
        )
      end

      it 'adds enchantments' do
        expect(item.enchantments.length).to eq 2
      end
    end

    context 'when there are multiple matching canonical models' do
      before do
        create_list(
          :canonical_jewelry_item,
          2,
          :with_enchantments,
          name: 'Gold Diamond Ring',
        )
      end

      it "doesn't set enchantments" do
        expect(item.enchantables_enchantments.length).to eq 0
      end
    end
  end
end
