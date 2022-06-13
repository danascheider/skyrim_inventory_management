# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::MiscItem, type: :model do
  describe 'validations' do
    describe 'name' do
      it "can't be blank" do
        model = build(:canonical_misc_item, name: nil)

        model.validate
        expect(model.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item_code' do
      it "can't be blank" do
        model = build(:canonical_misc_item, item_code: nil)

        model.validate
        expect(model.errors[:item_code]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:canonical_misc_item, item_code: 'foo')
        model = build(:canonical_misc_item, item_code: 'foo')

        model.validate
        expect(model.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'unit_weight' do
      it "can't be blank" do
        model = build(:canonical_misc_item, unit_weight: nil)

        model.validate
        expect(model.errors[:unit_weight]).to include "can't be blank"
      end

      it 'must be a number' do
        model = build(:canonical_misc_item, unit_weight: 'foo')

        model.validate
        expect(model.errors[:unit_weight]).to include 'is not a number'
      end

      it 'must be at least zero' do
        model = build(:canonical_misc_item, unit_weight: -2)

        model.validate
        expect(model.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end

    describe 'item_types' do
      it "can't be blank" do
        model = build(:canonical_misc_item, item_types: nil)

        model.validate
        expect(model.errors[:item_types]).to include "can't be blank"
      end

      it 'must include at least one valid type' do
        model = build(:canonical_misc_item, item_types: [])

        model.validate
        expect(model.errors[:item_types]).to include 'must include at least one item type'
      end

      it 'must include only valid types' do
        model = build(:canonical_misc_item, item_types: ['Dwemer artifact', 'industrial equipment'])

        model.validate
        expect(model.errors[:item_types]).to include 'can only include valid item types'
      end
    end

    describe 'purchasable' do
      it "can't be blank" do
        model = build(:canonical_misc_item, purchasable: nil)

        model.validate
        expect(model.errors[:purchasable]).to include 'must be true or false'
      end
    end

    describe 'unique_item' do
      it "can't be blank" do
        model = build(:canonical_misc_item, unique_item: nil)

        model.validate
        expect(model.errors[:unique_item]).to include 'must be true or false'
      end
    end

    describe 'rare_item' do
      it "can't be blank" do
        model = build(:canonical_misc_item, rare_item: nil)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true or false'
      end

      it 'must be true if unique_item is true' do
        model = build(:canonical_misc_item, unique_item: true, rare_item: false)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true if item is unique'
      end
    end

    describe 'quest_item' do
      it "can't be blank" do
        model = build(:canonical_misc_item, quest_item: nil)

        model.validate
        expect(model.errors[:quest_item]).to include 'must be true or false'
      end
    end
  end

  describe 'default behavior' do
    it 'upcases the item code' do
      item = create(:canonical_misc_item, item_code: 'abc123')
      expect(item.reload.item_code).to eq 'ABC123'
    end
  end

  describe 'class methods' do
    describe '::unique_identifier' do
      it 'returns ":item_code"' do
        expect(described_class.unique_identifier).to eq :item_code
      end
    end
  end
end
