## An analysis on Record labels data on Spotify
# SUMMERY
In this project, I utilized the interaction between spotify developer web API and R programming language in order to extract music data from spotify and apply an analysi on two Canadian record labels based in Toronto, ON. (Arts & Crafts and Royal Mountain records)

# Tools and Programs
I used the R package called [spotifyR](https://github.com/charlie86/spotifyr) in order to pull data through the spotify web api. Trying the [Client credentials](https://developer.spotify.com/documentation/general/guides/authorization/) method, I encountered access limitation to user data. That's because Certain functions in the package require the user code flow type of authorization. The user code flow takes more effort and I could't find any straight-forward instructions for that. Therefore I decided to make a guideline about how [Authorization code](https://developer.spotify.com/documentation/general/guides/authorization/code-flow/) works.

# Packages that 
# Authorization
Client_id, Client_secret and Redirect_uri: to get these variables, you need to set up a new app in the [Spotify developer dashboard](https://developer.spotify.com/dashboard/)
redirect_uri is set to default (https://localhost:8888/callback/) as spotify recommends. I have used a few code lines from [Martijn van Vreeden's analysis](https://martijnvanvreeden.nl/collecting-spotify-data-with-r/). However, I had to combine this method with spotifyR functions to get more accurate results in my field of analysis.

### To get the token
```
<browseURL(paste0('https://accounts.spotify.com/authorize?client_id=',client_id,'&response_type=code&redirect_uri=',website_uri,'/&scope=user-read-recently-played'),browser = getOption("browser"), encodeIfNeeded = FALSE)>

```
Replaced cliend_id and website_uri with mine. Spotify redirects you to a link with the user token value embeded in. Copy and assign it to user_code variable
```
user_code <- user_code_value #type the code here

```
### Construct body of POST request
```
request_body <- list(grant_type='authorization_code',
                     code=user_code,
                     redirect_uri=website_uri, #input your domain name
                     client_id = sp_client_id, #input your Spotify Client ID
                     client_secret = sp_client_secret) #input your Spotify Client Secret

```
### To get the user token
```
user_token <- httr::content(httr::POST('https://accounts.spotify.com/api/token',
                                       body=request_body,
                                       encode='form'))

user_token$access_token -> token
auth_header <- httr::add_headers('Authorization'= paste('Bearer',token))
write(user_token$refresh_token, ".spotify")

```
### In case of timed-out or failed authorization, the token should be refreshed:
```
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

```
## a Case-study on two independant record labels based in Toronto, Ontario
There are several pre-made functions in spotifyR for reaching the labels data. but there is a pre-defined limit in terms of rows in pulling data (50).
```
get_label_artists(
  label = 'arts-&-crafts',
  market = NULL,
  limit = 50, # Maximum limit is 50!
  offset = 0,
  authorization = get_spotify_access_token()
)

```
To avoid the mentioned. I have developed a method on collecting the track, album data from the artists of a specific record label. for this purpose you need to search the query through this method. In the spotify desktop app, type: <label: "label name">. this will return any song, album that ever got released on the label. select all the songs and add them to new playlist. renamed the playlist to arts_and_crafts. By using the get_playlist_audio_features function I was able to bypass the limitation and reach the target data, that is the audio features of the songs on a playlist. Here is an analysis on audio features of any track that ever got published/distributed through the Arts & Crafts and Royal Mountain labels in Canada on Spotify:
```
Arts_and_Crafts <- get_playlist_audio_features(
  'Spotify_user_id', #Spotify user id, copy from the user profile link
  'Playlist_id', #Playlist id, copy the id character the link of the playlist
  authorization = token # rename the access_token to token in order to use the user data funcions
)

```
In order to clean the data, I applied the filter functions to narrow down the available markets to Canada:
```
Arts_and_crafts_CA <- filter(Arts_and_Crafts, track.available_markets == "CA")

```

Same goes with Royal Mountain record label:
```
Royal_Mountain <- get_playlist_audio_features(
  'Spotify_user_id', #Spotify user id, copy from the user profile link
  'Playlist_id', #Playlist id, copy the id character the link of the playlist
  authorization = token # rename the access_token to token in order to use the user data funcions
)

Royal_Mountain_CA <- filter(Royal_Mountain, track.available_markets == "CA")

```
To apply an anlysis on the song features, I chose 4 metric: Energy, speechiness, instrumentalness, danceability and popularity as the main factor of comparison. I created a new variable called "year" and grouped the tracks accordingly:
```
ArtsCrafts_year <- Arts_and_crafts_CA %>%
  mutate(year = year(track.album.release_date)) %>%
  group_by(year)


Royal_Mountain_year <- Royal_Mountain_CA %>%
  mutate(year = year(track.album.release_date)) %>%
  group_by(year)
  
  ```
### To get glimpse on the average of tracks audio features through the years of 2012-2021:
```
aggregate(Royal_Mountain_year[, 6:37], list(Royal_Mountain_year$year), mean)
aggregate(ArtsCrafts_year[, 6:37], list(ArtsCrafts_year$year), mean)

```

### Here is a visualization on relation between the tracks popularity and several metric that are mentioned before:
```
ggplot(data=Arts_and_crafts_CA)+geom_point(mapping=aes(y=track.popularity, x=instrumentalness))
ggplot(data=Royal_Mountain_CA)+geom_point(mapping=aes(y=track.popularity, x=instrumentalness))  

```
![Rplot_royal_mountain_instrumentalness](https://user-images.githubusercontent.com/93812491/143511141-5aa2d17c-184d-40db-8c68-68c8cd58a04a.png)
![Rplot_royal_mountain_instrumentalness](https://user-images.githubusercontent.com/93812491/143511243-8bffe95f-020d-4d34-959b-0e5c110b87f2.png)

Royal mountain is more various in terms of instrumentalness that can interpreted as different styles of production.
Arts and Crafts was more active through Vocal-based genres of music

```
ggplot(data=Arts_and_crafts_CA)+geom_point(mapping=aes(y=track.popularity, x=energy))
ggplot(data=Royal_Mountain_CA)+geom_point(mapping=aes(y=track.popularity, x=energy))

```
![Rplot_artscrafts_energy](https://user-images.githubusercontent.com/93812491/143511404-96f604c6-8a50-483c-94af-14aa9a8f7c19.png)
![Rplot_royalmountain_energy](https://user-images.githubusercontent.com/93812491/143511411-93c595bd-1dbd-4130-9d45-cb22f00ad3af.png)

Royal mountain tends to be more active releasing more energetic tracks
```
ggplot(data=Arts_and_crafts_CA)+geom_point(mapping=aes(y=track.popularity, x=speechiness))
ggplot(data=Royal_Mountain_CA)+geom_point(mapping=aes(y=track.popularity, x=speechiness))

```
![Rplot_artscrafts_speechiness](https://user-images.githubusercontent.com/93812491/143511433-5864a1f2-2b52-4c84-9741-751d40af22ac.png)
![Rplot_royalmountain_speechiness](https://user-images.githubusercontent.com/93812491/143511442-5c2d6410-e368-462a-a78a-d193f32da159.png)

Arts & Crafts released more vocal-based tracks that reached popularity (this also supports the first table's results)

```
ggplot(data=Arts_and_crafts_CA)+geom_point(mapping=aes(y=track.popularity, x=danceability))
ggplot(data=Royal_Mountain_CA)+geom_point(mapping=aes(y=track.popularity, x=danceability))

```

Royal Mountain acted more various in terms of dancebility of the released tracks


#### Thanks for reading, Farshad Bokaie
