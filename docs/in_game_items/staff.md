# Staff

The `Staff` is one of the simpler in-game items to associate to the appropriate canonical model. It has three matchable attributes:

* `name`
* `unit_weight`
* `magical_effects`

There is only one situation in which a match based on these attributes could be ambiguous: the "Forsworn Staff". There are two versions of this staff. The one with item code `"000FA2C1"` has magical effects reading, "A gout of fire that does 8 points per second. Targets on fire take extra damage." The one with item code `"000CC826"` has `nil` in the `magical_effects` field. This makes it impossible to tell if a non-canonical staff called "Forsworn Staff" has `nil` in the `magical_effects` field because the user hasn't populated it yet or because the canonical value for that field is `nil`. In other words, we have no way to know whether the `nil` in this context is meaningful.

This has been treated as an edge case since it only involves one possible staff. Staves that should be matched to item `"000CC826"` will simply never be associated to a canonical model due to ambiguous matching.

## Staff Enchanting

One factor in staves is the fact that the user can buy unenchanted staves from [Neloth](https://elderscrolls.fandom.com/wiki/Neloth_(Dragonborn)) in [Tel Mithryn](https://elderscrolls.fandom.com/wiki/Tel_Mithryn) as part of the [Dragonborn](https://elderscrolls.fandom.com/wiki/The_Elder_Scrolls_V:_Dragonborn) add-on. These can be enchanted using the [staff enchanter](https://elderscrolls.fandom.com/wiki/Staff_Enchanter) at Tel Mithryn. When they are enchanted, they turn into a different staff with a different item code and the original unenchanted staff disappears. Because of this, it makes sense to not associate spells or powers directly to non-canonical staves and instead to use the associations on the canonical model. Instead of delegating methods, this has been implemented as methods on the non-canonical model that returns an empty ActiveRecord relation if the canonical model is not present.

One possible edge case here would be staves that are differentiated by the spells or powers they are enchanted with. However, there currently are no such canonical staves. In fact, all but the "Forsworn Staff" are differentiable by `name` alone.
