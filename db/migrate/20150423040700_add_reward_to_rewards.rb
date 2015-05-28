class AddRewardToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :reward, :integer
  end
end
