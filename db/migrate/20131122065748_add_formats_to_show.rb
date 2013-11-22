class AddFormatsToShow < ActiveRecord::Migration
  def change
    add_column :shows, :format_1, :string
    add_column :shows, :format_2, :string
    add_column :shows, :format_3, :string
    add_column :shows, :format_4, :string
    add_column :shows, :format_5, :string
  end
end
