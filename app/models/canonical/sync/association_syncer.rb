# frozen_string_literal: true

module Canonical
  module Sync
    class AssociationSyncer
      def self.perform(preserve_existing_records)
        new(preserve_existing_records).perform
      end

      def initialize(preserve_existing_records)
        @preserve_existing_records = preserve_existing_records
      end

      def perform
        raise Canonical::Sync::PrerequisiteNotMetError.new(prerequisite_error_message) unless prerequisite_conditions_met?

        Rails.logger.info "Syncing #{model_name.downcase.pluralize}..."

        ActiveRecord::Base.transaction do
          destroy_existing_models unless preserve_existing_records

          json_data.each do |object|
            model = create_or_update_model(object.delete(:attributes))

            associations = object.keys

            next unless associations.any?

            associations.each do |key, _class_mapping|
              reflection                   = model_class.reflect_on_association(key)
              association_name             = reflection.through_reflection.name
              associated_model             = reflection.source_reflection.name
              associated_model_class       = reflection.klass
              associated_model_identifier  = associated_model_class.unique_identifier
              associated_fk                = reflection.foreign_key.to_sym

              if !preserve_existing_records
                identifiers = object[key].pluck(associated_model_identifier)
                assn_ids    = associated_model_class.where(associated_model_identifier => identifiers).ids
                model.send(association_name).where.not(associated_fk => assn_ids).destroy_all
              end

              object[key].each do |association|
                join_model = model
                               .send(association_name)
                               .find_or_initialize_by(associated_model => associated_model_class.find_by(associated_model_identifier => association.delete(associated_model_identifier)))
                join_model.assign_attributes(association)
                join_model.save!
              rescue ActiveRecord::RecordInvalid => e
                Rails.logger.error "Validation error saving associations for #{model_name.downcase} \"#{model.send(model_identifier)}\": #{e.message}"
                raise e
              end
            end
          end
        rescue StandardError => e
          Rails.logger.error "Unexpected error #{e.class} while syncing #{model_name.downcase.pluralize}: #{e.message}"
          raise e
        end
      rescue PrerequisiteNotMetError => e
        Rails.logger.error e.message
        raise e
      end

      private

      attr_reader :preserve_existing_records

      def model_class
        raise NotImplementedError.new('Child class of Canonical::Sync::AssociationSyncer must implement #model_class method')
      end

      def model_name
        model_class.to_s.scan(/[A-Z][a-z]*/).join(' ')
      end

      def model_identifier
        model_class.unique_identifier
      end

      def json_file_path
        raise NotImplementedError.new('Child class of Canonical::Sync::AssociationSyncer must implement #json_file_path method')
      end

      def json_data
        @json_data ||= JSON.parse(File.read(json_file_path), symbolize_names: true)
      end

      def prerequisites
        []
      end

      def prerequisite_error_message
        "Prerequisite(s) not met: sync #{prerequisites.map(&:to_s).join(', ')} before #{model_name.downcase.pluralize}"
      end

      def prerequisite_conditions_met?
        prerequisites.empty? || prerequisites.all?(&:any?)
      end

      def create_or_update_model(attributes)
        model = model_class.find_or_initialize_by(model_identifier => attributes[model_identifier])
        model.assign_attributes(attributes)
        model.save!
        model
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Error saving #{model_name.downcase} \"#{attributes[model_identifier]}\": #{e.message}"
        raise e
      rescue StandardError => e
        Rails.logger.error "Unexpected error #{e.class} saving #{model_name.downcase} \"#{attributes[model_identifier]}\": #{e.message}"
        raise e
      end

      def destroy_existing_models
        identifiers = json_data.pluck(:attributes).map {|item| item[model_identifier] }
        model_class.where.not(model_identifier => identifiers).destroy_all
      end
    end
  end
end
