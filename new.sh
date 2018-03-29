#!/bin/bash

usage() {
  echo './new.sh post-name'
  echo 'This will create a new post in content/post prefixed with the date'
  echo 'and postfixed with ".md"'
}

if [[ "$#" -eq 0 ]] ; then
  usage
  exit 1
fi

DATE="$(date +%Y-%m-%d)"

hugo new "post/${DATE}-${1}.md"
