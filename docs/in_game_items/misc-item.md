# Misc Item

The `MiscItem` model differs from some of the other in-game items. As noted in the docs on the [canonical misc item](/docs/canonical_models/canonical-misc-item.md), misc items have some peculiarities relating to the uniqueness and differentiability of the associated canonical records. Specifically, there are a few canonical records, as noted in the docs for the canonical model, that are differentiable only by item code. Since item codes are opaque to players, none of the information a user would input about an item would be sufficient to identify what the true canonical association should be. Because of this, the `MiscItem` model uses an additional algorithm to identify its canonical association.

## Matching Attributes

`MiscItem` models are matched to `Canonical::MiscItem` models using only two fields:

* `name`
* `unit_weight`

## Ambiguous Canonical Associations

There are a small number of `Canonical::MiscItem` records that have duplicate names. None of these are differentiable by `name` and `unit_weight` alone. Indeed, as noted above, some are differentiable only by `item_code`, a low-level implementation detail of the game that was added to SIM only to differentiate otherwise identical records. This has implications for the in-game `MiscItem` model's approach to finding its association.

Like other in-game item models, a `MiscItem` first identifies a pool of possible canonical matches using the `name`, matched case-insensitively, and, if set, the `unit_weight` of the item. SIM knows there is an ambiguous match when both `name` and `unit_weight` are set but there are still multiple `canonical_models`. When this happens, SIM follows an algorithm as follows to decide which canonical model to associate. SIM iterates through the possible canonical matches. For each canonical model, it checks whether the model is designated as a `unique_item` and, if so, whether it already has a corresponding in-game item for the relevant game. If a canonical model of a unique item already has an association in a given game, that model is skipped and the next is tested. If all matching canonical models are unique and already have an association for the given game, a validation error is added to the `MiscItem` model indicating it is a duplicate of a unique in-game item.
