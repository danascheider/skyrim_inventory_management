# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Staff, type: :model do
  describe 'validations' do
    subject(:validate) { staff.validate }

    let(:staff) { build(:staff) }

    it 'is invalid without a name' do
      staff.name = nil
      validate
      expect(staff.errors[:name]).to include "can't be blank"
    end
  end
end
