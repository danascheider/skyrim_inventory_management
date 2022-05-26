# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '::create_or_update_for_google' do
    subject(:create_or_update) { described_class.create_or_update_for_google(payload) }

    let(:payload) do
      {
        'exp'     => (Time.zone.now + 2.days).to_i,
        'email'   => 'jane.doe@gmail.com',
        'name'    => 'Jane Doe',
        'picture' => 'https://example.com/user_images/89',
      }
    end

    context 'when a user with that email as uid does not exist' do
      it 'creates a user' do
        expect { create_or_update }
          .to change(described_class, :count).from(0).to(1)
      end

      it 'sets the attributes' do
        create_or_update
        expect(described_class.last.attributes).to include(
                                                     'uid'       => 'jane.doe@gmail.com',
                                                     'email'     => 'jane.doe@gmail.com',
                                                     'name'      => 'Jane Doe',
                                                     'image_url' => 'https://example.com/user_images/89',
                                                   )
      end
    end

    context 'when there is already a user with that email as uid' do
      let!(:user) { create(:user, uid: 'jane.doe@gmail.com', email: 'jane.doe@gmail.com', name: 'Jane Doe', image_url: nil) }

      it 'does not create a new user' do
        expect { create_or_update }
          .not_to change(described_class, :count)
      end

      it 'updates the attributes' do
        create_or_update
        expect(user.reload.image_url).to eq 'https://example.com/user_images/89'
      end
    end
  end

  describe '#shopping_lists' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    let(:game1) { create(:game, user: user1) }
    let(:game2) { create(:game, user: user1) }
    let(:game3) { create(:game_with_shopping_lists, user: user2) }

    let!(:shopping_list1) { create(:aggregate_shopping_list, game: game1) }
    let!(:shopping_list2) { create(:shopping_list, game: game1) }
    let!(:shopping_list3) { create(:aggregate_shopping_list, game: game2) }
    let!(:shopping_list4) { create(:shopping_list, game: game2) }

    it "returns all the shopping lists for the user's games" do
      expect(user1.shopping_lists).to eq([
                                           shopping_list4,
                                           shopping_list3,
                                           shopping_list2,
                                           shopping_list1,
                                         ])
    end
  end

  describe '#inventory_lists' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    let(:game1) { create(:game, user: user1) }
    let(:game2) { create(:game, user: user1) }
    let(:game3) { create(:game_with_inventory_lists, user: user2) }

    let!(:inventory_list1) { create(:aggregate_inventory_list, game: game1) }
    let!(:inventory_list2) { create(:inventory_list, game: game1) }
    let!(:inventory_list3) { create(:aggregate_inventory_list, game: game2) }
    let!(:inventory_list4) { create(:inventory_list, game: game2) }

    it "returns all the inventory lists for the user's games" do
      expect(user1.inventory_lists).to eq([
                                            inventory_list4,
                                            inventory_list3,
                                            inventory_list2,
                                            inventory_list1,
                                          ])
    end
  end

  describe '#shopping_list_items' do
    subject(:shopping_list_items) { user1.shopping_list_items.to_a.sort }

    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    let(:game1) { create(:game_with_shopping_lists_and_items, user: user1) }
    let(:game2) { create(:game_with_shopping_lists_and_items, user: user1) }
    let(:game3) { create(:game_with_shopping_lists_and_items, user: user2) }

    it 'includes the shopping list items belonging to that user' do
      user1_list_items = game1.shopping_list_items.to_a + game2.shopping_list_items.to_a
      user1_list_items.sort!

      expect(shopping_list_items).to eq user1_list_items
    end
  end

  describe '#inventory_items' do
    subject(:inventory_items) { user1.inventory_items.to_a.sort }

    let(:user1) { create(:user) }
    let(:user2) { create(:user) }

    let(:game1) { create(:game_with_inventory_lists_and_items, user: user1) }
    let(:game2) { create(:game_with_inventory_lists_and_items, user: user1) }
    let(:game3) { create(:game_with_inventory_lists_and_items, user: user2) }

    it 'includes the inventory list items belonging to that user' do
      user1_list_items = game1.inventory_items.to_a + game2.inventory_items.to_a
      user1_list_items.sort!

      expect(inventory_items).to eq user1_list_items
    end
  end
end
