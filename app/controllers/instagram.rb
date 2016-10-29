# ##################### THE FLOW OF OAuth 2.0 #######################
# ----------------------------------------------------------------------

# 

# Step 0:   Provide a way to manage a ridirect to the third party login

# Step 1:   Redirect the users to the third party Auth url. This redirect 
#           usually require send some query params to notify the third party
#           who you are and where are you comming from.

# Step 2:   The third party service will responde back to your application to
#           the callback URL. In this case they are responding with a code.
#           Look the what the params have.

# Step 3:   Once you have the code. Format a Post request to get an access token
#           and some Users information. Inspect the response out of that Post.
#           Use this info to create a user in your DB save and the token
#           in the sessions hash.

# Step 4:   Use the access token saved in the session hash to consume the API

# ----------------------------------------------------------------------


# ##################### API WRAPER CONFIGURATION #######################
# ----------------------------------------------------------------------

# Make sure you register a callback URL with the third party
CALLBACK_URL = "http://localhost:9393/auth/callback"


# Here your cerdentials. You can allocate this somewhere else. Environment file
# would be a good place. Id and secret better to be saved in an .env file.
Instagram.configure do |config|
  config.client_id = "2b089c3e792e413e83df3a594320373c"
  config.client_secret = "528659e2e55b4e4790231e7ab47ca68a"
end

# ---------------------------------------------------------------------


# ##################### AUTH AND CONSUPTION FLOW #######################
# ----------------------------------------------------------------------

# Step 0: Provide a way to manage a ridirect to the third party login mechanism.
get '/' do

  # Link to: get /auth/connect
  '<a href="/auth/connect">
    <img src="http://i.kinja-img.com/gawker-media/image/upload/t_original/ijmyfpjavgey76pyxnft.jpg">
  </a>'
end

# Step 1: Redirect to third party login.
get '/auth/connect' do
  
  # Redirects to instagram OAuth URL and passes the your callback and extra info
  p url = Instagram.authorize_url(:redirect_uri => CALLBACK_URL)
  
  redirect url
end

# Step 2: CALLBACK_URL registred on third party
get "/auth/callback" do

  p '#### The code comming back from the third party ####'
  p params
  p '####################################################'


# Use the code to format a post request to the third party and request an
# access token.
  response = Instagram.get_access_token(params[:code], :redirect_uri => CALLBACK_URL)

# Step 3: Save user info and access token
  p "##########   accsess_token ##############"
  p response.access_token
  p "--------------------------------------"
  p "##########    user info    ##############"
  p response
  p "--------------------------------------"

  user_info = response.user

  # Creating SQL and NoSQL User from info provided by third party
  NoSqlUser.create(
    bio: user_info.bio,
    full_name: user_info.full_name,
    instagram_id: user_info.id,
    profile_picture: user_info.profile_picture,
    username: user_info.username,
    website: user_info.website)

  RdbmsUser.create(
    bio: user_info.bio,
    full_name: user_info.full_name,
    instagram_id: user_info.id,
    profile_picture: user_info.profile_picture,
    username: user_info.username,
    website: user_info.website)

  # Saving the token in sessions hash
  session[:access_token] = response.access_token

  redirect "/user_recent_media"
end

get "/user_recent_media" do
  
# Step 4: Consume the API  
  client = Instagram.client(:access_token => session[:access_token])
  user = client.user
  recent_media = client.user_recent_media

  # Printing one picture object coming from third party
  pp JSON.parse(recent_media.first.to_json)

  # This is an extra step to find the user...
  no_sql_user_id = NoSqlUser.find_by(instagram_id: recent_media.first.user.id)
  rdbms_user_id = RdbmsUser.find_by(instagram_id: recent_media.first.user.id)

  # Saving Pictures in Mongo and Postgres 
  recent_media.each do |media|
    NoSqlPicture.create(
      no_sql_user_id: no_sql_user_id.id,
      instagram_id: media.id,
      instagram_type: media.type,
      location: media.location,
      link: media.link,
      thumbnail: media.images.thumbnail.url,
      standard_resolution: media.images.standard_resolution.url
      )

    RdbmsPicture.create(
      rdbms_user_id: rdbms_user_id.id,
      instagram_id: media.id,
      instagram_type: media.type,
      location: 'we can not include a hash in sql',
      link: media.link,
      thumbnail: media.images.thumbnail.url,
      standard_resolution: media.images.standard_resolution.url
      )
  end


  # You now can use third party data in your views
  # This is an expensive example but here we use both DB's to render
  html = "<h1>#{no_sql_user_id.username}'s recent media</h1>"
  for media_item in RdbmsPicture.all
    html << "<div style='float:left;'><img src='#{media_item.thumbnail}'></div>"
  end

  html
end

# ----------------------------------------------------------------------