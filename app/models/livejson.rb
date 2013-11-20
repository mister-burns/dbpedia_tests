class Livejson < ActiveRecord::Base
  validates :label, uniqueness: true
end
