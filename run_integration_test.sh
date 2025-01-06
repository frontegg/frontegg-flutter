#!/bin/sh

while getopts ":a:i:t:" opt; do
  case $opt in
    a) android_device="$OPTARG"
    ;;
    i) ios_device="$OPTARG"
    ;;
    t) test_path="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    exit 1
    ;;
  esac

  case $OPTARG in
    -*) echo "Option $opt needs a valid argument"
    exit 1
    ;;
  esac
done

cd example || exit 1

flutter pub global activate patrol_cli

patrol doctor


if [ -z "$test_path" ]; then
  test_path="integration_test/src/"
fi

echo "Starting test on $test_path"

# iOS run
if [ -n "$ios_device" ]; then
  echo "Start iOS testing on '$ios_device' device..."
  patrol test -d "$ios_device" -t "$test_path" --uninstall
fi

# Android run
if [ -n "$android_device" ]; then
  echo "Start iOS testing on '$android_device' device..."
  patrol test -d "$android_device" -t "$test_path" --uninstall
fi




