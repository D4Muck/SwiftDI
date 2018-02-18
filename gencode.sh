#!/bin/bash

# set -x

SWIFT_FILE_PATH=$SRCROOT/Libs/SwiftDI/SwiftDI/FilesToInclude
TEMPLATE_PATH=$SRCROOT/Libs/SwiftDI/Templates
TEMPLATE_OUTPUT_PATH=Templates-Built

mkdir -p $TEMPLATE_OUTPUT_PATH

for entry in $(find $TEMPLATE_PATH -name "*.swifttemplate" -type f)
do
  OUTPUT_FILE=$TEMPLATE_OUTPUT_PATH/$(basename $entry)

  echo "<%" > $OUTPUT_FILE

  for swiftfile in $(find $SWIFT_FILE_PATH -name "*.swift" -type f)
  do
    sed '/import /d' $swiftfile >> $OUTPUT_FILE
  done

  echo "%>" >> $OUTPUT_FILE
  cat $entry >> $OUTPUT_FILE
done

sourcery --verbose
