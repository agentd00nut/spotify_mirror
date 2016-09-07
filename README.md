# spotify_mirror

Dependencies
============
*jq* 
OS X
	brew install jq
Linux
	sudo apt-get install jq
or just go here 
	https://stedolan.github.io/jq/download/


Initial Setup
==============

Because it's in bash and runs locally you will need your own client id and secret.
Just go here https://developer.spotify.com/my-applications/ . Click *Create An App* and fill out the form.
Literally nothing matters, name it anything, give it any description.
Put *Client Id* in the string on line 1
Put *Client Secret* in the string on line 2

"Shouldn't this be automatic" Yes but until i rewrite it in another language and make a server, it's not.

Setup
=====

Before using this tool it's likely you need to fetch yourself a new OAuth Token.
Just go here. https://developer.spotify.com/web-api/console/get-album/
Click *Get Oauth Token*
Click all four playlist options.
Request Token.
Copy the entire token.
Replace the string on line 3 with your token and now you are set for a few hours.

"Why do i have to do this every time!" Because it's bash and it's running locally and boy it'd be great if someone made this bit automatic.
If only it was open source, my oh my.


Usage
=======

	./spotify_mirror.sh -u agentd00nut -s "00 tier" -m "00 tier_albums" -e expand

- -u user, your spotify username
- -s source, source playlist name, case sensitive
- -m mirror, mirror playlist name, case sensitive, usually the "destination" for programs actions.
- -e expand, find each artist in source playlist, find each album for each artist, place each song from each album into the mirror.


You can re run the command and it will do nothing.  The important bit to realize there is it won't duplicate songs in a playlist!
There is a duplicate function laid out in the get opts, it doesn't work because  wrote something interesting instead.


Who would want this?
====================

Me.  Also, anyone who uses discover a lot and goes "boy i really like all these songs, i wish there was a quick way to make a playlist of all the artists on this playlist".
Additionally anyone who ever says "Man i wish i could make a playlist out of this sick 'Drum n Bass' playlist and this 'whatever the fuck' playlist and 
that it would get updated when either one of those playlists get updated!"... though they'll have to wait for the -m mirror function.

This is stupid, make it easier to use
======================================

I'll be making a web portal ( woa automatic OAuth! ).  You'll just login with spotify, use the functions there and lalala it'll be magic and have ads.
