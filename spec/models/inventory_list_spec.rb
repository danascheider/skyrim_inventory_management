# frozen_string_literal: true

require 'rails_helper'

RSpec.describe InventoryList, type: :model do
  describe 'scopes' do
    describe '::index_order' do
      subject(:index_order) { game.inventory_lists.index_order.to_a }

      let!(:game)            { create(:game) }
      let!(:aggregate_list)  { create(:aggregate_inventory_list, game: game) }
      let!(:inventory_list1) { create(:inventory_list, game: game) }
      let!(:inventory_list2) { create(:inventory_list, game: game) }
      let!(:inventory_list3) { create(:inventory_list, game: game) }

      before do
        inventory_list2.update!(title: 'Windstad Manor')
      end

      it 'is in reverse chronological order by updated_at with aggregate before anything' do
        expect(index_order).to eq([aggregate_list, inventory_list2, inventory_list3, inventory_list1])
      end
    end

    # Aggregatable
    describe '::includes_items' do
      subject(:includes_items) { game.inventory_lists.includes_items }

      let!(:game)           { create(:game) }
      let!(:aggregate_list) { create(:aggregate_inventory_list, game: game) }
      let!(:lists)          { create_list(:inventory_list_with_list_items, 2, game: game) }

      it 'includes the inventory list items' do
        expect(includes_items).to eq game.inventory_lists.includes(:list_items)
      end
    end

    # Aggregatable
    describe '::aggregates_first' do
      subject(:aggregate_first) { game.inventory_lists.aggregate_first.to_a }

      let!(:game)           { create(:game) }
      let!(:aggregate_list) { create(:aggregate_inventory_list, game: game) }
      let!(:inventory_list) { create(:inventory_list, game: game) }

      it 'returns the inventory lists with the aggregate list first' do
        expect(aggregate_first).to eq([aggregate_list, inventory_list])
      end
    end

    describe '::belongs_to_user' do
      let(:user)   { create(:user) }
      let!(:game1) { create(:game_with_inventory_lists, user: user) }
      let!(:game2) { create(:game_with_inventory_lists, user: user) }
      let!(:game3) { create(:game_with_inventory_lists, user: user) }

      it "returns all the inventory lists from all the user's games" do
        # These are going to be rearranged in the output since game.shopping_lists
        # comes back aggregate list first and the scope will return them in descending
        # updated_at order. There was no easy programmatic way to rearrange them so
        # I just have to pull them all out and reorder them in the expectation.
        agg_list1, game1_list1, game1_list2 = game1.inventory_lists.to_a
        agg_list2, game2_list1, game2_list2 = game2.inventory_lists.to_a
        agg_list3, game3_list1, game3_list2 = game3.inventory_lists.to_a

        expect(described_class.belonging_to_user(user).to_a).to eq([
                                                                     game3_list1,
                                                                     game3_list2,
                                                                     agg_list3,
                                                                     game2_list1,
                                                                     game2_list2,
                                                                     agg_list2,
                                                                     game1_list1,
                                                                     game1_list2,
                                                                     agg_list1,
                                                                   ])
      end
    end
  end

  describe 'validations' do
    # Aggregatable
    describe 'aggregate lists' do
      context 'when there are no aggregate lists' do
        let(:game)           { create(:game) }
        let(:aggregate_list) { build(:aggregate_shopping_list, game: game) }

        it 'is valid' do
          expect(aggregate_list).to be_valid
        end
      end

      context 'when there is an existing aggregate list belonging to another user' do
        let(:game)           { create(:game) }
        let(:aggregate_list) { build(:aggregate_shopping_list, game: game) }

        before do
          create(:aggregate_shopping_list)
        end

        it 'is valid' do
          expect(aggregate_list).to be_valid
        end
      end

      context 'when the user already has an aggregate list' do
        let(:game)           { create(:game) }
        let(:aggregate_list) { build(:aggregate_shopping_list, game: game) }

        before do
          create(:aggregate_shopping_list, game: game)
        end

        it 'is invalid', :aggregate_failures do
          expect(aggregate_list).not_to be_valid
          expect(aggregate_list.errors[:aggregate]).to eq ['can only be one list per game']
        end
      end
    end

    describe 'title validations' do
      # Aggregatable
      context 'when the title is "all items"' do
        it 'is allowed for an aggregate list' do
          list = build(:aggregate_inventory_list, title: 'All Items')
          expect(list).to be_valid
        end

        it 'is not allowed for a regular list', :aggregate_failures do
          list = build(:inventory_list, title: 'all items')
          expect(list).not_to be_valid
          expect(list.errors[:title]).to eq(['cannot be "All Items"'])
        end
      end

      context 'when the title contains "all items" as well as other characters' do
        it 'is valid' do
          list = build(:inventory_list, title: 'aLL iTems the seQUel')
          expect(list).to be_valid
        end
      end

      describe 'allowed characters' do
        it 'allows alphanumeric characters, spaces, commas, apostrophes, and hyphens' do
          list = build(:inventory_list, title: "aB 61 ,'-")
          expect(list).to be_valid
        end

        it "doesn't allow newlines", :aggregate_failures do
          list = build(:inventory_list, title: "My\nList 1  ")
          expect(list).not_to be_valid
          expect(list.errors[:title]).to eq(["can only contain alphanumeric characters, spaces, commas (,), hyphens (-), and apostrophes (')"])
        end

        it "doesn't allow other non-space whitespace", :aggregate_failures do
          list = build(:inventory_list, title: "My\tList 1")
          expect(list).not_to be_valid
          expect(list.errors[:title]).to eq(["can only contain alphanumeric characters, spaces, commas (,), hyphens (-), and apostrophes (')"])
        end

        it "doesn't allow special characters", :aggregate_failures do
          list = build(:inventory_list, title: 'My^List&1')
          expect(list).not_to be_valid
          expect(list.errors[:title]).to eq(["can only contain alphanumeric characters, spaces, commas (,), hyphens (-), and apostrophes (')"])
        end

        # Leading and trailing whitespace characters will be stripped anyway so no need to validate
        it 'ignores leading or trailing whitespace characters' do
          list = build(:inventory_list, title: "My List 1\n\t")
          expect(list).to be_valid
        end
      end
    end
  end

  # Aggregatable
  describe '#aggregate_list' do
    let!(:aggregate_list) { create(:aggregate_inventory_list) }
    let(:inventory_list) { create(:inventory_list, game: aggregate_list.game) }

    it 'returns the aggregate list that tracks it' do
      expect(inventory_list.aggregate_list).to eq aggregate_list
    end
  end

  describe 'title transformations' do
    describe 'setting a default title' do
      let(:game) { create(:game) }

      # I don't use FactoryBot to create the models in the subject blocks because
      # it sets values for certain attributes and I don't want those to get in the way.
      context 'when the list is not an aggregate list' do
        context 'when the user has set a title' do
          subject(:title) { game.inventory_lists.create!(title: 'Heljarchen Hall').title }

          let(:game) { create(:game) }

          it 'keeps the title the user has set' do
            expect(title).to eq 'Heljarchen Hall'
          end
        end

        context 'when the user has not set a title' do
          subject(:title) { game.inventory_lists.create!.title }

          context 'when the game has all default-titled regular lists' do
            before do
              # Create lists for a different game to make sure the name of this game's
              # list isn't affected by them
              create_list(:inventory_list, 2, title: nil)
              create_list(:inventory_list, 2, title: nil, game: game)
            end

            it 'sets the title based on the highest numbered default title' do
              expect(title).to eq 'My List 3'
            end
          end

          context 'when the game has differently titled regular lists' do
            before do
              create(:inventory_list, title: nil)
              create(:inventory_list, game: game, title: nil)
              create(:inventory_list, game: game, title: 'Windstad Manor')
              create(:inventory_list, game: game, title: nil)
            end

            it 'uses the next highest number in default lists' do
              expect(title).to eq 'My List 3'
            end
          end

          context 'when the game has an inventory list with a similar title' do
            before do
              create(:inventory_list, game: game, title: 'This List is Called My List 4')
              create_list(:inventory_list, 2, game: game, title: nil)
            end

            it 'sets the title based on the highest numbered list called "My List N"' do
              expect(title).to eq 'My List 3'
            end
          end

          context 'when there is an inventory list called "My List <non-integer>"' do
            before do
              create(:inventory_list, game: game, title: 'My List Is the Best List')
              create_list(:inventory_list, 2, game: game, title: nil)
            end

            it 'sets the title based on the highest numbered list called "My List N"' do
              expect(title).to eq 'My List 3'
            end
          end

          context 'when there is an inventory list called "My List <negative integer>"' do
            before do
              create(:inventory_list, game: game, title: 'My List -4')
            end

            it 'ignores the list title with the negative integer' do
              expect(title).to eq 'My List 1'
            end
          end
        end
      end

      # Aggregatable
      context 'when the list is an aggregate list' do
        context 'when the user has set a title' do
          subject(:title) { game.inventory_lists.create!(aggregate: true, title: 'Something other than all items').title }

          it 'overrides the title the user has set' do
            expect(title).to eq 'All Items'
          end
        end

        context 'when the user has not set a title' do
          subject(:title) { game.inventory_lists.create!(aggregate: true).title }

          it 'sets the title to "All Items"' do
            expect(title).to eq 'All Items'
          end
        end
      end
    end

    context 'when the request includes sloppy data' do
      it 'uses intelligent title capitalisation' do
        list = create(:inventory_list, title: 'lord oF thE rIngs')
        expect(list.title).to eq 'Lord of the Rings'
      end

      it 'strips trailing and leading whitespace' do
        list = create(:inventory_list, title: " lord oF tHe RiNgs\n")
        expect(list.title).to eq 'Lord of the Rings'
      end
    end
  end

  describe 'associations' do
    subject(:items) { inventory_list.list_items }

    let!(:aggregate_list) { create(:aggregate_inventory_list) }
    let(:inventory_list)  { create(:inventory_list, game: aggregate_list.game, aggregate_list_id: aggregate_list.id) }
    let!(:item1)          { create(:inventory_list_item, list: inventory_list) }
    let!(:item2)          { create(:inventory_list_item, list: inventory_list) }
    let!(:item3)          { create(:inventory_list_item, list: inventory_list) }

    before do
      item2.update!(quantity: 2)
    end

    it 'keeps child models in descending order of updated_at' do
      expect(inventory_list.list_items.to_a).to eq([item2, item3, item1])
    end
  end

  describe 'Aggregatable methods' do
    describe '#user' do
      let(:inventory_list) { create(:inventory_list) }

      it 'delegates to the game' do
        expect(inventory_list.user).to eq(inventory_list.game.user)
      end
    end
  end
end