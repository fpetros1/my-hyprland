hyprctl clients -j | jq '.[] | select(.class == "Steam") | select(.title == "Steam")' | jq '.workspace.id' | tail -n 1
