# Book

The `Book` model represents in-game books backed by the `Canonical::Book` class. Books can be any of several book types, explained in the [docs for canonical books](/docs/canonical_models/canonical-book.md), ranging from notes and letters to lore books and Elder Scrolls.

## Matching Attributes

`Book` models are matched to `Canonical::Book` models using the following fields:

* `title` (and `title_variants` on the canonical model, see below)
* `authors`
* `unit_weight`
* `skill_name` (only found on skill books)

There are a couple peculiarities to keep in mind here.

### Title Variants

The `Canonical::Book` model has two fields indicating the title, or possible title, of a book: `title` (a string field) and `title_variants` (an array of strings). When a `Book` model searches for its `Canonical::Book`, it matches its title against the canonical books' titles, _as well as each of their title variants,_ case-insensitively.

### Authors

Both the `Canonical::Book` and `Book` models have arrays of `authors`. However, when matching canonical models, **the whole `authors` array must match** - it is not enough for a subset of authors to match, and the order of authors must be the same as that on the canonical model.

### Recipes and Associations

The `Book` model is associated to the `Canonical::Ingredient` model via the `RecipesCanonicalIngredient` (formerly `Canonical::RecipesIngredient`) join model. This association can exist if and only if at least one of the matching canonical models has a `book_type` of `"recipe"`. The association is to `Canonical::Ingredient` and not `Ingredient` because the recipe can correspond to any instance of the ingredient - it doesn't pertain to specific instances.

If a book does have `canonical_ingredients`, they will also be matched against the ingredients associated with the canonical model. Ingredients must exactly match the canonical - there can be no ingredients that aren't present on a matching canonical.
