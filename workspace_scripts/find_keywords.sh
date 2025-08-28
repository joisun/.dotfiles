#!/bin/bash

# usage exp: ./find_keywords.sh "test" .
grep -rin $1 --exclude-dir=node_modules --exclude-dir=backend --exclude-dir=dist --exclude-dir=build --exclude-dir=dir $*
