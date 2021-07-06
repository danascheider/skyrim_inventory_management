# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShoppingListItem, type: :model do
  describe 'delegation' do
    subject(:user) { create(:user) }

    let(:shopping_list) { create(:shopping_list, user: user) }
    let(:list_item) { create(:shopping_list_item, list: shopping_list) }
    
    before do
      create(:master_shopping_list, user: user)
    end

    describe '#user' do
      it 'returns the owner of its ShoppingList' do
        expect(list_item.user).to eq(user)
      end
    end
  end

  describe 'scopes' do
    describe '::index_order' do
      let!(:master_list) { create(:master_shopping_list) }

      let!(:list_item1) { create(:shopping_list_item, list: list) }
      let!(:list_item2) { create(:shopping_list_item, list: list) }
      let!(:list_item3) { create(:shopping_list_item, list: list) }

      let(:list) { create(:shopping_list, user: master_list.user) }

      before do
        list_item2.update!(quantity: 3)
      end

      it 'returns the list items in descending chronological order by updated_at' do
        expect(list.list_items.index_order.to_a).to eq([list_item2, list_item3, list_item1])
      end
    end
  end

  describe '::combine_or_create!' do
    context 'when there is an existing item on the same list with the same description' do
      subject(:combine_or_create) { described_class.combine_or_create!(description: 'existing item', quantity: 1, list: shopping_list, notes: 'notes 2') }

      let(:master_list) { create(:master_shopping_list) }
      let!(:shopping_list) { create(:shopping_list, user: master_list.user) }
      let!(:existing_item) { create(:shopping_list_item, description: 'Existing item', quantity: 2, list: shopping_list, notes: 'notes 1') }

      it "doesn't create a new list item" do
        expect { combine_or_create }.not_to change(shopping_list.list_items, :count)
      end

      it 'adds the quantity to the existing item' do
        combine_or_create
        expect(existing_item.reload.quantity).to eq 3
      end

      it 'concatenates the notes for the two items' do
        combine_or_create
        expect(existing_item.reload.notes).to eq 'notes 1 -- notes 2'
      end
    end
  end

  describe '::combine_or_new' do
    context 'when there is an existing item on the same list with the same description' do
      subject(:combine_or_new) { described_class.combine_or_new(description: 'existing item', quantity: 1, list: shopping_list, notes: 'notes 2') }

      let(:master_list) { create(:master_shopping_list) }
      let!(:shopping_list) { create(:shopping_list, user: master_list.user) }
      let!(:existing_item) { create(:shopping_list_item, description: 'Existing item', quantity: 2, list: shopping_list, notes: 'notes 1') }

      before do
        allow(ShoppingListItem).to receive(:new)
      end

      it "doesn't instantiate a new item" do
        combine_or_new
        expect(ShoppingListItem).not_to have_received(:new)
      end

      it 'returns the existing item with the quantity updated', :aggregate_failures do
        expect(combine_or_new).to eq existing_item
        expect(combine_or_new.quantity).to eq 3
      end

      it 'concatenates the notes for the two items', :aggregate_failures do
        expect(combine_or_new).to eq existing_item
        expect(combine_or_new.notes).to eq 'notes 1 -- notes 2'
      end
    end

    context 'when there is not an existing item on the same list with that description' do
      subject(:combine_or_create) { described_class.combine_or_create!(description: 'new item', quantity: 1, list: shopping_list) }

      let(:master_list) { create(:master_shopping_list) }
      let!(:shopping_list) { create(:shopping_list, user: master_list.user) }

      it 'creates a new item on the list' do
        expect { combine_or_create }.to change(shopping_list.list_items, :count).by(1)
      end
    end
  end

  describe '#update!' do
    let(:master_list) { create(:master_shopping_list) }
    let(:shopping_list) { create(:shopping_list, user: master_list.user) }
    let!(:list_item) { create(:shopping_list_item, quantity: 1, list: shopping_list) }

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
end
