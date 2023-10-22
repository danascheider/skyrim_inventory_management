# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RecipesCanonicalIngredient, type: :model do
  describe 'validations' do
    it 'is invalid if the book is not a recipe' do
      book = create(:canonical_book, book_type: 'skill book', skill_name: 'Heavy Armor')
      model = build(:recipes_canonical_ingredient, recipe: book)

      model.validate
      expect(model.errors[:recipe]).to include 'must be a recipe'
    end

    it 'is valid if the book is a recipe' do
      book = create(:canonical_recipe)
      model = build(:recipes_canonical_ingredient, recipe: book)

      expect(model).to be_valid
    end
  end
end
