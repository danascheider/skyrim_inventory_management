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

  before_validation :set_canonical_weapon
  before_validation :set_values_from_canonical

  after_save :set_enchantments

  DOES_NOT_MATCH = "doesn't match a weapon that exists in Skyrim"

  def canonical_model
    canonical_weapon
  end

  def canonical_models
    return Canonical::Weapon.where(id: canonical_weapon.id) if canonical_weapon.present?

    canonicals = Canonical::Weapon.where('name ILIKE ?', name)
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
    return unless canonical_models.count == 1

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

  def attributes_to_match
    {
      unit_weight:,
      category:,
      weapon_type:,
      magical_effects:,
    }.compact
  end

  def ensure_canonicals_exist
    errors.add(:base, DOES_NOT_MATCH) if canonical_models.none?
  end
end
