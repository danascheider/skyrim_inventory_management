# frozen_string_literal: true

require 'rails_helper'
require 'service/ok_result'

RSpec.describe UsersController::ShowService do
  describe '#perform' do
    subject(:perform) { described_class.new(user).perform }

    let(:user) { create(:user) }

    it 'returns a Service::OKResult' do
      expect(perform).to be_a(Service::OKResult)
    end

    it 'includes the payload' do
      expect(perform.resource).to eq(user)
    end
  end
end
