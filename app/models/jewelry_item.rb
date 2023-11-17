# frozen_string_literal: true

class JewelryItem < ApplicationRecord
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
  validates :unit_weight,
            allow_blank: true,
            numericality: {
              greater_than_or_equal_to: 0,
            }

  validate :ensure_match_exists
  validate :validate_unique_canonical

  before_validation :set_canonical_jewelry_item
  after_save :set_enchantments

  DOES_NOT_MATCH = "doesn't match any jewelry item that exists in Skyrim"
  DUPLICATE_MATCH = 'is a duplicate of a unique in-game item'

  def crafting_materials
    canonical_jewelry_item&.crafting_materials
  end

  def canonical_model
    canonical_jewelry_item
  end

  def canonical_models
    return Canonical::JewelryItem.where(id: canonical_jewelry_item_id) if canonical_model_matches?

    query = 'name ILIKE :name'
    query += ' AND magical_effects ILIKE :magical_effects' if magical_effects.present?

    canonicals = Canonical::JewelryItem.where(query, name:, magical_effects:)
    canonicals = canonicals.where(**attributes_to_match) if attributes_to_match.any?

    return canonicals if enchantments.none?

    enchantables_enchantments.each do |join_model|
      canonicals = if join_model.strength.present?
                     canonicals.left_outer_joins(:enchantables_enchantments).where(
                       '(enchantables_enchantments.enchantment_id = :enchantment_id AND enchantables_enchantments.strength = :strength) OR canonical_jewelry_items.enchantable = true',
                       enchantment_id: join_model.enchantment_id,
                       strength: join_model.strength,
                     )
                   else
                     canonicals.left_outer_joins(:enchantables_enchantments).where(
                       '(enchantables_enchantments.enchantment_id = :enchantment_id AND enchantables_enchantments.strength IS NULL) OR canonical_jewelry_items.enchantable = true',
                       enchantment_id: join_model.enchantment_id,
                     )
                   end
    end

    canonicals.uniq
  end

  def jewelry_type
    canonical_model&.jewelry_type
  end

  private

  def ensure_match_exists
    return if canonical_models.any?

    errors.add(:base, DOES_NOT_MATCH)
  end

  def set_canonical_jewelry_item
    canonicals = canonical_models

    unless canonicals.count == 1
      clear_canonical_jewelry_item
      return
    end

    self.canonical_jewelry_item = canonicals.first
    self.name = canonical_jewelry_item.name
    self.unit_weight = canonical_jewelry_item.unit_weight
    self.magical_effects = canonical_jewelry_item.magical_effects
  end

  def validate_unique_canonical
    return unless canonical_jewelry_item&.unique_item

    jewelry_items = canonical_jewelry_item.jewelry_items.where(game_id:)

    return if jewelry_items.count < 1
    return if jewelry_items.count == 1 && jewelry_items.first == self

    errors.add(:base, DUPLICATE_MATCH)
  end

  def set_enchantments
    return if canonical_jewelry_item.nil?
    return if canonical_jewelry_item.enchantments.empty?

    canonical_jewelry_item.enchantables_enchantments.each do |model|
      enchantables_enchantments.find_or_create_by!(
        enchantment_id: model.enchantment_id,
        strength: model.strength,
      ) {|new_model| new_model.added_automatically = true }
    end
  end

  def clear_canonical_jewelry_item
    self.canonical_jewelry_item_id = nil
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
