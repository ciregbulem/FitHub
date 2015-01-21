class AddTempEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :temp_email, :string
  end
end
