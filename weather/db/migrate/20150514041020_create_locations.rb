class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.belongs_to :postcode, index: true
      t.string :loc_id, unique: true
      t.float :lat
      t.float :lon

      t.timestamps null: false
    end

  end
end
