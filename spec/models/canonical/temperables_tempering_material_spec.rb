# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::TemperablesTemperingMaterial, type: :model do
  describe 'validations' do
    it 'is valid with valid attributes' do
      material = create(:canonical_material)
      armor    = create(:canonical_armor)
      model    = described_class.new(quantity: 3, material: material, temperable: armor)

      expect(model).to be_valid
    end

    describe 'quantity' do
      it 'is invalid if quantity is 0 or less' do
        model = build(:canonical_temperables_tempering_material, :for_weapon, quantity: 0)

        model.validate
        expect(model.errors[:quantity]).to include 'must be greater than 0'
      end

      it 'is invalid if quantity is not an integer' do
        model = build(:canonical_temperables_tempering_material, :for_armor, quantity: 7.6)

        model.validate
        expect(model.errors[:quantity]).to include 'must be an integer'
      end
    end

    describe 'temperable and canonical material' do
      let(:material) { create(:canonical_material) }
      let(:weapon)   { create(:canonical_weapon) }

      it 'must be a unique combination' do
        create(:canonical_temperables_tempering_material, material: material, temperable: weapon)
        model = build(:canonical_temperables_tempering_material, material: material, temperable: weapon)

        model.validate
        expect(model.errors[:material_id]).to include 'must form a unique combination with temperable item'
      end
    end

    describe 'polymorphic associations' do
      subject(:temperable_type) { described_class.new(temperable: item, material: create(:canonical_material)).temperable_type }

      context 'when the association is an armor item' do
        let(:item) { create(:canonical_armor) }

        it 'sets the temperable type' do
          expect(temperable_type).to eq 'Canonical::Armor'
        end
      end

      context 'when the association is a weapon' do
        let(:item) { create(:canonical_weapon) }

        it 'sets the temperable type' do
          expect(temperable_type).to eq 'Canonical::Weapon'
        end
      end
    end
  end
end
