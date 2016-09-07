#!/bin/bash

id="2db021e2640d4413abfe8366d87bc6f5"
secret=""
token="BQBp7MTIh0DtV8gfQbGDBc5hYspg7eaRk0fwKx7jNWxIwl4IuLG2OsjOfNxoz-6LOvTFMRVz6iQ_UevMvMNlmaH27MyHwqB2DKm6SQ3FAdtf3iJB-KYj0XmFlH-3hHu0AzBVWi2unPiSG7pNXJvUjbZAnHu-KvMK5LGacyPBuXHfK6iNwl6lvPYvSWNLQl7wbrVj4PDjTsSjOQDLplMnuXY2FQ7saUc5f-t0vwWbjZIVEu9kHpn7I5ld7NRS"
auth="Authorization: Bearer ${token}"

while getopts ":u:m:s:d:e" opt; do
  case $opt in
    u)
      user=$OPTARG>&2
      ;;
    m)
	  mirror=$OPTARG>&2
	  ;;
	s)
	  source=$OPTARG>&2
	  ;;
	d)
	  duplicate=$OPTARG>&2
	  ;;
	e)
	  expand=true>&2
	  ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done
shift $((OPTIND-1)) 

spotify_GET(){
	url=$1
	auth=$2

	curl -s -X GET "${url}" -H "Accept: application/json" -H "${auth}"

}

get_playlists(){
	user=$1
	auth=$2

	spotify_GET "https://api.spotify.com/v1/users/${user}/playlists" "${auth}"
}

playlist_exists(){
	user=$1
	auth=$2
	playlist=$3

	get_playlists "${user}" "${auth}"   | jq .items[].name  | grep -q "${playlist}"  || false
}

get_playlist_id(){
	user=$1
	auth=$2
	playlist=$3

	get_playlists "${user}" "${auth}"  | jq  -r '.items[] | "\"" + .name + "\",,," + .id ' | grep "\"${playlist}\"" | awk -F",,," '{print $2}'
}

make_playlist(){
	user=$1
	auth=$2
	playlist=$3


	curl -s -X POST "https://api.spotify.com/v1/users/${user}/playlists" -H "Accept: application/json" -H "${auth}" --data "{\"name\":\"${playlist}\",\"public\":false}" | jq .id | tr -d '"'
}

get_albums(){
	user=$1
	auth=$2
	source=$3
	spotify_GET "https://api.spotify.com/v1/users/${user}/playlists/${source}" "${auth}" | jq  '.tracks.items[].track | .album.id' | uniq | tr -d '"'  #| jq .tracks.items[].track.id)
}

get_album_tracks(){
	auth=$1
	album_id=$2

	spotify_GET  "https://api.spotify.com/v1/albums/${album_id}/tracks" "${auth}"
}

get_playlist_tracks(){
	user=$1
	auth=$2
	playlist_id=$3
	spotify_GET  "https://api.spotify.com/v1/users/${user}/playlists/${playlist_id}/tracks" "${auth}"
}


#get_playlists "${user}" "${auth}"  | jq  -r '.items[] | "\"" + .name + "\" " + .id ' | grep "\"The Sound of Bassnectar\""
# Find all the in one playlist, and put all their tracks in another.
if [ -n "$expand" ]; then

	if ! playlist_exists "${user}" "${auth}" "${source}" ; then 
		echo "'${source}' doesn't exist for ${user}"
		exit;
	fi

	source_id=$( get_playlist_id "${user}" "${auth}" "${source}" )  # Check if source exists.

	echo "'${source}' found... '${source_id}'"
	

	if ! playlist_exists "${user}" "${auth}" "${mirror}" ; then 

		echo "Make '${mirror}' for ${user}"	
		mirror_id=$( make_playlist "${user}" "${auth}" "${mirror}" )
	
	else
		mirror_id=$( get_playlist_id "${user}" "${auth}" "${mirror}" )
	fi

	
	OFS=${IFS};
	IFS=$'\n'
 	mirror_tracks=( $( get_playlist_tracks "${user}" "${auth}" "${mirror_id}" | jq -r  .items[].track.name ) )
	IFS=${OFS}

	echo "'${mirror}' found... '${mirror_id}'... ${#mirror_tracks[@]} tracks found..."

	if [ "${#mirror_tracks[@]}" -eq "0" ]; then
		mirror_tracks[0]="RANDOM BULLSHIT SO THAT THE MAIN LOOP WORKS LOL THIS IS GHETTO"
	fi

	#echo ${mirror_tracks[@]};
	#exit;

	echo "Get the albums that make up '${source_id}'"

	source_albums=$( get_albums "${user}" "${auth}" "${source_id}" })

	for album in ${source_albums[@]}; do
		
		echo "Check ${album} for new songs."

		new_tracks=()
		i=0
		while read track_info; do 
			track=`echo ${track_info} | awk -F",,," '{print $1}'`
			uri=`echo ${track_info} | awk -F",,," '{print $2}'`

			if ! grep -iq "${track}" <( echo ${mirror_tracks[@]} ); then 
				echo "Add '${track}' to '${mirror}' as '${uri}'"
				new_tracks[i]="${uri}"
				let i++
			fi
				
		done << EOF
$( get_album_tracks "${auth}"  "${album}" | jq -r '.items[] | .name +",,,"+ .uri' )
EOF

		track_string=$( IFS=$','; echo "${new_tracks[*]}" )
		
		if [ -n "${track_string}" ]; then
			echo "Add Tracks To '${mirror}'"
			curl -s -X POST "https://api.spotify.com/v1/users/${user}/playlists/${mirror_id}/tracks?uris=${track_string}" -H "Accept: application/json" -H "${auth}" 1>/dev/null
		fi


	done
fi



#if [ -n "$duplicate" ]; then
#	source_tracks=$(curl -X GET "https://api.spotify.com/v1/users/${user}/playlists/${source}" -H "Accept: application/json" -H ${auth} | jq .tracks.items[].track.id)
#
#
#	curl -X GET "https://api.spotify.com/v1/users/${user}/playlists/${source}" -H "Accept: application/json" -H ${auth} \
#		-H "Content-Type: application/json" --data \
#		 "{\"name\":\"NewPlaylist\",\"public\":false}"
#fi

#curl -X GET "https://api.spotify.com/v1/users//playlists/" -H "Accept: application/json" -H ${auth}