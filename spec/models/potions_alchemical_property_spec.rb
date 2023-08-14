# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PotionsAlchemicalProperty, type: :model do
  describe 'validations' do
    let(:model) { build(:potions_alchemical_property) }

    describe 'unique combination of potion and alchemical property' do
      let(:model) { create(:potions_alchemical_property) }
      let(:non_unique_model) do
        build(
          :potions_alchemical_property,
          potion: model.potion,
          alchemical_property: model.alchemical_property,
        )
      end

      it 'is invalid with a non-unique combination of potion and alchemical property' do
        non_unique_model.validate
        expect(non_unique_model.errors[:alchemical_property_id])
          .to include 'must form a unique combination with potion'
      end
    end

    describe '#strength' do
      it 'can be blank' do
        model.strength = nil
        model.validate

        expect(model.errors[:strength]).to be_empty
      end

      it 'is invalid with a non-numeric strength' do
        model.strength = 'foobar'
        model.validate

        expect(model.errors[:strength])
          .to include 'is not a number'
      end

      it 'is invalid with a non-integer strength' do
        model.strength = 2.3
        model.validate

        expect(model.errors[:strength])
          .to include 'must be an integer'
      end

      it 'is invalid with a strength of 0 or less' do
        model.strength = -1
        model.validate

        expect(model.errors[:strength])
          .to include 'must be greater than 0'
      end
    end

    describe '#duration' do
      it 'can be blank' do
        model.duration = nil
        model.validate

        expect(model.errors[:duration]).to be_empty
      end

      it 'is invalid with a non-numeric duration' do
        model.duration = 'foobar'
        model.validate

        expect(model.errors[:duration])
          .to include 'is not a number'
      end

      it 'is invalid with a non-integer duration' do
        model.duration = 2.3
        model.validate

        expect(model.errors[:duration])
          .to include 'must be an integer'
      end

      it 'is invalid with a duration of 0 or less' do
        model.duration = -1
        model.validate

        expect(model.errors[:duration])
          .to include 'must be greater than 0'
      end
    end
  end

  describe '#canonical_models' do
    subject(:canonical_models) { model.canonical_models }

    context 'when there is one matching canonical model' do
      let!(:canonical_potion) { create(:canonical_potion, :with_association, name: 'My Potion') }
      let(:model) { build(:potions_alchemical_property, potion:) }

      context 'when matching only on potion_id and alchemical_property_id' do
        let(:potion) { create(:potion, name: 'My Potion', canonical_potion:) }

        before do
          canonical_potion.reload

          model.alchemical_property_id = canonical_potion.alchemical_properties.first.id
          model.save!
        end

        it 'returns the model' do
          expect(canonical_models)
            .to contain_exactly(canonical_potion.canonical_potions_alchemical_properties.first)
        end
      end

      context 'when matching on strength and duration' do
        let(:potion) { create(:potion, name: 'My Potion') }
        let(:model) do
          build(
            :potions_alchemical_property,
            potion:,
            alchemical_property: canonical_potion.alchemical_properties.first,
            strength: 2,
            duration: 4,
          )
        end

        before do
          canonical_potion.canonical_potions_alchemical_properties.first.update!(
            strength: 2,
            duration: 4,
          )

          create(
            :potions_alchemical_property,
            potion:,
            alchemical_property: canonical_potion.alchemical_properties.first,
            strength: 4,
            duration: 2,
          )

          canonical_potion.canonical_potions_alchemical_properties.reload
        end

        it 'returns the matching canonical model' do
          expect(canonical_models).to contain_exactly(canonical_potion.canonical_potions_alchemical_properties.first)
        end
      end
    end

    context 'when there are multiple matching canonical models' do
      let!(:matching_canonicals) do
        create_list(
          :canonical_potion,
          2,
          :with_association,
          name: 'my potion',
          unit_weight: 0.5,
        )
      end

      let(:potion) { create(:potion, name: 'My Potion') }
      let(:model) { build(:potions_alchemical_property, potion:) }

      it 'returns all matching canonical models' do
        expect(canonical_models)
          .to contain_exactly(
            matching_canonicals.first.canonical_potions_alchemical_properties.first,
            matching_canonicals.last.canonical_potions_alchemical_properties.first,
          )
      end
    end

    context 'when there are no matching canonical models' do
      let(:model) { build(:potions_alchemical_property) }

      it 'is empty' do
        expect(canonical_models).to be_empty
      end
    end
  end
end
