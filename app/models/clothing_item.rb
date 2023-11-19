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

  def canonical_model
    canonical_clothing_item
  end

  def canonical_models
    return Canonical::ClothingItem.where(id: canonical_clothing_item_id) if canonical_model_matches?

    query = 'name ILIKE :name'
    query += ' AND magical_effects ILIKE :magical_effects' if magical_effects.present?

    canonicals = Canonical::ClothingItem.where(query, name:, magical_effects:)
    canonicals = canonicals.where(**attributes_to_match) if attributes_to_match.any?

    return canonicals if enchantments.none?

    enchantables_enchantments.each do |join_model|
      canonicals = if join_model.strength.present?
                     canonicals.left_outer_joins(:enchantables_enchantments).where(
                       '(enchantables_enchantments.enchantment_id = :enchantment_id AND enchantables_enchantments.strength = :strength) OR canonical_clothing_items.enchantable = true',
                       enchantment_id: join_model.enchantment_id,
                       strength: join_model.strength,
                     )
                   else
                     canonicals.left_outer_joins(:enchantables_enchantments).where(
                       '(enchantables_enchantments.enchantment_id = :enchantment_id AND enchantables_enchantments.strength IS NULL) OR canonical_clothing_items.enchantable = true',
                       enchantment_id: join_model.enchantment_id,
                     )
                   end
    end

    canonicals.uniq
  end

  private

  def set_canonical_clothing_item
    canonicals = canonical_models

    unless canonicals.count == 1
      clear_canonical_clothing_item
      return
    end

    self.canonical_clothing_item = canonicals.first
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
      ) {|new_model| new_model.added_automatically = true }
    end
  end

  def clear_canonical_clothing_item
    self.canonical_clothing_item_id = nil
  end

  def canonical_model_matches?
    return false if canonical_model.nil?
    return false unless name.casecmp(canonical_model.name).zero?
    return false unless magical_effects.nil? || magical_effects.casecmp(canonical_model.magical_effects)&.zero?
    return false unless unit_weight.nil? || unit_weight == canonical_model.unit_weight

    true
  end

  def attributes_to_match
    { unit_weight: }.compact
  end
end
