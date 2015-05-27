class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.belongs_to :postcode, index: true
      t.string :loc_id
      t.float :lat
      t.float :lon
      t.boolean :active
      t.string :loc_type
      t.string :state

      t.timestamps null: false
    end

  end
end
