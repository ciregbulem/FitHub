class AddFitbitImageToUser < ActiveRecord::Migration
  def change
    add_column :users, :fitbit_image, :string
  end
end
