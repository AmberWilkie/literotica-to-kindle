# Literotica to Kindle

This is a simple app to pick up hot new stories in your favorite genres, and send them to your Kindle. Check out [Literotica.com](http://www.literotica.com) for more info.

## Environmental Variables
You'll need to store your favorite genres in a `.env` file. Separate them by pipes (`|`). Because the top genre page has a weird link system, it's easiest to grab the links from the site itself. You only need the genre and the number that follows. (That will make sense when you start looking at the [lists](https://www.literotica.com/top/)). The file needs to look like this:

You also need to set up a send-from email account. It's easiest with Gmail, and I'd highly recommend creating a separate account for this service.


Here's what your `.env` file needs to look like:
```
GENRE_LINKS=Erotic-Couplings-2|First-Time-40
EMAIL_TO=somekindle_12@kindle.com
EMAIL_FROM=<your email address or whatever you want>
EMAIL_USERNAME=<your sandbox gmail account>
EMAIL_PASSWORD=<your sandbox gmail account password>
```


### To Literotica
I've been a big fan for the last twenty (?) years. Thanks for supporting such an awesome, open, engaged community. If you're interested in hiring someone to develop an open API for you (to avoid this web scraping, perhaps), please get in touch! I've got lots of ideas for improvements to the user experience.
