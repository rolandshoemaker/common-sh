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

also I wrote a python tool (`quick-doc.py`) for generating markdown from comments
in shell scripts based on the following comment format

```
# desc: this is the description, any *markdown* can be
# desc: put here since we are just passing it through
# desc: as markdown!
# usage: function "argument" [optional argument]
# requires: required_function another_required
a_function() {
	echo "woop woop"
}
```

output of it can be seen [here](#the-good-part)!

## usage

Either copy+paste the functions that you want into your sciprt, or source the entire file
for the *everything* (although idk why you'd want to do this, then you'd have to
distribute `common.sh`... w/e). a lot of the functions are interdependent on each other,
but the comment above the function should explain which other functions it depends on.

## the good part!


### table of contents

* [`p`](#p)
* [`err`](#err)
* [`has`](#has)
* [`require`](#require)
* [`ok`](#ok)
* [`get_yn`](#get_yn)
* [`download`](#download)

### `p`

basic print

```sh
p "print func yo"
```

#### source

```sh
p() {
	echo "$1"
}
```

### `err`

abort

```sh
err "what happd" [OPTIONAL_ERROR_CODE]
```

#### source

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

#### requires

* [p](#p)

### `has`

do you has $1?

```sh
if has curl; then
	p "you have curl :o"
fi
```

#### source

```sh
has() {
	if command -v $1 > /dev/null 2>&1; then
		return 0
	else
		return 1
	fi
}
```

### `require`

what does this script NEED

```sh
require curl
```

#### source

```sh
require() {
	if ! has $1; then
		err "$1 is required for this script!"
	fi
}
```

#### requires

* [has](#has)
* [err](#err)

### `ok`

make sure last command succeded

```sh
command_that_might_fail
ok "well that failed damn" [OPTIONAL_ERROR_CODE]
```

#### source

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

#### requires

* [err](#err)

### `get_yn`

get y/n prompt from user, if the bool is set at the end
then that will be the default answer (if user just presses
enter).

```sh
get_yn result_var "question to ask" [true|false]
```

#### source

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

#### requires

* [p](#p)

### `download`

download a file with (curl->wget) fallback

```sh
download "http://www.google.com/index.html" [OPTIONAL_DOWNLOAD_PATH]
```

#### source

```sh
download() {
	if has curl; then

	else
		if has wget; then

		else
			err "neither curl nor wget are available!"
		fi
	fi
}
```

#### requires

* [p](#p)
* [err](#err)