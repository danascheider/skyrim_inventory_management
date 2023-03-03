# frozen_string_literal: true

require 'rails_helper'
require 'service/internal_server_error_result'

RSpec.describe ApplicationController::AuthorizationService do
  describe '#perform' do
    subject(:perform) { described_class.new(controller).perform }

    let(:controller) { instance_double(ApplicationController) }

    context 'when a user exists' do
      let!(:user) { create(:user, display_name: 'Jane Doe', email: 'jane.doe@gmail.com', uid: 'jane.doe@gmail.com') }

      before do
        allow(controller).to receive(:current_user=)
      end

      it 'sets the current user' do
        perform
        expect(controller).to have_received(:current_user=).with(user)
      end

      it 'returns nil' do
        expect(perform).to be nil
      end
    end

    context 'when there are no users' do
      it 'returns a Service::InternalServerErrorResult' do
        expect(perform).to be_a(Service::InternalServerErrorResult)
      end
    end
  end
end
