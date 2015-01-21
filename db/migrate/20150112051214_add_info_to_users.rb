class AddInfoToUsers < ActiveRecord::Migration
  def change
    add_column :users, :info, :hstore
  end
end
