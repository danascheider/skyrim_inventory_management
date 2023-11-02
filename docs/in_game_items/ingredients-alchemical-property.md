# IngredientsAlchemicalProperty

The `IngredientsAlchemicalProperty` model is a join model between `Ingredient` and `AlchemicalProperty`. Most of its idiosyncrasies are mirrored in the `Canonical::IngredientsAlchemicalProperty` model.

## Count Limit

Ingredients in Skyrim all have exactly 4 alchemical properties, each with a `priority` numbered 1-4. A validation exists to prevent a fifth alchemical property from being added to an ingredient.

## Priority

In Skyrim, each ingredient's properties have a `priority` that affects which potions are produced, how strong they are, and how long the effects last when they are combined with other ingredients. More information is available in the [canonical model docs](/docs/canonical_models/canonical-ingredients-alchemical-property.md#priority) and the [UESP wiki](https://en.uesp.net/wiki/Skyrim:Alchemy_Effects). The `priority` is a number between 1 and 4, inclusive.

The value of `priority` on a model must be unique for its associated `Ingredient` model. So, if 4 models have the same `ingredient` and all have a `priority` defined, each of the integers from 1-4 will be represented. As noted in the docs for the canonical model, `priority` is not a required attribute because, if an ingredient has 4 alchemical properties, changing the priority of those properties involves first setting `priority` to `NULL` on two or more of the join models.

## Matching Canonical Models

Unlike primary in-game items, these join models do not have a direct association to their corresponding canonical models. They do, however, have a `#canonical_models` method that returns all `Canonical::IngredientAlchemicalProperty` models that match their `priority` value. On each save, validations ensure that at least one matching canonical model exists.

If a there is exactly one matching canonical model, a `before_validation` hook sets the `priority` value to match it on each save.

## Strength and Duration Modifiers

While the `Canonical::IngredientsAlchemicalProperty` model has `strength_modifier` and `duration_modifier` fields, these fields represent values invisible to players and therefore are not present on the `IngredientsAlchemicalProperty` model. However, these models do have `#strength_modifier` and `#duration_modifier` methods. These methods return `nil` if there are multiple matching canonical models. If there is a single canonical model, the methods return its `strength_modifier` or `duration_modifier`, or `1` if these are blank.
