# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalArmorsEnchantment, type: :model do
  describe 'validations' do
    describe 'canonical armor and enchantment' do
      let(:enchantment) { create(:enchantment) }
      let(:armor)       { create(:canonical_armor) }

      it 'must form a unique combination' do
        create(:canonical_armors_enchantment, canonical_armor: armor, enchantment: enchantment)
        model = build(:canonical_armors_enchantment, canonical_armor: armor, enchantment: enchantment)

        model.validate
        expect(model.errors[:enchantment_id]).to include 'must form a unique combination with canonical armor item'
      end
    end
  end
end
