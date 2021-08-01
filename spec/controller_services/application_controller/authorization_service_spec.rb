# frozen_string_literal: true

require 'rails_helper'
require 'service/unauthorized_result'
require 'service/internal_server_error_result'

RSpec.describe ApplicationController::AuthorizationService do
  describe '#perform' do
    subject(:perform) { described_class.new(controller, 'xxxxxxxxxxxxxx').perform }

    let(:controller) { instance_double(ApplicationController) }
    let(:validator)  { instance_double(GoogleIDToken::Validator, check: payload) }

    before do
      allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
    end

    context 'when the token is valid' do
      let(:user) { create(:user, name: 'Jane Doe', email: 'jane.doe@gmail.com', uid: 'jane.doe@gmail.com') }
      let(:payload) do
        {
          'exp'     => (Time.zone.now + 1.day).to_i,
          'email'   => 'jane.doe@gmail.com',
          'name'    => 'Jane Doe',
          'picture' => nil,
        }
      end

      before do
        allow(User).to receive(:create_or_update_for_google).and_return(user)
        allow(controller).to receive(:current_user=)
      end

      it 'creates or updates the user' do
        perform
        expect(User).to have_received(:create_or_update_for_google).with(payload)
      end

      it 'sets the current user' do
        perform
        expect(controller).to have_received(:current_user=).with(user)
      end

      it 'returns nil' do
        expect(perform).to be nil
      end
    end

    context 'when the token is invalid' do
      let(:payload) do
        {
          'exp'     => (Time.zone.now - 1.day).to_i,
          'email'   => 'jane.doe@gmail.com',
          'name'    => 'Jane Doe',
          'picture' => nil,
        }
      end

      before do
        allow(controller).to receive(:current_user=)
      end

      it 'does not set the current user' do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end
    end

    context 'when validation raises a GoogleIDToken::ValidationError' do
      let(:payload) { {} }

      before do
        allow(validator).to receive(:check).and_raise(GoogleIDToken::ValidationError)
        allow(Rails.logger).to receive(:error)
        allow(controller).to receive(:current_user=)
      end

      it 'does not set the current user' do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'logs the error message' do
        perform
        expect(Rails.logger).to have_received(:error).with('Token validation failed -- GoogleIDToken::ValidationError')
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end
    end

    context 'when validation raises a GoogleIDToken::CertificateError' do
      let(:payload) { {} }

      before do
        allow(validator).to receive(:check).and_raise(GoogleIDToken::CertificateError)
        allow(Rails.logger).to receive(:error)
        allow(controller).to receive(:current_user=)
      end

      it 'does not set the current user' do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'logs the error message' do
        perform
        expect(Rails.logger).to have_received(:error).with('Problem with OAuth certificate -- GoogleIDToken::CertificateError')
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end
    end

    context 'when something unexpected goes wrong' do
      let(:payload) { {} }

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_raise(StandardError, 'Something went horribly wrong')
      end

      it 'returns a Service::InternalServerErrorResult' do
        expect(perform).to be_a(Service::InternalServerErrorResult)
      end

      it 'sets the errors' do
        expect(perform.errors).to eq(['Something went horribly wrong'])
      end
    end
  end
end
