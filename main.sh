#!/bin/bash

clear
serialNo=""

camera () {
  clear
  local serialNo=$1
    
  orientation=0
  size=0
  cameraId=0
  
  read -rp "Camera Orientation: " orientation
  read -rp "max-size: " size
  
  scrcpy -s "$serialNo" --list-cameras
  read -rp "Camera Id: " cameraId
  
  echo "Press any key to continue.."
  read -rsn1
  clear
  
  echo "Starting Camera..."
  
  scrcpy --v4l2-sink=/dev/video0 --no-audio --video-source=camera --max-size="$size" --orientation="$orientation" \
  --camera-id="$cameraId" -s "$serialNo" &>/dev/null
  
  exit 0
}

listen_over_adb () {
  adb_devices="$(adb devices | wc -l)"
  adb_devices_count="$((adb_devices - 2))"

  echo "awaiting devices"

  while [ $adb_devices_count -le 0 ]; do
    adb_devices="$(adb devices | wc -l)"
    adb_devices_count="$((adb_devices - 2))"
    sleep 0.1
  done

  echo -e "please authorize your device(s) if they are not authorized\npress any key to continue..."
  read -rsn1
  echo ""

  if [ $adb_devices_count -eq 1 ]; then
    serialNo="$(adb get-serialno)"
  elif [ $adb_devices_count -gt 1 ]; then
    echo -e "$adb_devices_count found\nPlease Select A device by Serial Number/Connection ip[:port]"
    adb devices
    read -rp "Device: " serialNo
  fi
}

if [ ! "$(id -u)" -eq 0 ]; then
  echo "This tool must be ran as root"
  exit 1
fi

echo "Starting to listen for device"
listen_over_adb
echo -en "\nDevice serial number: $serialNo\n\nPress any key to continue..."
read -rsn1
camera "$serialNo"