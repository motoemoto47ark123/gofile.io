#!/bin/bash

echo "Select download option:"
echo "1. Download a single file"
echo "2. Download multiple files from a text file"
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
  read -p "Enter the URL: " url
  urls=("$url")
elif [ "$choice" == "2" ]; then
  read -p "Enter the name of the text file: " text_file
  mapfile -t urls < "$text_file"
else
  echo "Invalid choice"
  exit 1
fi

for url in "${urls[@]}"; do
  id=$(sed 's|.*gofile.io/d/||g' <<< "$url")
  echo "Downloading $id"

  #get guest account token for url and cookie
  token=$(curl -s 'https://api.gofile.io/createAccount' | jq -r '.data.token' 2>/dev/null)

  #get content info from api
  resp=$(curl 'https://api.gofile.io/getContent?contentId='"$id"'&token='"$token"'&websiteToken=12345&cache=true' 2>/dev/null)

  #load the page once so download links don't get redirected
  curl -H 'Cookie: accountToken='"$token" "$url" -o /dev/null 2>/dev/null

  for i in $(jq '.data.contents | keys | .[]' <<< "$resp"); do
    name=$(jq -r '.data.contents['"$i"'].name' <<< "$resp")
    file_url=$(jq -r '.data.contents['"$i"'].link' <<< "$resp")
    echo
    echo "Downloading $name"
    curl -H 'Cookie: accountToken='"$token" "$file_url" -o "$name"
  done
done

echo
echo
echo "Note: gofile.io is entirely free with ads,"
echo "you can support it at https://gofile.io/donate"
