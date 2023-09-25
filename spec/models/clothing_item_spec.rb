# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClothingItem, type: :model do
  describe 'validations' do
    let(:item) { build(:clothing_item) }

    before do
      allow_any_instance_of(ClothingItemValidator).to receive(:validate)
    end

    it 'is invalid without a name' do
      item.name = nil
      item.validate
      expect(item.errors[:name]).to include "can't be blank"
    end

    it 'is invalid with unit weight less than 0' do
      item.unit_weight = -1
      item.validate
      expect(item.errors[:unit_weight]).to include 'must be greater than or equal to 0'
    end

    it 'validates against canonical models' do
      expect_any_instance_of(ClothingItemValidator).to receive(:validate).with(item)
      item.validate
    end
  end

  describe '::before_validation' do
    context 'when there is a single matching canonical model' do
      let!(:matching_canonical) do
        create(
          :canonical_clothing_item,
          :with_enchantments,
          name: 'Fine Clothes',
          unit_weight: 1,
          magical_effects: 'Something',
        )
      end

      let(:item) do
        build(
          :clothing_item,
          name: 'Fine clothes',
          unit_weight: 1,
        )
      end

      before do
        create(:canonical_clothing_item, name: 'Fine Clothes', unit_weight: 2)
      end

      it 'assigns the canonical clothing item' do
        item.validate
        expect(item.canonical_clothing_item).to eq matching_canonical
      end

      it 'sets the attributes', :aggregate_failures do
        item.validate
        expect(item.name).to eq 'Fine Clothes'
        expect(item.magical_effects).to eq 'Something'
      end
    end

    context 'when there are multiple matching canonical models' do
      let!(:matching_canonicals) do
        create_list(
          :canonical_clothing_item,
          2,
          :with_enchantments,
          name: 'Fine Clothes',
          unit_weight: 1,
        )
      end

      let(:item) { build(:clothing_item, name: 'Fine clothes') }

      it "doesn't set the corresponding canonical clothing item" do
        item.validate
        expect(item.canonical_clothing_item).to be_nil
      end

      it "doesn't set other attributes", :aggregate_failures do
        item.validate
        expect(item.name).to eq 'Fine clothes'
        expect(item.unit_weight).to be_nil
        expect(item.magical_effects).to be_nil
      end
    end

    context 'when there are no matching canonical models' do
      let(:item) { build(:clothing_item) }

      it 'is invalid' do
        item.validate
        expect(item.errors[:base]).to include "doesn't match a clothing item that exists in Skyrim"
      end
    end
  end

  describe '::after_create' do
    context 'when there is a single matching canonical model' do
      let!(:matching_canonical) do
        create(
          :canonical_clothing_item,
          :with_enchantments,
          name: 'Fine Clothes',
          unit_weight: 1,
          magical_effects: 'Something',
        )
      end

      context "when the new item doesn't have its own enchantments" do
        let(:item) do
          build(
            :clothing_item,
            name: 'Fine clothes',
            unit_weight: 1,
          )
        end

        it 'adds enchantments from the canonical model' do
          item.save!
          expect(item.enchantments.length).to eq 2
        end

        it 'sets the correct strengths', :aggregate_failures do
          item.save!
          matching_canonical.enchantables_enchantments.each do |join_model|
            has_matching = item.enchantables_enchantments.any? do |model|
              model.enchantment == join_model.enchantment && model.strength == join_model.strength
            end

            expect(has_matching).to be true
          end
        end
      end

      context 'when the new item has its own enchantments' do
        let(:item) do
          create(
            :clothing_item,
            :with_enchantments,
            name: 'Fine clothes',
            unit_weight: 1,
          )
        end

        it "doesn't remove the existing enchantments" do
          item.save!
          expect(item.enchantments.reload.length).to eq 4
        end
      end
    end

    context 'when there are multiple matching canonical models' do
      let!(:matching_canonicals) do
        create_list(
          :canonical_clothing_item,
          2,
          :with_enchantments,
          name: 'Fine Clothes',
          unit_weight: 1,
          magical_effects: 'Something',
        )
      end

      let(:item) { build(:clothing_item, name: 'fine clothes') }

      it "doesn't add enchantments" do
        item.save!
        expect(item.enchantments).to be_blank
      end
    end
  end

  describe '#canonical_clothing_items' do
    subject(:canonical_clothing_items) { item.canonical_clothing_items }

    context 'when the item has an association defined' do
      let(:item) do
        create(
          :clothing_item,
          canonical_clothing_item:,
          name: 'Fine Clothes',
          unit_weight: 1,
          magical_effects: nil,
        )
      end

      let(:canonical_clothing_item) do
        create(
          :canonical_clothing_item,
          name: 'Fine Clothes',
          unit_weight: 1,
          magical_effects: nil,
        )
      end

      it 'returns the associated model in an array' do
        expect(canonical_clothing_items).to eq [canonical_clothing_item]
      end
    end

    context 'when the item does not have an association defined' do
      before do
        create(:canonical_clothing_item, name: 'Something Else')
      end

      context 'when only the name has to match' do
        let!(:matching_canonicals) { create_list(:canonical_clothing_item, 3, name: item.name, unit_weight: 2.5) }

        let(:item) { build(:clothing_item, unit_weight: nil) }

        it 'returns all matching items' do
          expect(canonical_clothing_items).to eq matching_canonicals
        end
      end

      context 'when multiple attributes have to match' do
        let!(:matching_canonicals) { create_list(:canonical_clothing_item, 3, name: item.name, unit_weight: 2.5) }

        let(:item) { build(:clothing_item, unit_weight: 2.5) }

        before do
          create(:canonical_clothing_item, name: item.name, unit_weight: 1)
        end

        it 'returns only the items for which all values match' do
          expect(canonical_clothing_items).to eq matching_canonicals
        end
      end
    end
  end
end