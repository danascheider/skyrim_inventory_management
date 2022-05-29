# Canonical::Ingredient

The `Canonical::Ingredient` model has a couple of special characteristics that set it apart from other canonical models.

## Treatment of Rare Ingredients

Ingredients differ from other objects in Skyrim in that they are consumable. For this reason, an ingredient can be considered a `rare_item` in situations where a non-consumable item would not be. The challenge presented by this is augmented by the fact that it's impossible to find detailed information online about acquisition of different ingredients, especially Solstheim ingredients (designated by `ingredient_type: 'Solstheim'`). For this reason, we've shot from the hip in determining which ingredients qualify as `rare_item`s, taking into account the subjective experience of how hard it is to find something in the game.

The factors considered in determining whether an ingredient is rare include:

* Whether it is [purchasable](#purchasability)
* Whether purchasing it requires the [Merchant perk](#merchant-perk)
* Its [ingredient type](#merchant-availability)
* The number of locations where it is found
* The number of guaranteed samples
* Subjective experiences finding the ingredient in-game

Unlike other canonical models, an ingredient can still be rare if a guaranteed sample is present in one of the ownable properties (Breezehome, Vlindrel Hall, Severin Manor, etc.). Ideally, instead of a boolean `rare_item` field, there would be a scaled field that could indicate _how_ rare an ingredient is. However, the absence of consistent information online would prevent this field from being populated with reliable values, so we've stuck to `rare_item` for consistency with other models.

### Merchant Availability

No merchant is guaranteed to carry a particular ingredient at a particular time. Merchant availability is indicated by the `ingredient_type` field. There are four possible values to this field: `"common"`, `"uncommon"`, `"rare"`, and `"Solstheim"`. A `NULL` value in this field means the ingredient cannot be purchased from merchants. **The `ingredient_type` field is not an indicator of how common or easy to find an ingredient actually is** - the value of this field has a specific meaning that pertains only to the likelihood of the ingredient being carried by a particular merchant at a particular time.

Merchants carry the following:

| Ingredient Type | Maximum Total Quantity | Probability of Particular Ingredient |
| --------------- | ---------------------- | ------------------------------------ |
| common          | 15                     | 36%                                  |
| uncommon        | 10                     | 15%                                  |
| rare            | 5                      | 21%                                  |
| Solstheim*      | 6                      | ~60%                                 |

The observant reader will notice that there is a higher probability of a given merchant carrying a given rare ingredient than a given uncommon ingredient. This is a result of the fact that there are considerably more uncommon ingredients than rare ones, and all of these are potentially represented in the 10 (uncommon) or 5 (rare) ingredients a merchant offers at a given time. Consequently, there are numerous ingredients with a `"rare"` ingredient type that have `rare_item` set to `false`.

#### Solstheim Ingredients

Solstheim ingredients may only be harvested, found, and purchased in Solstheim. No information is available online about the relative prevalence of each ingredient, so Solstheim ingredients are given their own ingredient type in SIM and presumed to be equally common, even though this is not necessarily the case. For this reason, the probability of 60% given in the table above is not necessarily uniformly distributed across all Solstheim ingredients.

Solstheim ingredients can only be purchased through [Milore Ienth](https://en.uesp.net/wiki/Skyrim:Milore_Ienth) or, sometimes, the [Tel Mithryn Apothecary](https://en.uesp.net/wiki/Skyrim:Tel_Mithryn_Apothecary), as these are the only apothecary merchants in Solstheim.

### Purchasability

The `purchasable` column indicates whether an ingredient may be purchased from merchants or other NPCs. All `purchasable` ingredients also have a non-`NULL` `ingredient_type`. Conversely, ingredients that are not purchasable always have a `NULL` `ingredient_type`.

Because purchasability can be determined based on the `ingredient_type` field, the `purchasable` field is redundant for ingredients. This column could probably be dropped. However, since it can be dropped at any time but not as easily recovered, we've decided to leave it for now, at least until the [ingredients epic](https://trello.com/c/WE1ztpCb/154-ingredient-features) has been kicked off. At that point, we'll know more about whether there is a benefit to having this column compared to just defining a `#purchasable` method that would give ingredients the same API as other canonical models.

#### Merchant Perk

Some ingredients are purchasable only with the Merchant perk (which requires a Speech level of 50). These ingredients are designated by the `purchase_requires_perk` boolean column. This column will be `NULL` if the ingredient is not purchasable at all. Purchasable ingredients will have this column set to `true` (if the ingredient can only be purchased with the perk) or `false` (if they are always purchasable).