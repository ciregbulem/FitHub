class AddRefToRewards < ActiveRecord::Migration
  def change
    add_reference :rewards, :admin, index: true
  end
end
