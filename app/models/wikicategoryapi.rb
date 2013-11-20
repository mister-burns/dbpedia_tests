class Wikicategoryapi < ActiveRecord::Base
  validates :page_id, uniqueness: true
end
