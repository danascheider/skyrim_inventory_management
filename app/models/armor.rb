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
    return Canonical::Armor.where(id: canonical_armor.id) if canonical_model_matches?

    canonicals = Canonical::Armor.where('name ILIKE ?', name)
    attributes_to_match.any? ? canonicals.where(**attributes_to_match) : canonicals
  end

  def crafting_materials
    canonical_armor&.crafting_materials
  end

  def tempering_materials
    canonical_armor&.tempering_materials
  end

  private

  def set_canonical_armor
    return unless canonical_models.count == 1

    self.canonical_armor ||= canonical_models.first
    self.name = canonical_armor.name # in case casing differs
    self.unit_weight = canonical_armor.unit_weight
    self.weight = canonical_armor.weight
    self.magical_effects = canonical_armor.magical_effects

    set_enchantments if persisted?
  end

  def set_enchantments
    return if canonical_armor.enchantments.empty?

    canonical_armor.enchantables_enchantments.each do |model|
      enchantables_enchantments.find_or_create_by!(
        enchantment_id: model.enchantment_id,
        strength: model.strength,
      )
    end
  end

  def canonical_model_matches?
    return false if canonical_model.nil?
    return false unless name.nil? || name.casecmp(canonical_model.name).zero?
    return false unless unit_weight.nil? || unit_weight == canonical_model.unit_weight
    return false unless magical_effects.nil? || magical_effects == canonical_model.magical_effects

    true
  end

  def attributes_to_match
    {
      unit_weight:,
      weight:,
      magical_effects:,
    }.compact
  end
end
