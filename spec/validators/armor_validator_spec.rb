# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArmorValidator do
  subject(:validate) { described_class.new.validate(armor) }

  let(:armor) { build(:armor) }

  context 'when there is no matching canonical armor' do
    it 'sets an error' do
      validate
      expect(armor.errors[:base]).to include "doesn't match an armor item that exists in Skyrim"
    end
  end

  context 'when the record has a canonical model' do
    let(:canonical_armor) do
      create(
        :canonical_armor,
        unit_weight: 2.5,
        name: 'Fur Helmet',
        weight: 'light armor',
        magical_effects: 'Something',
      )
    end

    context 'when the unit weight does not match' do
      let(:armor) do
        build(
          :armor,
          canonical_armor:,
          name: 'Fur Helmet',
          weight: 'light armor',
          unit_weight: 1,
          magical_effects: 'Something',
        )
      end

      it 'sets an error' do
        validate
        expect(armor.errors[:unit_weight]).to include 'does not match value on canonical model'
      end
    end

    context 'when the weight does not match' do
      let(:armor) do
        build(
          :armor,
          canonical_armor:,
          name: 'Fur Helmet',
          weight: 'heavy armor',
          unit_weight: 1,
          magical_effects: 'Something',
        )
      end

      it 'sets an error' do
        validate
        expect(armor.errors[:weight]).to include 'does not match value on canonical model'
      end
    end

    context 'when the magical effects do not match' do
      let(:armor) do
        build(
          :armor,
          canonical_armor:,
          name: 'Fur Helmet',
          weight: 'light armor',
          unit_weight: 1,
          magical_effects: 'Nothing',
        )
      end

      it 'sets an error' do
        validate
        expect(armor.errors[:magical_effects]).to include 'does not match value on canonical model'
      end
    end
  end

  context 'when there are multiple matching canonical armors' do
    let!(:canonicals) { create_list(:canonical_armor, 2, name: armor.name) }

    it 'is valid' do
      expect(armor).to be_valid
    end
  end
end
