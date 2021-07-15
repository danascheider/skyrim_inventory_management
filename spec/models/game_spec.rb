# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:user) { create(:user) }

  describe 'validations' do
    describe 'name' do
      describe 'uniqueness' do
        let(:game) { build(:game, name: 'My Game', user: user) }

        it 'is unique per user' do
          create(:game, name: 'My Game', user: user)
          expect(game).not_to be_valid
        end

        it "doesn't have to be unique across all users" do
          create(:game, name: 'My Game')
          expect(game).to be_valid
        end
      end

      describe 'format' do
        it 'only contains alphanumeric characters, spaces, commas, and apostrophes' do
          game = build(:game, name: "#\t&\n^")
          expect(game).not_to be_valid
        end
      end
    end
  end

  describe 'name transformations' do
    context 'when the user has set a name' do
      subject(:name) { user.games.create!(name: 'Skyrim, Baby').name }

      it 'keeps the name the user has set' do
        expect(name).to eq 'Skyrim, Baby'
      end
    end

    context 'wheen the name has a default value' do
      subject(:name) { user.games.create!.name }

      before do
        # create games for a different user to makee sure the name of the
        # game isn't affected by them
        create_list(:game, 2, name: nil)
        create_list(:game, 2, name: nil, user: user)
      end

      it 'sets the name based on how many default-named games the user has' do
        expect(name).to eq 'My Game 3'
      end
    end

    context 'when the request includes sloppy data' do
      it 'uses intelligent title capitalisation' do
        game = create(:game, name: 'loRd oF tHe rIngS')
        expect(game.name).to eq 'Lord of the Rings'
      end

      it 'strips trailing and leading whitespace' do
        game = create(:game, name: "  lord oF tHE rIngS\n\t")
        expect(game.name).to eq 'Lord of the Rings'
      end
    end
  end

  describe '#aggregate_shopping_list' do
    subject(:aggregate_shopping_list) { game.aggregate_shopping_list }

    let(:game) { create(:game) }
    let!(:aggregate_list) { create(:aggregate_shopping_list, game: game) }

    before do
      create_list(:shopping_list, 2, game: game)
    end

    it "returns that game's aggregate shopping list" do
      expect(aggregate_shopping_list).to eq aggregate_list
    end
  end
end
