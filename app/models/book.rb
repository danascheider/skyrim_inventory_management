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
  before_validation :validate_unique_canonical

  DUPLICATE_MATCH = 'is a duplicate of a unique in-game item'

  def canonical_model
    canonical_book
  end

  def canonical_models
    return Canonical::Book.where(id: canonical_book_id) if canonical_model_matches?

    canonicals = Canonical::Book.where('title ILIKE :title OR :title ILIKE ANY(title_variants)', title:)
    canonicals = canonicals.where(**attributes_to_match) if attributes_to_match.any?

    return canonicals unless canonical_ingredients.any?

    recipes_canonical_ingredients.each do |join_model|
      canonicals = canonicals
                     .joins(:recipes_canonical_ingredients)
                     .where(
                       recipes_canonical_ingredients: {
                         ingredient_id: join_model.ingredient_id,
                       },
                     )
    end

    canonicals
  end

  def recipe?
    canonical_models.any? {|model| model.book_type == 'recipe' }
  end

  private

  def set_canonical_book
    canonicals = canonical_models

    unless canonicals.count == 1
      clear_canonical_book
      return
    end

    self.canonical_book = canonicals.first
  end

  def set_values_from_canonical
    return if canonical_book.nil?

    self.title = canonical_book.title
    self.authors = canonical_book.authors
    self.unit_weight = canonical_book.unit_weight
    self.skill_name = canonical_book.skill_name
  end

  def validate_unique_canonical
    return unless canonical_book&.unique_item

    books = canonical_book.books.where(game_id:)

    return if books.count < 1
    return if books.count == 1 && books.first == self

    errors.add(:base, DUPLICATE_MATCH)
  end

  def clear_canonical_book
    self.canonical_book_id = nil
  end

  def canonical_model_matches?
    return false if canonical_model.nil?
    return false unless title.casecmp(canonical_model.title).zero?
    return false unless unit_weight.nil? || unit_weight == canonical_model.unit_weight
    return false unless skill_name.nil? || skill_name == canonical_model.skill_name

    true
  end

  def attributes_to_match
    {
      authors: authors.presence,
      unit_weight:,
      skill_name:,
    }.compact
  end
end
