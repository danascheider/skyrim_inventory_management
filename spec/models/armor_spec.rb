# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Armor, type: :model do
  describe 'validations' do
    let(:armor) { build(:armor) }

    before do
      allow_any_instance_of(ArmorValidator).to receive(:validate)
    end

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

    it 'validates against canonical models' do
      expect_any_instance_of(ArmorValidator).to receive(:validate).with(armor)
      armor.validate
    end
  end

  describe 'delegated methods' do
    let!(:canonical_armor) { create(:canonical_armor, name: 'Steel Plate Armor') }
    let(:armor) { create(:armor, name: 'Steel Plate Armor', canonical_armor:) }

    before do
      3.times do |n|
        canonical_armor.canonical_craftables_crafting_materials.create!(
          material: create(:canonical_material),
          quantity: n + 1,
        )
      end

      canonical_armor.canonical_temperables_tempering_materials.create!(
        material: create(:canonical_material),
        quantity: 1,
      )
    end

    describe '#crafting_materials' do
      it 'uses the values from the canonical model' do
        expect(armor.crafting_materials).to eq canonical_armor.crafting_materials
      end

      it 'can access quantities transitively' do
        expect(armor.crafting_materials.first.quantity_needed).to eq 1
      end
    end

    describe '#tempering_materials' do
      it 'uses the values from the canonical model' do
        expect(armor.tempering_materials).to eq canonical_armor.tempering_materials
      end

      it 'can access quantities transitively' do
        expect(armor.tempering_materials.first.quantity_needed).to eq 1
      end
    end

    context 'when there is no canonical model' do
      let(:armor) { build(:armor, canonical_armor: nil) }

      it 'returns a nil value for crafting_materials' do
        expect(armor.crafting_materials).to be_nil
      end

      it 'returns a nil value for tempering_materials' do
        expect(armor.tempering_materials).to be_nil
      end
    end
  end

  describe '::before_validation' do
    context 'when there is a single matching canonical model' do
      let!(:matching_canonical) do
        create(
          :canonical_armor,
          :with_enchantments,
          name: 'Steel Plate Armor',
          unit_weight: 20,
          weight: 'heavy armor',
          magical_effects: 'Something',
        )
      end

      let(:armor) do
        build(
          :armor,
          name: 'Steel plate armor',
          unit_weight: 20,
        )
      end

      before do
        create(:canonical_armor, name: 'Steel Plate Armor', unit_weight: 30)
      end

      it 'assigns the canonical armor' do
        armor.validate
        expect(armor.canonical_armor).to eq matching_canonical
      end

      it 'sets the attributes', :aggregate_failures do
        armor.validate
        expect(armor.name).to eq 'Steel Plate Armor'
        expect(armor.unit_weight).to eq 20
        expect(armor.weight).to eq 'heavy armor'
        expect(armor.magical_effects).to eq 'Something'
      end
    end

    context 'when there are multiple matching canonical models' do
      let!(:matching_canonicals) do
        create_list(
          :canonical_armor,
          2,
          :with_enchantments,
          name: 'Steel Plate Armor',
          weight: 'heavy armor',
        )
      end

      let(:armor) { build(:armor, name: 'Steel plate armor') }

      it "doesn't set the corresponding canonical armor" do
        armor.validate
        expect(armor.canonical_armor).to be_nil
      end

      it "doesn't set other attributes", :aggregate_failures do
        armor.validate
        expect(armor.name).to eq 'Steel plate armor'
        expect(armor.weight).to be_nil
        expect(armor.unit_weight).to be_nil
      end
    end

    context 'when there are no matching canonical models' do
      let(:armor) { build(:armor) }

      it 'is invalid' do
        armor.validate
        expect(armor.errors[:base]).to include "doesn't match an armor item that exists in Skyrim"
      end
    end
  end

  describe '::after_create' do
    context 'when there is a single matching canonical model' do
      let!(:matching_canonical) do
        create(
          :canonical_armor,
          :with_enchantments,
          name: 'Steel Plate Armor',
          unit_weight: 20,
          weight: 'heavy armor',
          magical_effects: 'Something',
        )
      end

      context "when the new armor doesn't have its own enchantments" do
        let(:armor) do
          build(
            :armor,
            name: 'Steel plate armor',
            unit_weight: 20,
          )
        end

        it 'adds enchantments from the canonical armor' do
          armor.save!
          expect(armor.enchantments.length).to eq 2
        end

        it 'sets the correct strengths', :aggregate_failures do
          armor.save!
          matching_canonical.enchantables_enchantments.each do |join_model|
            has_matching = armor.enchantables_enchantments.any? do |model|
              model.enchantment == join_model.enchantment && model.strength == join_model.strength
            end

            expect(has_matching).to be true
          end
        end
      end

      context 'when the new armor has its own enchantments' do
        let(:armor) do
          create(
            :armor,
            :with_enchantments,
            name: 'Steel plate armor',
            unit_weight: 20,
          )
        end

        it "doesn't remove the existing enchantments" do
          expect(armor.enchantments.reload.length).to eq 4
        end
      end
    end

    context 'when there are multiple matching canonical models' do
      let!(:matching_canonicals) do
        create_list(
          :canonical_armor,
          2,
          :with_enchantments,
          name: 'Steel Plate Armor',
          unit_weight: 20,
          weight: 'heavy armor',
          magical_effects: 'Something',
        )
      end

      let(:armor) { create(:armor, name: 'Steel Plate Armor') }

      it "doesn't add enchantments" do
        expect(armor.enchantments).to be_blank
      end
    end
  end

  describe '#canonical_armors' do
    subject(:canonical_armors) { armor.canonical_armors }

    context 'when the item has an association defined' do
      let(:armor) do
        create(
          :armor,
          canonical_armor:,
          name: 'Steel Plate Armor',
          weight: 'heavy armor',
          unit_weight: 20,
          magical_effects: nil,
        )
      end

      let(:canonical_armor) do
        create(
          :canonical_armor,
          name: 'Steel Plate Armor',
          weight: 'heavy armor',
          unit_weight: 20,
          magical_effects: nil,
        )
      end

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

        let(:armor) { build(:armor, unit_weight: nil) }

        it 'returns all matching items' do
          expect(canonical_armors).to eq matching_canonicals
        end
      end

      context 'when multiple attributes have to match' do
        let!(:matching_canonicals) { create_list(:canonical_armor, 3, name: armor.name, unit_weight: 2.5) }

        let(:armor) { build(:armor, unit_weight: 2.5) }

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
