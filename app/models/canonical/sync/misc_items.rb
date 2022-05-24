# frozen_string_literal: true

module Canonical
  module Sync
    class MiscItems < Syncer
      private

      def model_class
        Canonical::MiscItem
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_misc_items.json')
      end
    end
  end
end
