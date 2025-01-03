#!/bin/bash

set -e

DEST_DIR="${THIRD_PARTY_ADDONS}"
REQUIREMENTS_FILE="${DEST_DIR}/third-party-addons-requirements.txt"

mkdir -p "$DEST_DIR"
> "$REQUIREMENTS_FILE"

echo "Running gitaggregate..."
gitaggregate -c /third-party-addons.yml --expand-env

repos=$(yq eval 'keys | .[]' /third-party-addons.yml)

for repo in $repos; do
    repo_path=$(realpath "$repo")
    addons=$(yq eval ".\"$repo\".addons" /third-party-addons.yml)
    exclude=$(yq eval ".\"$repo\".exclude" /third-party-addons.yml)

    if [[ "$addons" != "null" && -n "$addons" ]]; then
        # Copy only specified addons
        echo "Addons specified for $repo: $addons"
        IFS=',' read -ra ADDONS <<< "$addons"
        for addon in "${ADDONS[@]}"; do
            addon_path="$repo_path/$addon"
            if [ -d "$addon_path" ]; then
                echo "Copying addon: $addon from $repo to $DEST_DIR"
                cp -r "$addon_path" "$DEST_DIR/"
            else
                echo "Warning: Addon $addon not found in $repo. Skipping."
            fi
        done
    elif [[ "$exclude" != "null" && -n "$exclude" ]]; then
        # Copy all addons except those in exclude
        echo "Excluding addons for $repo: $exclude"
        IFS=',' read -ra EXCLUDE <<< "$exclude"
        for addon_path in "$repo_path"/*; do
            addon=$(basename "$addon_path")
            if [[ ! " ${EXCLUDE[@]} " =~ " ${addon} " ]]; then
                echo "Copying addon: $addon from $repo to $DEST_DIR"
                cp -r "$addon_path" "$DEST_DIR/"
            else
                echo "Excluding addon: $addon from $repo"
            fi
        done
    else
        # Copy all contents if neither addons nor exclude is specified
        echo "No addons or exclude specified for $repo. Copying all contents."
        cp -r "$repo_path"/* "$DEST_DIR/"
    fi

    # Append requirements.txt to the global file
    if [ -f "$repo_path/requirements.txt" ]; then
        echo "Found requirements.txt in $repo_path. Appending to $REQUIREMENTS_FILE."
        cat "$repo_path/requirements.txt" >> "$REQUIREMENTS_FILE"
        echo "" >> "$REQUIREMENTS_FILE"
    fi
    
    # Remove the source repository after processing
    echo "Removing source repository: $repo_path"
    rm -rf "$repo_path"
done

# Install dependencies if requirements file is not empty
if [ -s "$REQUIREMENTS_FILE" ]; then
    echo "Installing dependencies from $REQUIREMENTS_FILE."
    python3 -m pip install -r "$REQUIREMENTS_FILE"
fi
