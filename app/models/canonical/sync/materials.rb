# frozen_string_literal: true

module Canonical
  module Sync
    class Materials < Syncer
      private

      def model_class
        Canonical::Material
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_materials.json')
      end
    end
  end
end
