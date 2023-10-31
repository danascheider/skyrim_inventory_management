# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ingredient, type: :model do
  describe 'validations' do
    subject(:validate) { ingredient.validate }

    let(:ingredient) { build(:ingredient) }

    describe '#name' do
      it "can't be blank" do
        ingredient.name = nil
        validate
        expect(ingredient.errors[:name]).to include "can't be blank"
      end
    end

    describe '#unit_weight' do
      it 'can be blank' do
        ingredient.unit_weight = nil
        validate
        expect(ingredient.errors[:unit_weight]).to be_empty
      end

      it 'must be at least 0' do
        ingredient.unit_weight = -2.7
        validate
        expect(ingredient.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end

    context 'when there are multiple matching canonical ingredients' do
      before do
        create_list(:canonical_ingredient, 3, name: ingredient.name)
      end

      it 'is valid' do
        expect(ingredient).to be_valid
      end
    end

    context 'when there is one matching canonical ingredient' do
      before do
        create(:canonical_ingredient, name: ingredient.name)
      end

      it 'is valid' do
        expect(ingredient).to be_valid
      end
    end

    context 'when there are no matching canonical ingredients' do
      it 'is invalid' do
        validate
        expect(ingredient.errors[:base]).to include "doesn't match an ingredient that exists in Skyrim"
      end
    end

    describe 'canonical ingredient validations' do
      let(:ingredient) { build(:ingredient, canonical_ingredient:, game:) }
      let(:game) { create(:game) }

      context 'when the canonical ingredient is not unique' do
        let(:canonical_ingredient) { create(:canonical_ingredient) }

        before do
          create_list(
            :ingredient,
            3,
            canonical_ingredient:,
            game:,
          )
        end

        it 'is valid' do
          expect(ingredient).to be_valid
        end
      end

      context 'when the canonical ingredient is unique' do
        let(:canonical_ingredient) do
          create(
            :canonical_ingredient,
            unique_item: true,
            rare_item: true,
          )
        end

        context 'when the canonical ingredient has no other matches' do
          it 'is valid' do
            expect(ingredient).to be_valid
          end
        end

        context 'when the canonical ingredient has another match for another game' do
          before do
            create(:ingredient, canonical_ingredient:)
          end

          it 'is valid' do
            expect(ingredient).to be_valid
          end
        end

        context 'when the canonical ingredient has another match for the same game' do
          before do
            create(
              :ingredient,
              canonical_ingredient:,
              game:,
            )
          end

          it 'is invalid' do
            validate
            expect(ingredient.errors[:base]).to include 'is a duplicate of a unique in-game item'
          end
        end
      end
    end
  end

  describe '#canonical_ingredients' do
    subject(:canonical_ingredients) { ingredient.reload.canonical_ingredients }

    context 'when the model has a canonical ingredient assigned' do
      let(:ingredient) { create(:ingredient, canonical_ingredient:) }
      let(:canonical_ingredient) { create(:canonical_ingredient) }

      before do
        create(:canonical_ingredient)
      end

      it 'returns the canonical ingredient' do
        expect(canonical_ingredients).to contain_exactly(canonical_ingredient)
      end
    end

    context 'when there are matching canonical ingredients' do
      context 'when only the names have to match' do
        let!(:matching_canonicals) { create_list(:canonical_ingredient, 3, name: 'Blue Mountain Flower') }
        let(:ingredient) { create(:ingredient, name: 'Blue Mountain Flower') }

        it 'returns all the matching canonical ingredients' do
          expect(ingredient.canonical_ingredients).to eq matching_canonicals
        end
      end

      context 'when names and unit weights are defined' do
        let!(:matching_canonicals) { create_list(:canonical_ingredient, 2, name: 'Blue Mountain Flower', unit_weight: 0.1) }
        let(:ingredient) { create(:ingredient, name: 'Blue Mountain Flower', unit_weight: 0.1) }

        before do
          create(:canonical_ingredient, name: 'Blue Mountain Flower', unit_weight: 0.2)
        end

        it 'returns all the matching canonical ingredients' do
          expect(ingredient.canonical_ingredients).to eq matching_canonicals
        end
      end

      # NB: No context is required for when no join model fully matches because
      #     join model validations will fail if they don't match.
      context 'when there are also alchemical properties involved' do
        let!(:matching_canonicals) do
          create_list(
            :canonical_ingredient,
            3,
            :with_alchemical_properties,
            name: 'Blue Mountain Flower',
          )
        end

        let(:ingredient) { create(:ingredient, name: 'Blue Mountain Flower') }
        let(:alchemical_property) { matching_canonicals.second.alchemical_properties.reload.second }

        context 'when multiple join models fully match' do
          before do
            matching_canonicals
              .last
              .reload
              .canonical_ingredients_alchemical_properties
              .find_by(priority: alchemical_property.priority)
              .update!(
                alchemical_property:,
              )

            create(
              :ingredients_alchemical_property,
              ingredient:,
              alchemical_property:,
              priority: alchemical_property.priority,
            )
          end

          it 'returns the matching models' do
            expect(canonical_ingredients).to contain_exactly(matching_canonicals.second, matching_canonicals.last)
          end
        end

        context 'when one join model fully matches' do
          before do
            matching_canonicals
              .last
              .reload
              .canonical_ingredients_alchemical_properties
              .find_by(priority: 4)
              .update!(
                alchemical_property:,
              )

            create(
              :ingredients_alchemical_property,
              ingredient:,
              alchemical_property:,
              priority: 4,
            )
          end

          it 'includes only the model that fully matches' do
            expect(canonical_ingredients).to contain_exactly(matching_canonicals.last)
          end
        end
      end
    end

    context 'when there are no matching canonical ingredients' do
      let(:ingredient) { build(:ingredient) }

      it 'is empty' do
        expect(ingredient.canonical_ingredients).to be_empty
      end
    end
  end

  describe '::before_validation' do
    let(:ingredient) { build(:ingredient) }

    context 'when there is a matching canonical ingredient' do
      let!(:matching_canonical) { create(:canonical_ingredient, name: ingredient.name) }

      it 'sets the canonical_ingredient' do
        ingredient.validate
        expect(ingredient.canonical_ingredient).to eq matching_canonical
      end
    end

    context 'when there are multiple matching canonical ingredients' do
      let!(:matching_canonicals) { create_list(:canonical_ingredient, 2, name: ingredient.name) }

      it "doesn't set the canonical ingredient" do
        ingredient.validate
        expect(ingredient.canonical_ingredient).to be_nil
      end
    end

    context 'when there is no matching canonical ingredient' do
      it "doesn't set the canonical ingredient" do
        ingredient.validate
        expect(ingredient.canonical_ingredient).to be_nil
      end
    end
  end
end
