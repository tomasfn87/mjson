#!/bin/bash

toGreen () { gawk -v text="$1" 'BEGIN {
  printf "%s", "\033[1;32m" text "\033[0m" }';
}

toRed () { gawk -v text="$1" 'BEGIN {
  printf "%s", "\033[1;31m" text "\033[0m" }';
}

toYellow () { gawk -v text="$1" 'BEGIN {
  printf "%s", "\033[1;33m" text "\033[0m" }';
}

verifyJson () {
  echo $(python3 /usr/local/lib/verify-minify-json/verify_json.py "$1");
}

openJson () {
  echo -n " * Checking if source file exists...    "
  if [ -r "$1" ];
  then
    echo "[$(toGreen OK)]";
  else
    echo "$(toRed ERROR): file not found";
    echo; echo "Please choose an existing file:";
    return 3;
  fi;

  echo -n " * Checking JSON file integrity...      ";

  if [ $(verifyJson "$1") == 1 ];
  then
    echo "$(toRed ERROR): not a JSON file";
    echo; echo "Please choose a JSON file ('$(toYellow file.json)'):";
    return 1;
  elif [ $(verifyJson "$1") == 2 ];
  then
    echo "$(toRed ERROR): invalid JSON data";
    echo; echo "Please choose a valid JSON file:";
    return 2;
  else
    echo "[$(toGreen OK)]";
    return 0;
  fi;
}

echo "Choose JSON file to be minified:";
read -ei "$(echo )" JSONFILE;
openJson "$JSONFILE"
while [ $? != 0 ];
do
  read -ei "$(echo "$JSONFILE")" JSONFILE;
  openJson "$JSONFILE";
done;

echo; echo "Save minified JSON file to:";
read -ei "$JSONFILE" MINIFIEDJSON;

while [ "$MINIFIEDJSON" == "$JSONFILE" ] || [ $(verifyJson "$MINIFIEDJSON") == 1 ];
do
  if [ "$MINIFIEDJSON" == "$JSONFILE" ];
  then
    echo; echo "$(toRed ERROR): cannot overwrite source file $(toYellow "$JSONFILE")";
    echo; echo "Please rename the target minified file or save it to another folder:";
    read -ei "$(echo "$MINIFIEDJSON")" MINIFIEDJSON;
  elif [ $(verifyJson "$MINIFIEDJSON") == 1 ];
  then
    echo; echo "$(toRed ERROR): minified JSON file extension must be '.json'";
    echo; echo "Please change the file extension to '$(toYellow .json)':";
    read -ei "$(echo "$MINIFIEDJSON")" MINIFIEDJSON;
  fi;
done;

echo; echo -n " * Checking if target file exists...    "
if [ -w "$MINIFIEDJSON" ];
then
  echo "[$(toGreen OK)]";
  echo -n "Overwrite file? (Y/N) "
  read OPTION;
  OPTIONS=(Y y N n); YES=(Y y); NO=(N n); NEWFILE=maybe;
  while [[ ! "${OPTIONS[*]}" =~ "${OPTION}" ]];
  do
    echo; echo -n "$(toRed ERROR): invalid option, choose [Y]es or [N]o: ";
    read OPTION;
  done;
  if [[ "${YES[*]}" =~ "${OPTION}" ]];
  then
    echo; echo " * File will be overwritten...";
  elif [[ "${NO[*]} " =~ "${OPTION}" ]];
  then
    NEWFILE="$MINIFIEDJSON";
    while [ "$NEWFILE" == "$MINIFIEDJSON" ];
    do
      echo; echo "Save minified JSON file to: "
      read -ei "$(echo "$NEWFILE")" NEWFILE;
      if [ "$NEWFILE" == "$MINIFIEDJSON" ];
      then
        echo; echo "$(toRed ERROR): please rename the file or save it to another folder";
      fi;
    done;
    touch "$NEWFILE";
    while [ $(verifyJson "$NEWFILE") == 1 ];
    do
      echo; echo "$(toRed ERROR): minified JSON file extension must be '$(toYellow .json)'";
      rm "$NEWFILE";
      echo; echo "Please rename the target minified file or save it to another folder:";
      read -ei $(echo "$NEWFILE") NEWFILE;
      touch "$NEWFILE";
    done;
    echo; echo " * File will be created...";
    MINIFIEDJSON="$NEWFILE";
    touch "$MINIFIEDJSON";
  fi;
elif [ ! -w "$MINIFIEDJSON" ];
then
  echo "[NO]";
  echo; echo " * File will be created..."
  touch "$MINIFIEDJSON";
fi;

echo -n " * Minifying JSON file...               "
python3 /usr/local/lib/verify-minify-json/minify.py $JSONFILE | cat > "$MINIFIEDJSON";
echo "[$(toGreen OK)]";

echo -n " * Checking minified output file...     "
if [ $(verifyJson "$MINIFIEDJSON") != 0 ];
then
  echo "$(toRed ERROR): minified JSON validation failed";
else
  echo "[$(toGreen OK)]";
fi;
echo; echo "File saved to $(toYellow $(realpath "$MINIFIEDJSON"))";
exit 0;