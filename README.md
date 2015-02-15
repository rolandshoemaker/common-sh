# common-sh

a *library* (i use the term extremely liberally) of *Bourne* shell functions
(`sh` not `bash`, but most of the functions should work in `bash` too i guess) in
an attempt to make writing bourne shell scripts somewhat quickier.

## usage

Either copy+paste the functions that you want into your sciprt, or source the entire file
for the *everything* (although idk why you'd want to do this, then you'd have to
distribute `common.sh`... w/e). a lot of the functions are interdependent on each other,
but the comment above the function should explain which other functions it depends on.

## the good part!


### table of contents

* [p](#p)
* [err](#err)
* [has](#has)
* [require](#require)
* [ok](#ok)
* [get_yn](#get_yn)
* [download](#download)

### `p`

basic print

	p "print func yo"

#### source

	p() {
		echo "$1"
	}

### `err`

abort

	err "what happd" [OPTIONAL_ERROR_CODE]

#### source

	err() {
		local ECODE
		p "ERROR: $1" >&2
		if [ "$#" -eq "2" ]; then
			ECODE=$2
		else
			ECODE=1
		fi
		exit $ECODE
	}#### requires

* [p](#p)



### `has`

do you has $1?

	has curl

#### source

	has() {
		if command -v $1 > /dev/null 2>&1; then
			return 0
		else
			return 1
		fi
	}

### `require`

what does this script NEED

	require curl

#### source

	require() {
		if ! has $1; then
			err "$1 is required for this script!"
		fi
	}#### requires

* [has](#has)
* [err](#err)



### `ok`

make sure last command succeded

	command_that_might_fail
	ok "well that failed damn" [OPTIONAL_ERROR_CODE]

#### source

	ok() {
		if [ $? != 0 ]; then
			if [ "$#" -eq "2" ]; then
				local ECODE=$2
			else
				local ECODE=1
			fi
			err "$1" $ECODE
		fi
	}#### requires

* [err](#err)



### `get_yn`

get y/n prompt from user

	get_yn result_var "question to ask" [true|false]

#### source

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
	}#### requires

* [p](#p)



### `download`

download a file with (curl->wget) fallback

	download "http://www.google.com/index.html" [OPTIONAL_DOWNLOAD_PATH]

#### source

	download() {
		if has curl; then
	
		else
			if has wget; then
	
			else
				err "neither curl nor wget are available!"
			fi
		fi
	}#### requires

* [p](#p)
* [err](#err)

