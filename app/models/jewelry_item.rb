# frozen_string_literal: true

class JewelryItem < ApplicationRecord
  DOES_NOT_MATCH = "doesn't match any jewelry item that exists in Skyrim"

  belongs_to :game
  belongs_to :canonical_jewelry_item,
             optional: true,
             inverse_of: :jewelry_items,
             class_name: 'Canonical::JewelryItem'

  has_many :enchantables_enchantments,
           dependent: :destroy,
           as: :enchantable
  has_many :enchantments,
           -> { select 'enchantments.*, enchantables_enchantments.strength as strength' },
           through: :enchantables_enchantments,
           source: :enchantment

  validates :name, presence: true
  validates :jewelry_type,
            allow_blank: true,
            inclusion: {
              in: Canonical::JewelryItem::JEWELRY_TYPES,
              message: Canonical::JewelryItem::JEWELRY_TYPE_VALIDATION_MESSAGE,
            }
  validates :unit_weight,
            allow_blank: true,
            numericality: {
              greater_than_or_equal_to: 0,
            }

  validate :ensure_match_exists

  before_validation :set_canonical_jewelry_item
  after_create :set_enchantments, if: -> { canonical_jewelry_item.present? }

  def crafting_materials
    canonical_jewelry_item&.crafting_materials
  end

  def canonical_jewelry_items
    return [canonical_jewelry_item] if canonical_jewelry_item.present?

    attrs_to_match = {
      jewelry_type:,
      unit_weight:,
      magical_effects:,
    }.compact

    canonicals = Canonical::JewelryItem.where('name ILIKE ?', name)
    attrs_to_match.any? ? canonicals.where(**attrs_to_match) : canonicals
  end

  private

  def ensure_match_exists
    return if canonical_jewelry_items.any?

    errors.add(:base, DOES_NOT_MATCH)
  end

  def set_canonical_jewelry_item
    return unless canonical_jewelry_items.count == 1

    self.canonical_jewelry_item ||= canonical_jewelry_items.first

    self.name = canonical_jewelry_item.name
    self.unit_weight = canonical_jewelry_item.unit_weight
    self.jewelry_type = canonical_jewelry_item.jewelry_type
    self.magical_effects = canonical_jewelry_item.magical_effects

    set_enchantments if persisted?
  end

  def set_enchantments
    return if canonical_jewelry_item.enchantments.empty?

    canonical_jewelry_item.enchantables_enchantments.each do |model|
      enchantables_enchantments.find_or_create_by!(
        enchantment_id: model.enchantment_id,
        strength: model.strength,
      )
    end
  end
end
