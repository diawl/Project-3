class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.belongs_to :wdate, index: true
      t.time :timestamp

      t.timestamps null: false
    end
  end
end
