# frozen_string_literal: true

module Canonical
  module Sync
    class ClothingItems < AssociationSyncer
      private

      def model_class
        Canonical::ClothingItem
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_clothing.json')
      end

      def prerequisites
        [Enchantment]
      end
    end
  end
end
