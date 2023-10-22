# frozen_string_literal: true

class Book < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_book,
             optional: true,
             class_name: 'Canonical::Book',
             inverse_of: :books

  has_many :recipes_canonical_ingredients,
           dependent: :destroy,
           inverse_of: :recipe,
           foreign_key: 'recipe_id'
  has_many :canonical_ingredients,
           through: :recipes_canonical_ingredients,
           class_name: 'Canonical::Ingredient',
           source: :ingredient

  validates :title, presence: true
  validates :unit_weight,
            numericality: {
              greater_than_or_equal_to: 0,
              allow_nil: true,
            }

  before_validation :set_canonical_book
  before_validation :set_values_from_canonical

  def canonical_model
    canonical_book
  end

  def canonical_models
    return Canonical::Book.where(id: canonical_book_id) if canonical_book_id.present?

    canonicals = Canonical::Book.where('title ILIKE :title OR :title ILIKE ANY(title_variants)', title:)
    canonicals = canonicals.where(**attributes_to_match) if attributes_to_match.any?

    return canonicals unless canonical_ingredients.any?

    recipes_canonical_ingredients.each do |join_model|
      canonicals = canonicals.joins(:recipes_canonical_ingredients).where(recipes_canonical_ingredients: { ingredient_id: join_model.ingredient_id })
    end

    canonicals
  end

  def recipe?
    canonical_models.any? {|model| model.book_type == 'recipe' }
  end

  private

  def set_canonical_book
    self.canonical_book = canonical_models.first if canonical_models.count == 1
  end

  def set_values_from_canonical
    return if canonical_book.nil?

    self.title = canonical_book.title
    self.authors = canonical_book.authors
    self.unit_weight = canonical_book.unit_weight
    self.skill_name = canonical_book.skill_name
  end

  def attributes_to_match
    {
      authors: authors.presence,
      unit_weight:,
      skill_name:,
    }.compact
  end
end
