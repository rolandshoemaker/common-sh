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

# desc: abort
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

# desc: do you has $1?
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

# desc: what does this script NEED
# usage: require curl
# requires: has err
require() {
	if ! has $1; then
		err "$1 is required for this script!"
	fi
}

# desc: make sure last command succeded
# usage: command_that_might_fail
# usage: ok "well that failed damn" [OPTIONAL_ERROR_CODE]
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
# usage: get_yn result_var "question to ask" [true|false]
# requires: p
get_yn() {
	local __answervar=$1
	local resp
	local default
	local question="$2"
	if [ "$#" -eq "3" ]; then
		if [ ! -z "$3" ]; then
			prompt="Y/n"
			default=0
		else
			prompt="y/N"
			default=1
		fi
	else
		local prompt="y/n"
	fi
	while true; do
	    read -p "$question [$prompt]: " yn
	    case $yn in
	        [yY]*) resp=0; break;;
	        [nN]*) resp=1; break;;
			"")
				if [ "$#" -eq "3" ]; then
					resp=$default; break
				else
					p "Please enter y or n."
				fi
			;;
	        *) p "Please enter y or n.";;
	    esac
	done
	eval $__answervar=$resp
}

# desc: download a file with (curl->wget) fallback
# usage: download "http://www.google.com/index.html" [OPTIONAL_DOWNLOAD_PATH]
# requires: p err
download() {
	if has curl; then

	else
		if has wget; then

		else
			err "neither curl nor wget are available!"
		fi
	fi
}
