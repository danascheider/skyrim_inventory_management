# frozen_string_literal: true

require 'json'

namespace :canonical_models do
  namespace :populate do
    desc 'Populate or update canonical alchemical properties from JSON data'
    task alchemical_properties: :environment do
      Rails.logger.info 'Populating canonical alchemical properties...'

      alchemical_properties = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'alchemical_properties.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        alchemical_properties.each do |property_attributes|
          property = AlchemicalProperty.find_or_initialize_by(name: property_attributes[:name])
          property.assign_attributes(property_attributes)
          property.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Error saving alchemical property \"#{property_attributes[:name]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Populate or update canonical enchantments from JSON data'
    task enchantments: :environment do
      Rails.logger.info 'Populating canonical enchantments...'

      enchantments = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'enchantments.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        enchantments.each do |enchantment_attributes|
          enchantment = Enchantment.find_or_initialize_by(name: enchantment_attributes[:name])
          enchantment.assign_attributes(enchantment_attributes)
          enchantment.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Error saving enchantment \"#{enchantment_attributes[:name]}\": #{e.message}")
          raise e
        end
      end
    end

    desc 'Populate or update canonical spells from JSON data'
    task spells: :environment do
      Rails.logger.info 'Populating canonical spells...'

      spells = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'spells.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        spells.each do |spell_attributes|
          spell = Spell.find_or_initialize_by(name: spell_attributes[:name])
          spell.assign_attributes(spell_attributes)
          spell.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Error saving spell \"#{spell_attributes[:name]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Populate or update all canonical models from JSON files'
    task all: :environment do
      Rake::Task['canonical_models:populate:alchemical_properties'].invoke
      Rake::Task['canonical_models:populate:enchantments'].invoke
      Rake::Task['canonical_models:populate:spells'].invoke
    end
  end
end
