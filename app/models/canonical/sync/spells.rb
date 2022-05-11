# frozen_string_literal: true

module Canonical
  module Sync
    class Spells < Syncer
      private

      def model_class
        Spell
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'spells.json')
      end
    end
  end
end
