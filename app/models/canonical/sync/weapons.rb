# frozen_string_literal: true

module Canonical
  module Sync
    class Weapons < AssociationSyncer
      private

      def model_class
        Canonical::Weapon
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_weapons.json')
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
