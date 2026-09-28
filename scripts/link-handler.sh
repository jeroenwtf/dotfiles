#!/usr/bin/env bash
set -euo pipefail

domains_file="$HOME/.dotfiles/link-handler/domains.yaml"
default_browser="firefox-developer-edition"
alternate_browser="firefox"
url="${1:-}"

if [ -f "$domains_file" ] && [[ ${url,,} =~ ^https?:// ]]; then
	rest="${url#*://}"
	rest="${rest%%'?'*}"
	rest="${rest%%'#'*}"
	if [[ $rest == */* ]]; then
		path="${rest#*/}"
		host="${rest%%/*}"
	else
		path=''
		host="$rest"
	fi
	host="${host##*@}"
	host="${host%%:*}"
	host="${host,,}"

	while read -r entry; do
		if [[ $entry == */* ]]; then
			entry_host="${entry%%/*}"
			entry_path="${entry#*/}"
			entry_path="${entry_path%/}"
		else
			entry_host="$entry"
			entry_path=''
		fi
		entry_host="${entry_host,,}"
		if [[ $host == "$entry_host" || $host == *."$entry_host" ]]; then
			if [ -z "$entry_path" ] || [ "$path" = "$entry_path" ] || [[ $path == "$entry_path"/* ]]; then
				exec "$alternate_browser" "$url"
			fi
		fi
	done < <(sed -nE 's/[[:space:]]*#.*$//; s/^[[:space:]]*-[[:space:]]*//p' "$domains_file")
fi

if [ -n "$url" ]; then
	exec "$default_browser" "$url"
fi
exec "$default_browser"
