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
* [`broke`](#broke)
* [`get_yn`](#get_yn)
* [`download`](#download)
* [`extract`](#extract)
* [`fibonacci`](#fibonacci)

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
        local ECODE
        if [ "$#" -eq "2" ]; then
            ECODE=$2
        else
            ECODE=1
        fi
        err "$1" $ECODE
    fi
}
```

### Requires

* [`err`](#err)

## `broke`

returns true if the last command broke and doesn't exit
like [`ok`](#ok) does.

```sh
something_that_will_brak
if broke; then
  do_something
fi
```

### Source

```sh
broke() {
    if [ $? != 0 ]; then
        return 0
    else
        return 1
    fi
}
```

## `get_yn`

get y/n prompt from user, if the bool is set at the end
then that will be the default answer (if user just presses
enter).

```sh
if get_yn "question to ask" [true|false]; then
  p "they said yes!"
else
  p "oh noooo"
fi
```

### Source

```sh
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
```

### Requires

* [`p`](#p)

## `download`

download a file with (curl->wget) fallback, aborts if niether tools
are available. downloads to current directory or path provided
(path should contain filename!)

```sh
download "http://www.google.com" [OPTIONAL_DOWNLOAD_PATH]
```

### Source

```sh
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
```

### Requires

* [`has`](#has)
* [`err`](#err)

## `extract`

extract a file (tar|tar.gz|zip|rar) either to the current directory or a
specified path, based on [extract.sh](https://github.com/xvoland/Extract/blob/master/extract.sh)
written by [xvoland](https://github.com/xvoland).

```sh
extract thing.tar.gz [MAYBE/TO/HERE]
```

### Source

```sh
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
```

### Requires

* [`require`](#require)
* [`err`](#err)
* [`broke`](#broke)

## `fibonacci`

calculate the fibonacci sequence for ***n*** iterations.

```sh
fibonacii 10
  0 1 1 2 3 5 8 13 21 34
```

### Source

```sh
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
```

### Requires

* [`p`](#p)