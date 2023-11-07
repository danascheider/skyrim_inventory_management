# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Armor, type: :model do
  describe 'validations' do
    subject(:validate) { armor.validate }

    let(:armor) { build(:armor) }

    before do
      allow_any_instance_of(ArmorValidator).to receive(:validate)
    end

    it 'is invalid without a name' do
      armor.name = nil
      validate
      expect(armor.errors[:name]).to include "can't be blank"
    end

    it 'is invalid with an invalid weight value' do
      armor.weight = 'medium armor'
      validate
      expect(armor.errors[:weight]).to include 'must be "light armor" or "heavy armor"'
    end

    it 'is invalid with a negative unit weight' do
      armor.unit_weight = -2.5
      validate
      expect(armor.errors[:unit_weight]).to include 'must be greater than or equal to 0'
    end

    it 'validates against canonical models' do
      expect_any_instance_of(ArmorValidator).to receive(:validate).with(armor)
      validate
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
    subject(:validate) { armor.validate }

    context 'when there is a single matching canonical model' do
      let(:armor) do
        build(
          :armor,
          name: 'steel plate armor',
          unit_weight: 20,
          magical_effects: 'something',
        )
      end

      let!(:matching_canonical) do
        create(
          :canonical_armor,
          :with_enchantments,
          name: 'Steel Plate Armor',
          unit_weight: 20,
          magical_effects: 'Something',
          weight: 'heavy armor',
        )
      end

      before do
        create(
          :canonical_armor,
          name: 'Steel Plate Armor',
          unit_weight: 30,
        )
      end

      it 'assigns the canonical armor' do
        expect { validate }
          .to change(armor, :canonical_armor)
                .from(nil)
                .to(matching_canonical)
      end

      it 'sets the attributes', :aggregate_failures do
        validate
        expect(armor.name).to eq 'Steel Plate Armor'
        expect(armor.magical_effects).to eq 'Something'
        expect(armor.unit_weight).to eq 20
        expect(armor.weight).to eq 'heavy armor'
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
        validate
        expect(armor.canonical_armor).to be_nil
      end

      it "doesn't set other attributes", :aggregate_failures do
        validate
        expect(armor.name).to eq 'Steel plate armor'
        expect(armor.weight).to be_nil
        expect(armor.unit_weight).to be_nil
      end
    end

    context 'when there are no matching canonical models' do
      let(:armor) { build(:armor) }

      it 'is invalid' do
        validate
        expect(armor.errors[:base]).to include "doesn't match an armor item that exists in Skyrim"
      end
    end

    context 'when updating in-game item attributes' do
      let(:armor) { create(:armor, :with_matching_canonical) }

      context 'when the update changes the canonical association' do
        let!(:new_canonical) do
          create(
            :canonical_armor,
            name: 'Imperial Boots of Resist Frost',
            weight: 'light armor',
            magical_effects: 'This Will Be Case Insensitive',
            unit_weight: 2,
          )
        end

        it 'changes the canonical association' do
          armor.name = 'Imperial boots of resist frost'
          armor.magical_effects = 'this will be case insensitive'
          armor.weight = nil
          armor.unit_weight = nil

          expect { validate }
            .to change(armor, :canonical_armor)
                  .to(new_canonical)
        end

        it 'sets attributes on the in-game item', :aggregate_failures do
          armor.name = 'Imperial boots of resist frost'
          armor.magical_effects = 'this will be case insensitive'
          armor.weight = nil
          armor.unit_weight = nil

          validate

          expect(armor.name).to eq 'Imperial Boots of Resist Frost'
          expect(armor.magical_effects).to eq 'This Will Be Case Insensitive'
          expect(armor.weight).to eq 'light armor'
          expect(armor.unit_weight).to eq 2
        end
      end

      context 'when the update results in an ambiguous match' do
        before do
          create_list(
            :canonical_armor,
            2,
            name: 'Imperial Boots of Resist Frost',
            weight: 'light armor',
            magical_effects: 'This Will Be Case Insensitive',
            unit_weight: 2,
          )
        end

        it 'removes the canonical_armor association' do
          armor.name = 'imperial boots of resist frost'
          armor.magical_effects = 'this will be case insensitive'
          armor.weight = nil
          armor.unit_weight = nil

          expect { validate }
            .to change(armor, :canonical_armor)
                  .to(nil)
        end

        it "doesn't set attributes", :aggregate_failures do
          armor.name = 'imperial boots of resist frost'
          armor.magical_effects = 'this will be case insensitive'
          armor.weight = nil
          armor.unit_weight = nil

          validate

          expect(armor.name).to eq 'imperial boots of resist frost'
          expect(armor.magical_effects).to eq 'this will be case insensitive'
          expect(armor.weight).to be_nil
          expect(armor.unit_weight).to be_nil
        end
      end

      context 'when the update results in no match' do
        it 'removes the canonical_armor association' do
          armor.name = 'imperial boots of resist frost'

          expect { validate }
            .to change(armor, :canonical_armor)
                  .to(nil)
        end
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

  describe '#canonical_models' do
    subject(:canonical_models) { armor.canonical_models }

    context 'when there is no existing canonical match' do
      before do
        create(:canonical_armor, name: 'Something Else')
      end

      context 'when only the name has to match' do
        let!(:matching_canonicals) { create_list(:canonical_armor, 3, name: armor.name, unit_weight: 2.5) }

        let(:armor) { build(:armor, unit_weight: nil) }

        it 'returns all matching items' do
          expect(canonical_models).to contain_exactly(*matching_canonicals)
        end
      end

      context 'when multiple attributes have to match' do
        let!(:matching_canonicals) { create_list(:canonical_armor, 3, name: armor.name, unit_weight: 2.5) }

        let(:armor) { build(:armor, unit_weight: 2.5) }

        before do
          create(:canonical_armor, name: armor.name, unit_weight: 1)
        end

        it 'returns only the items for which all values match' do
          expect(canonical_models).to contain_exactly(*matching_canonicals)
        end
      end
    end

    context 'when changed attributes lead to a changed canonical' do
      let(:armor) { create(:armor, :with_matching_canonical) }

      let!(:new_canonical) do
        create(
          :canonical_armor,
          name: "Ahzidal's Boots of Waterwalking",
          unit_weight: 9,
          weight: 'heavy armor',
          magical_effects: 'Waterwalking. If you wear any four Relics of Ahzidal, +10 Enchanting.',
        )
      end

      it 'returns the new canonical' do
        armor.name = "Ahzidal's Boots of Waterwalking"
        armor.unit_weight = 9
        armor.weight = nil
        armor.magical_effects = nil

        expect(canonical_models).to contain_exactly(new_canonical)
      end
    end
  end
end
