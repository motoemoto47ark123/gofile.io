#!/bin/bash

file="$1"
echo "Uploading $file"

#get guest account token for url and cookie
token=$(curl -s 'https://api.gofile.io/createAccount' | jq -r '.data.token' 2>/dev/null)

# upload file and show progress
response=$(curl -# -H "Content-Type: multipart/form-data" -H "Cookie: accountToken=$token" -F "file=@$file" https://store1.gofile.io/uploadFile)

status=$(jq -r '.status' <<< "$response")
if [ "$status" == "ok" ]; then
  downloadPage=$(jq -r '.data.downloadPage' <<< "$response")
  code=$(jq -r '.data.code' <<< "$response")
  echo "Upload successful!"
  echo "Download page: $downloadPage"
else
  message=$(jq -r '.message' <<< "$response")
  echo "Upload failed: $message"
fi

echo
echo "Note: gofile.io is entirely free with ads,"
echo "you can support it at https://gofile.io/donate"
