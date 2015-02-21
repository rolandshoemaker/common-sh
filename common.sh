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
# usage:     p "you have curl :o"
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
        local ECODE
        if [ "$#" -eq "2" ]; then
            ECODE=$2
        else
            ECODE=1
        fi
        err "$1" $ECODE
    fi
}

# desc: returns true if the last command broke and doesn't exit
# desc: like [`ok`](#ok) does.
# usage: something_that_will_brak
# usage: if broke; then
# usage:   do_something
# usage: fi
broke() {
    if [ $? != 0 ]; then
        return 0
    else
        return 1
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
        dwn_cmd="curl"
        if [ "$#" -eq "2" ]; then
            dwn_cmd="$dwn_cmd -o $2"
        else
            dwn_cmd="$dwn_cmd -O"
        fi
    else
        if has wget; then
            dwn_cmd="wget"
            if [ "$#" -eq "2" ]; then
                dwn_cmd="$dwn_cmd -O $2"
            fi
        else
            err "neither curl nor wget are available!"
        fi
    fi
    $dwn_cmd "$1"
}


# desc: extract a file (tar|tar.gz|zip|rar) either to the current directory or a
# desc: specified path, based on [extract.sh](https://github.com/xvoland/Extract/blob/master/extract.sh)
# desc: written by [xvoland](https://github.com/xvoland).
# usage: extract thing.tar.gz [MAYBE/TO/HERE]
# requires: require err broke
extract() {
    if [ -f "$1" ] ; then
        case "$1" in
          	*.tar|*.tar.bz2|*.bz2|*.tbz2)
	            require tar
	            local extractr="tar"
	            filename="${fullfile##*/}"
	            ext="${filename#*.}"
	            if [ "$ext" = "tar" ]; then
	                extractr="$extractr xvf"
	            elif [ "$ext" = "tar.bz2" ] || [ "$ext" = "bz2" ] || [ "$ext" = "tbz2" ]; then
	                extractr="$extractr xvjf"
	            elif [ "$ext" = "tar.gz" ] || [ "$ext" = "tgz"] || [ "$ext" = "tar.xz" ]; then
	                extractr="$extractr xvzf"
	            fi
	            if [ "$#" -eq "2" ]; then
	                extractr="$extractr -C $2"
	            fi
	            $extractr
	            if [ "$#" -eq "2" ]; then
	                ok "couldn't extract $1 to $2"
	            else
	                ok "couldn't extract $1"
	            fi
	        ;;
            *.rar)
	            local extractr="unrar x -ad $1"
	            if [ "$#" -eq "2" ]; then
	                if [ ! -d "$2" ]; then
	                    mkdir -p "$2"
	                fi
	                cd "$2"
	            fi
	            $extractr
	            if broke; then
	                if [ "$#" -eq "2" ]; then
	                    cd -
	                    err "couldn't extract $1 to $2"
	                fi
	                err "couldn't extract $1"
	            fi
          	;;
	        *.lzma)
				require unlzma
	            unlzma "$1"
	        ;;
	        *.gz)
				require gunzip
	            gunzip "$1"
	        ;;
	        *.zip)
				require unzip
	            unzip "$1"
	        ;;
	        *.Z)
				require uncompress
	            uncompress "$1"
	        ;;
	        *.7z)
				require 7z
	            7z x "$1"
	        ;;
	        *.xz)
				require unxz
	            unxz "$1"
	        ;;
	        *.exe)
				require cabextract
	            cabextract "$1"
	        ;;
	        *)
	            err "$1 - unknown archive type"
	        ;;
        esac
    else
        err "$1 does not exist"
    fi
}

# desc: generate a password.
gen_pw() {

}

# desc: get external (internet facing) IP address using the
# desc: [opendns](https://opendns.com) DNS resolver and dig.
# desc: should add some curl/wget fallback type dealio...?
# usage: myip=$( w_ip )
# requires: require
w_ip() {
	require dig
	echo `dig +short myip.opendns.com @resolver1.opendns.com`
}

# desc: calculate the fibonacci sequence for ***n*** iterations.
# usage: fibonacii 10
# usage:   0 1 1 2 3 5 8 13 21 34
# requires: p
fibonacci() {
	local a=0
	local b=1
	local iters=0
	while [ $iters -lt $1 ]; do
		echo -n "$a "
		local n=`expr $a + $b`
		a=$b
		b=$n
		iters=`expr $iters + 1`
	done
}

