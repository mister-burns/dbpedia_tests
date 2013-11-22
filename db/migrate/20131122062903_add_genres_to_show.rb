class AddGenresToShow < ActiveRecord::Migration
  def change
    add_column :shows, :genre_1, :string
    add_column :shows, :genre_2, :string
    add_column :shows, :genre_3, :string
    add_column :shows, :genre_4, :string
    add_column :shows, :genre_5, :string
  end
end
