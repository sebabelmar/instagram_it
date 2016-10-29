class RdbmsUser < ActiveRecord::Base
  
  validates :instagram_id, uniqueness: true
  has_many :rdbms_pictures
  
end
