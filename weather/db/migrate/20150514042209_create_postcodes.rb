class CreatePostcodes < ActiveRecord::Migration
  def change
    create_table :postcodes do |t|
      t.integer :postcode
      t.float :lat
      t.float :lon

      t.timestamps null: false
    end
  end
end