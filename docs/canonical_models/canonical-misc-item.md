# Canonical::MiscItem

The `Canonical::MiscItem` model has a couple of special characteristics that set it apart from other canonical models.

## Indistinguishable Associations

A `Canonical::MiscItem` model stores significant metadata about an item, such as whether it is rare or unique, whether it can be purchased, what type of item it is, whether it is a quest item or reward, and a description of the item (if available). However, only two of these values - the `name` and the `unit_weight` - are visible to the player. In certain cases, these two attributes are insufficient to distinguish multiple matching canonical models. Indeed, some `Canonical::MiscItem` records are distinguishable from one or more other records only by `item_code`, a low-level implementation detail of the game not generally visible to players.

At this writing, there are 5 duplicate `name`s among the canonical misc items in the production database:

* "Skull" (occurs twice)
* "Reaper Gem Fragment" (occurs 3 times)
* "Werewolf Totem" (occurs 3 times)
* "Opaque Vessel" (occurs 3 times)
* "Crown of Barenziah" (occurs twice)

Of these, only the Skull and the Crown of Barenziah are differentiable by any attribute but item code - however, the field that differentiates them is the `description` field, which is not visible to players and not present on the `::MiscItem` model.

Because of the difficulty of uniquely identifying misc items, the `::MiscItem` model uses a slightly different algorithm for assigning associations than other in-game item classes. Details are available in the docs for the in-game item class.
