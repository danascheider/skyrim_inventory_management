#! /bin/bash

function xargs-r() {
  # Portable version of "xargs -r". The -r flag is a GNU extension that
  # prevents xargs from running if there are no input files.
  if IFS= read -r -d $'\n' path; then
    { echo "$path"; cat; } | xargs $@
  fi
}

git diff --diff-filter=d --name-only --cached --relative -- '*.rb' 'Gemfile' '*.rake' ':(exclude)db/schema.rb' | xargs-r -E '' -t "bundle exec rubocop -A"
