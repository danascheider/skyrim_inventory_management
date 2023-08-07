# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MiscItem, type: :model do
  describe 'validations' do
    let(:item) { build(:misc_item) }

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
        expect(item.errors[:unit_weight]).to be_blank
      end

      it 'is invalid if less than 0' do
        item.unit_weight = -1.2
        item.validate
        expect(item.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end

    describe '#canonical_misc_items' do
      context 'when there is a single matching canonical misc item' do
        let(:item) { create(:misc_item, :with_matching_canonical) }

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

        let(:item) { build(:misc_item, name: "Wylandria's Soul Gem", unit_weight: 0) }

        before do
          create(:canonical_misc_item, name: "Wylandria's Soul Gem", unit_weight: 1.0)
        end

        it 'returns the matching models' do
          expect(canonical_models).to contain_exactly(*matching_canonicals)
        end
      end
    end
  end

  describe '::before_validation' do
    context 'when there is a single matching canonical model' do
      let!(:matching_canonical) do
        create(
          :canonical_misc_item,
          name: "Wylandria's Soul Gem",
          unit_weight: 0,
        )
      end

      let(:item) { build(:misc_item, name: "wylandria's soul gem") }

      it 'assigns the canonical misc item' do
        item.validate
        expect(item.canonical_misc_item).to eq matching_canonical
      end

      it 'sets the attributes', :aggregate_failures do
        item.validate
        expect(item.name).to eq "Wylandria's Soul Gem"
        expect(item.unit_weight).to eq 0
      end
    end

    context 'when there are multiple matching canonical models' do
      let!(:matching_canonicals) do
        [
          create(:canonical_misc_item, name: "Wylandria's Soul Gem", unit_weight: 0),
          create(:canonical_misc_item, name: "Wylandria's Soul Gem", unit_weight: 1),
        ]
      end

      let(:item) { create(:misc_item, name: "Wylandria's Soul Gem") }

      it "doesn't set the association" do
        item.validate
        expect(item.canonical_misc_item).to be_nil
      end
    end

    context "when multiple complete matches can't be further differentiated" do
      let(:game) { create(:game) }
      let(:item) { build(:misc_item, name: 'Skull', unit_weight: 2, game:) }

      context 'when a canonical model indicates a unique item' do
        let!(:matching_canonicals) do
          create_list(
            :canonical_misc_item,
            3,
            name: 'Skull',
            unit_weight: 2,
            unique_item: true,
            rare_item: true,
          )
        end

        context 'when the canonical model is already associated with a non-canonical model' do
          context 'when at least one canonical does not yet have an association' do
            before do
              create(
                :misc_item,
                canonical_misc_item: matching_canonicals.first,
                name: 'Skull',
                unit_weight: 2,
                game:,
              )
            end

            it 'assigns the first canonical model without an existing association' do
              item.validate
              expect(item.canonical_misc_item).to eq matching_canonicals.second
            end
          end

          context 'when all canonicals already have associations' do
            before do
              matching_canonicals.each do |model|
                create(
                  :misc_item,
                  canonical_misc_item: model,
                  name: model.name,
                  unit_weight: model.unit_weight,
                  game:,
                )
              end
            end

            it 'raises a validation error' do
              item.validate
              expect(item.errors[:base]).to include 'is a duplicate of a unique in-game item'
            end
          end
        end

        context 'when the canonical model has no non-canonical association' do
          it 'assigns the first matching canonical model' do
            item.validate
            expect(item.canonical_misc_item).to eq matching_canonicals.first
          end
        end
      end

      context 'when the item is not unique' do
        let!(:matching_canonicals) do
          create_list(
            :canonical_misc_item,
            3,
            name: 'Skull',
            unit_weight: 2,
          )
        end

        it 'associates the first matching canonical model' do
          item.validate
          expect(item.canonical_misc_item).to eq matching_canonicals.first
        end
      end
    end

    context 'when there is already a canonical_misc_item assigned' do
      let(:canonical_misc_item) { create(:canonical_misc_item, unique_item: true, rare_item: true) }
      let(:item) { create(:misc_item, canonical_misc_item:) }

      it "doesn't raise an error" do
        item.validate
        expect(item.errors[:base]).to be_empty
      end
    end
  end
end
