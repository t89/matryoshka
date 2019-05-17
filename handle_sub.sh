#!/bin/bash
##
#  handle_sub.sh
#  Matryoshka
#
#  Created by Thomas Johannesmeyer (thomas@geeky.gent) on 08.04.2019.
#  Copyright (c) 2019 www.geeky.gent. All rights reserved.
#
# This script is executed for each submodule. Git and terminal commands
# behave relative to the _submodule's root_.
# It takes one parameter (bool) which toggles auto-committing.


# assign parameters
should_autocommit="$1"


# highlight textsections within echo
bold=$(tput bold)
normal=$(tput sgr0)

# Let's see if an update is necessary
git fetch --quiet

# Kept for debugging purposes
# head_sha1="$(git rev-parse HEAD)"
old_head_msg="$(git rev-list --format=%B --max-count=1 "$sha1")"
active_branch="$(git rev-parse --abbrev-ref HEAD)"
upstream_status="$(git log HEAD..origin/"$active_branch" --oneline)"

# printf "\n  > Active branch: %s\n  > HEAD: %s\n\n" "$active_branch" "$old_head_msg"

# $upstream_status is empty unless changes on origin are available
if [ ! "$upstream_status" = "" ]; then

  git pull origin "$active_branch" --quiet

  updated_hash="$(git rev-parse HEAD)"
  sub_head_msg="$(git rev-list --format=%B --max-count=1 "$updated_hash")"

  # short_old_hash="$(git rev-parse --short "$sha1")"
  short_new_hash="$(git rev-parse --short "$updated_hash")"

  printf "\n  > FROM: %s%s%s\n" "${bold}" "$old_head_msg" "${normal}"
  printf "\n  > TO:   %s%s%s\n" "${bold}" "$sub_head_msg" "${normal}"

  if [ "$should_autocommit" = "1" ]; then

    # Reference submodule new head-sha1 in commit msg
    commit_msg="Update $name to $short_new_hash"
    printf "\n  > Committing: %s%s%s\n\n\n" "${bold}" "$commit_msg" "${normal}"

    # Move cwd out of submodule into super-projects root
    cd "$(git rev-parse --show-superproject-working-tree)" || return

    git add "./$name"
    git commit -m "$commit_msg" --quiet

  fi

else
  printf "%s  > Already up to date.%s\n\n\n" "${bold}" "${normal}"
fi

exit 0
