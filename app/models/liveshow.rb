class Liveshow < ActiveRecord::Base
  validates :label, uniqueness: true
end
