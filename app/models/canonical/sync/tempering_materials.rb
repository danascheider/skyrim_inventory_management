# frozen_string_literal: true

module Canonical
  module Sync
    class TemperingMaterials
      def self.perform(preserve_existing_records)
        new(preserve_existing_records).perform
      end

      def initialize(preserve_existing_records)
        @preserve_existing_records = preserve_existing_records
      end

      def perform
        Rails.logger.info 'Syncing canonical tempering materials...'

        raise PrerequisiteNotMetError.new(prerequisite_error_message) unless prerequisite_conditions_met?

        ActiveRecord::Base.transaction do
          destroy_existing_models unless preserve_existing_records

          json_data.each do |object|
            temperable = self
                           .class
                           .const_get(object[:temperable][:type])
                           .find_by(item_code: object[:temperable][:item_code])

            if temperable.name != object[:metadata][:name]
              raise DataIntegrityError.new(
                "Expected temperable item name to be #{object[:metadata][:name]} but was #{temperable.name}",
              )
            end

            object[:materials].each do |material|
              source_material_class = self.class.const_get(material[:metadata][:source_material_type])
              source_material = source_material_class.find_by(item_code: material[:metadata][:item_code])

              if source_material.name != material[:metadata][:name]
                raise DataIntegrityError.new(
                  "Expected material name to be #{material[:metadata][:name]} but was #{source_material.name}",
                )
              end

              attributes = material[:attributes].merge(temperable:, source_material:)

              create_or_update_model(attributes)
            end
          end
        end
      rescue StandardError => e
        Rails.logger.error(e.message)
        raise e
      end

      private

      attr_reader :preserve_existing_records

      def model_class
        Canonical::Material
      end

      def prerequisites
        [
          Canonical::Armor,
          Canonical::Weapon,
          Canonical::RawMaterial,
          Canonical::Ingredient,
        ]
      end

      def prerequisite_conditions_met?
        prerequisites.all?(&:any?)
      end

      def prerequisite_error_message
        "Prerequisite(s) not met: sync #{prerequisites.map(&:to_s).join(', ')} before tempering materials"
      end

      def json_file_path
        Rails.root.join(
          'lib',
          'tasks',
          'canonical_models',
          'canonical_tempering_materials.json',
        )
      end

      def json_data
        @json_data ||= JSON.parse(File.read(json_file_path), symbolize_names: true)
      end

      def destroy_existing_models
        model_class.with_temperable.destroy_all
      end

      def create_or_update_model(attributes)
        model_class.find_or_create_by!(**attributes)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Error saving #{model_name.downcase} with attributes #{attributes}: #{e.message}"
      rescue StandardError => e
        Rails.logger.error "Unexpected error #{e.class} saving #{model_name.downcase} with attributes #{attributes}: #{e.message}"
      end
    end
  end
end
