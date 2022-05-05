# frozen_string_literal: true

require 'json'

FALSEY_VALUES = [false, 'false'].freeze

namespace :canonical_models do
  namespace :sync do
    desc 'Sync alchemical properties in the database with JSON data'
    task :alchemical_properties, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Syncing canonical alchemical properties...'

      args.with_defaults(preserve_existing_records: false)

      alchemical_properties = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'alchemical_properties.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if FALSEY_VALUES.include?(args[:preserve_existing_records])
          names = alchemical_properties.pluck(:name)
          AlchemicalProperty.where.not(name: names).destroy_all
        end

        alchemical_properties.each do |property_attributes|
          property = AlchemicalProperty.find_or_initialize_by(name: property_attributes[:name])
          property.assign_attributes(property_attributes)
          property.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Validation error saving alchemical property \"#{property_attributes[:name]}\": #{e.message}"
          raise e
        rescue StandardError => e
          Rails.logger.error "Unknown error #{e.class} saving alchemical property \"#{property_attributes[:name]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Sync canonical enchantments in the database with JSON data'
    task :enchantments, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Syncing canonical enchantments...'

      args.with_defaults(preserve_existing_records: false)

      enchantments = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'enchantments.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if FALSEY_VALUES.include?(args[:preserve_existing_records])
          names = enchantments.pluck(:name)
          Enchantment.where.not(name: names).destroy_all
        end

        enchantments.each do |enchantment_attributes|
          enchantment = Enchantment.find_or_initialize_by(name: enchantment_attributes[:name])
          enchantment.assign_attributes(enchantment_attributes)
          enchantment.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Validation error saving enchantment \"#{enchantment_attributes[:name]}\": #{e.message}")
          raise e
        rescue StandardError => e
          Rails.logger.error "Unknown error #{e.class} saving enchantment \"#{enchantment_attributes[:name]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Sync canonical spells in the database with JSON data'
    task :spells, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Syncing canonical spells...'

      args.with_defaults(preserve_existing_records: false)

      spells = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'spells.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if FALSEY_VALUES.include?(args[:preserve_existing_records])
          names = spells.pluck(:name)
          Spell.where.not(name: names).destroy_all
        end

        spells.each do |spell_attributes|
          spell = Spell.find_or_initialize_by(name: spell_attributes[:name])
          spell.assign_attributes(spell_attributes)
          spell.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Validation error saving spell \"#{spell_attributes[:name]}\": #{e.message}"
          raise e
        rescue StandardError => e
          Rails.logger.error "Unknown error #{e.class} saving spell \"#{spell_attributes[:name]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Sync canonical properties in the database with JSON data'
    task :canonical_properties, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Syncing canonical properties...'

      args.with_defaults(preserve_existing_records: false)

      canonical_properties = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_properties.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if FALSEY_VALUES.include?(args[:preserve_existing_records])
          names = canonical_properties.pluck(:name)
          CanonicalProperty.where.not(name: names).destroy_all
        end

        canonical_properties.each do |canonical_property_attributes|
          property = CanonicalProperty.find_or_initialize_by(name: canonical_property_attributes[:name])
          property.assign_attributes(canonical_property_attributes)
          property.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Validation error saving canonical property \"#{canonical_property_attributes[:name]}\": #{e.message}"
          raise e
        rescue StandardError => e
          Rails.logger.error "Unknown error saving canonical property \"#{canonical_property_attributes[:name]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Sync canonical building and smithing materials in the database with JSON data'
    task :canonical_materials, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Syncing canonical materials...'

      args.with_defaults(preserve_existing_records: false)

      canonical_materials = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_materials.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if FALSEY_VALUES.include?(args[:preserve_existing_records])
          item_codes = canonical_materials.pluck(:item_code)
          CanonicalMaterial.where.not(item_code: item_codes).destroy_all
        end

        canonical_materials.each do |canonical_material_attributes|
          material = CanonicalMaterial.find_or_initialize_by(item_code: canonical_material_attributes[:item_code])
          material.assign_attributes(canonical_material_attributes)
          material.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Validation error saving canonical material \"#{canonical_material_attributes[:item_code]}\": #{e.message}"
          raise e
        rescue StandardError => e
          Rails.logger.error "Unknown error saving canonical material \"#{canonical_material_attributes[:item_code]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Sync canonical jewelry items in the database with JSON data'
    # rubocop:disable Layout/BlockAlignment
    task :canonical_jewelry,
         [:preserve_existing_records] => %w[
                                           environment
                                           canonical_models:sync:canonical_materials
                                           canonical_models:sync:enchantments
                                         ] do |_t, args|
      Rails.logger.info 'Syncing canonical jewelry items...'

      args.with_defaults(preserve_existing_records: false)

      items = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_jewelry.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if FALSEY_VALUES.include?(args[:preserve_existing_records])
          item_codes = items.map {|item| item[:attributes][:item_code] }
          CanonicalJewelryItem.where.not(item_code: item_codes).destroy_all
        end

        items.each do |data|
          item = CanonicalJewelryItem.find_or_initialize_by(item_code: data[:attributes][:item_code])
          item.assign_attributes(data[:attributes])
          item.save!

          if FALSEY_VALUES.include?(args[:preserve_existing_records])
            material_codes = data[:materials].pluck(:item_code)
            material_ids   = item.canonical_materials.where.not(item_code: material_codes).ids
            item.canonical_jewelry_items_canonical_materials.where(canonical_material_id: material_ids).destroy_all

            enchantment_names = data[:enchantments].pluck(:name)
            enchantment_ids   = item.enchantments.where.not(name: enchantment_names).ids
            item.canonical_jewelry_items_enchantments.where(enchantment_id: enchantment_ids).destroy_all
          end

          data[:materials].each do |m|
            material = CanonicalMaterial.find_by(item_code: m[:item_code])

            if material.present? && item.canonical_materials.exclude?(material)
              CanonicalJewelryItemsCanonicalMaterial.create!(
                canonical_jewelry_item: item,
                canonical_material:     material,
                quantity:               m[:quantity],
              )
            elsif item.canonical_materials.include?(material)
              item.canonical_jewelry_items_canonical_materials
                .find_by(canonical_material_id: material.id)
                .update!(quantity: m[:quantity])
            else
              Rails.logger.warn("Jewelry item #{item.item_code} calls for material #{m[:item_code]} but material does not exist.")
            end
          end

          data[:enchantments].each do |en|
            enchantment = Enchantment.find_by(name: en[:name])

            if enchantment.present? && item.enchantments.exclude?(enchantment)
              CanonicalJewelryItemsEnchantment.create!(
                canonical_jewelry_item: item,
                enchantment:            enchantment,
                strength:               en[:strength],
              )
            elsif item.enchantments.include?(enchantment)
              item.canonical_jewelry_items_enchantments
                .find_by(enchantment_id: enchantment.id)
                .update!(strength: en[:strength])
            else
              Rails.logger.warn("Jewelry item #{item.item_code} calls for enchantment #{en[:name]} but enchantment does not exist.")
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Validation error saving canonical jewelry item \"#{data[:attributes][:item_code]}\": #{e.message}"
          raise e
        rescue StandardError => e
          Rails.logger.error "Unknown error saving canonical jewelry item \"#{data[:attributes][:item_code]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Sync canonical clothing items in the database with JSON data'
    task :canonical_clothing,
         [:preserve_existing_records] => %w[
                                           environment
                                           canonical_models:sync:canonical_materials
                                           canonical_models:sync:enchantments
                                         ] do |_t, args|
      Rails.logger.info 'Syncing canonical clothing items...'

      args.with_defaults(preserve_existing_records: false)

      items = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_clothing.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if FALSEY_VALUES.include?(args[:preserve_existing_records])
          item_codes = items.map {|item| item[:attributes][:item_code] }
          CanonicalClothingItem.where.not(item_code: item_codes).destroy_all
        end

        items.each do |data|
          item = CanonicalClothingItem.find_or_initialize_by(item_code: data[:attributes][:item_code])
          item.assign_attributes(data[:attributes])
          item.save!

          if FALSEY_VALUES.include?(args[:preserve_existing_records])
            names           = data[:enchantments].pluck(:name)
            enchantment_ids = item.enchantments.where.not(name: names).ids
            item.canonical_clothing_items_enchantments.where(enchantment_id: enchantment_ids).destroy_all
          end

          data[:enchantments].each do |en|
            enchantment = Enchantment.find_by(name: en[:name])

            if enchantment.present? && item.enchantments.exclude?(enchantment)
              CanonicalClothingItemsEnchantment.find_or_create_by!(
                canonical_clothing_item: item,
                enchantment:             enchantment,
                strength:                en[:strength],
              )
            elsif item.enchantments.include?(enchantment)
              item.canonical_clothing_items_enchantments
                .find_by(enchantment_id: enchantment.id)
                .update!(strength: en[:strength])
            else
              Rails.logger.warn("Clothing item #{item.item_code} calls for enchantment #{en[:name]} but enchantment does not exist.")
            end
          end
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "Validation error saving canonical clothing items: #{e.message}"
        raise e
      rescue StandardError => e
        Rails.logger.error "Unknown error saving canonical clothing items: #{e.message}"
        raise e
      end
    end

    desc 'Sync canonical armor models in the database with JSON data'
    task :canonical_armor,
         [:preserve_existing_records] => %w[
                                           environment
                                           canonical_models:sync:canonical_materials
                                           canonical_models:sync:enchantments
                                         ] do |_t, args|
      Rails.logger.info 'Syncing canonical armor items...'

      args.with_defaults(preserve_existing_records: false)

      items = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_armor.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if FALSEY_VALUES.include?(args[:preserve_existing_records])
          item_codes = items.map {|item| item[:attributes][:item_code] }
          CanonicalArmor.where.not(item_code: item_codes).destroy_all
        end

        items.each do |data|
          item = CanonicalArmor.find_or_initialize_by(item_code: data[:attributes][:item_code])
          item.assign_attributes(data[:attributes])
          item.save!

          if FALSEY_VALUES.include?(args[:preserve_existing_records])
            enchantment_names = data[:enchantments].pluck(:name)
            enchantment_ids   = item.enchantments.where.not(name: enchantment_names).ids
            item.canonical_armors_enchantments.where(enchantment_id: enchantment_ids).destroy_all

            smithing_material_codes = data[:smithing_materials].pluck(:item_code)
            smithing_material_ids   = item.smithing_materials.where.not(item_code: smithing_material_codes).ids
            item.canonical_armors_smithing_materials.where(canonical_material_id: smithing_material_ids).destroy_all

            tempering_material_codes = data[:tempering_materials].pluck(:item_code)
            tempering_material_ids   = item.tempering_materials.where.not(item_code: tempering_material_codes).ids
            item.canonical_armors_tempering_materials.where(canonical_material_id: tempering_material_ids).destroy_all
          end

          data[:smithing_materials].each do |m|
            material = CanonicalMaterial.find_by(item_code: m[:item_code])

            if material.present? && item.smithing_materials.exclude?(material)
              CanonicalArmorsSmithingMaterial.create!(
                canonical_armor:    item,
                canonical_material: material,
                quantity:           m[:quantity],
              )
            elsif item.smithing_materials.include?(material)
              item.canonical_armors_smithing_materials
                .find_by(canonical_material_id: material.id)
                .update!(quantity: m[:quantity])
            else
              Rails.logger.warn("Armor item #{item.item_code} calls for smithing material #{m[:item_code]} but material does not exist.")
            end
          end

          data[:tempering_materials].each do |m|
            material = CanonicalMaterial.find_by(item_code: m[:item_code])

            if material.present? && item.tempering_materials.exclude?(material)
              CanonicalArmorsTemperingMaterial.create!(
                canonical_armor:    item,
                canonical_material: material,
                quantity:           m[:quantity],
              )
            elsif item.tempering_materials.include?(material)
              item.canonical_armors_tempering_materials
                .find_by(canonical_material_id: material.id)
                .update!(quantity: m[:quantity])
            else
              Rails.logger.warn("Armor item #{item.item_code} calls for tempering material #{m[:item_code]} but material does not exist.")
            end
          end

          data[:enchantments].each do |en|
            enchantment = Enchantment.find_by(name: en[:name])

            if enchantment.present? && item.enchantments.exclude?(enchantment)
              CanonicalArmorsEnchantment.create!(
                canonical_armor: item,
                enchantment:     enchantment,
                strength:        en[:strength],
              )
            elsif item.enchantments.include?(enchantment)
              item.canonical_armors_enchantments
                .find_by(enchantment_id: enchantment.id)
                .update!(strength: en[:strength])
            else
              Rails.logger.warn("Armor item #{item.item_code} calls for enchantment #{en[:name]} but enchantment does not exist.")
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Validation error saving canonical jewelry item \"#{data[:attributes][:item_code]}\": #{e.message}"
          raise e
        rescue StandardError => e
          Rails.logger.error "Unknown error saving canonical jewelry item \"#{data[:attributes][:item_code]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Sync canonical ingredient models in the database with JSON data'
    task :canonical_ingredients,
         %i[preserve_existing_records] => %w[
                                            environment
                                            canonical_models:sync:alchemical_properties
                                          ] do |_t, args|
      Rails.logger.info 'Syncing canonical ingredients...'

      args.with_defaults(preserve_existing_records: false)

      ingredients = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_ingredients.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if FALSEY_VALUES.include?(args[:preserve_existing_records])
          item_codes = ingredients.map {|item| item[:attributes][:item_code] }
          CanonicalIngredient.where.not(item_code: item_codes).destroy_all
        end

        ingredients.each do |i|
          ingredient = CanonicalIngredient.find_or_initialize_by(item_code: i[:attributes][:item_code])
          ingredient.assign_attributes(i[:attributes])
          ingredient.save!

          if FALSEY_VALUES.include?(args[:preserve_existing_records])
            alchemical_property_ids = AlchemicalProperty.where(name: i[:alchemical_properties].pluck(:name)).ids
            ingredient.alchemical_properties_canonical_ingredients
              .where
              .not(alchemical_property_id: alchemical_property_ids)
              .destroy_all
          end

          i[:alchemical_properties].each do |property|
            alchemical_property = AlchemicalProperty.find_by(name: property[:name])

            if alchemical_property.present? && ingredient.alchemical_properties.exclude?(alchemical_property)
              AlchemicalPropertiesCanonicalIngredient.create!(
                alchemical_property:  alchemical_property,
                canonical_ingredient: ingredient,
                priority:             property[:priority],
                strength_modifier:    property[:strength_modifier],
                duration_modifier:    property[:duration_modifier],
              )
            elsif ingredient.alchemical_properties.include?(alchemical_property)
              join_model = ingredient.alchemical_properties_canonical_ingredients.find_by(alchemical_property_id: alchemical_property.id)

              Rails.logger.warn "(Canonical Ingredient #{ingredient.item_code}): Priority of alchemical properties must be updated manually" unless join_model.priority == property[:priority]

              join_model.update!(strength_modifier: property[:strength_modifier], duration_modifier: property[:duration_modifier])
            else
              Rails.logger.warn "CanonicalIngredient #{ingredient.item_code} calls for alchemical property #{alchemical_property.name} but alchemical property does not exist"
            end
          end
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Validation error creating ingredient #{i[:attributes][:item_code]}: #{e.message}"
          raise e
        rescue StandardError => e
          Rails.logger.error "Unexpected #{e.class} creating ingredient #{i[:attributes][:item_code]}: #{e.message}"
          e.backtrace.each {|line| Rails.logger.error "  #{line}" }
          raise e
        end
      end
    rescue StandardError => e
      Rails.logger.error "Unexpected error #{e.class} syncing ingredients: #{e.message}"
    end
    # rubocop:enable Layout/BlockAlignment

    desc 'Sync all canonical models with JSON files'
    task :all, [:preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Rake::Task['canonical_models:sync:canonical_properties'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:enchantments'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:spells'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:alchemical_properties'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:canonical_materials'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:canonical_jewelry'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:canonical_clothing'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:canonical_armor'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:sync:canonical_ingredients'].invoke(args[:preserve_existing_records])
    end
  end
end
