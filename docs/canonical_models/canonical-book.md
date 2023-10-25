# Canonical::Book

The `Canonical::Book` model has some special characteristics, mainly pertaining to attributes of the model.

## Title Variants

The `title_variants` array includes alternative spellings of the title, full titles if different from the title that appears in inventory, and other variations on a book's title that may occur in game. Since the purpose of canonical models is validation of user-generated input, title variants can be used to ensure that whichever version of the title the user inputs will be associated to the correct model.

## Book Type

There are numerous items classed as "books" in Skyrim. These include letters, documents, journals, recipes, lore books, skill books, quest books, Black Books, treasure maps, and Elder Scrolls.

### Recipes

Recipes are special in that they have associated canonical ingredients. This is to distinguish between multiple recipes for the same potions. There are other books that are called recipes or contain lists of components - such as "recipes" for spider scrolls found in Solstheim - that are nonetheless not classified as recipes in SIM because they cannot have associated ingredients. If you attempt to associate ingredients to a book that is not a recipe, a validation error will occur.

Recipes that can be associated with canonical ingredients are associated using the polymorphic [`RecipesCanonicalIngredient`](/docs/canonical_models/recipes-canonical-ingredient.md) model, which associates canonical ingredients to either `Book` or `Canonical::Book` models.

### Skill Books

Skill books have to have to have a `skill_name` defined. A validation error will be raised if a book is designated a skill book but does not include the `skill_name` field, or if the skill is not a recognised skill in Skyrim. On the other hand, a book that _isn't_ a skill book is not allowed to have this field defined. In this case, a validation error will be raised indicating that only skill books can have skill names.

## Purchasable, Rare and Unique Items

There are three boolean fields on the `Canonical::Book` model that interact with one another: `purchasable`, `rare_item`, and `unique_item`.

### Purchasable

Books that can be purchased through Urag Gro-Shub or another source are designated as `purchasable`.

### Unique Items

Books and other items classed as books that are unique in the game will have `unique_item` set to `true`. Items whose content varies by interpolated variables (e.g., letters with equivalent text signed by different NPCs, bounties pointing to radiant locations or items, etc.), are not considered unique.

### Rare Items

Books can also be designated as `rare_item`s. The logic determining whether a book should be considered rare is as follows:

* Unique items are always rare
* Books that are purchasable are rare if there are less than three other locations in the game where the book can be found
* Books that are not purchasable are rare if the book is found in fewer than 10 locations in the game
* Non-unique books are never classed as rare if they are found in one of the canonical ownable properties.

## Solstheim Only

Books that are only found in Solstheim, whether rare or not, have the `solstheim_only` attribute set to `true`. This column is a little extraneous since all books will ultimately be associated with locations where they are found, but I had already collected this data so I opted to include it and drop the column later if it turns out not to be needed.

## Quest Items

Like with other canonical models, SIM defines a quest item differently than Skyrim does. A quest item is any item that can only be obtained in the course of a quest, whether that item is required for the quest or not. Quest rewards are considered quest items if completing a quest is the only way to obtain them.
