# frozen_string_literal: true

module Canonical
  module Sync
    class AlchemicalProperties < Syncer
      private

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'alchemical_properties.json')
      end

      def model_class
        AlchemicalProperty
      end
    end
  end
end
