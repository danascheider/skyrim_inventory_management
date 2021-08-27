# Canonical Models

SIM knows certain things about Skyrim that it may or may not immediately reveal to users. Canonical models are models representing things in Skyrim the user may not know yet. Currently there are three canonical models:

* [`AlchemicalProperty`](/app/models/alchemical_property.rb)
* [`Enchantment`](/app/models/enchantment.rb)
* [`Spell`](/app/models/spell.rb)

These models are not user-created and are to be stored in the database with actual data from the game. There is [planned work](https://trello.com/c/WwBkrm30/179-populate-canonical-models-in-database) to populate the models in the database and provide seeds or a Rake task to seed development and test databases.
