# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShoppingListItem, type: :model do
  describe 'delegation' do
    subject(:owner) { list_item.user }

    let(:list_item) { create(:shopping_list_item) }

    describe '#user' do
      it 'returns the owner of its ShoppingList' do
        expect(owner).to eq(list_item.shopping_list.user)
      end
    end
  end

  describe '::create_or_combine!' do
    context 'when there is an existing item on the same list with the same description' do
      subject(:create_or_combine) { described_class.create_or_combine!(description: 'existing item', quantity: 1, shopping_list: shopping_list, notes: 'notes 2') }

      let!(:shopping_list) { create(:shopping_list) }
      let!(:existing_item) { create(:shopping_list_item, description: 'Existing item', quantity: 2, shopping_list: shopping_list, notes: 'notes 1') }

      it "doesn't create a new list item" do
        expect { create_or_combine }.not_to change(shopping_list.shopping_list_items, :count)
      end

      it 'adds the quantity to the existing item' do
        create_or_combine
        expect(existing_item.reload.quantity).to eq 3
      end

      it 'concatenates the notes for the two items' do
        create_or_combine
        expect(existing_item.reload.notes).to eq 'notes 1 -- notes 2'
      end
    end

    context 'when there is not an existing item on the same list with that description' do
      subject(:create_or_combine) { described_class.create_or_combine!(description: 'new item', quantity: 1, shopping_list: shopping_list) }

      let!(:shopping_list) { create(:shopping_list) }

      it 'creates a new item on the list' do
        expect { create_or_combine }.to change(shopping_list.shopping_list_items, :count).by(1)
      end

      it 'creates a new item on the master list' do
        expect { create_or_combine }.to change(shopping_list.user.master_shopping_list.shopping_list_items, :count).by(1)
      end
    end
  end

  describe '#update!' do
    let!(:list_item) { create(:shopping_list_item, quantity: 1) }

    context 'when updating quantity' do
      subject(:update_item) { list_item.update!(quantity: 4) }

      it 'updates as normal' do
        expect { update_item }.to change(list_item, :quantity).from(1).to(4)
      end
    end

    context 'when updating description' do
      subject(:update_item) { list_item.update!(description: 'Something else') }

      it 'raises an error' do
        expect { update_item }.to raise_error(ActiveRecord::RecordNotSaved)
      end
    end
  end

  describe 'updating the master list' do
    let(:shopping_list) { create(:shopping_list) }
    let(:master_list) { shopping_list.user.master_shopping_list }

    context 'when creating a new list item' do
      subject(:create_item) { create(:shopping_list_item, shopping_list: shopping_list) }

      context 'when there is no matching item already on the master list' do
        it 'adds the same item to the master list' do
          expect { create_item }.to change(master_list.shopping_list_items, :count).from(0).to(1)
        end
      end

      context 'when there is a matching item on the master list' do
        subject(:create_item) { create(:shopping_list_item, description: 'Ebony sword', quantity: 2, shopping_list: shopping_list) }

        let!(:item_on_master_list) { create(:shopping_list_item, description: 'Ebony sword', quantity: 1, shopping_list: master_list) }

        it 'updates the quantity on the master list' do
          create_item
          expect(item_on_master_list.reload.quantity).to eq 3
        end
      end
    end

    context 'when updating an existing list item' do
      let!(:list_item) { create(:shopping_list_item, description: 'Ebony sword', quantity: 2, shopping_list: shopping_list) }
      
      context 'when incrementing the quantity' do
        subject(:update_item) { list_item.update!(quantity: 3) }

        it 'increases the quantity on the master list' do
          update_item
          expect(master_list.shopping_list_items.find_by(description: 'Ebony sword').quantity).to eq 3
        end
      end

      context 'when decrementing the quantity' do
        subject(:update_item) { list_item.update!(quantity: 1) }

        it 'decreases the quantity on the master list' do
          update_item
          expect(master_list.shopping_list_items.find_by(description: 'Ebony sword').quantity).to eq 1
        end
      end
    end

    context 'when destroying a list item' do
      subject(:destroy_item) { list_item.destroy! }

      let!(:list_item) { create(:shopping_list_item, description: 'Ebony sword', quantity: 2, shopping_list: shopping_list) }
      let(:master_list_item) { master_list.shopping_list_items.find_by_description('Ebony sword') }

      context 'when the new quantity on the master list is greater than 0' do

        before do
          master_list_item.update!(quantity: 3)
        end

        it 'adjusts the quantity on the master list' do
          destroy_item
          expect(master_list_item.reload.quantity).to eq 1
        end
      end

      context 'when the new quantity on the master list is 0' do
        it 'removes the item from the master list' do
          expect { destroy_item }.to change(master_list.shopping_list_items, :count).from(1).to(0)
        end
      end
    end
  end
end
