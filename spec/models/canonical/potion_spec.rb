# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::Potion, type: :model do
  describe 'validations' do
    describe 'name' do
      it "can't be blank" do
        model = build(:canonical_potion, name: nil)

        model.validate
        expect(model.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item_code' do
      it "can't be blank" do
        model = build(:canonical_potion, item_code: nil)

        model.validate
        expect(model.errors[:item_code]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:canonical_potion, item_code: 'foobar')
        model = build(:canonical_potion, item_code: 'foobar')

        model.validate
        expect(model.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'unit_weight' do
      it "can't be blank" do
        model = build(:canonical_potion, unit_weight: nil)

        model.validate
        expect(model.errors[:unit_weight]).to include "can't be blank"
      end

      it 'must be a number' do
        model = build(:canonical_potion, unit_weight: 'foo')

        model.validate
        expect(model.errors[:unit_weight]).to include 'is not a number'
      end

      it 'must be at least zero' do
        model = build(:canonical_potion, unit_weight: -0.5)

        model.validate
        expect(model.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end

    describe 'purchasable' do
      it "can't be blank" do
        model = build(:canonical_potion, purchasable: nil)

        model.validate
        expect(model.errors[:purchasable]).to include 'must be true or false'
      end
    end

    describe 'unique_item' do
      it "can't be blank" do
        model = build(:canonical_potion, unique_item: nil)

        model.validate
        expect(model.errors[:unique_item]).to include 'must be true or false'
      end
    end

    describe 'rare_item' do
      it "can't be blank" do
        model = build(:canonical_potion, rare_item: nil)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true or false'
      end

      it 'must be true if item is unique' do
        model = build(:canonical_potion, unique_item: true, rare_item: false)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true if item is unique'
      end
    end

    describe 'quest_item' do
      it "can't be blank" do
        model = build(:canonical_potion, quest_item: nil)

        model.validate
        expect(model.errors[:quest_item]).to include 'must be true or false'
      end
    end
  end

  describe 'default behavior' do
    it 'upcases item codes' do
      potion = create(:canonical_potion, item_code: 'abc123')
      expect(potion.reload.item_code).to eq 'ABC123'
    end
  end

  describe 'associations' do
    describe 'alchemical properties' do
      let(:potion) { create(:canonical_potion) }
      let(:alchemical_property) { create(:alchemical_property) }

      before do
        potion
          .canonical_potions_alchemical_properties
          .create!(
            alchemical_property:,
            strength: 15,
            duration: 30,
          )

        potion.reload
      end

      it 'returns the alchemical property' do
        expect(potion.alchemical_properties.first).to eq alchemical_property
      end
    end
  end

  describe '::unique_identifier' do
    it 'returns ":item_code"' do
      expect(described_class.unique_identifier).to eq :item_code
    end
  end
end
