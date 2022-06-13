# Canonical::IngredientsAlchemicalProperty

The `Canonical::IngredientsAlchemicalProperty` model is a join model between `Canonical::Ingredient` and `AlchemicalProperty`. It has a couple noteworthy characteristics.

## Count Limit

Each ingredient has four and only four alchemical properties. Therefore, a validation error will be raised if you attempt to create a fifth model for the same canonical ingredient.

## Priority

In Skyrim, each ingredient's properties have a priority that affects which potions are produced, how strong they are, and how long the effects last when they are combined with other ingredients. ([This wiki page](https://en.uesp.net/wiki/Skyrim:Alchemy_Effects) offers detailed information about how priority affects potions produced.) In SIM, the `priority` field is used to track this. Because each canonical ingredient has exactly four alchemical properties, the integer priority values for each model will range from 1 to 4.

There is a uniqueness constraint in place on the `Canonical::IngredientsAlchemicalProperty` model to ensure that each ingredient only has one property with each valid value. Because of this, changing priority values after four models with priorities exist in the database for a single ingredient requires an additional step. Before you can change the priority on any model, you will need to clear any that conflict.

Say you have four `Canonical::IngredientsAlchemicalProperty` models:
```ruby
[
  {
    id: 21,
    ingredient_id: 6,
    alchemical_property_id: 47,
    priority: 1
  },
  {
    id: 22,
    ingredient_id: 6,
    alchemical_property_id: 33,
    priority: 2
  },
  {
    id: 23,
    ingredient_id: 6,
    alchemical_property_id: 60,
    priority: 3
  },
  {
    id: 24,
    ingredient_id: 6,
    alchemical_property_id: 14,
    priority: 4
  }
]
```
If you want to change switch the priority of the model with ID `22` to `3`, you will first need to clear priorities from that model and the one whose priority is currently 3 (the one with ID of `23`) and then change both. If you aren't simply swapping values on two models, you may have to set the priority on three or even all four of the models to `nil` before you can update the values.

**Note that, because of the possible necessity of changing priorities, there is no `presence` validation on the `priority` attribute - it is allowed to be blank.**

The priority of an alchemical property on a given ingredient can be accessed from the ingredient:

```ruby
ingredient = Canonical::Ingredient.first
ingredient.alchemical_properties.first.priority #=> the priority defined on the join model
```

## `strength_modifier` and `duration_modifier`

Some ingredients will produce an effect that is stronger or lasts longer than other ingredients with the same alchemical property. This is represented as a modifier on the standard strength or duration for a potion made with that ingredient. The [linked wiki page](https://en.uesp.net/wiki/Skyrim:Alchemy_Effects) also details how this interacts with priority and affects potion strength, duration, and effects.