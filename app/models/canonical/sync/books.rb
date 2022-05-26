# frozen_string_literal: true

module Canonical
  module Sync
    class Books < AssociationSyncer
      private

      def model_class
        Canonical::Book
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_books.json')
      end

      def prerequisites
        [Canonical::Ingredient]
      end
    end
  end
end
