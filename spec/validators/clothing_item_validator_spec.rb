# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClothingItemValidator do
  subject(:validate) { described_class.new.validate(item) }

  let(:item) { build(:clothing_item) }

  context 'when there is no matching canonical clothing item' do
    it 'sets an error' do
      validate
      expect(item.errors[:base]).to include "doesn't match a clothing item that exists in Skyrim"
    end
  end

  context 'when the record has a canonical model' do
    let(:canonical_clothing_item) do
      create(
        :canonical_clothing_item,
        unit_weight: 1,
        name: 'Fine Clothes',
        magical_effects: 'Something',
      )
    end

    context 'when the unit weight does not match' do
      let(:item) do
        build(
          :clothing_item,
          canonical_clothing_item:,
          name: 'Fine Clothes',
          unit_weight: 2.5,
          magical_effects: 'Something',
        )
      end

      it 'sets an error' do
        validate
        expect(item.errors[:unit_weight]).to include 'does not match value on canonical model'
      end
    end

    context 'when the magical effects do not match' do
      let(:item) do
        build(
          :clothing_item,
          canonical_clothing_item:,
          name: 'Fine Clothes',
          unit_weight: 1,
          magical_effects: 'Nothing',
        )
      end

      it 'sets an error' do
        validate
        expect(item.errors[:magical_effects]).to include 'does not match value on canonical model'
      end
    end
  end

  context 'when there are multiple matching canonical clothing items' do
    let!(:canonicals) { create_list(:canonical_clothing_item, 2, name: item.name) }

    it 'is valid' do
      expect(item).to be_valid
    end
  end

  describe 'canonical clothing item validations' do
    let(:item) { build(:clothing_item, canonical_clothing_item:, game:) }
    let(:game) { create(:game) }

    context 'when the canonical model is not unique' do
      let(:canonical_clothing_item) { create(:canonical_clothing_item) }

      before do
        create_list(
          :clothing_item,
          3,
          canonical_clothing_item:,
          game:,
        )
      end

      it 'is valid' do
        validate
        expect(item.errors[:base]).to be_empty
      end
    end

    context 'when the canonical model is unique' do
      let(:canonical_clothing_item) do
        create(
          :canonical_clothing_item,
          unique_item: true,
          rare_item: true,
        )
      end

      context 'when the canonical model has no other clothing items for this game' do
        it 'is valid' do
          validate
          expect(item.errors[:base]).to be_empty
        end
      end

      context 'when the canonical model has another clothing item for a different game' do
        before do
          create(:clothing_item, canonical_clothing_item:)
        end

        it 'is valid' do
          item.validate
          expect(item.errors[:base]).to be_empty
        end
      end

      context 'when the canonical model has another clothing item for the same game' do
        before do
          create(:clothing_item, canonical_clothing_item:, game:)
        end

        it 'is invalid' do
          validate
          expect(item.errors[:base]).to include 'is a duplicate of a unique in-game item'
        end
      end
    end
  end
end
