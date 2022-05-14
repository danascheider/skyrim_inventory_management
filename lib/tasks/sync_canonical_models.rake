# frozen_string_literal: true

require 'json'

FALSEY_VALUES = [false, 'false'].freeze

namespace :canonical_models do
  namespace :sync do
    desc 'Sync alchemical properties in the database with JSON data'
    task :alchemical_properties, [:preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:alchemical_property, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical enchantments in the database with JSON data'
    task :enchantments, [:preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:enchantment, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical spells in the database with JSON data'
    task :spells, [:preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:spell, FALSEY_VALUES.exclude?(preserve_existing_records))
    end

    desc 'Sync canonical properties in the database with JSON data'
    task :properties, [:preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:property, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical building and smithing materials in the database with JSON data'
    task :materials, [:preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:material, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical jewelry items in the database with JSON data'
    # rubocop:disable Layout/BlockAlignment
    task :jewelry,
         [:preserve_existing_records] => %w[
                                           environment
                                           canonical_models:sync:materials
                                           canonical_models:sync:enchantments
                                         ] do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:jewelry, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical clothing items in the database with JSON data'
    task :clothing,
         [:preserve_existing_records] => %w[
                                           environment
                                           canonical_models:sync:materials
                                           canonical_models:sync:enchantments
                                         ] do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:clothing, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical armor models in the database with JSON data'
    task :armor,
         [:preserve_existing_records] => %w[
                                           environment
                                           canonical_models:sync:materials
                                           canonical_models:sync:enchantments
                                         ] do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:armor, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical ingredient models in the database with JSON data'
    task :ingredients,
         %i[preserve_existing_records] => %w[
                                            environment
                                            canonical_models:sync:alchemical_properties
                                          ] do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:ingredient, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical weapon models in the database with JSON data'
    task :weapons,
         %i[preserve_existing_records] => %w[
                                            environment
                                            canonical_models:sync:enchantments
                                            canonical_models:sync:materials
                                          ] do |_t, args|
      Rails.logger.info 'Syncing canonical weapons...'

      args.with_defaults(preserve_existing_records: false)
      preserve_existing_records = FALSEY_VALUES.exclude?(args[:preserve_existing_records])

      weapons    = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_weapons.json')), symbolize_names: true)
      item_codes = []
      weapons.each do |data|
        code = data.dig(:attributes, :item_code).upcase!
        item_codes << code unless preserve_existing_records
      end

      ActiveRecord::Base.transaction do
        Canonical::Weapon.where.not(item_code: item_codes).destroy_all unless preserve_existing_records

        weapons.each do |data|
          weapon = Canonical::Weapon.find_or_initialize_by(item_code: data.dig(:attributes, :item_code))
          weapon.assign_attributes(data[:attributes])
          weapon.save!

          if !preserve_existing_records
            enchantment_names = data[:enchantments].pluck(:name).split(',')
            enchantment_ids   = weapon.enchantments.where.not(name: enchantment_names).ids
            weapon.canonical_weapons_enchantments.where(enchantment_id: enchantment_ids).destroy_all

            data[:smithing_materials].each {|material| material[:item_code].upcase! }
            smithing_material_codes = data[:smithing_materials].pluck(:item_code)
            smithing_material_ids   = weapon.smithing_materials.where.not(item_code: smithing_material_codes).ids
            weapon.canonical_weapons_smithing_materials.where(material_id: smithing_material_ids).destroy_all

            data[:tempering_materials].each {|material| material[:item_code].upcase! }
            tempering_material_codes = data[:tempering_materials].pluck(:item_code)
            tempering_material_ids   = weapon.tempering_materials.where.not(item_code: tempering_material_codes).ids
            weapon.canonical_weapons_tempering_materials.where(material_id: tempering_material_ids).destroy_all
          end

          data[:smithing_materials].each do |m|
            material = Canonical::Material.find_by(item_code: m[:item_code])

            if material.present? && weapon.smithing_materials.exclude?(material)
              Canonical::WeaponsSmithingMaterial.create!(
                weapon:   weapon,
                material: material,
                quantity: m[:quantity],
              )
            elsif weapon.smithing_materials.include?(material)
              weapon.canonical_weapons_smithing_materials
                .find_by(material_id: material.id)
                .update!(quantity: m[:quantity])
            else
              Rails.logger.warn("Weapon \"#{weapon.item_code}\" calls for smithing material \"#{m[:item_code]}\" but material does not exist.")
            end
          end

          data[:tempering_materials].each do |m|
            material = Canonical::Material.find_by(item_code: m[:item_code])

            if material.present? && weapon.tempering_materials.exclude?(material)
              Canonical::WeaponsTemperingMaterial.create!(
                weapon:   weapon,
                material: material,
                quantity: m[:quantity],
              )
            elsif weapon.tempering_materials.include?(material)
              weapon.canonical_weapons_tempering_materials
                .find_by(material_id: material.id)
                .update!(quantity: m[:quantity])
            else
              Rails.logger.warn("Weapon \"#{weapon.item_code}\" calls for tempering material \"#{m[:item_code]}\" but material does not exist.")
            end
          end

          data[:enchantments].each do |ench|
            enchantment = Enchantment.find_by(name: ench[:name])

            if enchantment.present? && weapon.enchantments.exclude?(enchantment)
              Canonical::WeaponsEnchantment.create!(
                weapon:      weapon,
                enchantment: enchantment,
                strength:    ench[:strength],
              )
            elsif weapon.enchantments.include?(enchantment)
              weapon.canonical_weapons_enchantments
                .find_by(enchantment_id: enchantment.id)
                .update!(strength: ench[:strength])
            else
              Rails.logger.warn("Weapon #{weapon.item_code} calls for enchantment #{ench[:name]} but enchantment does not exist.")
            end
          rescue ActiveRecord::RecordInvalid => e
            Rails.logger.error "Validation error saving canonical weapon \"#{data.dig(:attributes, :item_code)}\": #{e.message}"
            raise e
          rescue StandardError => e
            Rails.logger.error "Unknown error saving canonical weapon \"#{data.dig(:attributes, :item_code)}\": #{e.message}"
            raise e
          end
        end
      end
    end
    # rubocop:enable Layout/BlockAlignment

    desc 'Sync all canonical models with JSON files'
    task :all, [:preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Rake::Task['canonical_models:sync:properties'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:enchantments'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:spells'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:alchemical_properties'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:materials'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:jewelry'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:clothing'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:armor'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:ingredients'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:weapons'].invoke(args[:preserve_existing_records])
    end
  end
end
