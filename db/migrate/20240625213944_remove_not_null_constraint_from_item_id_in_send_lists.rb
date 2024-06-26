class RemoveNotNullConstraintFromItemIdInSendLists < ActiveRecord::Migration[6.0]
  def change
    change_column_null :send_lists, :item_id, true
  end
end
