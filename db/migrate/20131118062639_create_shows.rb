class CreateShows < ActiveRecord::Migration
  def change
    create_table :shows do |t|
      t.integer :wikipage_id
      t.string :show_name
      t.integer :number_of_episodes
      t.integer :number_of_seasons
      t.datetime :first_aired
      t.datetime :last_aired

      t.timestamps
    end
  end
end
