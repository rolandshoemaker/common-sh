#!/bin/sh
#                                                                        __         
#                                                                       /\ \        
#   ___    ___     ___ ___     ___ ___     ___     ___              ____\ \ \___    
#  /'___\ / __`\ /' __` __`\ /' __` __`\  / __`\ /' _ `\  _______  /',__\\ \  _ `\  
# /\ \__//\ \_\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \_\ \/\ \/\ \/\______\/\__, `\\ \ \ \ \ 
# \ \____\ \____/\ \_\ \_\ \_\ \_\ \_\ \_\ \____/\ \_\ \_\/______/\/\____/ \ \_\ \_\
#  \/____/\/___/  \/_/\/_/\/_/\/_/\/_/\/_/\/___/  \/_/\/_/         \/___/   \/_/\/_/
#
#
# licensed under the MIT license <http://opensource.org/licenses/MIT>
#

# desc: basic print function, you know, like echo but one character...
# usage: p "print func yo"
p() {
	echo "$1"
}

# desc: abort program with error message and optional error code (default is 1).
# usage: err "what happd" [OPTIONAL_ERROR_CODE]
# requires: p
err() {
	local ECODE
	p "ERROR: $1" >&2
	if [ "$#" -eq "2" ]; then
		ECODE=$2
	else
		ECODE=1
	fi
	exit $ECODE
}

# desc: do you has $1? returns 0 or 1.
# usage: if has curl; then
# usage: 	p "you have curl :o"
# usage: fi
has() {
	if command -v $1 > /dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

# desc: what does this script NEED, aborts if user doesn't have it.
# usage: require curl
# requires: has err
require() {
	if ! has $1; then
		err "$1 is required for this script!"
	fi
}

# desc: make sure last command succeded, abort if it didn't
# desc: as with err you can set a optional error code to return
# desc: (default is 1).
# usage: command_that_might_fail
# usage: ok "well that failed then didn't it" [OPTIONAL_ERROR_CODE]
# requires: err
ok() {
	if [ $? != 0 ]; then
		if [ "$#" -eq "2" ]; then
			local ECODE=$2
		else
			local ECODE=1
		fi
		err "$1" $ECODE
	fi
}

# desc: get y/n prompt from user, if the bool is set at the end
# desc: then that will be the default answer (if user just presses
# desc: enter).
# usage: if get_yn "question to ask" [true|false]; then
# usage:   p "they said yes!"
# usage: else
# usage:   p "oh noooo"
# usage: fi
# requires: p
get_yn() {
	local prompt
	local resp
	local default
	local question="$1"
	if [ "$#" -eq "2" ]; then
		if [ ! -z "$2" ]; then
			prompt="Y/n"
			default=0
		else
			prompt="y/N"
			default=1
		fi
	else
		prompt="y/n"
	fi
	while true; do
	    read -p "$question [$prompt]: " yn
	    case $yn in
	        [yY]*) resp=0; break;;
	        [nN]*) resp=1; break;;
			"")
				if [ "$#" -eq "2" ]; then
					resp=$default; break
				else
					p "Please enter y or n."
				fi
			;;
	        *) p "Please enter y or n.";;
	    esac
	done
	return $resp
}

# desc: download a file with (curl->wget) fallback, aborts if niether tools
# desc: are available. downloads to current directory or path provided
# desc: (path should contain filename!)
# usage: download "http://www.google.com" [OPTIONAL_DOWNLOAD_PATH]
# requires: has err
download() {
	local dwn_cmd
	if has curl; then
		if [ "$#" -eq "2" ]; then
			dwn_cmd="curl -o $2"
		else
			dwn_cmd="curl -O"
		fi
	else
		if has wget; then
			dwn_cmd="wget"
			if [ "$#" -eq "2" ]; then
				dwn_cmd="$dwn_cmd -O $s"
			fi
		else
			err "neither curl nor wget are available!"
		fi
	fi
	$dwn_cmd "$1"
}
