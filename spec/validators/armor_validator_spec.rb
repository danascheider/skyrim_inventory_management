# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ArmorValidator do
  subject(:validate) { described_class.new.validate(armor) }

  let(:armor) { build(:armor) }

  context 'when there is no matching canonical armor' do
    it 'sets an error' do
      validate
      expect(armor.errors[:base]).to include "doesn't match an armor item that exists in Skyrim"
    end
  end

  context 'when there are matching canonical armors' do
    let!(:canonicals) { create_list(:canonical_armor, 2, name: armor.name) }

    it 'is valid' do
      expect(armor).to be_valid
    end
  end
end
