# Canonical::Material

The `Canonical::Material` model is a polymorphic join model connecting polymorphic items with polymorphic materials used to craft or temper them. This model is essential because not all materials used for smithing and building are materials in the strictest sense. For instance, a Dwarven crossbow is a required component of an enhanced Dwarven crossbow, but is obviously best categorised as a `Canonical::Weapon` and not a `Canonical::RawMaterial`.

## Polymorphic Associations

The `Canonical::Material` model's associations have a few interesting features.

### Source Material

The polymorphic association `source_material` can point to any object used as a material for smithing or building. In practice, in the base game (as well as Dawnguard, Dragonborn, and Hearthfire), a `source_material` can be a `Canonical::RawMaterial` (i.e., a material that is used solely or primarily for smithing or building), a `Canonical::Weapon` (e.g., crossbow as described above), or a `Canonical::Ingredient` (e.g., Daedra heart for Daedric armours and weapons).

### Craftable and Temperable

The `Canonical::Material` model has two additional polymorphic associations, `craftable` and `temperable`, pointing to the item that can be either crafted or tempered using the `source_material`. Validations ensure that each `Canonical::Material` has one, and only one, of these associations.

In the base game (including Dawnguard, Dragonborn, and Hearthfire), `craftable` models include:

  * `Canonical::Weapon`
  * `Canonical::Armor`
  * `Canonical::JewelryItem`

`Canonical::Weapon`s and `Canonical::Armor` pieces can also be `temperable`.
