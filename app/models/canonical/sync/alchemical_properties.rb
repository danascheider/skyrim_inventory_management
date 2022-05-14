# frozen_string_literal: true

module Canonical
  module Sync
    class AlchemicalProperties < Syncer
      private

      def model_class
        AlchemicalProperty
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'alchemical_properties.json')
      end
    end
  end
end
