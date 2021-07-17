# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Verifications', type: :request do
  subject(:verify_token) { get '/auth/verify_token', headers: { 'Authorization' => "Bearer #{token}" } }

  let(:token) { 'xxxxxxxx' }
  let(:validator) { instance_double(GoogleIDToken::Validator, check: validator_data) }

  around do |example|
    Timecop.freeze(Time.zone.now) { example.run }
  end

  context 'when the token is valid and verified' do
    let(:validator_data) do
      {
        'exp'   => (Time.zone.now + 1.year).to_i,
        'email' => 'foobar@gmail.com',
        'name'  => 'Foo Bar',
      }
    end

    before do
      allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
    end

    it 'returns status 204' do
      verify_token
      expect(response.status).to eq 204
    end

    context 'when no existing user matches' do
      let(:expected_user_attributes) do
        {
          'uid'       => 'foobar@gmail.com',
          'email'     => 'foobar@gmail.com',
          'name'      => 'Foo Bar',
          'image_url' => nil,
        }
      end

      it 'creates a new user with the data from the payload', :aggregate_failures do
        expect { verify_token }
          .to change(User, :count).from(0).to(1)
        expect(User.last.attributes).to include(**expected_user_attributes.merge({ 'id' => User.last.id }))
      end
    end

    context 'when an existing user matches' do
      let!(:user) { create(:user, email: 'foobar@gmail.com', uid: 'foobar@gmail.com', name: 'Jane Doe') }

      let(:expected_user_attributes) do
        {
          'id'        => user.id,
          'uid'       => 'foobar@gmail.com',
          'email'     => 'foobar@gmail.com',
          'name'      => 'Foo Bar',
          'image_url' => nil,
        }
      end

      it "doesn't create a new user" do
        expect { verify_token }
          .not_to change(User, :count)
      end

      it 'updates the attributes' do
        verify_token
        expect(user.reload.attributes).to include(**expected_user_attributes)
      end
    end
  end

  context 'when the token is not authorised' do
    let(:validator_data) do
      # I'm not sure this is a realistic payload - just something we
      # don't expect
      { 'error' => 'something went wrong' }
    end

    it 'returns 401' do
      verify_token
      expect(response.status).to eq 401
    end
  end

  context 'when the token does not match the given client ID' do
    let(:validator_data) { {} }

    it 'returns 401' do
      allow(validator).to receive(:check).and_raise(GoogleIDToken::AudienceMismatchError)
      verify_token
      expect(response.status).to eq 401
    end
  end
end
