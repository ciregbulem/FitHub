class AddFbLinkToUser < ActiveRecord::Migration
  def change
    add_column :users, :fb_link, :string
  end
end
