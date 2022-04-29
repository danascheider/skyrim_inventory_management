# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlchemicalProperty, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'must be present' do
        property = described_class.new

        property.validate
        expect(property.errors[:name]).to include "can't be blank"
      end

      it 'must be unique' do
        described_class.create!(name: 'Restore Health', strength_unit: 'point')

        property = described_class.new(name: 'Restore Health')
        property.validate
        expect(property.errors[:name]).to include 'must be unique'
      end
    end

    describe 'strength_unit' do
      it "isn't required" do
        property = described_class.new
        property.validate
        expect(property.errors[:strength_unit]).to be_empty
      end

      it 'must be one of "point" or "percentage"' do
        property = described_class.new(strength_unit: 'Foobar')
        property.validate
        expect(property.errors[:strength_unit]).to include 'must be "point" or "percentage"'
      end
    end
  end
end
