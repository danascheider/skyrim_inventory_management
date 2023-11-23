# Potion

The `Potion` model represents in-game items of the `Canonical::Potion` type. Like the [`Ingredient`](/docs/in_game_items/ingredient.md) model, the `Potion` model's association to [alchemical properties](/docs/canonical_models/canonical-ingredient.md#accessing-alchemical-properties), which work similarly to how they work for the `Ingredient` model.

## Matching to Canonical Models

Potions differ from some in-game items in that they may or may not have a corresponding canonical version. User-created potions do not have this, since there are a nearly infinite number of possible combinations of [strength and duration](/docs/in_game_items/potions-alchemical-property.md) for each alchemical property.

When a `Potion` is created, it is then matched to a subset of canonical potions by its `name`, `unit_weight` and `magical_effects` attributes (if defined). The `name` and `magical_effects` attributes are matched case-insensitively. If the potion has alchemical properties, the results are further narrowed down based on those associations, checking for the `alchemical_property_id`, `strength` and `duration` defined on the [`PotionsAlchemicalProperty`](/docs/in_game_items/potions-alchemical-property.md) model. If these match for all defined alchemical properties, it is considered a match.

## The `PotionsAlchemicalProperty` Join Model

The `Potion` model is associated to the `AlchemicalProperty` model via the `PotionsAlchemicalProperty` join model. This model has [its own docs](/docs/in_game_items/potions-alchemical-property.md) but it is worth mentioning here as well. The join table contains attributes about the integer `strength` and `duration` of the property in that potion. There is a validation on the join model ensuring that no potion can have more than 4 alchemical effects.

When a potion is matched with a `Canonical::Potion`, any alchemical properties present on the canonical potion but not the in-game potion will be added. In this case, the `added_automatically` attribute will be set to `true` on the join model. If the alchemical property is added to the potion by the user, this attribute will be set to `false`. Automatically added alchemical properties are ignored by the algorithm that matches `Potion` models with `Canonical::Potion`s.
