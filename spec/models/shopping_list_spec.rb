# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShoppingList, type: :model do
  describe 'validations' do
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
          expect(master_list.errors[:master]).to eq ['user can only have one master shopping list']
        end
      end
    end
  end

  describe 'after create hook' do
    subject(:create_shopping_list) { create(:shopping_list, user: user) }

    let(:user) { create(:user) }

    context 'when the user has an existing master list' do
      before do
        create(:master_shopping_list, user: user)
      end

      it "doesn't raise a validation error" do
        expect { create_shopping_list }.not_to raise_error
      end
  
      it "doesn't create another master list" do
        expect { create_shopping_list }.to change(user.shopping_lists, :count).from(1).to(2)
      end
    end

    context "when the user doesn't have a master list yet" do
      it 'creates two lists' do
        expect { create_shopping_list }.to change(user.shopping_lists, :count).from(0).to(2)
      end

      it 'creates a master list' do
        create_shopping_list
        expect(user.master_shopping_list).not_to be nil
      end
    end
  end
end
