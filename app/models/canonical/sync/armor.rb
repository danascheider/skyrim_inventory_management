# frozen_string_literal: true

module Canonical
  module Sync
    class Armor < AssociationSyncer
      private

      def model_class
        Canonical::Armor
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_armor.json')
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
