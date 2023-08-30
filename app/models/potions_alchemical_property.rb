# frozen_string_literal: true

class PotionsAlchemicalProperty < ApplicationRecord
  belongs_to :potion
  belongs_to :alchemical_property

  validates :alchemical_property_id,
            uniqueness: {
              scope: :potion_id,
              message: 'must form a unique combination with potion',
            }
  validates :strength,
            numericality: {
              greater_than: 0,
              only_integer: true,
              allow_nil: true,
            }
  validates :duration,
            numericality: {
              greater_than: 0,
              only_integer: true,
              allow_nil: true,
            }

  before_validation :set_attributes_from_canonical, if: -> { canonical_model.present? }

  delegate :canonical_potions, :canonical_potion, to: :potion

  def canonical_models
    return Canonical::PotionsAlchemicalProperty.where(**attributes_to_match) if attributes_to_match.any?

    Canonical::PotionsAlchemicalProperty.none
  end

  def canonical_model
    @canonical_model ||= begin
      models = canonical_models
      models.first if models.count == 1
    end
  end

  private

  def set_attributes_from_canonical
    return if canonical_model.nil?

    self.strength = canonical_model.strength
    self.duration = canonical_model.duration
  end

  def attributes_to_match
    {
      potion_id: canonical_potions.ids.presence,
      alchemical_property_id:,
      strength:,
      duration:,
    }.compact
  end
end
