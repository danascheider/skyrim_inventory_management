# Canonical::Staff

The `Canonical::Staff` model represents a staff in Skyrim. Staves may be enchanted with spells or powers (notably not with enchantments) and their function depends on which spell or power they are enchanted with.

## Spells and Powers

Staves can be enchanted using spells or powers. Each staff can have multiple spells, powers, or (theoretically) both. (Note that staves cannot be enchanted with enchantments like other items can.) Spells are associated to `Canonical::Staff` model via the `Canonical::StavesSpell` join model. The join model contains a `strength` field to indicate the strength of the spell, if it differs from the base spell. Powers are associated to `Canonical::Staff` models via the polymorphic join model `Canonical::PowerablesPower`.

Not all staves have spells or powers; some have miscellaneous effects described in the `magical_effects` field. Additionally, [unenchanted staves](#staff-enchanting) are available for players to enchant themselves in the [Dragonborn add-on](https://elderscrolls.fandom.com/wiki/The_Elder_Scrolls_V:_Dragonborn).

## Staff Enchanting

Unenchanted staves are available to purchase (in the Dragonborn add-on) from [Neloth](https://elderscrolls.fandom.com/wiki/Neloth_(Dragonborn)?so=search) to use with the [staff enchanter](https://elderscrolls.fandom.com/wiki/Staff_Enchanter) at [Tel Mithryn](https://elderscrolls.fandom.com/wiki/Tel_Mithryn). Staves enchanted using the staff enchanter are limited to the same set of spells as other staves but are further limited in that the player character must know the spell used to enchant the staff. These staves cannot be enchanted with powers.
