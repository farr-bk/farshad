## An analysis on Record labels data on Spotify
# SUMMERY
##### In this project, I utilized the interaction between spotify developer web API and R programming language in order to extract music data from spotify and apply an analysi on two Canadian record labels based in Toronto, ON. (Arts & Crafts and Royal Mountain records)

# Tools and Programs
I used the R package called [spotifyR](https://github.com/charlie86/spotifyr) in order to pull data through the spotify web api. Trying the [Client credentials](https://developer.spotify.com/documentation/general/guides/authorization/) method, I encountered access limitation to user data. That's because Certain functions in the package require the user code flow type of authorization. The user code flow takes more effort and I could't find any straight-forward instructions for that. Therefore I decided to make a guideline about how [Authorization code](https://developer.spotify.com/documentation/general/guides/authorization/code-flow/) works.

# Authorization
Client_id, Client_secret and Redirect_uri: to get these variables, you need to set up a new app in the [Spotify developer dashboard](https://developer.spotify.com/dashboard/)
redirect_uri is set to default (https://localhost:8888/callback/) as spotify recommends.

```
<browseURL(paste0('https://accounts.spotify.com/authorize?client_id=',client_id,'&response_type=code&redirect_uri=',website_uri,'/&scope=user-read-recently-played'),browser = getOption("browser"), encodeIfNeeded = FALSE)>
```
