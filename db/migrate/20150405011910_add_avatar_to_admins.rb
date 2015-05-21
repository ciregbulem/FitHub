class AddAvatarToAdmins < ActiveRecord::Migration
  def self.up
    add_attachment :admins, :avatar
  end

  def self.down
    remove_attachment :admins, :avatar
  end
end
