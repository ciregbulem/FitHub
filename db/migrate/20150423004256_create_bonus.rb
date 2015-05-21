class CreateBonus < ActiveRecord::Migration
  def change
    create_table :bonus do |t|
      t.string :title
      t.string :target_unit
      t.integer :goal
      t.string :period

      t.timestamps
    end
  end
end
