# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EnchantablesEnchantment, type: :model do
  let(:enchantment) { create(:enchantment) }

  describe 'validations' do
    describe 'enchantable item and enchantment' do
      let(:armor) { create(:canonical_armor) }

      it 'must form a unique combination' do
        create(:enchantables_enchantment, :for_canonical_armor, enchantable: armor, enchantment:)
        model = build(:enchantables_enchantment, :for_canonical_armor, enchantable: armor, enchantment:)

        model.validate
        expect(model.errors[:enchantment_id]).to include 'must form a unique combination with enchantable item'
      end
    end

    describe 'polymorphic associations' do
      subject(:enchantable_type) { described_class.new(enchantable: item, enchantment: create(:enchantment)).enchantable_type }

      context 'when the association is a canonical armor item' do
        let(:item) { create(:canonical_armor) }

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'Canonical::Armor'
        end
      end

      context 'when the association is a canonical weapon' do
        let(:item) { create(:canonical_weapon) }

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'Canonical::Weapon'
        end
      end

      context 'when the association is a canonical jewelry item' do
        let(:item) { create(:canonical_jewelry_item) }

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'Canonical::JewelryItem'
        end
      end

      context 'when the association is a canonical clothing item' do
        let(:item) { create(:canonical_clothing_item) }

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'Canonical::ClothingItem'
        end
      end

      context 'when the association is an armor item' do
        let(:item) { create(:armor) }

        before do
          create(:canonical_armor)
        end

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'Armor'
        end
      end

      context 'when the association is a clothing item' do
        let(:item) { create(:clothing_item) }

        before do
          create(:canonical_clothing_item)
        end

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'ClothingItem'
        end
      end

      context 'when the association is a jewelry item' do
        let(:item) { create(:jewelry_item) }

        before do
          create(:canonical_jewelry_item)
        end

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'JewelryItem'
        end
      end

      context 'when the association is a weapon' do
        let(:item) { create(:weapon) }

        before do
          create(:canonical_weapon)
        end

        it 'sets the enchantable type' do
          expect(enchantable_type).to eq 'Weapon'
        end
      end
    end
  end

  describe '::after_validation' do
    subject(:validate) { model.validate }

    let(:model) { build(:enchantables_enchantment, enchantable:, enchantment:, strength: 1) }

    context 'when the enchantable is a canonical model' do
      let(:enchantable) { create(:canonical_armor) }

      it "doesn't add errors" do
        expect { validate }
          .not_to change(model, :errors)
      end
    end

    context 'when the enchantable is not a canonical model' do
      let(:enchantable) { create(:armor) }

      context 'when there is a canonical model that matches' do
        before do
          canonical = create(:canonical_armor)

          create(
            :enchantables_enchantment,
            enchantable: canonical,
            enchantment:,
          )
        end

        it "doesn't add errors" do
          expect { validate }
            .not_to change(model, :errors)
        end
      end

      context 'when there is no canonical model that matches' do
        before do
          canonicals = create_list(
            :canonical_armor,
            2,
            enchantable: false,
          )

          create(
            :enchantables_enchantment,
            enchantable: canonicals.first,
            enchantment:,
            strength: 2,
          )
        end

        it 'adds errors' do
          validate
          expect(model.errors[:base]).to include "doesn't match any canonical model"
        end
      end
    end
  end

  describe '::after_save' do
    subject(:save_model) { model.save! }

    let(:model) { build(:enchantables_enchantment, enchantable:, enchantment:) }

    before do
      allow(enchantable).to receive(:save!)
    end

    context 'when the enchantable association is a canonical model' do
      let(:enchantable) { create(:canonical_jewelry_item) }

      it "doesn't save the enchantable association" do
        save_model
        expect(enchantable).not_to have_received(:save!)
      end
    end

    context 'when the enchantable association is not a canonical model' do
      let(:enchantable) { create(:jewelry_item, :with_matching_canonical) }

      it 'saves the enchantable association' do
        save_model
        expect(enchantable).to have_received(:save!)
      end
    end
  end
end
