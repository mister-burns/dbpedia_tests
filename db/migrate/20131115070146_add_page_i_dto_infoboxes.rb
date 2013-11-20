class AddPageIDtoInfoboxes < ActiveRecord::Migration
  def change
    add_column :infoboxes, :page_id, :integer
  end
end
