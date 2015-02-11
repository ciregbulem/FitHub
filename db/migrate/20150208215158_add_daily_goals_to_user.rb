class AddDailyGoalsToUser < ActiveRecord::Migration
  def change
    add_column :users, :daily_cals_goal, :string
    add_column :users, :daily_steps_goal, :string
    add_column :users, :daily_dist_goal, :string
  end
end
