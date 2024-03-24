# frozen_string_literal: true

module Canonical
  class Material < ApplicationRecord
    self.table_name = 'canonical_materials'

    belongs_to :source_material, polymorphic: true
    belongs_to :craftable, optional: true, polymorphic: true
    belongs_to :temperable, optional: true, polymorphic: true

    validate :validate_mutual_exclusivity
    validate :validate_uniqueness_in_proper_scope
    validates :quantity,
              numericality: {
                only_integer: true,
                greater_than: 0,
              }

    delegate :name, to: :source_material

    NON_UNIQUE_CRAFTABLE_MESSAGE = 'must form a unique combination with craftable item'
    NON_UNIQUE_TEMPERABLE_MESSAGE = 'must form a unique combination with temperable item'

    private

    def validate_mutual_exclusivity
      return unless craftable.present? && temperable.present?

      errors.add(
        :base,
        'must have either a craftable or a temperable association, not both',
      )
    end

    def validate_uniqueness_in_proper_scope
      if craftable.present?
        existing_model = Canonical::Material.find_by(
          source_material_id:,
          source_material_type:,
          craftable_id:,
          craftable_type:,
        )

        return if existing_model.nil?

        errors.add(:source_material, NON_UNIQUE_CRAFTABLE_MESSAGE)
      elsif temperable.present?
        existing_model = Canonical::Material.find_by(
          source_material_id:,
          source_material_type:,
          temperable_id:,
          temperable_type:,
        )

        return if existing_model.nil?

        errors.add(:source_material, NON_UNIQUE_TEMPERABLE_MESSAGE)
      else
        errors.add(:base, 'must have either a craftable or a temperable association')
      end
    end
  end
end
