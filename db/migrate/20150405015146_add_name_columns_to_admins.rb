class AddNameColumnsToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :fname, :string
    add_column :admins, :lname, :string
  end
end
