class AddNetworksToShow < ActiveRecord::Migration
  def change
    add_column :shows, :network_1, :string
    add_column :shows, :network_2, :string
  end
end
