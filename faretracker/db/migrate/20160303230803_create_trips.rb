class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.string :origin
      t.string :destination
      t.string :date
      t.boolean :active

      t.timestamps null: false
    end
  end
end
