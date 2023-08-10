# Ingredient

The `Ingredient` model represents in-game items of the `Canonical::Ingredient` type. This model has some special characteristics that set it apart from other in-game items. Some of these correspond to characteristics of the `Canonical::Ingredient` model, in particular the aspect of [alchemical properties](/docs/canonical_models/canonical-ingredient.md#accessing-alchemical-properties).

## Matching to Canonical Models

Matching an `Ingredient` to a `Canonical::Ingredient` is a bit more complex than matching the previously-introduced [`Armor`](/docs/in_game_items/armor.md) and [`ClothingItem`](/docs/in_game_items/clothing-item.md) models to their corresponding canonical models. This is because ingredients may be uniquely identified by their alchemical properties, which are associations and not attributes of the model itself.

When an `Ingredient` is created, it is then matched to a subset of canonical ingredients by its `name` and `unit_weight` attributes (the only attributes of `Canonical::Ingredient` also present on `Ingredient`). If the ingredient has alchemical properties, these are further narrowed down based on those associations, checking for the `alchemical_property_id` and `priority` defined on the [`IngredientsAlchemicalProperty`](/docs/in_game_items/ingredients-alchemical-property.md) model. If these match for all defined alchemical properties, it is considered a match.

## The `IngredientsAlchemicalProperty` Join Model

The `Ingredient` model is associated to the `AlchemicalProperty` model via the `IngredientsAlchemicalProperty` join model. This model has [its own docs](/docs/in_game_items/ingredients-alchemical-property.md) but it is worth mentioning here as well. The join table contains attributes about the `priority` (1-4) of the alchemical property on the ingredient, its `strength_modifier` and its `duration_modifier`. More information is available in the [canonical model docs](/docs/canonical_models/canonical-ingredients-alchemical-property.md).
