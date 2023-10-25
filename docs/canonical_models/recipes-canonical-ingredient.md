# RecipesCanonicalIngredient

Not strictly a canonical model, the `RecipesCanonicalIngredient` model is a join model that associates books of `book_type` `"recipe"` to the ingredients specified in the recipe. The associated `recipe` may be either a `Canonical::Book`, or a `Book`. If it is a `Canonical::Book`, the book type must be `recipe`. If it is a `Book`, the `book_type` of at least one matching canonical model must be `"recipe"`. There is no special data stored on this model - just the relationships between the recipe and the canonical ingredients required to prepare it.
