# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::Staff, type: :model do
  describe 'validations' do
    describe 'name' do
      it "can't be blank" do
        model = build(:canonical_staff, name: nil)

        model.validate
        expect(model.errors[:name]).to include "can't be blank"
      end
    end

    describe 'item_code' do
      it "can't be blank" do
        model = build(:canonical_staff, item_code: nil)

        model.validate
        expect(model.errors[:item_code]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:canonical_staff, item_code: 'foobar')
        model = build(:canonical_staff, item_code: 'foobar')

        model.validate
        expect(model.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'unit_weight' do
      it "can't be blank" do
        model = build(:canonical_staff, unit_weight: nil)

        model.validate
        expect(model.errors[:unit_weight]).to include "can't be blank"
      end

      it 'must be a number' do
        model = build(:canonical_staff, unit_weight: 'foobar')

        model.validate
        expect(model.errors[:unit_weight]).to include 'is not a number'
      end

      it 'must be at least zero' do
        model = build(:canonical_staff, unit_weight: -2.2)

        model.validate
        expect(model.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end

    describe 'base_damage' do
      it "can't be blank" do
        model = build(:canonical_staff, base_damage: nil)

        model.validate
        expect(model.errors[:base_damage]).to include "can't be blank"
      end

      it 'must be a number' do
        model = build(:canonical_staff, base_damage: 'foobar')

        model.validate
        expect(model.errors[:base_damage]).to include 'is not a number'
      end

      it 'must be at least zero' do
        model = build(:canonical_staff, base_damage: -1)

        model.validate
        expect(model.errors[:base_damage]).to include 'must be greater than or equal to 0'
      end

      it 'must be an integer' do
        model = build(:canonical_staff, base_damage: 8.2)

        model.validate
        expect(model.errors[:base_damage]).to include 'must be an integer'
      end
    end

    describe 'school' do
      it 'can be blank' do
        model = build(:canonical_staff, school: nil)

        expect(model).to be_valid
      end

      it 'must be an actual school' do
        model = build(:canonical_staff, school: 'Hard Knocks')

        model.validate
        expect(model.errors[:school]).to include 'must be a valid school of magic'
      end
    end

    describe 'daedric' do
      it "can't be blank" do
        model = build(:canonical_staff, daedric: nil)

        model.validate
        expect(model.errors[:daedric]).to include 'must be true or false'
      end
    end

    describe 'purchasable' do
      it "can't be blank" do
        model = build(:canonical_staff, purchasable: nil)

        model.validate
        expect(model.errors[:purchasable]).to include 'must be true or false'
      end
    end

    describe 'unique_item' do
      it "can't be blank" do
        model = build(:canonical_staff, unique_item: nil)

        model.validate
        expect(model.errors[:unique_item]).to include 'must be true or false'
      end
    end

    describe 'rare_item' do
      it "can't be blank" do
        model = build(:canonical_staff, rare_item: nil)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true or false'
      end

      it 'must be true if the item is unique' do
        model = build(:canonical_staff, unique_item: true, rare_item: false)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true if item is unique'
      end
    end

    describe 'quest_item' do
      it "can't be blank" do
        model = build(:canonical_staff, quest_item: nil)

        model.validate
        expect(model.errors[:quest_item]).to include 'must be true or false'
      end
    end

    describe 'leveled' do
      it "can't be blank" do
        model = build(:canonical_staff, leveled: nil)

        model.validate
        expect(model.errors[:leveled]).to include 'must be true or false'
      end
    end
  end

  describe 'associations' do
    describe 'powers' do
      let(:staff) { create(:canonical_staff) }
      let(:power) { create(:power) }

      it 'returns the power' do
        staff.canonical_powerables_powers.create!(power:)
        expect(staff.powers.first).to eq power
      end
    end

    describe 'spells' do
      let(:staff) { create(:canonical_staff) }
      let(:spell) { create(:spell) }

      it 'returns the spell' do
        staff.canonical_staves_spells.create!(spell:)
        expect(staff.spells.first).to eq spell
      end
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
