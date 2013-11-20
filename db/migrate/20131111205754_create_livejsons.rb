class CreateLivejsons < ActiveRecord::Migration
  def change
    create_table :livejsons do |t|
      t.string :label
      t.text :jsondata

      t.timestamps
    end
  end
end
