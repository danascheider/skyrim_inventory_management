# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShoppingList, type: :model do
  describe 'scopes' do
    describe '::index_order' do
      subject(:index_order) { user.shopping_lists.index_order.to_a }

      let!(:user) { create(:user) }
      let!(:master_list) { create(:master_shopping_list, user: user) }
      let!(:shopping_list1) { create(:shopping_list, user: user) }
      let!(:shopping_list2) { create(:shopping_list, user: user) }
      let!(:shopping_list3) { create(:shopping_list, user: user) }

      before do
        shopping_list2.update!(title: 'Windstad Manor')
      end

      it 'is in reverse chronological order by updated_at with master before anything' do
        expect(index_order).to eq([master_list, shopping_list2, shopping_list3, shopping_list1])
      end
    end

    # MasterListable
    describe '::includes_items' do
      subject(:includes_items) { user.shopping_lists.includes_items }

      let!(:user) { create(:user) }
      let!(:master_list) { create(:master_shopping_list, user: user) }
      let!(:lists) { create_list(:shopping_list_with_list_items, 2, user: user) }

      it 'includes the shopping list items' do
        expect(includes_items).to eq user.shopping_lists.includes(:list_items)
      end
    end

    # MasterListable
    describe '::master_first' do
      subject(:master_first) { user.shopping_lists.master_first.to_a }

      let!(:user) { create(:user) }
      let!(:master_list) { create(:master_shopping_list, user: user) }
      let!(:shopping_list) { create(:shopping_list, user: user) }

      it 'returns the shopping lists with the master list first' do
        expect(master_first).to eq([master_list, shopping_list])
      end
    end
  end

  describe 'validations' do
    # MasterListable
    describe 'master lists' do
      context 'when there are no master lists' do
        let(:user) { create(:user) }
        let(:master_list) { build(:master_shopping_list, user: user) }

        it 'is valid' do
          expect(master_list).to be_valid
        end
      end

      context 'when there is an existing master list belonging to another user' do
        let(:user) { create(:user) }
        let(:master_list) { build(:master_shopping_list, user: user) }

        before do
          create(:master_shopping_list)
        end

        it 'is valid' do
          expect(master_list).to be_valid
        end
      end

      context 'when the user already has a master list' do
        let(:user) { create(:user) }
        let(:master_list) { build(:master_shopping_list, user: user) }

        before do
          create(:master_shopping_list, user: user)
        end

        it 'is invalid', :aggregate_failures do
          expect(master_list).not_to be_valid
          expect(master_list.errors[:master]).to eq ['can only be one list per user']
        end
      end
    end

    describe 'title validations' do
      # MasterListable
      context 'when the title is "master"' do
        it 'is allowed for a master list' do
          list = build(:master_shopping_list, title: 'Master')
          expect(list).to be_valid
        end

        it 'is not allowed for a regular list', :aggregate_failures do
          list = build(:shopping_list, title: 'master')
          expect(list).not_to be_valid
          expect(list.errors[:title]).to eq(['cannot be "Master"'])
        end
      end

      context 'when the title contains "master" as well as other characters' do
        it 'is valid' do
          list = build(:shopping_list, title: 'mASter of the house')
          expect(list).to be_valid
        end
      end

      context 'allowed characters' do
        it 'allows alphanumeric characters and spaces' do
          list = build(:shopping_list, title: 'My List 1  ')
          expect(list).to be_valid
        end

        it "doesn't allow newlines", :aggregate_failures do
          list = build(:shopping_list, title: "My\nList 1  ")
          expect(list).not_to be_valid
          expect(list.errors[:title]).to eq(['can only include alphanumeric characters and spaces'])
        end

        it "doesn't allow other non-space whitespace", :aggregate_failures do
          list = build(:shopping_list, title: "My\tList 1")
          expect(list).not_to be_valid
          expect(list.errors[:title]).to eq(['can only include alphanumeric characters and spaces'])
        end

        it "doesn't allow special characters", :aggregate_failures do
          list = build(:shopping_list, title: 'My^List&1')
          expect(list).not_to be_valid
          expect(list.errors[:title]).to eq(['can only include alphanumeric characters and spaces'])
        end

        # Leading and trailing whitespace characters will be stripped anyway so no need to validate
        it 'ignores leading or trailing whitespace characters' do
          list = build(:shopping_list, title: "My List 1\n\t")
          expect(list).to be_valid
        end
      end
    end
  end

  # MasterListable
  describe '#master_list' do
    let!(:master_list) { create(:master_shopping_list) }
    let(:shopping_list) { create(:shopping_list, user: master_list.user) }

    it "returns the master list that tracks it" do
      expect(shopping_list.master_list).to eq master_list
    end
  end

  describe 'title transformations' do
    describe 'setting a default title' do
      let(:user) { create(:user) }
  
      # I don't use FactoryBot to create the models in the subject blocks because
      # it sets values for certain attributes and I don't want those to get in the way.
      context 'when the list is not a master list' do
        context 'when the user has set a title' do
          subject(:title) { user.shopping_lists.create!(title: 'Heljarchen Hall').title }
  
          let(:user) { create(:user) }
  
          it 'keeps the title the user has set' do
            expect(title).to eq 'Heljarchen Hall'
          end
        end
  
        context 'when the user has not set a title' do
          subject(:title) { user.shopping_lists.create!.title }
  
          before do
            # Create lists for a different user to make sure the name of this user's
            # list isn't affected by them
            create_list(:shopping_list, 2, title: nil)
            create_list(:shopping_list, 2, title: nil, user: user)
          end
  
          it 'sets the title based on how many regular lists the user has' do
            expect(title).to eq 'My List 3'
          end
        end
      end
  
      # MasterListable
      context 'when the list is a master list' do
        context 'when the user has set a title' do
          subject(:title) { user.shopping_lists.create!(master: true, title: 'Something other than master').title }
          
          it 'overrides the title the user has set' do
            expect(title).to eq 'Master'
          end
        end
  
        context 'when the user has not set a title' do
          subject(:title) { user.shopping_lists.create!(master: true).title }
  
          it 'sets the title to "Master"' do
            expect(title).to eq 'Master'
          end
        end
      end
    end

    context 'when the request includes sloppy data' do
      it 'uses intelligent title capitalisation' do
        list = create(:shopping_list, title: 'lord oF thE rIngs')
        expect(list.title).to eq 'Lord of the Rings'
      end

      it 'strips trailing and leading whitespace' do
        list = create(:shopping_list, title: " lord oF tHe RiNgs\n")
        expect(list.title).to eq 'Lord of the Rings'
      end
    end
  end

  describe 'relations' do
    subject(:items) { shopping_list.list_items }

    let!(:master_list) { create(:master_shopping_list) }
    let(:shopping_list) { create(:shopping_list, user: master_list.user, master_list_id: master_list.id) }
    let!(:item1) { create(:shopping_list_item, list: shopping_list) }
    let!(:item2) { create(:shopping_list_item, list: shopping_list) }
    let!(:item3) { create(:shopping_list_item, list: shopping_list) }

    before do
      item2.update!(quantity: 2)
    end

    it 'keeps child models in descending order of updated_at' do
      expect(shopping_list.list_items.to_a).to eq([item2, item3, item1])
    end
  end

  describe 'before destroy hook' do
    # MasterListable
    context 'when trying to destroy the master list' do
      subject(:destroy_list) { shopping_list.destroy! }
      let(:shopping_list) { create(:master_shopping_list) }

      context 'when the user has regular lists' do
        before do
          create(:shopping_list, user: shopping_list.user, master_list: shopping_list)
        end

        it 'raises an error and does not destroy the list' do
          expect { destroy_list }.to raise_error(ActiveRecord::RecordNotDestroyed)
        end
      end

      context 'when the user has no regular lists' do
        it 'destroys the master list' do
          expect { destroy_list }.to change(shopping_list.user.shopping_lists, :count).from(1).to(0)
        end
      end
    end
  end

  # MasterListable
  describe 'after destroy hook' do
    subject(:destroy_list) { shopping_list.destroy! }

    let!(:master_list) { create(:master_shopping_list, user: user) }
    let!(:shopping_list) { create(:shopping_list, user: user) }
    let(:user) { create(:user) }

    context 'when the user has additional regular lists' do
      before do
        create(:shopping_list, user: user)
      end

      it "doesn't destroy the master list" do
        expect { destroy_list }.not_to change(user, :master_shopping_list)
      end
    end

    context 'when the user has no additional regular lists' do
      it 'destroys the master list' do
        expect { destroy_list }.to change(user.shopping_lists, :count).from(2).to(0)
      end
    end
  end

  describe 'MasterListable methods' do
    describe '#add_item_from_child_list' do
      subject(:add_item) { master_list.add_item_from_child_list(list_item) }

      let(:master_list) { create(:master_shopping_list) }

      context 'when there is no matching item on the master list' do
        let(:list_item) { create(:shopping_list_item) }

        it 'creates a corresponding item on the master list' do
          expect { add_item }.to change(master_list.list_items, :count).from(0).to(1)
        end

        it 'sets the correct attributes' do
          add_item
          expect(master_list.list_items.last.attributes).to include(
                                                                     'description' => list_item.description,
                                                                     'quantity' => list_item.quantity,
                                                                     'notes' => list_item.notes
                                                                    )
        end
      end

      context 'when there is a matching item on the master list' do
        let!(:existing_list_item) { create(:shopping_list_item, list: master_list, quantity: 3, notes: 'notes 1 -- notes 2') }

        context 'when both have notes' do
          let(:list_item) { create(:shopping_list_item, description: existing_list_item.description, quantity: 2, notes: 'notes 3') }

          it 'combines the notes and quantities', :aggregate_failures do
            add_item
            expect(existing_list_item.reload.notes).to eq 'notes 1 -- notes 2 -- notes 3'
            expect(existing_list_item.reload.quantity).to eq 5
          end
        end
        
        context 'when neither have notes' do
          let!(:existing_list_item) { create(:shopping_list_item, list: master_list, quantity: 3, notes: nil) }
          let(:list_item) { create(:shopping_list_item, description: existing_list_item.description, quantity: 2, notes: nil) }

          it 'combines the quantities and leaves the notes nil' do
            add_item
            expect(existing_list_item.reload.quantity).to eq 5
            expect(existing_list_item.reload.notes). to be nil
          end
        end

        context 'when one has notes and the other does not' do
          let(:list_item) { create(:shopping_list_item, description: existing_list_item.description, quantity: 2) }

          it 'combines the quantities and uses the existing notes value', :aggregate_failures do
            add_item
            expect(existing_list_item.reload.quantity).to eq 5
            expect(existing_list_item.reload.notes).to eq 'notes 1 -- notes 2'
          end
        end
      end

      context 'when called on a non-master list' do
        let(:master_list) { create(:shopping_list) }
        let(:list_item) { create(:shopping_list_item) }

        it 'raises a MasterListError' do
          expect { add_item }.to raise_error(MasterListable::MasterListError)
        end
      end
    end

    describe '#remove_item_from_child_list' do
      subject(:remove_item) { master_list.remove_item_from_child_list(item_attrs) }

      context 'when there is no matching item on the master list' do
        let(:master_list) { create(:master_shopping_list) }
        let(:item_attrs) { { description: 'Necklace', quantity: 3, notes: 'some notes' } }

        it 'raises an error' do
          expect { remove_item }.to raise_error(MasterListable::MasterListError)
        end
      end

      context 'when the quantity is greater than the quantity on the master list' do
        let(:master_list) { create(:master_shopping_list) }
        let(:item_attrs) { { 'description' => 'Necklace', 'quantity' => 3, 'notes' => 'some notes' } }

        before do
          master_list.list_items.create(description: 'Necklace', quantity: 2)
        end

        it 'raises an error' do
          expect { remove_item }.to raise_error(MasterListable::MasterListError)
        end
      end

      context 'when the quantity is equal to the quantity on the master list' do
        let(:master_list) { create(:master_shopping_list) }
        let(:item_attrs) { { 'description' => 'Necklace', 'quantity' => 3, 'notes' => 'some notes' } }

        before do
          master_list.list_items.create(description: 'Necklace', quantity: 3)
        end

        it 'removes the item from the master list' do
          expect { remove_item }.to change(master_list.list_items, :count).from(1).to(0)
        end
      end

      context 'when the quantity is less than the quantity on the master list' do
        context 'complicated notes situations' do
          # Cases to cover:
          # notes 1 -- notes 2 -- notes 3 (remove notes 2 only)
          # notes 1 -- notes 2 -- notes 3 (remove notes 1 only)
          # notes 1 -- notes 2 -- notes 3 (remove notes 3 only)
          # notes 1 -- notes 2 -- notes 3 (remove notes 1 -- notes 2)
          # notes 1 -- notes 2 -- notes 3 (remove notes 2 -- notes 3)
          # notes 1 -- notes 2 -- notes 3 (remove all)
          # notes 1 -- notes 2 -- notes 3 (remove none)
        end
      end

      context 'when called on a non-master list' do
        let(:master_list) { create(:shopping_list) }
        let(:item_attrs) { { description: 'Necklace', quantity: 3, notes: 'some notes' } }

        it 'raises an error' do
          expect { remove_item }.to raise_error(MasterListable::MasterListError)
        end
      end
    end

    describe '#update_item_from_child_list' do
      subject(:update_item) { master_list.update_item_from_child_list(description, delta, old_notes, new_notes) }

      let(:master_list) { create(:master_shopping_list) }
      let(:description) { 'Corundum ingot' }

      context 'when adjusting quantity up' do
        let(:delta) { 2 }
        let(:old_notes) { 'something' }
        let(:new_notes) { 'another thing' }

        before do
          # upcase the description to test that the comparison is case insensitive
          master_list.list_items.create(description: description.upcase, quantity: 1, notes: "#{old_notes} -- something else")
        end

        it 'adds the quantity delta to the existing one' do
          update_item
          expect(master_list.list_items.first.quantity).to eq 3
        end

        it 'replaces the notes' do
          update_item
          expect(master_list.list_items.first.notes).to eq "#{new_notes} -- something else"
        end
      end

      context 'when adjusting quantity down' do
        let(:delta) { -2 }
        let(:old_notes) { 'something' }
        let(:new_notes) { 'another thing' }

        before do
          master_list.list_items.create(description: description, quantity: 3, notes: old_notes)
        end

        it 'adds the negative quantity delta to the existing one' do
          update_item
          expect(master_list.list_items.first.quantity).to eq 1
        end

        it 'replaces the notes' do
          update_item
          expect(master_list.list_items.first.notes).to eq new_notes
        end
      end

      context 'when the notes have not changed' do
        let(:delta) { -2 }
        let(:old_notes) { 'something' }
        let(:new_notes) { 'something' }

        before do
          master_list.list_items.create(description: description, quantity: 3, notes: "#{old_notes} -- something else")
        end

        it "doesn't mess with the notes" do
          update_item
          expect(master_list.list_items.first.notes).to eq 'something -- something else'  
        end
      end

      context 'when there are edge cases with the notes' do
        let(:delta) { 5 }
        let(:existing_notes) { 'notes 1 -- notes 2 -- notes 3' }

        before do
          master_list.list_items.create!(description: description, quantity: 3, notes: existing_notes)
        end
  
        context 'when replacing the middle notes' do
          let(:old_notes) { 'notes 2' }
          let(:new_notes) { 'something else' }

          it 'replaces the old notes on the list item' do
            update_item
            expect(master_list.list_items.first.notes).to eq 'notes 1 -- something else -- notes 3'
          end
        end

        context 'when replacing the first notes with nil' do
          let(:old_notes) { 'notes 1' }
          let(:new_notes) { nil }

          it "doesn't leave leading whitespace or dashes" do
            update_item
            expect(master_list.list_items.first.notes).to eq 'notes 2 -- notes 3'
          end
        end

        context 'when replacing two of the notes values' do
          let(:old_notes) { 'notes 2 -- notes 3' }
          let(:new_notes) { 'something else' }

          it "doesn't leave trailing whitespace or dashes" do
            update_item
            expect(master_list.list_items.first.notes).to eq 'notes 1 -- something else'
          end
        end

        context 'when replacing all of a combined note value' do
          let(:old_notes) { 'notes 1 -- notes 2 -- notes 3' }
          let(:new_notes) { nil }

          it 'sets the value to nil' do
            update_item
            expect(master_list.list_items.first.notes).to be nil
          end
        end

        context 'when there are multiple identical note values' do
          let(:existing_notes) { 'notes 1 -- notes 1 -- notes 2' }
          let(:old_notes) { 'notes 1' }
          let(:new_notes) { 'something else' }

          it 'only replaces one instance' do
            update_item
            expect(master_list.list_items.first.notes).to eq 'something else -- notes 1 -- notes 2'
          end
        end

        context 'when introducing new notes' do
          let(:old_notes) { 'notes 2' }
          let(:new_notes) { 'notes 2 -- notes 4' }

          it 'adds the new notes' do
            update_item
            expect(master_list.list_items.last.notes).to eq 'notes 1 -- notes 2 -- notes 4 -- notes 3'
          end
        end

        context 'when all the notes on the master list come from other items' do
          let(:old_notes) { nil }
          let(:new_notes) { 'notes 4' }

          it 'adds the new notes' do
            update_item
            expect(master_list.list_items.last.notes).to eq 'notes 1 -- notes 2 -- notes 3 -- notes 4'
          end
        end
      end

      context 'when the delta would bring the quantity below zero' do
        let(:delta) { -20 }
        let(:old_notes) { nil }
        let(:new_notes) { 'something else' }

        it 'raises an error' do
          expect { update_item }.to raise_error(MasterListable::MasterListError)
        end
      end

      context 'when there is no matching item on the master list' do
        let(:description) { 'Iron ore' }
        let(:delta) { 2 }
        let(:old_notes) { 'something' }
        let(:new_notes) { 'something else' }

        it 'raises an error' do
          expect { update_item }.to raise_error(MasterListable::MasterListError)
        end
      end

      context 'when called on a regular list' do
        let(:master_list) { create(:shopping_list) }
        let(:description) { 'Corundum ingot' }
        let(:delta) { 2 }
        let(:old_notes) { 'to build things' }
        let(:new_notes) { 'to make locks' }

        it 'raises an error' do
          expect { update_item }.to raise_error(MasterListable::MasterListError)
        end
      end
    end
  end
end
