class CreateConditions < ActiveRecord::Migration
  def change
    create_table :conditions do |t|
      t.belongs_to :measurement, index: true
      t.text :icon

      t.timestamps null: false
    end
  end
end
