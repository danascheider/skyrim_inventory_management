# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Power, type: :model do
  describe 'validations' do
    describe 'name' do
      it "can't be blank" do
        model = described_class.new(power_type: 'ability', source: 'Other', description: 'My Power')

        model.validate
        expect(model.errors[:name]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:power, name: 'foo')
        model = build(:power, name: 'foo')

        model.validate
        expect(model.errors[:name]).to include 'must be unique'
      end
    end

    describe 'power_type' do
      it "can't be blank" do
        model = described_class.new(name: 'Foo', source: 'Black Book: Epistolary Acumen', description: 'My Power')

        model.validate
        expect(model.errors[:power_type]).to include "can't be blank"
      end

      it 'must be a valid value' do
        model = build(:power, power_type: 'elemental')

        model.validate
        expect(model.errors[:power_type]).to include 'must be "greater", "lesser", or "ability"'
      end
    end

    describe 'source' do
      it "can't be blank" do
        model = described_class.new(name: 'Foo', power_type: 'lesser', description: 'My Power')

        model.validate
        expect(model.errors[:source]).to include "can't be blank"
      end
    end

    describe 'description' do
      it "can't be blank" do
        model = described_class.new(name: 'Foo', power_type: 'lesser', source: 'Somewhere idk')

        model.validate
        expect(model.errors[:description]).to include "can't be blank"
      end
    end
  end

  describe '::unique_identifier' do
    it 'returns ":name"' do
      expect(described_class.unique_identifier).to eq :name
    end
  end
end
