class CreateLiveshows < ActiveRecord::Migration
  def change
    create_table :liveshows do |t|
      t.string :label
      t.integer :number_of_episodes_owl
      t.integer :number_of_seasons_owl
      t.integer :number_of_episodes_prop
      t.integer :number_of_seasons_prop
      t.string :language
      t.string :country
      t.datetime :release_date
      t.datetime :first_aired
      t.text :info_box

      t.timestamps
    end
  end
end
