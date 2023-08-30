# frozen_string_literal: true

class Potion < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_potion, optional: true, class_name: 'Canonical::Potion'

  has_many :potions_alchemical_properties, dependent: :destroy, inverse_of: :potion
  has_many :alchemical_properties, through: :potions_alchemical_properties

  validates :name, presence: true
  validates :unit_weight, numericality: { greater_than_or_equal_to: 0, allow_blank: true }

  before_validation :set_canonical_potion

  def canonical_models
    return Canonical::Potion.where(id: canonical_potion_id) if canonical_potion.present?

    matching = Canonical::Potion.where('name ILIKE ?', name)
    matching = matching.where(**attributes_to_match) if attributes_to_match.any?

    return matching if matching.blank? || alchemical_properties.none?

    matching
      .joins(:canonical_potions_alchemical_properties)
      .where(association_query)
      .group('canonical_potions.id')
      .having('COUNT(*) >= ?', potions_alchemical_properties.length)
  end

  alias_method :canonical_potions, :canonical_models

  private

  def attributes_to_match
    { unit_weight: }.compact
  end

  def set_canonical_potion
    return unless canonical_models.count == 1
    return if canonical_potion.present?

    self.canonical_potion = canonical_models.first
    self.name = canonical_potion.name
    self.unit_weight = canonical_potion.unit_weight
  end

  def association_query
    properties_to_match = potions_alchemical_properties.map do |prop|
      { strength: prop.strength, duration: prop.duration }.compact
    end

    conditions = properties_to_match.map do |prop|
      strength_condition = prop[:strength].nil? ? nil : "(canonical_potions_alchemical_properties.strength = #{prop[:strength]})"
      duration_condition = prop[:duration].nil? ? nil : "(canonical_potions_alchemical_properties.duration = #{prop[:duration]})"

      conditions_array = [strength_condition, duration_condition].compact

      case conditions_array.length
      when 2
        "(#{conditions_array.join(' AND ')})"
      when 1
        conditions_array.first
      end
    end

    conditions.join(' OR ')
  end
end
