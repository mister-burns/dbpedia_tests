class Label < ActiveRecord::Base
  validates :label, uniqueness: true
end
