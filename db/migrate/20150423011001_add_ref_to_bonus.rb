class AddRefToBonus < ActiveRecord::Migration
  def change
    add_reference :bonus, :admin, index: true
  end
end
