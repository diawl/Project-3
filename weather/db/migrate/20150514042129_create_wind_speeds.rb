class CreateWindSpeeds < ActiveRecord::Migration
  def change
    create_table :wind_speeds do |t|
		t.belongs_to :measurement, index: true
		t.float :speed

		t.timestamps null: false
    end
  end
end
