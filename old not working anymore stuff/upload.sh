#!/bin/bash

echo "Select an option:"
echo "1. Upload a file"
echo "2. Upload a folder"
read -p "Enter 1 or 2: " choice

if [ "$choice" == "1" ]; then
  read -p "Enter the file name: " file
elif [ "$choice" == "2" ]; then
  read -p "Enter the folder name: " folder
  files=$(find "$folder" -type f)
else
  echo "Invalid choice. Exiting."
  exit 1
fi

function upload_file() {
  local file=$1
  echo "Uploading $file"

  token=$(curl -s 'https://api.gofile.io/createAccount' | jq -r '.data.token' 2>/dev/null)

  response=$(curl -# -H "Content-Type: multipart/form-data" -H "Cookie: accountToken=$token" -F "file=@$file" https://store1.gofile.io/uploadFile)

  status=$(jq -r '.status' <<< "$response")
  if [ "$status" == "ok" ]; then
    downloadPage=$(jq -r '.data.downloadPage' <<< "$response")
    code=$(jq -r '.data.code' <<< "$response")
    echo "Upload successful!"
    echo "Download page: $downloadPage"
    echo "$downloadPage" >> urls.txt
  else
    message=$(jq -r '.message' <<< "$response")
    echo "Upload failed: $message"
  fi
}

if [ "$choice" == "1" ]; then
  upload_file "$file"
elif [ "$choice" == "2" ]; then
  > urls.txt
  for file in $files; do
    upload_file "$file"
  done
fi

echo
echo "Note: gofile.io is entirely free with no ads,"
echo "you can support it at https://gofile.io/donate"
