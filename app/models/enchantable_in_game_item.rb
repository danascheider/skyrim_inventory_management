# frozen_string_literal: true

class EnchantableInGameItem < ApplicationRecord
  self.abstract_class = true

  MUST_DEFINE = 'Models inheriting from EnchantableInGameItem must define a'
  DUPLICATE_MATCH = 'is a duplicate of a unique in-game item'
  DOES_NOT_MATCH = "doesn't match any item that exists in Skyrim"

  belongs_to :game

  has_many :enchantables_enchantments,
           dependent: :destroy,
           as: :enchantable
  has_many :enchantments,
           -> { select 'enchantments.*, enchantables_enchantments.strength as strength' },
           through: :enchantables_enchantments,
           source: :enchantment

  validate :validate_unique_canonical
  validate :ensure_canonicals_exist

  before_validation :set_canonical_model
  before_validation :set_values_from_canonical

  after_create :set_enchantments, if: -> { canonical_model.present? }

  def canonical_model
    raise NotImplementedError.new("#{MUST_DEFINE} public \#canonical_model method")
  end

  def canonical_models
    return canonical_class.where(id: canonical_model_id) if canonical_model_matches?

    query = 'name ILIKE :name'
    query += ' AND magical_effects ILIKE :magical_effects' if magical_effects.present?

    canonicals = canonical_class.where(query, name:, magical_effects:)
    canonicals = canonicals.where(**attributes_to_match) if attributes_to_match.any?

    return canonicals if canonicals.none? || enchantments.none?

    enchantables_enchantments.added_manually.each do |join_model|
      canonicals = if join_model.strength.present?
                     canonicals.left_outer_joins(:enchantables_enchantments).where(
                       "(enchantables_enchantments.enchantment_id = :enchantment_id AND enchantables_enchantments.strength = :strength) OR #{canonical_table}.enchantable = true",
                       enchantment_id: join_model.enchantment_id,
                       strength: join_model.strength,
                     )
                   else
                     canonicals.left_outer_joins(:enchantables_enchantments).where(
                       "(enchantables_enchantments.enchantment_id = :enchantment_id AND enchantables_enchantments.strength IS NULL) OR #{canonical_table}.enchantable = true",
                       enchantment_id: join_model.enchantment_id,
                     )
                   end
    end

    canonical_class.where(id: canonicals.ids)
  end

  private

  def canonical_class
    raise NotImplementedError.new("#{MUST_DEFINE} private \#canonical_class method")
  end

  def canonical_model=(_other)
    raise NotImplementedError.new("#{MUST_DEFINE} private \#canonical_model= method")
  end

  def canonical_table
    raise NotImplementedError.new("#{MUST_DEFINE} private \#canonical_table method")
  end

  def canonical_model_id
    raise NotImplementedError.new("#{MUST_DEFINE} private \#canonical_model_id method")
  end

  def canonical_model_id_changed?
    raise NotImplementedError.new("#{MUST_DEFINE} private \#canonical_model_id_changed? method")
  end

  def inverse_relationship_name
    raise NotImplementedError.new("#{MUST_DEFINE} private \#inverse_relationship_name method")
  end

  def set_canonical_model
    canonicals = canonical_models

    unless canonicals.count == 1
      clear_canonical_model
      return
    end

    self.canonical_model = canonicals.first
  end

  def clear_canonical_model
    self.canonical_model = nil
    remove_automatically_added_enchantments!
  end

  def remove_automatically_added_enchantments!
    enchantables_enchantments.added_automatically.find_each(&:destroy!)
  end

  def set_values_from_canonical
    raise NotImplementedError.new("#{MUST_DEFINE} private \#set_values_from_canonical method")
  end

  def set_enchantments
    return if canonical_model.enchantments.empty?

    remove_automatically_added_enchantments!

    canonical_model.enchantables_enchantments.each do |model|
      enchantables_enchantments.find_or_create_by!(
        enchantment_id: model.enchantment_id,
        strength: model.strength,
      ) {|new_model| new_model.added_automatically = true }
    end
  end

  def validate_unique_canonical
    return unless canonical_model&.unique_item

    items = canonical_model.public_send(inverse_relationship_name).where(game_id:)

    return if items.count < 1
    return if items.count == 1 && items.first == self

    errors.add(:base, DUPLICATE_MATCH)
  end

  def ensure_canonicals_exist
    errors.add(:base, DOES_NOT_MATCH) if canonical_models.none?
  end

  def attributes_to_match
    raise NotImplementedError.new("#{MUST_DEFINE} private \#attributes_to_match method")
  end
end
