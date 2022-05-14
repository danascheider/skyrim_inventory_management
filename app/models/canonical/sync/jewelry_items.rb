# frozen_string_literal: true

module Canonical
  module Sync
    class JewelryItems < AssociationSyncer
      private

      def model_class
        Canonical::JewelryItem
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_jewelry.json')
      end

      def prerequisites
        [
          Enchantment,
          Canonical::Material,
        ]
      end
    end
  end
end
