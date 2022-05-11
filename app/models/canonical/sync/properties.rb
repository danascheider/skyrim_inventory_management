# frozen_string_literal: true

module Canonical
  module Sync
    class Properties
      JSON_FILE_PATH = Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_properties.json')

      def self.perform(preserve_existing_records)
        new(preserve_existing_records).perform
      end

      def initialize(preserve_existing_records)
        @preserve_existing_records = preserve_existing_records
      end

      def perform
        Rails.logger.info 'Syncing canonical properties...'

        ActiveRecord::Base.transaction do
          destroy_existing_models unless preserve_existing_records

          json_data.each {|object| create_or_update_model(object) }
        rescue StandardError => e
          Rails.logger.error "Unexpected error #{e.class} while syncing canonical properties: #{e.message}"
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
        Canonical::Property.where.not(name: names).destroy_all
      end

      def create_or_update_model(attributes)
        model = Canonical::Property.find_or_initialize_by(name: attributes[:name])
        model.assign_attributes(attributes)
        model.save!
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Error saving canonical property \"#{attributes[:name]}\": #{e.message}"
        raise e
      rescue StandardError => e
        Rails.logger.error "Unexpected error #{e.class} saving canonical property \"#{attributes[:name]}\": #{e.message}"
        raise e
      end
    end
  end
end
