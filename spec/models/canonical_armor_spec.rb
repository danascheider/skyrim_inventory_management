# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalArmor, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'is invalid without a name' do
        armor = described_class.new(weight: 'heavy armor', body_slot: 'body')

        armor.validate
        expect(armor.errors[:name]).to eq ["can't be blank"]
      end

    describe 'weight' do
      it 'is invalid without a valid weight' do
        armor = described_class.new(name: 'fur armor', body_slot: 'head')

        armor.validate
        expect(armor.errors[:weight]).to eq ["can't be blank", 'must be "light armor" or "heavy armor"']
      end
    end

    describe 'body_slot' do
      it 'is invalid without a valid body slot' do
        armor = described_class.new(name: 'fur armor', weight: 'light armor')

        armor.validate
        expect(armor.errors[:body_slot]).to eq ["can't be blank", 'must be "head", "body", "hands", "feet", or "shield"']
      end
    end
  end
end
