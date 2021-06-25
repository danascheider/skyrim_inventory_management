# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ShoppingList, type: :model do
  describe 'scopes' do
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

    describe 'title validations' do
      context 'when the title is "master"' do
        it 'is allowed for a master list' do
          list = build(:master_shopping_list, title: 'Master')
          expect(list).to be_valid
        end

        it 'is not allowed for a regular list', :aggregate_failures do
          list = build(:shopping_list, title: 'master')
          expect(list).not_to be_valid
          expect(list.errors[:title]).to eq(['cannot be "master" for a regular shopping list'])
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
          create_list(:shopping_list, 2, title: nil, user: user)
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

  describe 'title capitalisation' do
    it 'uses intelligent title capitalisation' do
      list = create(:shopping_list, title: 'lord oF thE rIngs')
      expect(list.title).to eq 'Lord of the Rings'
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

  describe 'before destroy hook' do
    context 'when trying to destroy the master list' do
      subject(:destroy_list) { shopping_list.destroy! }
      let(:shopping_list) { create(:master_shopping_list) }

      context 'when the user has regular lists' do
        before do
          create(:shopping_list, user: shopping_list.user)
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

  describe 'after destroy hook' do
    subject(:destroy_list) { shopping_list.destroy! }

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

    context 'when the list is a master list' do
      let(:shopping_list) { create(:master_shopping_list, user: user) }

      it "doesn't raise an error" do
        expect { destroy_list }.not_to raise_error
      end
    end
  end
end
