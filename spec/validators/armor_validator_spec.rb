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

    context 'when the canonical model is not unique' do
      let(:armor) { build(:armor, canonical_armor:, game:) }
      let(:game) { create(:game) }
      let(:canonical_armor) { create(:canonical_armor) }

      before do
        create_list(
          :armor,
          3,
          canonical_armor:,
          game:,
        )
      end

      it 'is valid' do
        validate
        expect(armor.errors[:base]).to be_empty
      end
    end

    context 'when the canonical model is unique' do
      let(:armor) { build(:armor, canonical_armor:, game:) }
      let(:game) { create(:game) }

      let(:canonical_armor) do
        create(
          :canonical_armor,
          unique_item: true,
          rare_item: true,
        )
      end

      context "when this is the canonical model's only association for this game" do
        it 'is valid' do
          validate
          expect(armor.errors[:base]).to be_empty
        end
      end

      context 'when the canonical model has a second association for another game' do
        before do
          create(:armor, canonical_armor:)
        end

        it 'is valid' do
          validate
          expect(armor.errors[:base]).to be_empty
        end
      end

      context 'when the canonical model has a second association for the same game' do
        before do
          create(:armor, canonical_armor:, game:)
        end

        it 'is invalid' do
          validate
          expect(armor.errors[:base]).to include 'is a duplicate of a unique in-game item'
        end
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
