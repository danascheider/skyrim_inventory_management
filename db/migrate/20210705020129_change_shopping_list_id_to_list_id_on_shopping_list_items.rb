class ChangeShoppingListIdToListIdOnShoppingListItems < ActiveRecord::Migration[6.1]
  def change
    rename_column :shopping_list_items, :shopping_list_id, :list_id
  end
end
