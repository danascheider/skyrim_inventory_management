# frozen_string_literal: true

module Canonical
  module Sync
    class Spells
      JSON_FILE_PATH = Rails.root.join('lib', 'tasks', 'canonical_models', 'spells.json')

      def self.perform(preserve_existing_records)
        new(preserve_existing_records).perform
      end

      def initialize(preserve_existing_records)
        @preserve_existing_records = preserve_existing_records
      end

      def perform
        Rails.logger.info 'Syncing spells...'

        ActiveRecord::Base.transaction do
          destroy_existing_models unless preserve_existing_records

          json_data.each {|object| create_or_update_model(object) }
        end
      rescue StandardError => e
        Rails.logger.error "Unexpected error #{e.class} while syncing spells: #{e.message}"
        raise e
      end

      private

      attr_reader :preserve_existing_records

      def json_data
        @json_data ||= JSON.parse(File.read(JSON_FILE_PATH), symbolize_names: true)
      end

      def destroy_existing_models
        names = json_data.pluck(:name)
        Spell.where.not(name: names).destroy_all
      end

      def create_or_update_model(attributes)
        model = Spell.find_or_initialize_by(name: attributes[:name])
        model.assign_attributes(attributes)
        model.save!
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Error saving spell \"#{attributes[:name]}\": #{e.message}"
        raise e
      rescue StandardError => e
        Rails.logger.error "Unexpected error #{e.class} saving spell \"#{attributes[:name]}\": #{e.message}"
        raise e
      end
    end
  end
end
