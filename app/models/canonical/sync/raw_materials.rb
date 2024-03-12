# frozen_string_literal: true

module Canonical
  module Sync
    class RawMaterials < Syncer
      private

      def model_class
        Canonical::RawMaterial
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_raw_materials.json')
      end
    end
  end
end
