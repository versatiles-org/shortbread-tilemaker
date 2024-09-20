log_message() {
	echo -e "\033[1;32m${1}\033[0m"
}

log_error() {
	echo -e "\033[1;31m${1}\033[0m"
}

download() {
	URL=$1
	FILENAME=$2

	if [[ $URL != http* ]]; then
		log_error "utils.sh/download(): First argument must be a valid URL"
		exit 1
	fi

	if [ -z "$FILENAME" ]; then
		log_error "utils.sh/download(): Second argument must be a filename"
		exit 1
	fi

	FILENAME_TEMP="${FILENAME}.tmp"

	if [[ ${URL##*.} == 'torrent' ]]; then
		aria2c --download-result=hide --summary-interval=0 --seed-time=0 --out="$FILENAME_TEMP" "$URL"
	else
		curl --location --progress-bar "$URL" --output "$FILENAME_TEMP"
	fi

	mv "$FILENAME_TEMP" "$FILENAME"
}
