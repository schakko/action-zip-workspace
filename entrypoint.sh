#!/bin/bash

# Note that this does not use pipefail
# because if the grep later doesn't match any deleted files,
# which is likely the majority case,
# it does not exit with a 0, and I only care about the final exit.
set -eo

# Set variables
FILENAME="workspace.zip"
SUBDIRECTORY=""

TMP_WORKSPACE="/github/__tmp__workspace"

# Set options based on user input
if [ -n "$1" ]; then
  FILENAME=$1;
fi

if [ -n "$2"]; then
  SUBDIRECTORY="/$2"
fi

echo "Before mkdir"
TARGET_DIR="${TMP_WORKSPACE}${SUBDIRECTORY}"
mkdir -p "${TARGET_DIR}"
echo "After mkdir"

echo "➤ Copying files..."
if [[ -e "$GITHUB_WORKSPACE/.distignore" ]]; then
	echo "ℹ︎ Using .distignore"
	# Copy from current branch to $TMP_WORKSPACE, excluding dotorg assets
	# The --delete flag will delete anything in destination that no longer exists in source
	rsync -rc --exclude-from="$GITHUB_WORKSPACE/.distignore" "$GITHUB_WORKSPACE/" "$TARGET_DIR/" --delete --delete-excluded
else
	echo "ℹ︎ Using .gitattributes"

	cd "$GITHUB_WORKSPACE"


	git config --global user.email "gh-actions+github@schakko.de"
	git config --global user.name "changme"

	# If there's no .gitattributes file, write a default one into place
	if [[ ! -e "$GITHUB_WORKSPACE/.gitattributes" ]]; then
		cat > "$GITHUB_WORKSPACE/.gitattributes" <<-EOL
		/.gitattributes export-ignore
		/.gitignore export-ignore
		/.github export-ignore
		EOL

		# Ensure we are in the $GITHUB_WORKSPACE directory, just in case
		# The .gitattributes file has to be committed to be used
		# Just don't push it to the origin repo :)
		git add .gitattributes && git commit -m "Add .gitattributes file"
	fi

	# This will exclude everything in the .gitattributes file with the export-ignore flag
	git archive HEAD | tar x --directory="$TARGET_DIR"
fi

echo "Generating zip file..."
cd "$TMP_WORKSPACE" || exit
zip -r "${GITHUB_WORKSPACE}/${FILENAME}" .
echo "✓ Zip file generated!"