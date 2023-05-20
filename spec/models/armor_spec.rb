# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Armor, type: :model do
  describe 'validations' do
    let(:armor) { build(:armor) }

    it 'is invalid without a name' do
      armor.name = nil
      armor.validate
      expect(armor.errors[:name]).to include "can't be blank"
    end
  end
end
