#!/bin/bash

toGreen () { gawk -v text=$1 'BEGIN {
    printf "%s", "\033[1;32m" text "\033[0m" }'
}

toRed () { gawk -v text=$1 'BEGIN {
    printf "%s", "\033[1;31m" text "\033[0m" }'
}

toYellow () { gawk -v text=$1 'BEGIN {
    printf "%s", "\033[1;33m" text "\033[0m" }'
}

if [ $1 == $2 ]
then
    echo "$(toRed ERROR): cannot overwrite source file $(toYellow $2)";
    echo "Please rename the minified file or save it to another folder";
    exit 1
fi;

echo "Minifying file..."
python3 /usr/local/bin/verify-minify-json/minify.py $1 | cat > $2;
echo "$(toGreen DONE)". "File saved to $(toYellow $2)";
exit 0;
