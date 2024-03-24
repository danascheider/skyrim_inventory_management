# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::Material, type: :model do
  let(:source_material) do
    create(:canonical_raw_material, name: 'Iron Ingot')
  end

  describe 'validations' do
    subject(:validate) { material.validate }

    let(:item) { create(:canonical_armor) }
    let(:material) do
      build(
        :canonical_material,
        source_material:,
        temperable: item,
      )
    end

    describe 'source_material' do
      it 'must form a unique combination with craftable, if present' do
        create(
          :canonical_material,
          source_material:,
          temperable: nil,
          craftable: item,
        )

        material.temperable = nil
        material.craftable = item
        validate

        expect(material.errors[:source_material]).to include 'must form a unique combination with craftable item'
      end

      it 'must form a unique combination with temperable, if present' do
        create(
          :canonical_material,
          source_material:,
          temperable: item,
        )

        validate

        expect(material.errors[:source_material]).to include 'must form a unique combination with temperable item'
      end

      it 'is valid when the combination is unique' do
        expect(material).to be_valid
      end
    end

    describe 'quantity' do
      it 'must be an integer' do
        material.quantity = 2.25
        validate
        expect(material.errors[:quantity]).to include 'must be an integer'
      end

      it 'must be positive' do
        material.quantity = 0
        validate

        expect(material.errors[:quantity]).to include 'must be greater than 0'
      end
    end

    describe 'craftable and temperable' do
      context 'when neither a craftable nor a temperable are present' do
        it 'is invalid with neither a craftable nor a temperable' do
          material.temperable = nil
          validate

          expect(material.errors[:base]).to include 'must have either a craftable or a temperable association'
        end
      end

      context 'when  both craftable and temperable are present' do
        it 'is invalid' do
          material.craftable = create(:canonical_jewelry_item)
          validate

          expect(material.errors[:base]).to include 'must have either a craftable or a temperable association, not both'
        end
      end
    end
  end

  describe 'delegated methods' do
    describe '#name' do
      subject(:name) { material.name }

      let(:craftable) { create(:canonical_weapon) }

      let(:material) do
        create(
          :canonical_material,
          source_material:,
          craftable:,
        )
      end

      it 'is delegated to the source material' do
        expect(name).to eq 'Iron Ingot'
      end
    end
  end
end
