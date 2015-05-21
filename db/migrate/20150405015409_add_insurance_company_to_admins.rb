class AddInsuranceCompanyToAdmins < ActiveRecord::Migration
  def change
    add_column :admins, :insurance_provider, :string
  end
end
