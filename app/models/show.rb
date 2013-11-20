class Show < ActiveRecord::Base
  validates :wikipage_id, uniqueness: true
end
