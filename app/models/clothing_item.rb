# frozen_string_literal: true

class ClothingItem < ApplicationRecord
  belongs_to :game

  belongs_to :canonical_clothing_item,
             optional: true,
             inverse_of: :clothing_items,
             class_name: 'Canonical::ClothingItem'

  has_many :enchantables_enchantments,
           dependent: :destroy,
           as: :enchantable
  has_many :enchantments,
           -> { select 'enchantments.*, enchantables_enchantments.strength as strength' },
           through: :enchantables_enchantments,
           source: :enchantment

  validates :name, presence: true
  validates :unit_weight,
            numericality: {
              greater_than_or_equal_to: 0,
              allow_nil: true,
            }

  validates_with ClothingItemValidator

  before_validation :set_canonical_clothing_item

  after_create :set_enchantments, if: -> { canonical_clothing_item.present? }

  def canonical_clothing_items
    return Array.wrap(canonical_clothing_item) if canonical_clothing_item

    attrs_to_match = { unit_weight:, magical_effects: }.compact

    canonicals = Canonical::ClothingItem.where('name ILIKE ?', name)
    attrs_to_match.any? ? canonicals.where(**attrs_to_match) : canonicals
  end

  private

  def set_canonical_clothing_item
    return unless canonical_clothing_items.count == 1

    self.canonical_clothing_item ||= canonical_clothing_items.first
    self.name = canonical_clothing_item.name # in case casing differs
    self.unit_weight = canonical_clothing_item.unit_weight
    self.magical_effects = canonical_clothing_item.magical_effects

    set_enchantments if persisted?
  end

  def set_enchantments
    return if canonical_clothing_item.enchantments.empty?

    canonical_clothing_item.enchantables_enchantments.each do |model|
      enchantables_enchantments.find_or_create_by!(
        enchantment_id: model.enchantment_id,
        strength: model.strength,
      )
    end
  end
end
