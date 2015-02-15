# basic print
# usage: p "print func yo"
p() {
	echo "$1"
}

# abort
# usage: err "what happd" [OPTIONAL_ERROR_CODE]
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

# do you has $1?
# usage: has curl
has() {
	if command -v $1 > /dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}

# what does this script NEED
# usage: require curl
require() {
	if ! has $1; then
		err "$1 is required for this script!"
	fi
}

# make sure last command succeded
# usage: command_that_might_fail
# usage: ok "well that failed damn" [OPTIONAL_ERROR_CODE]
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

# get y/n prompt from user
# usage: get_yn result_var "question to ask" [true|false]
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

# download a file with (curl->wget) fallback
# usage: download "http://www.google.com/index.html" [OPTIONAL_DOWNLOAD_PATH]
download() {

}
