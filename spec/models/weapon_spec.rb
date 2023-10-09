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

        it 'adds the canonical_weapon' do
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

          context 'when enchantments match on the canonical' do
            let!(:canonicals) do
              [
                create(:canonical_weapon, :with_enchantments, name: 'Foobar'),
                create(:canonical_weapon, :with_enchantments, name: 'Foobar', enchantable: false),
                create(:canonical_weapon, name: 'Foobar', enchantable: false),
              ]
            end

            before do
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

            it 'sets enchantments' do
              expect(weapon.reload.enchantments.length).to eq 1
            end
          end

          context 'when there are non-matching enchantments' do
            context 'when there is an enchantable canonical' do
              let!(:canonicals) do
                [
                  create(:canonical_weapon, :with_enchantments, name: 'Foobar', unit_weight: 12, enchantable: true),
                  create(:canonical_weapon, :with_enchantments, name: 'Foobar', enchantable: false),
                ]
              end

              before do
                create(:enchantables_enchantment, enchantable: weapon)
              end

              it 'assigns the enchantable canonical' do
                validate
                expect(weapon.canonical_weapon).to eq canonicals.first
              end

              it 'sets values on the weapon model', :aggregate_failures do
                validate
                expect(weapon.name).to eq 'Foobar'
                expect(weapon.category).to eq 'one-handed' # These values are the defaults for
                expect(weapon.weapon_type).to eq 'war axe' # the Canonical::Weapon factory.
                expect(weapon.unit_weight).to eq 12
                expect(weapon.magical_effects).to be_nil
              end

              it "doesn't set enchantments" do
                expect { validate }
                  .not_to change(weapon.enchantments.reload, :length)
              end
            end

            context 'when the canonicals are not enchantable' do
              let!(:canonicals) do
                [
                  create(:canonical_weapon, :with_enchantments, name: 'Foobar', unit_weight: 12, enchantable: false),
                  create(:canonical_weapon, :with_enchantments, name: 'Foobar', enchantable: false),
                ]
              end

              before do
                create(:enchantables_enchantment, enchantable: weapon)
              end

              it "doesn't set a canonical weapon" do
                validate
                expect(weapon.canonical_weapon).to be_nil
              end

              it "doesn't set values", :aggregate_failures do
                validate
                expect(weapon.name).to eq 'foobar'
              end

              it 'sets an error' do
                validate
                expect(weapon.errors[:base]).to include "doesn't match a weapon that exists in Skyrim"
              end
            end
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

  describe 'delegated methods'

  describe 'adding enchantments' do
    context 'when no canonical model is assigned'

    context 'when there is a canonical model assigned' do
      context 'when the canonical model is enchantable'

      context 'when the canonical model is not enchantable'
    end
  end
end
