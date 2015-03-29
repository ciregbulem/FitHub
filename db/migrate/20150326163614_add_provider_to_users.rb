class AddProviderToUsers < ActiveRecord::Migration
  def change
    add_column :users, :insurance_provider, :string
  end
end
