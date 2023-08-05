# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MiscItem, type: :model do
  describe 'validations' do
    let(:item) { build(:misc_item, :with_matching_canonical) }

    describe '#name' do
      it 'is invalid without a name' do
        item.name = nil
        item.validate
        expect(item.errors[:name]).to include "can't be blank"
      end
    end

    describe '#unit_weight' do
      it 'can be blank' do
        item.unit_weight = nil
        expect(item).to be_valid
      end

      it 'is invalid if less than 0' do
        item.unit_weight = -1.2
        item.validate
        expect(item.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end

    describe '#canonical_misc_items' do
      context 'when there is a single matching canonical misc item' do
        it 'is valid' do
          expect(item).to be_valid
        end
      end

      context 'when there are multiple matching canonical misc items' do
        let(:item) { build(:misc_item) }

        before do
          create_list(
            :canonical_misc_item,
            2,
            name: item.name,
          )
        end

        it 'is valid' do
          expect(item).to be_valid
        end
      end

      context 'when there are no matching canonical misc items' do
        let(:item) { build(:misc_item) }

        it 'adds errors' do
          pending
          item.validate
          expect(item.errors[:base]).to include "doesn't match any item that exists in Skyrim"
        end
      end
    end
  end

  describe '#canonical_models' do
    subject(:canonical_models) { item.canonical_models }

    context 'when the item has an association defined' do
      let(:item) { create(:misc_item, :with_matching_canonical) }

      before do
        create(:canonical_misc_item, name: item.name)
      end

      # TODO: This might not be desirable behaviour since it prevents the associated
      #       model from changing when the non-canonical model's matchable attributes
      #       are updated.
      it 'includes only the associated model' do
        expect(canonical_models).to contain_exactly(item.canonical_misc_item)
      end
    end

    context 'when the item does not have an association defined' do
      let(:item) { create(:misc_item, name: 'Wedding Ring') }

      context 'when only the name has to match' do
        let!(:matching_canonicals) do
          create_list(
            :canonical_misc_item,
            3,
            name: 'wedding ring',
          )
        end

        it 'matches case-insensitively' do
          expect(canonical_models).to contain_exactly(*matching_canonicals)
        end
      end

      context 'when both name and unit weight have to match' do
        let!(:matching_canonicals) do
          create_list(
            :canonical_misc_item,
            2,
            name: "Wylandria's Soul Gem",
            unit_weight: 0,
          )
        end

        let(:item) { create(:misc_item, name: "Wylandria's Soul Gem", unit_weight: 0) }

        before do
          create(:canonical_misc_item, name: 'wedding ring', unit_weight: 1.0)
        end

        it 'returns the matching models' do
          expect(canonical_models).to contain_exactly(*matching_canonicals)
        end
      end
    end
  end
end
