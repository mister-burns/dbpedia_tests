class Infobox < ActiveRecord::Base
  validates :label, uniqueness: true
end
