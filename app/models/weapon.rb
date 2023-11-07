# frozen_string_literal: true

class Weapon < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_weapon,
             optional: true,
             class_name: 'Canonical::Weapon',
             inverse_of: :weapons

  has_many :enchantables_enchantments,
           dependent: :destroy,
           as: :enchantable
  has_many :enchantments,
           -> { select 'enchantments.*, enchantables_enchantments.strength as strength' },
           through: :enchantables_enchantments

  validates :name, presence: true
  validates :unit_weight,
            numericality: {
              greater_than_or_equal_to: 0,
              allow_nil: true,
            }
  validates :category,
            inclusion: {
              in: Canonical::Weapon::VALID_WEAPON_TYPES.keys,
              message: 'must be "one-handed", "two-handed", or "archery"',
              allow_blank: true,
            }
  validates :weapon_type,
            inclusion: {
              in: Canonical::Weapon::VALID_WEAPON_TYPES.values.flatten,
              message: 'must be a valid type of weapon that occurs in Skyrim',
              allow_blank: true,
            }

  validate :ensure_canonicals_exist
  validate :validate_unique_canonical

  before_validation :set_canonical_weapon
  before_validation :set_values_from_canonical

  after_save :set_enchantments

  DOES_NOT_MATCH = "doesn't match a weapon that exists in Skyrim"
  DUPLICATE_MATCH = 'is a duplicate of a unique in-game item'

  def canonical_model
    canonical_weapon
  end

  def canonical_models
    return Canonical::Weapon.where(id: canonical_weapon.id) if canonical_model_matches?

    query = 'name ILIKE :name'
    query += ' AND magical_effects ILIKE :magical_effects' if magical_effects.present?

    canonicals = Canonical::Weapon.where(query, name:, magical_effects:)
    canonicals = attributes_to_match.any? ? canonicals.where(**attributes_to_match) : canonicals

    return canonicals if enchantments.none?

    enchantables_enchantments.each do |join_model|
      canonicals = if join_model.strength.present?
                     canonicals.left_outer_joins(:enchantables_enchantments).where(
                       '(enchantables_enchantments.enchantment_id = :enchantment_id AND enchantables_enchantments.enchantable_type = :type AND enchantables_enchantments.strength = :strength) OR canonical_weapons.enchantable = true',
                       enchantment_id: join_model.enchantment_id,
                       type: 'Canonical::Weapon',
                       strength: join_model.strength,
                     )
                   else
                     canonicals.left_outer_joins(:enchantables_enchantments).where(
                       '(enchantables_enchantments.enchantment_id = :enchantment_id AND enchantables_enchantments.enchantable_type = :type AND enchantables_enchantments.strength IS NULL) OR canonical_weapons.enchantable = true',
                       enchantment_id: join_model.enchantment_id,
                       type: 'Canonical::Weapon',
                     )
                   end
    end

    canonicals.uniq
  end

  def crafting_materials
    canonical_weapon&.crafting_materials
  end

  def tempering_materials
    canonical_weapon&.tempering_materials
  end

  private

  def set_canonical_weapon
    unless canonical_models.count == 1
      clear_canonical_weapon
      return
    end

    self.canonical_weapon = canonical_models.first
  end

  def set_values_from_canonical
    return if canonical_weapon.nil?

    self.name = canonical_weapon.name
    self.unit_weight = canonical_weapon.unit_weight
    self.category = canonical_weapon.category
    self.weapon_type = canonical_weapon.weapon_type
    self.magical_effects = canonical_weapon.magical_effects
  end

  def set_enchantments
    return if canonical_weapon.nil?
    return if canonical_weapon.enchantments.none?

    canonical_weapon.enchantments.each do |enchantment|
      enchantables_enchantments.find_or_create_by!(
        enchantment:,
        strength: enchantment.strength,
      )
    end
  end

  def validate_unique_canonical
    return unless canonical_weapon&.unique_item

    weapons = canonical_weapon.weapons.where(game_id:)

    return if weapons.count < 1
    return if weapons.count == 1 && weapons.first == self

    errors.add(:base, DUPLICATE_MATCH)
  end

  def canonical_model_matches?
    return false if canonical_model.nil?
    return false unless name.casecmp(canonical_model.name).zero?
    return false unless magical_effects&.casecmp(canonical_model.magical_effects)&.zero?
    return false unless unit_weight.nil? || unit_weight == canonical_model.unit_weight
    return false unless category.nil? || category == canonical_model.category
    return false unless weapon_type.nil? || weapon_type == canonical_model.weapon_type

    true
  end

  def attributes_to_match
    {
      unit_weight:,
      category:,
      weapon_type:,
    }.compact
  end

  def clear_canonical_weapon
    self.canonical_weapon_id = nil
  end

  def ensure_canonicals_exist
    errors.add(:base, DOES_NOT_MATCH) if canonical_models.none?
  end
end
