class CreateRainfalls < ActiveRecord::Migration
  def change
    create_table :rainfalls do |t|
      t.belongs_to :measurement, index: true
      t.float :precip
      t.float :probability

      t.timestamps null: false
    end
  end
end
