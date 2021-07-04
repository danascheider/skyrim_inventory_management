
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '::create_or_update_for_google' do
    subject(:create_or_update) { described_class.create_or_update_for_google(payload) }
    let(:payload) do
      {
        'exp' => (Time.now + 2.days).to_i,
        'email' => 'jane.doe@gmail.com',
        'name' => 'Jane Doe',
        'picture' => 'https://example.com/user_images/89'
      }
    end

    context 'when a user with that email as uid does not exist' do
      it 'creates a user' do
        expect { create_or_update }.to change(User, :count).from(0).to(1)
      end

      it 'sets the attributes' do
        create_or_update
        expect(User.last.attributes).to include(
          'uid' => 'jane.doe@gmail.com',
          'email' => 'jane.doe@gmail.com',
          'name' => 'Jane Doe',
          'image_url' => 'https://example.com/user_images/89'
        )
      end
    end

    context 'when there is already a user with that email as uid' do
      let!(:user) { create(:user, uid: 'jane.doe@gmail.com', email: 'jane.doe@gmail.com', name: 'Jane Doe', image_url: nil) }

      it 'does not create a new user' do
        expect { create_or_update }.not_to change(User, :count)
      end

      it 'updates the attributes' do
        create_or_update
        expect(user.reload.image_url).to eq 'https://example.com/user_images/89'
      end
    end
  end

  describe '#master_shopping_list' do
    subject(:user) { create(:user) }

    context 'when the user has a master shopping list' do
      let!(:master_list) { create(:master_shopping_list, user: user) }

      it 'returns the master list' do
        expect(user.master_shopping_list).to eq master_list
      end
    end

    context 'when the user has no master shopping list' do
      it 'returns nil' do
        expect(user.master_shopping_list).to be nil
      end
    end
  end
end
