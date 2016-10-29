class NoSqlPicture
  include Mongoid::Document
  # We dont need a migration!

  belongs_to :no_sql_user

  validates :instagram_id, uniqueness: true

	field :instagram_id, type: String
	field :instagram_type, type: String
	field :location, type: Hash
	field :link, type: String
	field :thumbnail, type: String
	field :standard_resolution, type: String
end


