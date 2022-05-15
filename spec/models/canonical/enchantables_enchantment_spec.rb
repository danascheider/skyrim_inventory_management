# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::EnchantablesEnchantment, type: :model do
  describe 'validations' do
    describe 'canonical armor and enchantment' do
      let(:enchantment) { create(:enchantment) }
      let(:armor)       { create(:canonical_armor) }

      it 'must form a unique combination' do
        create(:canonical_enchantables_enchantment, :for_armor, enchantable: armor, enchantment: enchantment)
        model = build(:canonical_enchantables_enchantment, :for_armor, enchantable: armor, enchantment: enchantment)

        model.validate
        expect(model.errors[:enchantment_id]).to include 'must form a unique combination with enchantable item'
      end
    end
  end
end
