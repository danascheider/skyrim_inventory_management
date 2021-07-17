# frozen_string_literal: true

require 'rails_helper'
require 'service/no_content_result'
require 'service/internal_server_error_result'

RSpec.describe GamesController::DestroyService do
  describe '#perform' do
    subject(:perform) { described_class.new(user, game.id).perform }

    context 'when all goes well' do
      let!(:game) { create(:game) }
      let!(:user) { game.user }

      it 'destroys the game' do
        expect { perform }
          .to change(user.games, :count).from(1).to(0)
      end

      it 'returns a Service::NoContentResult' do
        expect(perform).to be_a(Service::NoContentResult)
      end

      it "doesn't return any data", :aggregate_failures do
        expect(perform.resource).to be_blank
        expect(perform.errors).to be_blank
      end
    end

    context 'when the game does not exist' do
      let(:game) { double(id: 43598) }
      let(:user) { create(:user) }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't set data", :aggregate_failures do
        expect(perform.resource).to be_blank
        expect(perform.errors).to be_blank
      end
    end

    context 'when the game does not belong to the user' do
      let(:game) { create(:game) }
      let(:user) { create(:user) }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it "doesn't set data", :aggregate_failures do
        expect(perform.resource).to be_blank
        expect(perform.errors).to be_blank
      end
    end

    context 'when something unexpected goes wrong' do
      let!(:game) { create(:game) }
      let!(:user) { game.user }

      before do
        allow_any_instance_of(Game).to receive(:destroy!).and_raise(StandardError, 'Something went horribly wrong')
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
