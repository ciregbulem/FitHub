class AddAssociationToUser < ActiveRecord::Migration
  def change
  	change_table(:users) do |t|
  		t.belongs_to :admin, index: true
	end
  end
end
