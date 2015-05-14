class CreateWdates < ActiveRecord::Migration
  def change
    create_table :wdates do |t|
      t.belongs_to :location, index: true
      t.date :date

      t.timestamps null: false
    end
  end
end
