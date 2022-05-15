# frozen_string_literal: true

module Canonical
  module Sync
    class Powers < Syncer
      private

      def model_class
        Power
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'powers.json')
      end
    end
  end
end
