#!/bin/bash
SWIFT_FILE_PATH=Libs/SwiftDI/SwiftDI/FilesToInclude
TEMPLATE_PATH=Libs/SwiftDI/Templates
TEMPLATE_OUTPUT_PATH=Templates-Built

mkdir -p $TEMPLATE_OUTPUT_PATH

for entry in "$TEMPLATE_PATH"/*
do
  OUTPUT_FILE=$TEMPLATE_OUTPUT_PATH/$(basename $entry)

  echo "<%" > $OUTPUT_FILE

  for swiftfile in "$SWIFT_FILE_PATH"/*
  do
    sed '/import /d' $swiftfile >> $OUTPUT_FILE
  done

  echo "%>" >> $OUTPUT_FILE
  cat $entry >> $OUTPUT_FILE
done

Sourcery-0.10.1/bin/sourcery --verbose
