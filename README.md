## An analysis on Record labels data on Spotify
# SUMMERY
##### In this project, I utilized the interaction between spotify developer web API and R programming language in order to extract music data from spotify and apply an analysi on two Canadian record labels based in Toronto, ON. (Arts & Crafts and Royal Mountain records)

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
Replaced cliend_id and website_uri with mine. Spotify redirects you to a link with the user token value embeded in:
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
## In case of timed-out or failed authorization, the token should be refreshed:
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
# A Case-study on two independant record labels based in Toronto, Ontario
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
