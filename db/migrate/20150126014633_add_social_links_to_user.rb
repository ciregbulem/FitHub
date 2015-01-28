class AddSocialLinksToUser < ActiveRecord::Migration
  def change
    add_column :users, :tw_link, :string
    add_column :users, :ig_link, :string
  end
end
