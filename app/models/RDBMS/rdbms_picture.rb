class RdbmsPicture < ActiveRecord::Base
  # Remember to create a migration!

  validates :instagram_id, uniqueness: true
end
