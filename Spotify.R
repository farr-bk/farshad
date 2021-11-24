
# In this project, I used the R package called "spotifyR" in order to pull data through the spotify web api
# Trying the access_token method in the package, I encountered access limitation to user data. that's because Certain functions in the package require the user code flow type of authorization
# User token type: authorization code flow (credits to https://martijnvanvreeden.nl/collecting-spotify-data-with-r/)

#to get token FIRST TIME:

## client_id, client_secret and redirect_uri: to get these variables, you need to set up a new app in the spotify api dashboard (https://developer.spotify.com/dashboard/)
## redirect_uri is set to default (https://localhost:8888/callback/) as spotify recommends.

browseURL(paste0('https://accounts.spotify.com/authorize?client_id=',client_id,'&response_type=code&redirect_uri=',website_uri,'/&scope=user-read-recently-played'),browser = getOption("browser"), encodeIfNeeded = FALSE)


# after running the function, spotify asks for the access permission to user data. click agree and copy the user_code_value that is found in the browser URL that comes up.

user_code <- user_code_value #type the code here


#construct body of POST request FIRST TIME

request_body <- list(grant_type='authorization_code',
                     code=user_code,
                     redirect_uri=website_uri, #input your domain name
                     client_id = sp_client_id, #input your Spotify Client ID
                     client_secret = sp_client_secret) #input your Spotify Client Secret


#get user tokens FIRST TIME

user_token <- httr::content(httr::POST('https://accounts.spotify.com/api/token',
                                       body=request_body,
                                       encode='form'))

user_token$access_token -> token
auth_header <- httr::add_headers('Authorization'= paste('Bearer',token))
write(user_token$refresh_token, ".spotify")

#In case of timed-out or failed authorization, the token should be refreshed:

if(file.exists(".spotify")) {
  print("we have file")
  
  #REFRESH
  scan(file = ".spotify", what= list(id="")) -> red
  as.character(red) -> refresh_code
  request_body_refresh <- list(grant_type='refresh_token',
                               refresh_token=refresh_code,
                               redirect_uri=website_uri,
                               client_id = sp_client_id,
                               client_secret = sp_client_secret)
  
  #get user tokens REFRESH
  user_token_refresh <- httr::content(httr::POST('https://accounts.spotify.com/api/token',
                                                 body=request_body_refresh,
                                                 encode='form'))
  user_token_refresh$access_token -> token
}

# Notice that most of spotifyr functions have a limit of pulling data (50). additionally, using get_label_artist function results in limited data containing a list of artist who ever released any material on the record label

get_label_artists(
  label = 'arts-&-crafts',
  market = NULL,
  limit = 50, # Maximum limit is 50!
  offset = 0,
  authorization = get_spotify_access_token()
)

# Alternatively, the spotifyR search funcion also returns a limited number of results

Arts_and_Crafts <- search_spotify(
  'label: arts-&-crafts',
  type = c("track"),
  market = NULL,
  limit = 50,
  offset = 0,
  include_external = NULL,
  authorization = token,
  include_meta_info = FALSE
)

# To avoid the mentioned. I have developed a method on collecting the track, album data from the artists of a specific record label
# for this purpose you need to search the query through this method. In the spotify desktop app, type: <label: "label name">. this will return any song, album that ever got released on the label.
# select all the songs and add them to new playlist. renamed the playlist to arts_and_crafts
# By using the get_playlist_audio_features function I was able to bypass the limitation and reach the target data, that is the audio features of the songs on a playlist


# Here is an analysis on audio features of any track that ever got published/distributed through the Arts & Crafts and Royal Mountain labels in Canada on Spotify:

Arts_and_Crafts <- get_playlist_audio_features(
  'Spotify_user_id', #Spotify user id, copy from the user profile link
  'Playlist_id', #Playlist id, copy the id character the link of the playlist
  authorization = token # rename the access_token to token in order to use the user data funcions
)

# In order to clean the data, I applied the filter functions to narrow down the available markets to Canada
Arts_and_crafts_CA <- filter(Arts_and_Crafts, track.available_markets == "CA")


Royal_Mountain <- get_playlist_audio_features(
  'Spotify_user_id', #Spotify user id, copy from the user profile link
  'Playlist_id', #Playlist id, copy the id character the link of the playlist
  authorization = token # rename the access_token to token in order to use the user data funcions
)

Royal_Mountain_CA <- filter(Royal_Mountain, track.available_markets == "CA")


# To give a broader view about the performance of the label in terms of musicology I chose 4 different metrics that are variables of the final data frame:
## Energy, speechiness, instrumentalness, danceability and popularity as the main factor of comparison



# To apply an annual analysis, I created a new variable called "year" and grouped the tracks accordingly: 

ArtsCrafts_year <- Arts_and_crafts_CA %>%
  mutate(year = year(track.album.release_date)) %>%
  group_by(year)


Royal_Mountain_year <- Royal_Mountain_CA %>%
  mutate(year = year(track.album.release_date)) %>%
  group_by(year)


# To get glimpse on the average of tracks audio features through the years of 2012-2021:

aggregate(Royal_Mountain_year[, 6:37], list(Royal_Mountain_year$year), mean)
aggregate(ArtsCrafts_year[, 6:37], list(ArtsCrafts_year$year), mean)



# Here is an analytic visualization on relation between the tracks popularity and several metric that are mentioned before:

ggplot(data=Arts_and_crafts_CA)+geom_point(mapping=aes(y=track.popularity, x=instrumentalness))
ggplot(data=Royal_Mountain_CA)+geom_point(mapping=aes(y=track.popularity, x=instrumentalness))            

## Royal mountain is more various in terms of instrumentalness that can interpreted as different styles of production
## Arts and Crafts was more active through Vocal-based genres of music

ggplot(data=Arts_and_crafts_CA)+geom_point(mapping=aes(y=track.popularity, x=energy))
ggplot(data=Royal_Mountain_CA)+geom_point(mapping=aes(y=track.popularity, x=energy))

## Royal mountain tends to be more active releasing more energetic tracks

ggplot(data=Arts_and_crafts_CA)+geom_point(mapping=aes(y=track.popularity, x=speechiness))
ggplot(data=Royal_Mountain_CA)+geom_point(mapping=aes(y=track.popularity, x=speechiness))

## Arts & Crafts released more vocal-based tracks that reached popularity (this also supports the first table)

ggplot(data=Arts_and_crafts_CA)+geom_point(mapping=aes(y=track.popularity, x=danceability))
ggplot(data=Royal_Mountain_CA)+geom_point(mapping=aes(y=track.popularity, x=danceability))

## Royal Mountain acted more various in terms of dancebility of the released tracks



# Thanks for reading, Farshad Bokaie


