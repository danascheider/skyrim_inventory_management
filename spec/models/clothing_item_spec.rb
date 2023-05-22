# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClothingItem, type: :model do
  describe 'validations' do
    let(:item) { build(:clothing_item) }

    it 'is invalid without a name' do
      item.name = nil
      item.validate
      expect(item.errors[:name]).to include "can't be blank"
    end

    it 'is invalid with unit weight less than 0' do
      item.unit_weight = -1
      item.validate
      expect(item.errors[:unit_weight]).to include 'must be greater than or equal to 0'
    end

    it 'validates against canonical models'
  end
end
