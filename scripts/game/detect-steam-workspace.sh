hyprctl clients -j | jq '.[] | select(.class == "Steam")' | jq '.workspace.id' | tail -n 1
