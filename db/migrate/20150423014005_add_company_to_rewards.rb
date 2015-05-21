class AddCompanyToRewards < ActiveRecord::Migration
  def change
    add_column :rewards, :company, :string
  end
end
