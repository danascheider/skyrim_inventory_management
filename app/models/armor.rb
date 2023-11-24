# frozen_string_literal: true

class Armor < ApplicationRecord
  belongs_to :game

  belongs_to :canonical_armor,
             optional: true,
             inverse_of: :armors,
             class_name: 'Canonical::Armor'

  has_many :enchantables_enchantments,
           dependent: :destroy,
           as: :enchantable
  has_many :enchantments,
           -> { select 'enchantments.*, enchantables_enchantments.strength as strength' },
           through: :enchantables_enchantments,
           source: :enchantment

  validates :name, presence: true

  validates :weight,
            inclusion: {
              in: Canonical::Armor::ARMOR_WEIGHTS,
              message: 'must be "light armor" or "heavy armor"',
              allow_nil: true,
            }

  validates :unit_weight,
            numericality: {
              greater_than_or_equal_to: 0,
              allow_nil: true,
            }

  validates_with ArmorValidator

  before_validation :set_canonical_armor

  after_create :set_enchantments, if: -> { canonical_armor.present? }

  def canonical_model
    canonical_armor
  end

  def canonical_models
    return Canonical::Armor.where(id: canonical_armor_id) if canonical_model_matches?

    query = 'name ILIKE :name'
    query += ' AND magical_effects ILIKE :magical_effects' if magical_effects.present?

    canonicals = Canonical::Armor.where(query, name:, magical_effects:)
    canonicals = canonicals.where(**attributes_to_match) if attributes_to_match.any?

    return canonicals if enchantments.none?

    enchantables_enchantments.added_manually.each do |join_model|
      canonicals = if join_model.strength.present?
                     canonicals.left_outer_joins(:enchantables_enchantments).where(
                       '(enchantables_enchantments.enchantment_id = :enchantment_id AND enchantables_enchantments.strength = :strength) OR canonical_armors.enchantable = true',
                       enchantment_id: join_model.enchantment_id,
                       strength: join_model.strength,
                     )
                   else
                     canonicals.left_outer_joins(:enchantables_enchantments).where(
                       '(enchantables_enchantments.enchantment_id = :enchantment_id AND enchantables_enchantments.strength IS NULL) OR canonical_armors.enchantable = true',
                       enchantment_id: join_model.enchantment_id,
                     )
                   end
    end

    Canonical::Armor.where(id: canonicals.ids)
  end

  def crafting_materials
    canonical_armor&.crafting_materials
  end

  def tempering_materials
    canonical_armor&.tempering_materials
  end

  private

  def set_canonical_armor
    canonicals = canonical_models

    unless canonicals.count == 1
      clear_canonical_armor
      return
    end

    self.canonical_armor = canonicals.first
    self.name = canonical_armor.name # in case casing differs
    self.magical_effects = canonical_armor.magical_effects
    self.unit_weight = canonical_armor.unit_weight
    self.weight = canonical_armor.weight

    set_enchantments if persisted? && canonical_armor_id_changed?
  end

  def set_enchantments
    return if canonical_armor.enchantments.empty?

    enchantables_enchantments.added_automatically.find_each(&:destroy!)

    canonical_armor.enchantables_enchantments.each do |model|
      enchantables_enchantments.find_or_create_by!(
        enchantment_id: model.enchantment_id,
        strength: model.strength,
      ) {|new_model| new_model.added_automatically = true }
    end
  end

  def clear_canonical_armor
    self.canonical_armor_id = nil
    enchantables_enchantments.added_automatically.find_each(&:destroy!)
  end

  def canonical_model_matches?
    return false if canonical_model.nil?
    return false unless name.casecmp(canonical_model.name).zero?
    return false unless unit_weight.nil? || unit_weight == canonical_model.unit_weight
    return false unless magical_effects.nil? || magical_effects.casecmp(canonical_model.magical_effects)&.zero?

    true
  end

  def attributes_to_match
    {
      unit_weight:,
      weight:,
    }.compact
  end
end
