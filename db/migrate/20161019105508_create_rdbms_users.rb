class CreateRdbmsUsers < ActiveRecord::Migration
  def change
  	 create_table :rdbms_users do |t|
  	 		t.string :bio
				t.string :full_name
				t.string :instagram_id
				t.string :profile_picture
				t.string :username
				t.string :website
  	 end
  end
end