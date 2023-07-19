#!/usr/bin/env bash

mirrors="./mirrors.json"
country_file="./countries.json"

# Create a temporary file for the updated mirrors
tmp_file=$(mktemp)

# mapfile -t names < <(jq -r '.[]|.name' "$mirrors")
mapfile -t countries < <(jq -r '.[]|.country' "$mirrors")
# mapfile -t urls < <(jq -r '.[] | .url' "$mirrors" | sed "s#http.*\/\/##g")
get_current_mirror() {
    # name="$1"
    country="$1"
    # url=$(jq --arg name "$name" -r '.[]|select(.name == $name) | .url' $mirrors | sed -E "s#http.*//##g")
    code=$(jq --arg country "$country" -r '.[]|select(.name == $country) | .code' "$country_file")
    # echo "$code"
    jq \
    --arg code "$code" \
    --arg country "$country" \
    'map(if .country == $country then .code = $code else . end)' \
    "$mirrors" > "$tmp_file"

    mv "$tmp_file" "$mirrors"
    # 'map(if .name == $name then .protocols as $p | .urls = ($p | map("\(.)://\($url)")) | del(.url) else . end) ' \
    # --arg url "$url" \
    # 'map(if .name == $name then .protocols as $p | reduce $p[] as $protocol (.; . + { ($protocol) : (($protocol)+ "://" + ($url)) }) | del(.url) else . end) ' \
}
# get_current_mirror eze.sysarmy.com
# get_current_mirror "australia"

for country in "${countries[@]}"; do
    get_current_mirror "$country"
done

# for name in "${names[@]}"; do
#     get_current_mirror "$name"
# done

# Use below to add urls to json file
# urls="/etc/pacman.d/mirrorlist.pacnew"

# mapfile -t names < <(jq -r '.[]|.name' "$mirrors")


# # Function to update URL in mirrors array
# update_mirror_url() {
#     local name="$1"
#     local url="$2"
#     jq --arg name "$name" --arg url "$url" 'map(if .name == $name then .url = $url else . end)' "$mirrors" > "$tmp_file"
#     mv "$tmp_file" "$mirrors"
# }

# # Process each mirror object in the JSON array
# for ((i = 0; i < "${#names[@]}"; i++)); do
#     name="${names[i]}"
#     url=$(grep -F "Server = " "$urls" | grep -F "$name" | head -1 | awk '{print $3}'  | sed "s/\$repo.*//g")
#     update_mirror_url "$name" "$url"
# done

# # Function to extract URL from URLs file based on name
# get_url_by_name() {
#     name="$1"
#     grep -F "Server = " "$urls" | grep -F "$name" | head -1 | awk '{print $3}'
# }


# # Process each mirror object in the JSON array
# for ((i = 0; i < "${#names[@]}"; i++)); do
#     name="${names[i]}"
#     url=$(get_url_by_name "$name")
#     updated_line=$(jq --arg name "$name" --arg url "$url" '.[$idx | tonumber].url = $url' --argjson idx "$i" "$mirrors")
#     echo "$updated_line" >> "$tmp_file"
# done

# echo "done. $tmp_file"

# while IFS= read -r line; do
#     for name in "${names[@]}"; do
#         # echo "${name}"
#         url=$(grep "$name" "$urls")
#         if [[ "$line" =~ $name ]]; then
#             sed -E "s!\"name\":\"$name\",!\"name\":\"$name\",\n\"url\":\"$url\",!" "$mirrors"
#         fi
#         # echo "$url"
#         # sed -E "s!\"name\":\"$name\",!\"name\":\"$name\",\n\"url\":\"$url\",!" "$mirrors"
#         # sed -E "s#\"$name\",#changed#" "$mirrors"
#     done
# done < "$mirrors"

# while IFS= read -r line; do
#     name=$(jq -r '.name' <<< "$line")
#     url=$(grep -F "Server = " "$urls" | grep -F "$name" | head -1 | awk '{print $3}')
#     jq --arg name "$name" --arg url "$url" '.[] | select(.name == $name) | .url = $url' "$mirrors" > tmp_file && cat tmpfile >> /tmp/mirrors.json
# done < <(jq -c '.[]' "$mirrors")
# echo "done. $tmp_file"

# echo "${names[@]}"