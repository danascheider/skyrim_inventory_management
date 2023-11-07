# Property

The `Property` class represents in-game instances of the [`Canonical::Property`](/docs/canonical_models/canonical-property.md) type. Properties differ slightly from other in-game items in three ways:

* A property is also a location (in some cases with sublocations)
* A property can be associated with inventory and shopping lists (functionality that will be built out further for the MVP)
* All properties must always be associated to a `Canonical::Property`

Additionally, a number of characteristics of a property cannot be determined by the `Canonical::Property` associated. Users can add different amenities or, in the case of [homesteads](https://elderscrolls.fandom.com/wiki/Homestead_(Hearthfire)), build entirely different rooms on the property. For that reason, the `Canonical::Property` model has a number of attributes like `alchemy_lab_available` and `enchanters_tower_available` indicating whether the amenity or room _can be added_ to the property instead of whether it is actually present.

## Matching to a Canonical Model

Unlike other canonical models, of which there can be many, the `Canonical::Property` model only has 10 possible instances and all have a unique `name`. For this reason, unlike other canonical models, the `Canonical::Property` is identified using the `name` attribute alone (case insensitive). This is done in a `before_validation` action. In a second `before_validation` action, the `name`, `city`, and `hold` are set based on the values on the canonical property (if present). Finally, on validation, the property is marked invalid if there is no `canonical_property_id`.

Because canonical properties are uniquely named and limited in number, `Property` models don't have the same potential for ambiguous matches that other in-game items have. There will always be either one or zero matches. In the case where there are no matches, validations will fail due to the missing required association.

## Validations

For each of the boolean fields on the `Canonical::Property` model, the `Property` model has a field called `has_<amenity>`. For example, the field `alchemy_tower_available` corresponds to a field called `has_alchemy_tower`. In this example, if `alchemy_tower_available` is set to `false`, `has_alchemy_tower` must also be `false` on any associated `Property` models. The reverse is not true: if `alchemy_tower_available` is `true` on the canonical property, the `Property` model may still not have an alchemy tower.

### The `HomesteadValidator` Class

In addition to the logic described above, there is an additional complicating factor for the [homestead properties](https://elderscrolls.fandom.com/wiki/Homestead_(Hearthfire)) - Lakeview Manor, Heljarchen Hall, and Windstad Manor. The houses on these properties, which the player character purchases as land, are built by the player character. As such, there are multiple, mutually exclusive options for what to build in each wing. For example, an armory, a kitchen, and a library can all be built in one wing, but one homestead can only have one of these. The `HomesteadValidator` class is used to verify that each homestead has a maximum of one of the possible rooms for each wing. If the house is not a homestead (identified by `name` values of `'Lakeview Manor'`, `'Heljarchen Hall'`, or `'Windstad Manor'`), errors are added for each of the boolean fields that apply only to homesteads (if those values are set to `true`).
