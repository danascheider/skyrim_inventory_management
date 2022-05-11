# frozen_string_literal: true

module Canonical
  module Sync
    class Properties < Syncer
      private

      def model_class
        Canonical::Property
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_properties.json')
      end
    end
  end
end
