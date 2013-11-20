class CreateInfoboxes < ActiveRecord::Migration
  def change
    create_table :infoboxes do |t|
      t.string :label
      t.text :infobox

      t.timestamps
    end
  end
end
