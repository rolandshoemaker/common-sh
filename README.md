```
#                                                                        __         
#                                                                       /\ \        
#   ___    ___     ___ ___     ___ ___     ___     ___              ____\ \ \___    
#  /'___\ / __`\ /' __` __`\ /' __` __`\  / __`\ /' _ `\  _______  /',__\\ \  _ `\  
# /\ \__//\ \_\ \/\ \/\ \/\ \/\ \/\ \/\ \/\ \_\ \/\ \/\ \/\______\/\__, `\\ \ \ \ \ 
# \ \____\ \____/\ \_\ \_\ \_\ \_\ \_\ \_\ \____/\ \_\ \_\/______/\/\____/ \ \_\ \_\
#  \/____/\/___/  \/_/\/_/\/_/\/_/\/_/\/_/\/___/  \/_/\/_/         \/___/   \/_/\/_/
#
```

a *library* (i use the term ***extremely*** liberally) of *Bourne* shell functions
(`sh` not `bash`, but most of the functions should work in `bash` too i guess) in
an attempt to make writing bourne shell scripts somewhat quickier.

also I wrote a python tool ([`quick-doc.py`](https://github.com/rolandshoemaker/quick-doc))
for generating markdown from comments in shell scripts.

## Usage

Either copy+paste the functions that you want into your sciprt, or source the entire file
for the *everything* (although idk why you'd want to do this, then you'd have to
distribute `common.sh`... w/e). a lot of the functions are interdependent on each other,
but the comment above the function should explain which other functions it depends on.

## Documentation

The good part!

## Table of Contents

* [`p`](#p)
* [`err`](#err)
* [`has`](#has)
* [`require`](#require)
* [`ok`](#ok)
* [`get_yn`](#get_yn)
* [`download`](#download)

## `p`

basic print function, you know, like echo but one character...

```sh
p "print func yo"
```

### Source

```sh
p() {
	echo "$1"
}
```

## `err`

abort program with error message and optional error code (default is 1).

```sh
err "what happd" [OPTIONAL_ERROR_CODE]
```

### Source

```sh
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
```

### Requires

* [`p`](#p)

## `has`

do you has $1? returns 0 or 1.

```sh
if has curl; then
	p "you have curl :o"
fi
```

### Source

```sh
has() {
	if command -v $1 > /dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}
```

## `require`

what does this script NEED, aborts if user doesn't have it.

```sh
require curl
```

### Source

```sh
require() {
	if ! has $1; then
		err "$1 is required for this script!"
	fi
}
```

### Requires

* [`has`](#has)
* [`err`](#err)

## `ok`

make sure last command succeded, abort if it didn't
as with err you can set a optional error code to return
(default is 1).

```sh
command_that_might_fail
ok "well that failed then didn't it" [OPTIONAL_ERROR_CODE]
```

### Source

```sh
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
```

### Requires

* [`err`](#err)

## `get_yn`

get y/n prompt from user, if the bool is set at the end
then that will be the default answer (if user just presses
enter).

```sh
get_yn result_var "question to ask" [true|false]
```

### Source

```sh
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
```

### Requires

* [`p`](#p)

## `download`

download a file with (curl->wget) fallback, aborts if niether tools
are available.

```sh
download "http://www.google.com" [OPTIONAL_DOWNLOAD_PATH]
```

### Source

```sh
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

	$dwn_cmd $1
}
```

### Requires

* [`p`](#p)
* [`err`](#err)
