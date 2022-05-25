# frozen_string_literal: true

module Canonical
  module Sync
    class Potions < AssociationSyncer
      private

      def model_class
        Canonical::Potion
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_potions.json')
      end

      def prerequisites
        [AlchemicalProperty]
      end
    end
  end
end
