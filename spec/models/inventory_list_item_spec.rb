# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InventoryListItem, type: :model do
  let!(:game) { create(:game) }

  describe 'delegation' do
    let(:inventory_list) { create(:inventory_list, game: game) }
    let(:list_item)      { create(:inventory_list_item, list: inventory_list) }

    before do
      create(:aggregate_inventory_list, game: game)
    end

    describe '#game' do
      it 'returns the game its InventoryList belongs to' do
        expect(list_item.game).to eq(game)
      end
    end

    describe '#user' do
      it 'returns the user its game belongs to' do
        expect(list_item.user).to eq(game.user)
      end
    end
  end

  describe 'scopes' do
    describe '::index_order' do
      let!(:aggregate_list) { create(:aggregate_shopping_list) }

      let!(:list_item1) { create(:shopping_list_item, list: list) }
      let!(:list_item2) { create(:shopping_list_item, list: list) }
      let!(:list_item3) { create(:shopping_list_item, list: list) }

      let(:list) { create(:shopping_list, game: aggregate_list.game) }

      before do
        list_item2.update!(quantity: 3)
      end

      it 'returns the list items in descending chronological order by updated_at' do
        expect(list.list_items.index_order.to_a).to eq([list_item2, list_item3, list_item1])
      end
    end

    describe '::belonging_to_game' do
      let!(:list1) { create(:inventory_list_with_list_items, game: game) }
      let!(:list2) { create(:inventory_list_with_list_items, game: game) }
      let!(:list3) { create(:inventory_list_with_list_items, game: game) }

      it 'returns all list items from all the lists for the given game' do
        # We don't actually care what order these are in since we currently only use this
        # scope to determine whether a given item belongs to a particular game
        items = [
                  list1.list_items.to_a,
                  list2.list_items.to_a,
                  list3.list_items.to_a,
                ].flatten!

        expect(described_class.belonging_to_game(game).to_a.sort).to eq(items.sort)
      end
    end

    describe '::belonging_to_user' do
      # We're going to sort these because we don't actually care what order they're in
      subject(:belonging_to_user) { described_class.belonging_to_user(user).to_a.sort }

      let(:user) { game.user }

      before do
        create(:inventory_list_with_list_items, game: game)
        create(:game_with_inventory_lists_and_items, user: user)
        create(:game_with_inventory_lists_and_items, user: user)
        create(:inventory_list_with_list_items) # one from a different user
      end

      it 'returns all the list items belonging to the user', :aggregate_failures do
        all_items = []
        user.inventory_lists.each {|list| all_items << list.list_items }
        all_items.flatten!.sort!

        expect(belonging_to_user).to eq all_items
      end
    end
  end

  describe '::combine_or_create!' do
    context 'when there is an existing item on the same list with the same (case-insensitive) description' do
      subject(:combine_or_create) { described_class.combine_or_create!(description: 'existing item', quantity: 1, list: inventory_list, notes: 'notes 2') }

      let(:aggregate_list)  { create(:aggregate_inventory_list) }
      let!(:inventory_list) { create(:inventory_list, game: aggregate_list.game) }
      let!(:existing_item)  { create(:inventory_list_item, description: 'ExIsTiNg ItEm', quantity: 2, list: inventory_list, notes: 'notes 1') }

      it "doesn't create a new list item" do
        expect { combine_or_create }
          .not_to change(inventory_list.list_items, :count)
      end

      it 'adds the quantity to the existing item' do
        combine_or_create
        expect(existing_item.reload.quantity).to eq 3
      end

      it 'concatenates the notes for the two items' do
        combine_or_create
        expect(existing_item.reload.notes).to eq 'notes 1 -- notes 2'
      end

      context "when the new item doesn't have a unit_weight" do
        it 'leaves the unit_weight as-is' do
          combine_or_create
          expect(existing_item.reload.unit_weight).to eq 0.3
        end
      end

      context 'when the new item has a unit_weight' do
        subject(:combine_or_create) { described_class.combine_or_create!(description: 'existing item', quantity: 1, list: inventory_list, unit_weight: 0.2, notes: 'notes 2') }

        it 'uses the unit_weight from the new item' do
          combine_or_create
          expect(existing_item.reload.unit_weight).to eq 0.2
        end
      end
    end
  end

  describe '::combine_or_new' do
    context 'when there is an existing item on the same list with the same (case-insensitive) description' do
      subject(:combine_or_new) { described_class.combine_or_new(description: 'existing item', quantity: 1, list: inventory_list, notes: 'notes 2') }

      let(:aggregate_list) { create(:aggregate_inventory_list) }
      let!(:inventory_list) { create(:inventory_list, game: aggregate_list.game) }
      let!(:existing_item)  { create(:inventory_list_item, description: 'ExIsTiNg ItEm', quantity: 2, list: inventory_list, notes: 'notes 1') }

      before do
        allow(described_class).to receive(:new)
      end

      it "doesn't instantiate a new item" do
        combine_or_new
        expect(described_class).not_to have_received(:new)
      end

      it 'returns the existing item with the quantity updated', :aggregate_failures do
        expect(combine_or_new).to eq existing_item
        expect(combine_or_new.quantity).to eq 3
      end

      it 'concatenates the notes for the two items', :aggregate_failures do
        expect(combine_or_new).to eq existing_item
        expect(combine_or_new.notes).to eq 'notes 1 -- notes 2'
      end

      context "when the new item doesn't have a unit_weight" do
        it 'leaves the unit_weight as-is' do
          expect(combine_or_new.unit_weight).to eq 0.3
        end
      end

      context 'when the new item has a unit_weight' do
        subject(:combine_or_new) { described_class.combine_or_new(description: 'existing item', quantity: 1, unit_weight: 0.2, list: inventory_list, notes: 'notes 2') }

        it 'updates the unit_weight' do
          expect(combine_or_new.unit_weight).to eq 0.2
        end
      end
    end

    context 'when there is not an existing item on the same list with that description' do
      subject(:combine_or_create) { described_class.combine_or_create!(description: 'new item', quantity: 1, list: inventory_list) }

      let(:aggregate_list) { create(:aggregate_inventory_list) }
      let!(:inventory_list) { create(:inventory_list, game: aggregate_list.game) }

      it 'creates a new item on the list' do
        expect { combine_or_create }
          .to change(inventory_list.list_items, :count).by(1)
      end
    end
  end

  describe '#update!' do
    let(:aggregate_list) { create(:aggregate_inventory_list) }
    let(:inventory_list) { create(:inventory_list, game: aggregate_list.game) }
    let!(:list_item)     { create(:inventory_list_item, quantity: 1, list: inventory_list) }

    context 'when updating quantity' do
      subject(:update_item) { list_item.update!(quantity: 4) }

      it 'updates as normal' do
        expect { update_item }
          .to change(list_item, :quantity).from(1).to(4)
      end
    end

    context 'when updating description' do
      subject(:update_item) { list_item.update!(description: 'Something else') }

      it 'raises an error' do
        expect { update_item }
          .to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'notes field' do
    it 'cleans up leading and trailing dashes or whitespace' do
      inventory_list_item = build(:inventory_list_item, notes: ' -- some notes --')
      expect { inventory_list_item.save }
        .to change(inventory_list_item, :notes).to('some notes')
    end

    it 'saves as nil if it consists only of dashes' do
      inventory_list_item = build(:inventory_list_item, notes: '--')
      expect { inventory_list_item.save }
        .to change(inventory_list_item, :notes).to(nil)
    end
  end
end
