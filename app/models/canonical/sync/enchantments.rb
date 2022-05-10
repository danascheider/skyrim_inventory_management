# frozen_string_literal: true

module Canonical
  module Sync
    class Enchantments
      JSON_FILE_PATH = Rails.root.join('lib', 'tasks', 'canonical_models', 'enchantments.json')

      def self.perform(preserve_existing_records)
        new(preserve_existing_records).perform
      end

      def initialize(preserve_existing_records)
        @preserve_existing_records = preserve_existing_records
      end

      def perform
        Rails.logger.info 'Syncing enchantments...'

        ActiveRecord::Base.transaction do
          destroy_existing_models unless preserve_existing_records

          json_data.each {|object| create_or_update_model(object) }
        rescue StandardError => e
          Rails.logger.error "Unexpected error #{e.class} while syncing enchantments: #{e.message}"
          raise e
        end
      end

      private

      attr_reader :preserve_existing_records

      def json_data
        @json_data ||= JSON.parse(File.read(JSON_FILE_PATH), symbolize_names: true)
      end

      def destroy_existing_models
        names = json_data.pluck(:name)
        Enchantment.where.not(name: names).destroy_all
      end

      def create_or_update_model(attributes)
        model = Enchantment.find_or_initialize_by(name: attributes[:name])
        model.assign_attributes(attributes)
        model.save!
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Error saving enchantment \"#{attributes[:name]}\": #{e.message}"
        raise e
      rescue StandardError => e
        Rails.logger.error "Unexpected error #{e.class} saving enchantment \"#{attributes[:name]}\": #{e.message}"
        raise e
      end
    end
  end
end
