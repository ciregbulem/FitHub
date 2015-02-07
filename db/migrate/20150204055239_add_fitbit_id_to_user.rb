class AddFitbitIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :fitbit_id, :string
  end
end
