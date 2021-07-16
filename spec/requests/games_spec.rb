# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Games', type: :request do
  let(:headers) do
    {
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer xxxxxxx'
    }
  end

  describe 'GET /games' do
    subject(:get_games) { get '/games', headers: { 'Authorization' => 'Bearer xxxxxxx' } }

    context 'when authenticated' do
      let(:user) { create(:user) }
      let(:validation_data) do
        {
          'exp' => (Time.now + 1.year).to_i,
          'email' => user.email,
          'name' => user.name
        }
      end

      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      context 'when the user has no games' do
        it 'returns status 200' do
          get_games
          expect(response.status).to eq 200
        end

        it 'returns an empty array' do
          get_games
          expect(response.body).to eq('[]')
        end
      end

      context 'when the user has games' do
        before do
          create_list(:game, 2, user: user)
          create(:game) # for another user, shouldn't be returned
        end

        it 'returns status 200' do
          get_games
          expect(response.status).to eq 200
        end

        it "returns the authenticated user's games" do
          get_games
          expect(response.body).to eq(user.games.to_json)
        end
      end

      context 'when something unexpected goes wrong' do
        before do
          allow_any_instance_of(User).to receive(:games).and_raise(StandardError, 'Something went horribly wrong')
        end

        it 'returns status 500' do
          get_games
          expect(response.status).to eq 500
        end

        it 'returns the error message' do
          get_games
          expect(response.body).to eq({ errors: ['Something went horribly wrong'] }.to_json)
        end
      end
    end

    context 'when unauthenticated' do
      it 'returns status 401' do
        get_games
        expect(response.status).to eq 401
      end

      it 'returns an error message' do
        get_games
        expect(response.body).to eq({ errors: ['Google OAuth token validation failed'] }.to_json)
      end
    end
  end

  describe 'POST /games' do
    subject(:create_game) { post '/games', headers: headers, params: params.to_json }

    context 'when authenticated' do
      let(:user) { create(:user) }
      let(:validation_data) do
        {
          'exp' => (Time.now + 1.year).to_i,
          'email' => user.email,
          'name' => user.name
        }
      end

      let(:validator) { instance_double(GoogleIDToken::Validator, check: validation_data) }

      before do
        allow(GoogleIDToken::Validator).to receive(:new).and_return(validator)
      end

      context 'when all goes well' do
        let(:params) { { game: { name: 'My Game' } } }

        it 'creates a game' do
          expect { create_game }.to change(user.games, :count).by(1)
        end

        it 'returns status 201' do
          create_game
          expect(response.status).to eq 201
        end

        it 'returns the game' do
          create_game
          expect(response.body).to eq user.games.last.to_json
        end
      end

      context 'when the params are invalid' do
        let(:params) { { game: { name: '@#*!)&' } } }

        it "doesn't create a game" do
          expect { create_game }.not_to change(user.games, :count)
        end

        it 'returns status 422' do
          create_game
          expect(response.status).to eq 422
        end

        it 'returns the errors in the response body' do
          create_game
          expect(response.body).to eq({ errors: ["Name can only contain alphanumeric characters, spaces, commas (,), and apostrophes (')"] }.to_json)
        end
      end

      context 'when something unexpected goes wrong' do
        let(:params) { { name: 'My Game' } }

        before do
          allow_any_instance_of(Game).to receive(:save).and_raise(StandardError, 'Something has gone horribly wrong')
        end

        it 'returns a 500 status' do
          create_game
          expect(response.status).to eq 500
        end

        it 'returns the error message' do
          create_game
          expect(response.body).to eq({ errors: ['Something has gone horribly wrong'] }.to_json)
        end
      end
    end

    context 'when unauthenticated' do
      let(:params) { { game: { name: 'My Game' } } }

      it 'returns status 401' do
        create_game
        expect(response.status).to eq 401
      end

      it 'returns an error message' do
        create_game
        expect(response.body).to eq({ errors: ['Google OAuth token validation failed'] }.to_json)
      end
    end
  end
end
