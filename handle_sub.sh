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
bold=`tput bold`
normal=`tput sgr0`

# Let's see if an update is necessary
git fetch

# Kept for debugging purposes
# head_sha1="$(git rev-parse HEAD)"
head_commit_msg="$(git rev-list --format=%B --max-count=1 $sha1)"
active_branch="$(git rev-parse --abbrev-ref HEAD)"
upstream_status="$(git log HEAD..origin/$active_branch --oneline)"

echo "\n  > Active branch: $active_branch\n  > HEAD: $head_commit_msg\n\n"

# $upstream_status is empty unless changes on origin are available
if [ ! "$upstream_status" = "" ]; then

  git pull origin "$active_branch"

  updated_hash="$(git rev-parse HEAD)"
  shortened_hash="$(git rev-parse --short "$updated_hash")"

  if [ $should_autocommit = "1" ]; then

    # Reference submodule new head-sha1 in commit msg
    commit_msg="Update $name to $shortened_hash"
    echo "${bold}\n  > Committing: $commit_msg${normal}\n\n"

    # Move cwd out of submodule into super-projects root
    cd "$(git rev-parse --show-superproject-working-tree)"

    git add "./$name"
    git commit -m "$commit_msg"

  fi

else
  echo "${bold}  > Already up to date.${normal}\n\n"
fi

exit 0
