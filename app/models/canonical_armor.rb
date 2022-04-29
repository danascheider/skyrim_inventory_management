# frozen_string_literal: true

class CanonicalArmor < ApplicationRecord
  validates :name, presence: true
  validates :weight,
            presence:  true,
            inclusion: {
                         in:      ['light armor', 'heavy armor'],
                         message: 'must be "light armor" or "heavy armor"',
                       }
  validates :body_slot,
            presence:  true,
            inclusion: {
                         in:      %w[head body hands feet shield],
                         message: 'must be "head", "body", "hands", "feet", or "shield"',
                       }
end
