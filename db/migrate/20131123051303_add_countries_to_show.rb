class AddCountriesToShow < ActiveRecord::Migration
  def change
    add_column :shows, :country_1, :string
    add_column :shows, :country_2, :string
    add_column :shows, :country_3, :string
  end
end
