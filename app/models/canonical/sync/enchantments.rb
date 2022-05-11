# frozen_string_literal: true

module Canonical
  module Sync
    class Enchantments < Syncer
      private

      def model_class
        Enchantment
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'enchantments.json')
      end
    end
  end
end
