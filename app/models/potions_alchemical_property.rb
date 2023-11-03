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

  validate :ensure_max_per_potion

  MAX_PER_POTION = Canonical::PotionsAlchemicalProperty::MAX_PER_POTION

  private

  def ensure_max_per_potion
    return if potion.alchemical_properties.length < MAX_PER_POTION
    return if persisted? &&
      !potion_id_changed? &&
      potion.alchemical_properties.length == MAX_PER_POTION

    errors.add(
      :potion,
      "can have a maximum of #{MAX_PER_POTION} effects",
    )
  end
end
