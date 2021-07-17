#!/usr/bin/env bash

# Install dependencies
echo "+++ Installing dependencies......."
gem install bundler
bundle install

# Set up the database - requires having Postgres and the pg
# gem installed. The pg gem will be installed in the first
# step of this script by Bundler.
#
# The `rails db:setup` command, per the ActiveRecord docs,
# creates the databases (skyrim_inventory_management_development
# and skyrim_inventory_management_test), loads the schema,
# and initialises them with seed data.
echo "+++ Setting up development and test databases......."
bundle exec rails db:setup

# Install precommit hook to run Rubocop against changed Ruby
# files before each git commit
echo "+++ Installing Git precommit hook......."

# Make sure the `.git` directory has a `hooks` subdirectory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
mkdir -p "$SCRIPT_DIR/../.git/hooks"

# Copy the pre-commit hook in this directory to that directory
cp "$SCRIPT_DIR/pre-commit" "$SCRIPT_DIR/../.git/hooks"

echo "Done!"
