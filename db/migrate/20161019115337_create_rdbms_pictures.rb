class CreateRdbmsPictures < ActiveRecord::Migration
  def change
  	create_table :rdbms_pictures do |t|
  		t.string :instagram_id
			t.string :instagram_type
			t.string :location
			t.string :link
			t.string :thumbnail
			t.string :standard_resolution

			t.belongs_to :rdbms_user
  	end
  end
end
