class CreateWindDirections < ActiveRecord::Migration
  def change
    create_table :wind_directions do |t|
    	t.belongs_to :measurement, index: true
     	t.integer :bearing

     	t.timestamps null: false
    end
  end
end
