# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Potion, type: :model do
  describe 'validations' do
    let(:item) { build(:potion) }

    describe '#name' do
      it "can't be blank" do
        item.name = nil
        item.validate
        expect(item.errors[:name]).to include "can't be blank"
      end
    end

    describe '#unit_weight' do
      it 'can be blank' do
        item.unit_weight = nil
        item.validate
        expect(item.errors[:unit_weight]).to be_empty
      end

      it 'must be at least 0' do
        item.unit_weight = -0.5
        item.validate
        expect(item.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end
  end

  describe '#canonical_models' do
    subject(:canonical_models) { potion.canonical_models }

    context 'when the potion has an association defined' do
      let(:potion) { create(:potion, :with_matching_canonical) }

      it 'returns the associated canonical model' do
        expect(canonical_models).to contain_exactly(potion.canonical_potion)
      end
    end

    context 'when the potion does not have an association defined' do
      context 'when only the name has to match' do
        let(:potion) { build(:potion, name: 'Potion of Healing') }

        let!(:matching_canonicals) do
          create_list(
            :canonical_potion,
            3,
            name: 'potion of healing',
          )
        end

        before do
          create(:canonical_potion)
        end

        it 'matches case-insensitively' do
          expect(canonical_models).to eq matching_canonicals
        end
      end

      context 'when there is a unit weight defined' do
        let(:potion) { build(:potion, name: 'Potion of Healing', unit_weight: 0.5) }

        let!(:matching_canonicals) do
          create_list(
            :canonical_potion,
            3,
            name: 'potion of healing',
            unit_weight: 0.5,
          )
        end

        before do
          create(:canonical_potion, name: 'potion of healing', unit_weight: 0.6)
        end

        it 'returns all matching canonicals' do
          expect(canonical_models).to eq matching_canonicals
        end
      end

      context 'when there are no matches' do
        let(:potion) { build(:potion, name: 'Deadly Poison', unit_weight: 0.5) }

        before do
          create(:canonical_potion, name: 'Deadly Poison', unit_weight: 0.2)
        end

        it 'is empty' do
          expect(canonical_models).to be_empty
        end
      end
    end
  end

  describe '::before_validation' do
    let(:potion) { build(:potion) }

    context 'when there is a matching canonical potion' do
      let!(:matching_canonical) { create(:canonical_potion, name: potion.name.downcase) }

      it 'sets the canonical_potion' do
        potion.validate
        expect(potion.canonical_potion).to eq matching_canonical
      end

      it 'sets the name and unit weight', :aggregate_failures do
        potion.validate
        expect(potion.name).to eq matching_canonical.name
        expect(potion.unit_weight).to eq matching_canonical.unit_weight
      end
    end

    context 'when there are multiple matching canonical potions' do
      let!(:matching_canonicals) { create_list(:canonical_potion, 2, name: potion.name.downcase) }

      it "doesn't set the canonical_potion" do
        potion.validate
        expect(potion.canonical_potion).to be_nil
      end

      it "doesn't change the name" do
        expect { potion.validate }
          .not_to change(potion, :name)
      end

      it "doesn't change the unit_weight" do
        expect { potion.validate }
          .not_to change(potion, :unit_weight)
      end
    end

    context 'when there is no matching canonical potion' do
      it "doesn't set the canonical potion" do
        potion.validate
        expect(potion.canonical_potion).to be_nil
      end
    end
  end
end
