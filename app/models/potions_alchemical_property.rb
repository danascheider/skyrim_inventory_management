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

  delegate :canonical_potions, to: :potion

  def canonical_models
    return [] if canonical_potions.none?

    Canonical::PotionsAlchemicalProperty.where(**attributes_to_match)
  end

  private

  def attributes_to_match
    {
      potion_id: canonical_potions.ids.presence,
      alchemical_property_id:,
      strength:,
      duration:,
    }.compact
  end
end
