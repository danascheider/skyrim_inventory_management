# frozen_string_literal: true

class EnchantablesEnchantment < ApplicationRecord
  belongs_to :enchantable, polymorphic: true
  belongs_to :enchantment

  validates :enchantment_id, uniqueness: { scope: %i[enchantable_id enchantable_type], message: 'must form a unique combination with enchantable item' }

  after_validation :validate_against_canonical,
                   if: :should_validate_against_canonical?

  after_save :save_associated!, unless: :canonical_enchantable?

  private

  def save_associated!
    enchantable.save!
  end

  def validate_against_canonical
    errors.add(:base, "doesn't match any canonical model") unless valid_enchantable?
  end

  def valid_enchantable?
    enchantable.canonical_models.any? do |canonical|
      canonical.enchantable || canonical.enchantables_enchantments.where(enchantment:, strength:).any?
    end
  end

  def should_validate_against_canonical?
    errors.none? && !canonical_enchantable?
  end

  def canonical_enchantable?
    enchantable_type.start_with?('Canonical::')
  end
end
