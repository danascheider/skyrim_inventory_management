# frozen_string_literal: true

class Book < ApplicationRecord
  belongs_to :game
  belongs_to :canonical_book,
             optional: true,
             class_name: 'Canonical::Book',
             inverse_of: :books
end
