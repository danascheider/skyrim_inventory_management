# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Weapon, type: :model do
  describe 'validations' do
    subject(:validate) { weapon.validate }

    let(:weapon) { build(:weapon) }

    it 'is invalid without a name' do
      weapon.name = nil
      validate
      expect(weapon.errors[:name]).to include "can't be blank"
    end

    it 'is invalid with an invalid category name' do
      weapon.category = 'foo'
      validate
      expect(weapon.errors[:category]).to include 'must be "one-handed", "two-handed", or "archery"'
    end

    it 'is invalid with an invalid weapon type' do
      weapon.weapon_type = 'foo'
      validate
      expect(weapon.errors[:weapon_type]).to include 'must be a valid type of weapon that occurs in Skyrim'
    end

    it 'is invalid with a negative unit weight' do
      weapon.unit_weight = -0.5
      validate
      expect(weapon.errors[:unit_weight]).to include 'must be greater than or equal to 0'
    end
  end

  describe '::before_validation' do
    subject(:validate) { weapon.validate }

    context 'when there is a canonical model assigned' do
      let(:canonical_weapon) { weapon.canonical_weapon }

      context 'when the canonical model has no enchantments' do
        let(:weapon) { build(:weapon, :with_matching_canonical) }

        before do
          # A second possible match
          create(
            :canonical_weapon,
            name: canonical_weapon.name,
            category: canonical_weapon.category,
            weapon_type: canonical_weapon.weapon_type,
            unit_weight: canonical_weapon.unit_weight,
          )
        end

        it "doesn't change the canonical model" do
          expect { validate }
            .not_to change(weapon, :canonical_weapon)
        end

        it 'sets values on the weapon model', :aggregate_failures do
          validate
          expect(weapon.name).to eq canonical_weapon.name
          expect(weapon.category).to eq canonical_weapon.category
          expect(weapon.weapon_type).to eq canonical_weapon.weapon_type
          expect(weapon.unit_weight).to eq canonical_weapon.unit_weight
        end

        it "doesn't add enchantments" do
          validate
          expect(weapon.enchantments).to be_empty
        end
      end

      context 'when the canonical model has enchantments' do
        let(:weapon) { build(:weapon, :with_enchanted_canonical) }

        before do
          # A second possible match
          create(
            :canonical_weapon,
            name: canonical_weapon.name,
            category: canonical_weapon.category,
            weapon_type: canonical_weapon.weapon_type,
            unit_weight: canonical_weapon.unit_weight,
          )
        end

        it "doesn't change the canonical model" do
          expect { validate }
            .not_to change(weapon, :canonical_weapon)
        end

        it "doesn't add enchantments" do
          validate
          expect(weapon.enchantments).to be_empty
        end

        it 'sets values on the weapon model', :aggregate_failures do
          validate
          expect(weapon.name).to eq canonical_weapon.name
          expect(weapon.category).to eq canonical_weapon.category
          expect(weapon.weapon_type).to eq canonical_weapon.weapon_type
          expect(weapon.unit_weight).to eq canonical_weapon.unit_weight
          expect(weapon.magical_effects).to eq canonical_weapon.magical_effects
        end
      end
    end

    context 'when there is a single matching canonical model' do
      context 'when the canonical model has no enchantments' do
        let(:weapon) { build(:weapon, name: 'foobar', unit_weight: 12) }

        let!(:matching_canonical) { create(:canonical_weapon, name: 'Foobar', unit_weight: 12) }

        before do
          create(
            :canonical_weapon,
            name: 'Foobar',
            unit_weight: 14,
          )
        end

        it 'assigns the canonical_weapon' do
          expect { validate }
            .to change(weapon, :canonical_weapon)
                  .to(matching_canonical)
        end

        it 'sets values on the weapon model', :aggregate_failures do
          validate
          expect(weapon.name).to eq matching_canonical.name
          expect(weapon.category).to eq matching_canonical.category
          expect(weapon.weapon_type).to eq matching_canonical.weapon_type
          expect(weapon.unit_weight).to eq matching_canonical.unit_weight
          expect(weapon.magical_effects).to eq matching_canonical.magical_effects
        end

        it "doesn't set enchantments" do
          validate
          expect(weapon.enchantments).to be_empty
        end
      end

      context 'when the canonical model has enchantments' do
        context 'when the in-game item model has no enchantments' do
          let(:weapon) { build(:weapon, name: 'foobar', unit_weight: 12) }

          let!(:matching_canonical) { create(:canonical_weapon, :with_enchantments, name: 'Foobar', unit_weight: 12) }

          before do
            create(
              :canonical_weapon,
              name: 'Foobar',
              unit_weight: 14,
            )
          end

          it 'assigns the canonical_weapon' do
            expect { validate }
              .to change(weapon, :canonical_weapon)
                    .to(matching_canonical)
          end

          it 'sets values on the weapon model', :aggregate_failures do
            validate
            expect(weapon.name).to eq matching_canonical.name
            expect(weapon.category).to eq matching_canonical.category
            expect(weapon.weapon_type).to eq matching_canonical.weapon_type
            expect(weapon.unit_weight).to eq matching_canonical.unit_weight
            expect(weapon.magical_effects).to eq matching_canonical.magical_effects
          end

          it "doesn't set enchantments" do
            validate
            expect(weapon.enchantments).to be_empty
          end
        end

        context 'when the in-game item has enchantments' do
          let(:weapon) { create(:weapon, name: 'foobar') }

          let!(:canonicals) do
            [
              create(:canonical_weapon, :with_enchantments, name: 'Foobar'),
              create(:canonical_weapon, name: 'Foobar', enchantable: false),
              create(:canonical_weapon, name: 'Foobar', enchantable: false),
            ]
          end

          before do
            create(
              :enchantables_enchantment,
              enchantable: canonicals.second,
              enchantment: canonicals.first.enchantments.first,
              strength: 2, # test that matching is done by strength too
            )

            create(
              :enchantables_enchantment,
              enchantable: weapon,
              enchantment: canonicals.first.enchantments.first,
              strength: canonicals.first.enchantments.first.strength,
            )

            weapon.enchantables_enchantments.reload
          end

          it 'assigns the canonical_weapon' do
            validate
            expect(weapon.canonical_weapon).to eq canonicals.first
          end

          it 'sets values on the weapon model', :aggregate_failures do
            validate
            expect(weapon.name).to eq canonicals.first.name
            expect(weapon.category).to eq canonicals.first.category
            expect(weapon.weapon_type).to eq canonicals.first.weapon_type
            expect(weapon.unit_weight).to eq canonicals.first.unit_weight
            expect(weapon.magical_effects).to eq canonicals.first.magical_effects
          end
        end
      end
    end

    context 'when there are multiple matching canonical models' do
      context 'when there are no enchantments involved' do
        let(:weapon) { build(:weapon, name: 'foobar') }

        before do
          create_list(:canonical_weapon, 2, name: 'Foobar')
        end

        it "doesn't assign a canonical_weapon" do
          validate
          expect(weapon.canonical_weapon).to be_nil
        end

        it "doesn't set values", :aggregate_failures do
          validate
          expect(weapon.name).to eq 'foobar'
          expect(weapon.category).to be_nil
          expect(weapon.weapon_type).to be_nil
          expect(weapon.unit_weight).to be_nil
          expect(weapon.magical_effects).to be_nil
        end
      end

      context 'when there are enchantments' do
        context 'when the weapon itself has no enchantments' do
          let(:weapon) { build(:weapon, name: 'foobar') }

          before do
            create(:canonical_weapon, :with_enchantments, name: 'Foobar')
            create(:canonical_weapon, name: 'Foobar')
          end

          it "doesn't assign a canonical_weapon" do
            validate
            expect(weapon.canonical_weapon).to be_nil
          end

          it "doesn't set values", :aggregate_failures do
            validate
            expect(weapon.name).to eq 'foobar'
            expect(weapon.category).to be_nil
            expect(weapon.weapon_type).to be_nil
            expect(weapon.unit_weight).to be_nil
            expect(weapon.magical_effects).to be_nil
          end

          it "doesn't set enchantments" do
            validate
            expect(weapon.enchantments).to be_empty
          end

          it "doesn't set errors" do
            validate
            expect(weapon.errors[:base]).to be_empty
          end
        end

        context 'when the weapon itself is already enchanted' do
          let(:weapon) { create(:weapon, name: 'foobar') }

          let!(:canonicals) do
            [
              create(:canonical_weapon, :with_enchantments, name: 'Foobar', enchantable: false),
              create(:canonical_weapon, :with_enchantments, name: 'FoObAr', enchantable: false),
              create(:canonical_weapon, :with_enchantments, name: 'fOoBaR', enchantable: false),
              create(:canonical_weapon, name: 'fOObAR', enchantable: true),
            ]
          end

          before do
            create(
              :enchantables_enchantment,
              enchantable: weapon,
              enchantment: canonicals.first.enchantments.first,
              strength: canonicals.first.enchantments.first.strength,
            )
          end

          it "doesn't assign a canonical_weapon" do
            validate
            expect(weapon.canonical_weapon).to be_nil
          end

          it "doesn't set values", :aggregate_failures do
            validate
            expect(weapon.name).to eq 'foobar'
            expect(weapon.category).to be_nil
            expect(weapon.weapon_type).to be_nil
            expect(weapon.unit_weight).to be_nil
            expect(weapon.magical_effects).to be_nil
          end

          it "doesn't set enchantments" do
            expect { validate }
              .not_to change(weapon.enchantments, :length)
          end

          it "doesn't set errors" do
            validate
            expect(weapon.errors[:base]).to be_empty
          end
        end
      end
    end

    context 'when there are no matching canonical models' do
      let(:weapon) { build(:weapon, name: 'Foobar') }

      before do
        create_list(:canonical_weapon, 2)
      end

      it 'adds an error' do
        validate
        expect(weapon.errors[:base]).to include "doesn't match a weapon that exists in Skyrim"
      end
    end
  end

  describe '::after_save' do
    context 'when there is one matching canonical model' do
      subject(:save) { weapon.save! }

      context 'when neither the canonical nor the in-game item have enchantments' do
        let(:weapon) { build(:weapon, :with_matching_canonical) }

        it "doesn't add enchantments" do
          expect { save }
            .not_to change(weapon, :enchantments)
        end
      end

      context 'when the canonical weapon is enchanted' do
        subject(:add_enchantment) do
          create(
            :enchantables_enchantment,
            enchantable: weapon,
            enchantment: Canonical::Weapon.first.enchantments.first,
          )
        end

        let(:weapon) { build(:weapon, name: 'foobar') }

        context 'when the in-game item is not enchanted' do
          before do
            matching_canonical = create(
              :canonical_weapon,
              name: 'Foobar',
            )

            # We need to save the weapon now so that it doesn't add enchantments
            # from the matching canonical if we create/save it after the enchantments
            # have been added to the canonical.
            weapon.save!

            create_list(
              :enchantables_enchantment,
              2,
              enchantable: matching_canonical,
            )
          end

          it 'adds enchantments from the canonical' do
            add_enchantment
            expect(weapon.reload.enchantments.length).to eq 2
          end
        end

        context 'when the in-game item has matching enchantments' do
          before do
            create_list(
              :canonical_weapon,
              2,
              :with_enchantments,
              name: 'Foobar',
              # Set enchantable to false, otherwise both canonicals
              # will continue to match the weapon object even after
              # enchantments are added
              enchantable: false,
            )
          end

          it 'adds missing enchantments' do
            add_enchantment
            expect(weapon.reload.enchantments.length).to eq 2
          end
        end

        # We don't need to include sub-contexts for enchantable vs.
        # non-enchantable canonicals, because if the canonicals are not
        # enchantable then there will be no matching canonicals, which
        # would be impossible to set up because SIM doesn't allow any
        # weapon to be saved if no canonicals match.
        context 'when the in-game item has non-matching enchantments' do
          subject(:add_enchantment) { create(:enchantables_enchantment, enchantable: weapon) }

          let(:weapon) { create(:weapon, name: 'foobar') }

          before do
            create(
              :canonical_weapon,
              :with_enchantments,
              name: 'Foobar',
              enchantable: true,
            )

            create(
              :canonical_weapon,
              :with_enchantments,
              name: 'Foobar',
              enchantable: false,
            )
          end

          it 'sets the canonical weapon' do
            expect { add_enchantment }
              .to change(weapon.reload, :canonical_weapon)
                    .from(nil)
                    .to(Canonical::Weapon.first)
          end

          it 'adds any enchantments from the enchantable canonical' do
            add_enchantment
            expect(weapon.reload.enchantments.length).to eq 3
          end
        end
      end
    end

    context 'when there are multiple canonical models' do
      subject(:save) { weapon.save! }

      let(:weapon) { build(:weapon, name: 'Foobar') }

      before do
        create_list(
          :canonical_weapon,
          2,
          :with_enchantments,
          name: 'Foobar',
        )
      end

      it "doesn't add enchantments" do
        expect { save }
          .not_to change(weapon.enchantables_enchantments.reload, :length)
      end
    end
  end

  describe 'delegated methods'

  describe 'adding enchantments' do
    context 'when no canonical model is assigned' do
      let(:weapon) { create(:weapon, name: 'foobar') }

      context 'when there are multiple matching canonicals' do
        before do
          create_list(
            :canonical_weapon,
            2,
            :with_enchantments,
            name: 'Foobar',
            enchantable:,
          )
        end

        context 'when the added enchantment eliminates all canoncial matches' do
          subject(:add_enchantment) { create(:enchantables_enchantment, enchantable: weapon) }

          let(:enchantable) { false }

          it "doesn't allow enchantments if they eliminate all canonical matches", :aggregate_failures do
            expect { add_enchantment }
              .to raise_error(ActiveRecord::RecordInvalid)

            expect(weapon.enchantments.reload.length).to eq 0
          end
        end

        context 'when the added enchantment narrows it down to one canonical match' do
          subject(:add_enchantment) do
            create(
              :enchantables_enchantment,
              enchantable: weapon,
              enchantment: Canonical::Weapon.last.enchantments.first,
            )
          end

          let(:enchantable) { false }

          it 'sets the canonical weapon' do
            expect { add_enchantment }
              .to change(weapon.reload, :canonical_weapon)
                    .from(nil)
                    .to(Canonical::Weapon.last)
          end

          it 'adds missing enchantments' do
            add_enchantment
            expect(weapon.enchantments.reload.length).to eq 2
          end
        end

        context 'when there are still multiple canonicals after adding the enchantment' do
          subject(:add_enchantment) { create(:enchantables_enchantment, enchantable: weapon) }

          let(:enchantable) { true }

          it "doesn't assign a canonical weapon" do
            expect { add_enchantment }
              .not_to change(weapon.reload, :canonical_weapon)
          end

          it "doesn't add additional enchantments" do
            add_enchantment
            expect(weapon.enchantments.reload.length).to eq 1
          end
        end
      end
    end
  end
end
