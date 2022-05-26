# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Canonical::Book, type: :model do
  describe 'validations' do
    describe 'title' do
      it "can't be blank" do
        model = build(:canonical_book, title: nil)

        model.validate
        expect(model.errors[:title]).to include "can't be blank"
      end
    end

    describe 'item code' do
      it "can't be blank" do
        model = build(:canonical_book, item_code: nil)

        model.validate
        expect(model.errors[:item_code]).to include "can't be blank"
      end

      it 'must be unique' do
        create(:canonical_book, item_code: 'foobar')
        model = build(:canonical_book, item_code: 'foobar')

        model.validate
        expect(model.errors[:item_code]).to include 'must be unique'
      end
    end

    describe 'unit weight' do
      it "can't be blank" do
        model = build(:canonical_book, unit_weight: nil)

        model.validate
        expect(model.errors[:unit_weight]).to include "can't be blank"
      end

      it 'must be a number' do
        model = build(:canonical_book, unit_weight: 'foo')

        model.validate
        expect(model.errors[:unit_weight]).to include 'is not a number'
      end

      it 'must be at least zero' do
        model = build(:canonical_book, unit_weight: -4.2)

        model.validate
        expect(model.errors[:unit_weight]).to include 'must be greater than or equal to 0'
      end
    end

    describe 'book type' do
      it 'must be one of the allowed types' do
        model = build(:canonical_book, book_type: 'self-help')

        model.validate
        expect(model.errors[:book_type]).to include 'must be a book type that exists in Skyrim'
      end
    end

    describe 'skill name' do
      context 'when the book is a skill book' do
        it "can't be blank" do
          model = build(:canonical_book, book_type: 'skill book', skill_name: nil)

          model.validate
          expect(model.errors[:skill_name]).to include "can't be blank for skill books"
        end

        it 'must be a valid skill' do
          model = build(:canonical_book, book_type: 'skill book', skill_name: 'Kung-Fu Fighting')

          model.validate
          expect(model.errors[:skill_name]).to include 'must be a skill that exists in Skyrim'
        end
      end

      context 'when the book is not a skill book' do
        it 'cannot be defined' do
          model = build(:canonical_book, book_type: 'lore book', skill_name: 'One-Handed')

          model.validate
          expect(model.errors[:skill_name]).to include 'can only be defined for skill books'
        end

        it 'can be blank' do
          model = build(:canonical_book, book_type: 'recipe', skill_name: nil)

          expect(model).to be_valid
        end
      end
    end

    describe 'purchasable' do
      it 'is required' do
        model = build(:canonical_book, purchasable: nil)

        model.validate
        expect(model.errors[:purchasable]).to include 'must be true or false'
      end
    end

    describe 'unique_item' do
      it 'is required' do
        model = build(:canonical_book, unique_item: nil)

        model.validate
        expect(model.errors[:unique_item]).to include 'must be true or false'
      end
    end

    describe 'rare_item' do
      it 'is required' do
        model = build(:canonical_book, rare_item: nil)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true or false'
      end

      it 'must be true if the item is unique' do
        model = build(:canonical_book, unique_item: true, rare_item: false)

        model.validate
        expect(model.errors[:rare_item]).to include 'must be true if item is unique'
      end
    end

    describe 'solstheim_only' do
      it 'is required' do
        model = build(:canonical_book, solstheim_only: nil)

        model.validate
        expect(model.errors[:solstheim_only]).to include 'must be true or false'
      end
    end

    describe 'quest_item' do
      it 'is required' do
        model = build(:canonical_book, quest_item: nil)

        model.validate
        expect(model.errors[:quest_item]).to include 'must be true or false'
      end
    end
  end

  describe '::unique_identifier' do
    it 'returns ":item_code"' do
      expect(described_class.unique_identifier).to eq :item_code
    end
  end
end
