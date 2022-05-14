# frozen_string_literal: true

module Canonical
  module Sync
    class Armor
      def self.perform(preserve_existing_records)
        new(preserve_existing_records).perform
      end

      def initialize(preserve_existing_records)
        @preserve_existing_records = preserve_existing_records
      end

      def perform
        raise Canonical::Sync::PrerequisiteNotMetError.new('Prerequisite not met: sync canonical materials and enchantments before armor') unless Enchantment.any? && Canonical::Material.any?

        Rails.logger.info "Syncing #{model_name.downcase.pluralize}..."

        ActiveRecord::Base.transaction do
          destroy_existing_models unless preserve_existing_records

          json_data.each do |object|
            model = create_or_update_model(object[:attributes])

            if !preserve_existing_records
              names           = object[:enchantments].pluck(:name)
              enchantment_ids = Enchantment.where(name: names).ids
              model.canonical_armors_enchantments.where.not(enchantment_id: enchantment_ids).destroy_all
            end

            # create enchantments
            object[:enchantments].each do |enchantment|
              join_model          = model
                                      .canonical_armors_enchantments
                                      .find_or_initialize_by(enchantment: Enchantment.find_by(name: enchantment[:name]))
              join_model.strength = enchantment[:strength]
              join_model.save!
            rescue ActiveRecord::RecordInvalid => e
              Rails.logger.error "Validation error saving associations for #{model_name.downcase} \"#{model.send(model_identifier)}\": #{e.message}"
              raise e
            end

            if !preserve_existing_records
              codes        = object[:smithing_materials].pluck(:item_code)
              material_ids = Canonical::Material.where(item_code: codes).ids
              model.canonical_armors_smithing_materials.where.not(material_id: material_ids).destroy_all
            end

            # create materials
            object[:smithing_materials].each do |material|
              join_model          = model
                                      .canonical_armors_smithing_materials
                                      .find_or_initialize_by(material: Canonical::Material.find_by(item_code: material[:item_code]))
              join_model.quantity = material[:quantity]
              join_model.save!
            rescue ActiveRecord::RecordInvalid => e
              Rails.logger.error "Validation error saving associations for #{model_name.downcase} \"#{model.send(model_identifier)}\": #{e.message}"
              raise e
            end

            if !preserve_existing_records
              codes        = object[:tempering_materials].pluck(:item_code)
              material_ids = Canonical::Material.where(item_code: codes).ids
              model.canonical_armors_tempering_materials.where.not(material_id: material_ids).destroy_all
            end

            # create materials
            object[:tempering_materials].each do |material|
              join_model          = model
                                      .canonical_armors_tempering_materials
                                      .find_or_initialize_by(material: Canonical::Material.find_by(item_code: material[:item_code]))
              join_model.quantity = material[:quantity]
              join_model.save!
            rescue ActiveRecord::RecordInvalid => e
              Rails.logger.error "Validation error saving associations for #{model_name.downcase} \"#{model.send(model_identifier)}\": #{e.message}"
              raise e
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
        Canonical::Armor
      end

      def model_name
        model_class.to_s.scan(/[A-Z][a-z]*/).join(' ')
      end

      def model_identifier
        model_class.unique_identifier
      end

      def json_file_path
        Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_armor.json')
      end

      def json_data
        @json_data ||= JSON.parse(File.read(json_file_path), symbolize_names: true)
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
