# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CanonicalMaterial, type: :model do
  describe 'validations' do
    describe 'name' do
      it 'is invalid without a name' do
        material = described_class.new

        material.validate
        expect(material.errors[:name]).to eq ["can't be blank"]
      end

      it 'is invalid with a duplicate name' do
        described_class.create!(name: 'foo')
        material = described_class.new(name: 'foo')

        material.validate
        expect(material.errors[:name]).to eq ['has already been taken']
      end
    end
  end
end
