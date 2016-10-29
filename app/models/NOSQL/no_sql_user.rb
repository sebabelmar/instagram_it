class NoSqlUser 
	include ActiveModel::Validations
	include Mongoid::Document

	has_many :no_sql_pictures

	validates :instagram_id, uniqueness: true

	field :bio, type: String
	field :full_name, type: String
	field :instagram_id, type: String
	field :profile_picture, type: String
	field :username, type: String
	field :website, type: String
end






 