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
          create_list(:shopping_list, 2)
          create_list(:shopping_list, 2, user: user)
        end

        it 'sets the title based on how many regular lists the user has' do
          expect(title).to eq 'My List 3'
        end
      end
    end

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
