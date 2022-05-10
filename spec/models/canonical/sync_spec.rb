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
  end
end
