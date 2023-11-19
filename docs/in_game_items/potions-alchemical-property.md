# PotionsAlchemicalProperty

The `PotionsAlchemicalProperty` model is a join model between [`Potion`](/docs/in_game_items/potion.md) and `AlchemicalProperty`.

## Strength and Duration

In Skyrim, each potion's properties can have a `strength` and/or `duration` defined. Not every alchemical property will have these. For example, the "Cure Disease" property cures any disease and doesn't need any modification. On the other hand, the "Damage Health" property requires a `strength` attribute as it causes a different amount of damage depending on the ingredients, character level and perks.

## Matching Canonical Models

This join model does not validate the presence of a corresponding canonical model when it's created, both to avoid expensive database queries and to reflect the fact that not all potions have corresponding canonical potions.

## `added_automatically`

This `PotionsAlchemicalProperty` join model has an attribute, `added_automatically`, to indicate when an alchemical property has been added to a potion automatically based on its canonical potion versus when it has been added by the user.
