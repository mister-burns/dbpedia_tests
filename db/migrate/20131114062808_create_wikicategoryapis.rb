class CreateWikicategoryapis < ActiveRecord::Migration
  def change
    create_table :wikicategoryapis do |t|
      t.integer :page_id
      t.string :page_title

      t.timestamps
    end
  end
end
