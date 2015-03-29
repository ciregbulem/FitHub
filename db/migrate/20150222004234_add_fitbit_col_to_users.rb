class AddFitbitColToUsers < ActiveRecord::Migration
  def change
  	remove_column :users, :todays_cals
  	remove_column :users, :todays_steps
  	remove_column :users, :todays_dist
  	remove_column :users, :todays_sleep
    add_column :users, :todays_cals, :string
    add_column :users, :todays_steps, :string
    add_column :users, :todays_dist, :string
    add_column :users, :todays_sleep, :string
  end
end
