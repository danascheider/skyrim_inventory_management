# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::Sync do
  describe 'perform' do
    context 'when the model is ":all"'

    context 'when the model is ":alchemical_property"' do
      subject(:perform) { described_class.perform(:alchemical_property, false) }

      before do
        allow(Canonical::Sync::AlchemicalProperties).to receive(:perform)
      end

      it 'calls #perform on the correct syncer' do
        perform
        expect(Canonical::Sync::AlchemicalProperties).to have_received(:perform).with(false)
      end
    end

    context 'when the model is ":enchantment"' do
      subject(:perform) { described_class.perform(:enchantment, true) }

      before do
        allow(Canonical::Sync::Enchantments).to receive(:perform)
      end

      it 'calls #perform on the correct syncer' do
        perform
        expect(Canonical::Sync::Enchantments).to have_received(:perform).with(true)
      end
    end

    context 'when the model is ":spell"' do
      subject(:perform) { described_class.perform(:spell, false) }

      before do
        allow(Canonical::Sync::Spells).to receive(:perform)
      end

      it 'calls #perform on the correct syncer' do
        perform
        expect(Canonical::Sync::Spells).to have_received(:perform).with(false)
      end
    end

    context 'when the model is ":property"' do
      subject(:perform) { described_class.perform(:property, false) }

      before do
        allow(Canonical::Sync::Properties).to receive(:perform)
      end

      it 'calls #perform on the correct syncer' do
        perform
        expect(Canonical::Sync::Properties).to have_received(:perform).with(false)
      end
    end

    context 'when the model is ":material"' do
      subject(:perform) { described_class.perform(:material, true) }

      before do
        allow(Canonical::Sync::Materials).to receive(:perform)
      end

      it 'calls #perform on the correct syncer' do
        perform
        expect(Canonical::Sync::Materials).to have_received(:perform).with(true)
      end
    end
  end
end
