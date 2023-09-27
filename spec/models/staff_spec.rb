# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Staff, type: :model do
  describe 'validations' do
    subject(:validate) { staff.validate }

    let(:staff) { build(:staff) }

    describe 'name' do
      it 'is invalid without a name' do
        staff.name = nil
        validate
        expect(staff.errors[:name]).to include "can't be blank"
      end
    end

    describe 'unit_weight' do
      it 'is invalid with a negative unit weight' do
        staff.unit_weight = -2
        validate
        expect(staff.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end

      it 'can be nil' do
        staff.unit_weight = nil
        validate
        expect(staff.errors[:unit_weight]).to be_empty
      end
    end

    describe 'canonical_staff' do
      context 'when there is a canonical_staff associated' do
        let(:staff) { create(:staff, :with_matching_canonical) }

        it 'is valid' do
          expect(staff).to be_valid
        end
      end

      context 'when there is no canonical_staff associated' do
        let(:game) { create(:game) }
        let(:staff) { build(:staff, game:, name: 'my staff') }

        context 'when there are multiple matching canonical staves' do
          before do
            create_list(
              :canonical_staff,
              2,
              name: staff.name,
            )
          end

          it 'is valid' do
            expect(staff).to be_valid
          end
        end

        context 'when the matching canonical staff is unique and has an existing association' do
          before do
            canonical_staff = create(
              :canonical_staff,
              name: 'My Staff',
              unique_item: true,
              rare_item: true,
            )

            create(:staff, name: 'My Staff', game:, canonical_staff:)
          end

          it 'is invalid' do
            staff.validate
            expect(staff.errors[:base]).to include 'is a duplicate of a unique in-game item'
          end
        end

        context 'when there are no matching canonical staves' do
          it 'is invalid' do
            validate
            expect(staff.errors[:base]).to include "doesn't match any item that exists in Skyrim"
          end
        end
      end
    end
  end

  describe 'matching canonical models' do
    subject(:canonical_models) { staff.canonical_models }

    context 'when there are no matching canonical models' do
      let(:staff) { build(:staff) }

      it 'returns an empty ActiveRecord relation', :aggregate_failures do
        expect(canonical_models).to be_empty
        expect(canonical_models).to be_an(ActiveRecord::Relation)
      end
    end

    context 'when there is a canonical model assigned' do
      let(:staff) { create(:staff, :with_matching_canonical) }

      it 'returns an ActiveRecord relation with only that model', :aggregate_failures do
        expect(canonical_models).to be_an(ActiveRecord::Relation)
        expect(canonical_models).to contain_exactly staff.canonical_staff
      end
    end

    context 'when there are multiple matching canonical models' do
      let(:staff) { build(:staff, magical_effects: 'This staff has magical effects') }

      let!(:matching_canonicals) do
        create_list(
          :canonical_staff,
          2,
          name: staff.name,
          magical_effects: 'This staff has magical effects',
        )
      end

      before do
        create(:canonical_staff, name: staff.name)
      end

      it 'returns all the matching canonical models in an ActiveRecord relation', :aggregate_failures do
        expect(canonical_models).to be_an(ActiveRecord::Relation)
        expect(canonical_models).to contain_exactly(*matching_canonicals)
      end
    end
  end

  describe 'setting a canonical model' do
    context 'when there is an existing canonical staff' do
      let(:staff) { create(:staff, :with_matching_canonical) }

      it "doesn't change anything" do
        expect { staff.validate }
          .not_to change(staff.reload, :canonical_staff)
      end
    end

    context 'when there is a single matching canonical staff' do
      let(:game) { create(:game) }
      let(:staff) { build(:staff, name: 'my staff', unit_weight: nil, game:) }

      context 'when the matching canonical is a unique item' do
        let!(:canonical_staff) do
          create(
            :canonical_staff,
            name: 'My Staff',
            unit_weight: 8,
            magical_effects: 'Does stuff',
            unique_item: true,
            rare_item: true,
          )
        end

        context 'when the matching canonical already has an association for that game' do
          before do
            create(:staff, name: 'My Staff', canonical_staff:, game:)
          end

          it "doesn't associate the canonical model" do
            staff.validate
            expect(staff.canonical_staff).to be_nil
          end
        end

        context 'when the matching canonical already has an association for another game' do
          before do
            create(:staff, name: 'My Staff', canonical_staff:)
          end

          it 'associates the canonical model to the staff' do
            staff.validate
            expect(staff.canonical_staff).to eq canonical_staff
          end

          it 'sets values from the canonical model', :aggregate_failures do
            staff.validate
            expect(staff.name).to eq 'My Staff'
            expect(staff.unit_weight).to eq 8
            expect(staff.magical_effects).to eq 'Does stuff'
          end
        end

        context 'when the matching canonical has no existing associations' do
          it 'associates the canonical model to the staff' do
            staff.validate
            expect(staff.canonical_staff).to eq canonical_staff
          end

          it 'sets values from the canonical model', :aggregate_failures do
            staff.validate
            expect(staff.name).to eq 'My Staff'
            expect(staff.unit_weight).to eq 8
            expect(staff.magical_effects).to eq 'Does stuff'
          end
        end
      end

      context 'when the matching canonical is not unique' do
        let!(:canonical_staff) do
          create(
            :canonical_staff,
            name: 'My Staff',
            unit_weight: 8,
            magical_effects: 'Does stuff',
          )
        end

        before do
          create(:staff, name: 'My Staff', canonical_staff:, game:)
        end

        it 'allows a duplicate association' do
          staff.validate
          expect(staff.canonical_staff).to eq canonical_staff
        end

        it 'sets values from the canonical model', :aggregate_failures do
          staff.validate
          expect(staff.name).to eq 'My Staff'
          expect(staff.unit_weight).to eq 8
          expect(staff.magical_effects).to eq 'Does stuff'
        end
      end
    end

    context 'when there are multiple matching canonicals' do
      context 'when some matchable attributes are blank' do
        let(:staff) { build(:staff, unit_weight: nil, magical_effects: nil) }

        before do
          create(:canonical_staff, name: staff.name, unit_weight: 8, magical_effects: 'foo')
          create(:canonical_staff, name: staff.name, unit_weight: 2)
        end

        it "doesn't associate a canonical model" do
          staff.validate
          expect(staff.canonical_staff).to be_nil
        end
      end
    end
  end
end
