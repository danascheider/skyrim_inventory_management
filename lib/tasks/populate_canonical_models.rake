# frozen_string_literal: true

require 'json'

namespace :canonical_models do
  namespace :populate do
    desc 'Populate or update canonical alchemical properties from JSON data'
    task :alchemical_properties, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Populating canonical alchemical properties...'

      args.with_defaults(preserve_existing_records: false)

      alchemical_properties = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'alchemical_properties.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if [false, 'false'].include?(args[:preserve_existing_records])
          names = alchemical_properties.pluck(:name)
          AlchemicalProperty.where.not(name: names).destroy_all
        end

        alchemical_properties.each do |property_attributes|
          property = AlchemicalProperty.find_or_initialize_by(name: property_attributes[:name])
          property.assign_attributes(property_attributes)
          property.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Error saving alchemical property \"#{property_attributes[:name]}\": #{e.message}"
          raise e
        rescue StandardError => e
          Rails.logger.error "Unknown error saving alchemical property \"#{property_attributes[:name]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Populate or update canonical enchantments from JSON data'
    task :enchantments, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Populating canonical enchantments...'

      args.with_defaults(preserve_existing_records: false)

      enchantments = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'enchantments.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if [false, 'false'].include?(args[:preserve_existing_records])
          names = enchantments.pluck(:name)
          Enchantment.where.not(name: names).destroy_all
        end

        enchantments.each do |enchantment_attributes|
          enchantment = Enchantment.find_or_initialize_by(name: enchantment_attributes[:name])
          enchantment.assign_attributes(enchantment_attributes)
          enchantment.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error("Error saving enchantment \"#{enchantment_attributes[:name]}\": #{e.message}")
          raise e
        rescue StandardError => e
          Rails.logger.error "Unknown error saving enchantment \"#{enchantment_attributes[:name]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Populate or update canonical spells from JSON data'
    task :spells, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Populating canonical spells...'

      args.with_defaults(preserve_existing_records: false)

      spells = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'spells.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if [false, 'false'].include?(args[:preserve_existing_records])
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
          Rails.logger.error "Unknown error saving spell \"#{spell_attributes[:name]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Populate or update canonical properties from JSON data'
    task :canonical_properties, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Populating canonical properties...'

      args.with_defaults(preserve_existing_records: false)

      canonical_properties = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_properties.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if [false, 'false'].include?(args[:preserve_existing_records])
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

    desc 'Populate or update canonical building and smithing materials from JSON data'
    task :canonical_materials, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Populating canonical materials...'

      args.with_defaults(preserve_existing_records: false)

      canonical_materials = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_materials.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if [false, 'false'].include?(args[:preserve_existing_records])
          item_codes = canonical_materials.pluck(:item_code)
          CanonicalMaterials.where.not(item_code: item_codes).destroy_all
        end

        canonical_materials.each do |canonical_material_attributes|
          material = CanonicalMaterial.find_or_initialize_by(name: canonical_material_attributes[:name])
          material.assign_attributes(canonical_material_attributes)
          material.save!
        rescue ActiveRecord::RecordInvalid => e
          Rails.logger.error "Validation error saving canonical material \"#{canonical_material_attributes[:name]}\": #{e.message}"
          raise e
        rescue StandardError => e
          Rails.logger.error "Unknown error saving canonical material \"#{canonical_material_attributes[:name]}\": #{e.message}"
          raise e
        end
      end
    end

    desc 'Populate or update canonical jewelry items from JSON data'
    task :canonical_jewelry, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Populating canonical jewelry items...'

      args.with_defaults(preserve_existing_records: false)

      items = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_jewelry.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if [false, 'false'].include?(args[:preserve_existing_records])
          item_codes = items.map {|item| item[:attributes][:item_code] }
          CanonicalJewelryItem.where.not(item_code: item_codes).destroy_all
        end

        items.each do |data|
          item = CanonicalJewelryItem.find_or_initialize_by(name: data[:attributes][:name])
          item.assign_attributes(data[:attributes])
          item.save!

          if data.has_key?(:materials)
            data[:materials].each do |m|
              material = CanonicalMaterial.find_by(name: m[:name])

              if material.present? && item.canonical_materials.exclude?(material)
                CanonicalJewelryItemsCanonicalMaterial.create!(
                  canonical_jewelry_item: item,
                  canonical_material:     material,
                  quantity:               m[:quantity],
                )
              elsif item.canonical_materials.include?(material)
                Rails.logger.warn("Jewelry item #{item.item_code} already associated with material #{m[:name]}.")
              else
                Rails.logger.warn("Jewelry item #{item.item_code} calls for material #{m[:name]} but material does not exist.")
              end
            end
          end

          if data.has_key?(:enchantments)
            data[:enchantments].each do |en|
              enchantment = Enchantment.find_by(name: en[:name])

              if enchantment.present? && item.enchantments.exclude?(enchantment)
                CanonicalJewelryItemsEnchantment.create!(
                  canonical_jewelry_item: item,
                  enchantment:            enchantment,
                  strength:               en[:strength],
                )
              elsif item.enchantments.include?(enchantment)
                Rails.logger.warn("Jewelry item #{item.item_code} already associated with enchantment #{enchantment.name}.")
              else
                Rails.logger.warn("Jewelry item #{item.item_code} calls for enchantment #{en[:name]} but enchantment does not exist.")
              end
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

    desc 'Populate or update canonical clothing items from JSON data'
    task :canonical_clothing, [:preserve_existing_records] => :environment do
      Rails.logger.info 'Populating canonical clothing items...'

      args.with_defaults(preserve_existing_records: false)

      items = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_clothing.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if [false, 'false'].include?(args[:preserve_existing_records])
          item_codes = items.map {|item| item[:attributes][:item_code] }
          CanonicalClothingItem.where.not(item_code: item_codes).destroy_all
        end

        items.each do |data|
          item = CanonicalClothingItem.find_or_initialize_by(name: data[:attributes][:name])
          item.assign_attributes(data[:attributes])
          item.save!

          next unless data.has_key?(:enchantments)

          Rails.logger.info("Enchantments for item #{data[:attributes][:item_code]}: #{data[:enchantments]}")
          data[:enchantments].each do |en|
            enchantment = Enchantment.find_by(name: en[:name])

            if enchantment.present? && item.enchantments.exclude?(enchantment)
              CanonicalClothingItemsEnchantment.find_or_create_by!(
                canonical_clothing_item: item,
                enchantment:             enchantment,
                strength:                en[:strength],
              )
            elsif item.enchantments.include?(enchantment)
              Rails.logger.warn("Clothing item #{item.item_code} already associated with enchantment #{en[:name]}.")
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

    desc 'Populate or update canonical armor items from JSON data'
    task :canonical_armor, [:preserve_existing_records] => :environment do |_t, args|
      Rails.logger.info 'Populating canonical armor items...'

      args.with_defaults(preserve_existing_records: false)

      items = JSON.parse(File.read(Rails.root.join('lib', 'tasks', 'canonical_models', 'canonical_armor.json')), symbolize_names: true)

      ActiveRecord::Base.transaction do
        if [false, 'false'].include?(args[:preserve_existing_records])
          item_codes = items.map {|item| item[:attributes][:item_code] }
          CanonicalArmor.where.not(item_code: item_codes).destroy_all
        end

        items.each do |data|
          item = CanonicalArmor.find_or_initialize_by(name: data[:attributes][:name])
          item.assign_attributes(data[:attributes])
          item.save!

          if data.has_key?(:smithing_materials)
            data[:smithing_materials].each do |m|
              material = CanonicalMaterial.find_by(name: m[:name])

              if material.present? && item.smithing_materials.exclude?(material)
                CanonicalArmorsSmithingMaterial.create!(
                  canonical_armor:    item,
                  canonical_material: material,
                  quantity:           m[:quantity],
                )
              elsif item.smithing_materials.include?(material)
                Rails.logger.warn("Armor item #{item.item_code} already associated with smithing material #{m[:name]}.")
              else
                Rails.logger.warn("Armor item #{item.item_code} calls for smithing material #{m[:name]} but material does not exist.")
              end
            end
          end

          if data.has_key?(:tempering_materials)
            data[:tempering_materials].each do |m|
              material = CanonicalMaterial.find_by(name: m[:name])

              if material.present? && item.tempering_materials.exclude?(material)
                CanonicalArmorsTemperingMaterial.create!(
                  canonical_armor:    item,
                  canonical_material: material,
                  quantity:           m[:quantity],
                )
              elsif item.tempering_materials.include?(material)
                Rails.logger.warn("Armor item #{item.item_code} already associated with tempering material #{m[:name]}.")
              else
                Rails.logger.warn("Armor item #{item.item_code} calls for tempering material #{m[:name]} but material does not exist.")
              end
            end
          end

          if data.has_key?(:enchantments)
            data[:enchantments].each do |en|
              enchantment = Enchantment.find_by(name: en[:name])

              if enchantment.present? && item.enchantments.exclude?(enchantment)
                CanonicalArmorsEnchantment.create!(
                  canonical_armor: item,
                  enchantment:     enchantment,
                  strength:        en[:strength],
                )
              elsif item.enchantments.include?(enchantment)
                Rails.logger.warn("Armor item #{item.item_code} already associated with enchantment #{en[:name]}.")
              else
                Rails.logger.warn("Armor item #{item.item_code} calls for enchantment #{en[:name]} but enchantment does not exist.")
              end
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

    desc 'Populate or update all canonical models from JSON files'
    task :all, [:preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Rake::Task['canonical_models:populate:canonical_properties'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:populate:enchantments'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:populate:spells'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:populate:alchemical_properties'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:populate:canonical_materials'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:populate:canonical_jewelry'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:populate:canonical_clothing'].invoke(args[:preserve_existing_records])
      Rake::Task['canonical_models:populate:canonical_armor'].invoke(args[:preserve_existing_records])
    end
  end
end
