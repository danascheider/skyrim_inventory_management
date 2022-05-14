# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::Sync::Armor do
  # Use let! because if we wait to evaluate these until we've run the
  # examples, the stub in the before block will prevent `File.read` from
  # running.
  let(:json_path)  { Rails.root.join('spec', 'fixtures', 'canonical', 'sync', 'armor.json') }
  let!(:json_data) { File.read(json_path) }

  let(:material_codes) do
    %w[
      0005ACE5
      0005AD9F
      0005ACE4
      000DB5D2
      000800E4
      0003ADA3
      0003ADA4
    ]
  end

  before do
    allow(File).to receive(:read).and_return(json_data)
  end

  describe '::perform' do
    subject(:perform) { described_class.perform(preserve_existing_records) }

    context 'when preserve_existing_records is false' do
      let(:preserve_existing_records) { false }

      context 'when there are no existing armor items in the database' do
        let(:syncer) { described_class.new(preserve_existing_records) }

        before do
          create(:enchantment, name: 'Fortify Block')
          material_codes.each {|code| create(:canonical_material, item_code: code) }
          allow(described_class).to receive(:new).and_return(syncer)
        end

        it 'instantiates itseslf' do
          perform
          expect(described_class).to have_received(:new).with(preserve_existing_records)
        end

        it 'populates the models from the JSON file' do
          perform
          expect(Canonical::Armor.count).to eq 4
        end

        it 'creates the associations to enchantments where they exist', :aggregate_failures do
          perform
          expect(Canonical::Armor.find_by(item_code: 'XX01DB97').enchantments.length).to eq 0
          expect(Canonical::Armor.find_by(item_code: '000B50EF').enchantments.length).to eq 1
          expect(Canonical::Armor.find_by(item_code: '0001391A').enchantments.length).to eq 0
          expect(Canonical::Armor.find_by(item_code: '00013966').enchantments.length).to eq 0
        end

        it 'creates the associations to smithing materials where they exist', :aggregate_failures do
          perform
          expect(Canonical::Armor.find_by(item_code: 'XX01DB97').smithing_materials.length).to eq 0
          expect(Canonical::Armor.find_by(item_code: '000B50EF').smithing_materials.length).to eq 0
          expect(Canonical::Armor.find_by(item_code: '0001391A').smithing_materials.length).to eq 4
          expect(Canonical::Armor.find_by(item_code: '00013966').smithing_materials.length).to eq 3
        end

        it 'creates the associations to tempering materials where they exist', :aggregate_failures do
          perform
          expect(Canonical::Armor.find_by(item_code: 'XX01DB97').tempering_materials.length).to eq 1
          expect(Canonical::Armor.find_by(item_code: '000B50EF').tempering_materials.length).to eq 1
          expect(Canonical::Armor.find_by(item_code: '0001391A').tempering_materials.length).to eq 1
          expect(Canonical::Armor.find_by(item_code: '00013966').tempering_materials.length).to eq 1
        end
      end

      context 'when there are existing armor item records in the database' do
        let!(:item_in_json)     { create(:canonical_armor, item_code: 'XX01DB97', body_slot: 'feet') }
        let!(:item_not_in_json) { create(:canonical_armor, item_code: '12345678') }
        let(:syncer)            { described_class.new(preserve_existing_records) }

        before do
          create(:enchantment, name: 'Fortify Block')
          material_codes.each {|code| create(:canonical_material, item_code: code) }
        end

        it 'instantiates itself' do
          allow(described_class).to receive(:new).and_return(syncer)
          perform
          expect(described_class).to have_received(:new).with(preserve_existing_records)
        end

        it 'updates models that were already in the database' do
          perform
          expect(item_in_json.reload.body_slot).to eq 'body'
        end

        it "removes models in the database that aren't in the JSON data" do
          perform
          expect(Canonical::Armor.find_by(item_code: '12345678')).to be_nil
        end

        it 'adds new models to the database', :aggregate_failures do
          perform
          expect(Canonical::Armor.find_by(item_code: '000B50EF')).to be_present
          expect(Canonical::Armor.find_by(item_code: '0001391A')).to be_present
          expect(Canonical::Armor.find_by(item_code: '00013966')).to be_present
        end

        it "removes associations that don't exist in the JSON data" do
          item_in_json.canonical_armors_tempering_materials.create!(
            material: create(:canonical_material, name: 'Titanium Ingot'),
            quantity: 2,
          )
          perform
          expect(item_in_json.tempering_materials.find_by(name: 'Titanium Ingot')).to be_nil
        end

        it 'adds associations if they exist' do
          perform
          expect(item_in_json.tempering_materials.find_by(item_code: '0005ACE5')).to be_present
        end
      end

      context 'when there are no enchantments or materials in the database' do
        before do
          allow(Rails.logger).to receive(:error)
        end

        it "logs an error and doesn't create models", :aggregate_failures do
          expect { perform }
            .to raise_error(Canonical::Sync::PrerequisiteNotMetError)
          expect(Rails.logger).to have_received(:error).with('Prerequisite(s) not met: sync Enchantment, Canonical::Material before canonical armors')
          expect(Canonical::JewelryItem.count).to eq 0
        end
      end

      context 'when an enchantment or material is missing' do
        before do
          # prevent it from erroring out, which it will do if there are no
          # enchantments or materials at all
          create(:enchantment)
          create(:canonical_material)
          allow(Rails.logger).to receive(:error).twice
        end

        it 'logs a validation error', :aggregate_failures do
          expect { perform }
            .to raise_error ActiveRecord::RecordInvalid
          expect(Rails.logger).to have_received(:error).with('Validation error saving associations for canonical armor "XX01DB97": Validation failed: Material must exist')
        end
      end
    end

    context 'when preserve_existing_records is true' do
      let(:preserve_existing_records) { true }
      let(:syncer)                    { described_class.new(preserve_existing_records) }
      let!(:item_in_json)             { create(:canonical_armor, item_code: 'XX01DB97', body_slot: 'hands') }
      let!(:item_not_in_json)         { create(:canonical_armor, item_code: '12345678') }

      before do
        create(:enchantment, name: 'Fortify Block')
        material_codes.each {|code| create(:canonical_material, item_code: code) }
        create(:canonical_armors_tempering_material, armor: item_in_json, material: create(:canonical_material))
        allow(described_class).to receive(:new).and_return(syncer)
      end

      it 'instantiates itself' do
        perform
        expect(described_class).to have_received(:new).with(preserve_existing_records)
      end

      it 'updates models found in the JSON data' do
        perform
        expect(item_in_json.reload.body_slot).to eq 'body'
      end

      it 'adds models not already in the database', :aggregate_failures do
        perform
        expect(Canonical::Armor.find_by(item_code: '000B50EF')).to be_present
        expect(Canonical::Armor.find_by(item_code: '0001391A')).to be_present
        expect(Canonical::Armor.find_by(item_code: '00013966')).to be_present
      end

      it "doesn't destroy models that aren't in the JSON data" do
        perform
        expect(item_not_in_json.reload).to be_present
      end

      it "doesn't destroy associations" do
        perform
        expect(item_in_json.reload.canonical_armors_tempering_materials.length).to eq 2
      end
    end

    describe 'error logging' do
      let(:preserve_existing_records) { false }

      context 'when an ActiveRecord::RecordInvalid error is raised' do
        let(:errored_model) do
          instance_double Canonical::Armor,
                          errors: errors,
                          class:  class_double(Canonical::Armor, i18n_scope: :activerecord)
        end

        let(:errors) { double('errors', full_messages: ["Name can't be blank"]) }

        before do
          create(:enchantment)
          create(:canonical_material)

          allow_any_instance_of(Canonical::Armor)
            .to receive(:save!)
                  .and_raise(ActiveRecord::RecordInvalid, errored_model)
          allow(Rails.logger).to receive(:error)
        end

        it 'logs and reraises the error', :aggregate_failures do
          expect { perform }
            .to raise_error(ActiveRecord::RecordInvalid)
          expect(Rails.logger).to have_received(:error).with("Error saving canonical armor \"XX01DB97\": Validation failed: Name can't be blank")
        end
      end

      context 'when another error is raised pertaining to a specific model' do
        before do
          create(:enchantment)
          create(:canonical_material)
          allow(Canonical::Armor).to receive(:find_or_initialize_by).and_raise(StandardError, 'foobar')
          allow(Rails.logger).to receive(:error)
        end

        it 'logs and reraises the error', :aggregate_failures do
          expect { perform }
            .to raise_error(StandardError)
          expect(Rails.logger).to have_received(:error).with('Unexpected error StandardError saving canonical armor "XX01DB97": foobar')
        end
      end

      context 'when an error is raised not pertaining to a specific model' do
        before do
          create(:enchantment)
          create(:canonical_material)

          allow(Canonical::Armor).to receive(:where).and_raise(StandardError, 'foobar')
          allow(Rails.logger).to receive(:error)
        end

        it 'logs and reraises the error', :aggregate_failures do
          expect { perform }
            .to raise_error(StandardError)
          expect(Rails.logger).to have_received(:error).with('Unexpected error StandardError while syncing canonical armors: foobar')
        end
      end
    end
  end
end
