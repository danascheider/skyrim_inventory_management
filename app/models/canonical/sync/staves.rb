# frozen_string_literal: true

module Canonical
  module Sync
    class Staves < AssociationSyncer
      private

      def model_class
        Canonical::Staff
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_staves.json')
      end

      def prerequisites
        [Power, Spell]
      end
    end
  end
end
