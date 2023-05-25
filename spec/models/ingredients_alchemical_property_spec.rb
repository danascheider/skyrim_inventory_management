# frozen_string_literal: true

require 'rails_helper'

RSpec.describe IngredientsAlchemicalProperty, type: :model do
  describe 'validations' do
    let(:ingredient) { build(:ingredient) }

    before do
      create(:canonical_ingredient)
    end

    describe 'number of records per ingredient' do
      let!(:ingredient) { create(:ingredient_with_matching_canonical, :with_associations_and_properties) }

      it 'cannot have more than 4 records corresponding to one ingredient' do
        # Since the alchemical properties are added in FactoryBot's after(:create) hook,
        # the ingredient needs to be reloaded before Rails/RSpec will know about them.
        ingredient.reload

        new_association = build(:ingredients_alchemical_property, ingredient:)

        new_association.validate
        expect(new_association.errors[:ingredient]).to include 'already has 4 alchemical properties'
      end
    end

    describe 'canonical_models' do
      context 'when there is one matching canonical model' do
        let!(:canonical_ingredient) { create(:canonical_ingredient, :with_alchemical_properties) }
        let(:ingredient) { create(:ingredient, canonical_ingredient:) }
        let(:model) { build(:ingredients_alchemical_property, ingredient:) }

        before do
          canonical_ingredient.reload

          model.alchemical_property_id = canonical_ingredient.alchemical_properties.second.id
          model.priority = canonical_ingredient.alchemical_properties.second.priority
          model.save!
        end

        it 'is valid' do
          expect(model).to be_valid
        end
      end

      context 'when are multiple matching canonical models' do
        let!(:canonical_ingredient) { create(:canonical_ingredient, :with_alchemical_properties) }
        let!(:second_canonical) { create(:canonical_ingredient, :with_alchemical_properties) }
        let(:ingredient) { create(:ingredient) }
        let(:join_model) { canonical_ingredient.canonical_ingredients_alchemical_properties.second }
        let(:model) { build(:ingredients_alchemical_property, ingredient:) }

        before do
          canonical_ingredient.reload
          second_canonical.reload

          second_canonical
            .canonical_ingredients_alchemical_properties
            .find_by(priority: join_model.priority)
            .update!(alchemical_property_id: join_model.alchemical_property_id)

          model.alchemical_property_id = join_model.alchemical_property_id
          model.priority = join_model.priority
          model.save!
        end

        it 'is valid' do
          expect(model).to be_valid
        end
      end

      context 'when there are no matching canonical models' do
        let!(:canonical_ingredient) { create(:canonical_ingredient) }
        let(:ingredient) { create(:ingredient, canonical_ingredient:) }
        let(:model) { build(:ingredients_alchemical_property, ingredient:) }

        it 'is invalid' do
          model.validate
          expect(model.errors[:base]).to include 'is not consistent with any ingredient that exists in Skyrim'
        end
      end
    end

    describe 'priority' do
      let(:ingredient) { create(:ingredient) }

      it "can't be less than 1" do
        model = build(:ingredients_alchemical_property, priority: 0)

        model.validate
        expect(model.errors[:priority]).to include 'must be greater than or equal to 1'
      end

      it "can't be more than 4" do
        model = build(:ingredients_alchemical_property, priority: 5)

        model.validate
        expect(model.errors[:priority]).to include 'must be less than or equal to 4'
      end

      it 'must be an integer' do
        model = build(:ingredients_alchemical_property, priority: 3.2)

        model.validate
        expect(model.errors[:priority]).to include 'must be an integer'
      end

      describe 'uniqueness' do
        before do
          create(
            :ingredients_alchemical_property,
            :valid,
            priority: 1,
            ingredient:,
          )
        end

        it 'must be unique per ingredient' do
          model = build(
            :ingredients_alchemical_property,
            priority: 1,
            ingredient:,
          )

          model.validate
          expect(model.errors[:priority]).to include 'must be unique per ingredient'
        end

        it "doesn't have to be globally unique" do
          model = build(:ingredients_alchemical_property, :valid, priority: 1)

          expect(model).to be_valid
        end
      end
    end

    describe 'strength_modifier' do
      it 'must be greater than zero' do
        model = build(:ingredients_alchemical_property, strength_modifier: 0)

        model.validate
        expect(model.errors[:strength_modifier]).to include 'must be greater than 0'
      end
    end

    describe 'duration_modifier' do
      it 'must be greater than zero' do
        model = build(:ingredients_alchemical_property, duration_modifier: 0)

        model.validate
        expect(model.errors[:duration_modifier]).to include 'must be greater than 0'
      end
    end

    describe 'alchemical_property_id' do
      it 'must be unique per ingredient' do
        existing_model = create(:ingredients_alchemical_property, :valid)
        model = build(
          :ingredients_alchemical_property,
          ingredient: existing_model.ingredient,
          alchemical_property: existing_model.alchemical_property,
          priority: 1,
        )

        model.validate
        expect(model.errors[:alchemical_property_id]).to include 'must form a unique combination with ingredient'
      end
    end
  end

  describe '#canonical_models' do
    subject(:canonical_models) { model.canonical_models }

    context 'when there is one matching canonical model' do
      let!(:canonical_ingredient) { create(:canonical_ingredient, :with_alchemical_properties) }
      let(:ingredient) { create(:ingredient, canonical_ingredient:) }
      let(:model) { build(:ingredients_alchemical_property, ingredient:) }

      before do
        canonical_ingredient.reload

        model.alchemical_property_id = canonical_ingredient.alchemical_properties.second.id
        model.priority = canonical_ingredient.alchemical_properties.second.priority
        model.save!
      end

      it 'returns the model' do
        expect(canonical_models).to eq [canonical_ingredient.canonical_ingredients_alchemical_properties.second]
      end
    end

    context 'when are multiple matching canonical models' do
      let!(:canonical_ingredient) { create(:canonical_ingredient, :with_alchemical_properties) }
      let!(:second_canonical) { create(:canonical_ingredient, :with_alchemical_properties) }
      let(:ingredient) { create(:ingredient) }
      let(:join_model) { canonical_ingredient.canonical_ingredients_alchemical_properties.second }
      let(:model) { build(:ingredients_alchemical_property, ingredient:) }

      before do
        canonical_ingredient.reload
        second_canonical.reload

        second_canonical
          .canonical_ingredients_alchemical_properties
          .find_by(priority: join_model.priority)
          .update!(alchemical_property_id: join_model.alchemical_property_id)

        model.alchemical_property_id = join_model.alchemical_property_id
        model.priority = join_model.priority
        model.save!
      end

      it 'returns the matching models' do
        expect(canonical_models).to contain_exactly(
          *Canonical::IngredientsAlchemicalProperty
            .where(alchemical_property_id: join_model.alchemical_property_id)
            .to_a,
        )
      end
    end

    context 'when there are no matching canonical models' do
      let!(:canonical_ingredient) { create(:canonical_ingredient) }
      let(:ingredient) { create(:ingredient, canonical_ingredient:) }
      let(:model) { build(:ingredients_alchemical_property, ingredient:) }

      it 'is empty' do
        expect(canonical_models).to be_empty
      end
    end
  end

  describe '#canonical_model' do
    subject(:canonical_model) { model.reload.canonical_model }

    context 'when there is one matching canonical model' do
      let!(:canonical_ingredient) { create(:canonical_ingredient, :with_alchemical_properties) }
      let(:ingredient) { create(:ingredient, canonical_ingredient:) }
      let(:model) { build(:ingredients_alchemical_property, ingredient:) }

      before do
        canonical_ingredient.reload

        model.alchemical_property_id = canonical_ingredient.alchemical_properties.second.id
        model.priority = canonical_ingredient.alchemical_properties.second.priority
        model.save!
      end

      it 'returns the model' do
        expect(canonical_model).to eq canonical_ingredient.canonical_ingredients_alchemical_properties.second
      end
    end

    context 'when are multiple matching canonical models' do
      let!(:canonical_ingredient) { create(:canonical_ingredient, :with_alchemical_properties) }
      let!(:second_canonical) { create(:canonical_ingredient, :with_alchemical_properties) }
      let(:ingredient) { create(:ingredient) }
      let(:join_model) { canonical_ingredient.canonical_ingredients_alchemical_properties.second }
      let(:model) { build(:ingredients_alchemical_property, ingredient:) }

      before do
        canonical_ingredient.reload
        second_canonical.reload

        second_canonical
          .canonical_ingredients_alchemical_properties
          .find_by(priority: join_model.priority)
          .update!(alchemical_property_id: join_model.alchemical_property_id)

        model.alchemical_property_id = join_model.alchemical_property_id
        model.priority = join_model.priority
        model.save!
      end

      it 'is nil' do
        expect(canonical_model).to be_nil
      end
    end

    context 'when there are no matching canonical models' do
      subject(:canonical_model) { model.canonical_model }

      let!(:canonical_ingredient) { create(:canonical_ingredient) }
      let(:ingredient) { create(:ingredient, canonical_ingredient:) }
      let(:model) { build(:ingredients_alchemical_property, ingredient:) }

      it 'is empty' do
        expect(canonical_model).to be_nil
      end
    end
  end

  describe '::before_validation' do
    let!(:canonical_model) do
      create(
        :canonical_ingredients_alchemical_property,
        priority: 3,
        strength_modifier: 1.5,
        duration_modifier: 2.3,
      )
    end

    let(:canonical_ingredient) { canonical_model.ingredient }
    let(:ingredient) { create(:ingredient, canonical_ingredient:) }

    let(:model) do
      build(
        :ingredients_alchemical_property,
        alchemical_property: canonical_model.alchemical_property,
        ingredient:,
        priority: nil,
      )
    end

    it 'sets values from the canonical model', :aggregate_failures do
      model.validate
      expect(model.priority).to eq 3
      expect(model.strength_modifier).to eq 1.5
      expect(model.duration_modifier).to eq 2.3
    end
  end
end
