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

