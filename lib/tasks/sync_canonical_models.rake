# frozen_string_literal: true

require 'json'

FALSEY_VALUES = [false, 'false'].freeze

namespace :canonical_models do
  namespace :sync do
    desc 'Sync alchemical properties in the database with JSON data'
    task :alchemical_properties, %i[preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:alchemical_property, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical enchantments in the database with JSON data'
    task :enchantments, %i[preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:enchantment, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical spells in the database with JSON data'
    task :spells, %i[preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:spell, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical powers in the database with JSON data'
    task :powers, %i[preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:power, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical properties in the database with JSON data'
    task :properties, %i[preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:property, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical building and smithing materials in the database with JSON data'
    task :materials, %i[preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:material, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical jewelry items in the database with JSON data'
    # rubocop:disable Layout/BlockAlignment
    task :jewelry,
         %i[preserve_existing_records] => %w[
                                            environment
                                            canonical_models:sync:materials
                                            canonical_models:sync:enchantments
                                          ] do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:jewelry, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical clothing items in the database with JSON data'
    task :clothing,
         %i[preserve_existing_records] => %w[
                                            environment
                                            canonical_models:sync:materials
                                            canonical_models:sync:enchantments
                                          ] do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:clothing, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end

    desc 'Sync canonical armor models in the database with JSON data'
    task :armor,
         %i[preserve_existing_records] => %w[
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
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:weapon, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end
    # rubocop:enable Layout/BlockAlignment

    desc 'Sync all canonical models with JSON files'
    task :all, %i[preserve_existing_records] => :environment do |_t, args|
      args.with_defaults(preserve_existing_records: false)

      Canonical::Sync.perform(:all, FALSEY_VALUES.exclude?(args[:preserve_existing_records]))
    end
  end
end
