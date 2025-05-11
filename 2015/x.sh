#! /usr/bin/env bash

# for each folder in the current directory, look for the dart folder, in that folder create a test folder and a lib/src folder, in the test folder create a test.dart file

for folder in */; do
    if [ -d "$folder/dart" ]; then
        mkdir -p "$folder/dart/test"
        mkdir -p "$folder/dart/lib/src"
        touch "$folder/dart/test/test.dart"
        echo "Created test.dart in $folder/dart/test"
    fi
done
