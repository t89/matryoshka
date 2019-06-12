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


# highlight textsections within echo
bold=$(tput bold)
normal=$(tput sgr0)

# assign parameters
should_autocommit="$1"
stand_alone_repo="$2"

if [ ! "$stand_alone_repo" = "all" ]; then
  # Only one submodule should be updated
  if [ ! "$stand_alone_repo" = "$name" ]; then
    # Ignore others
    printf "%s  > Skipping %s%s\n\n\n" "${bold}" "$name" "${normal}"
    exit 0
  fi
fi

##
# Check if the submodule is dirty. Prevent dirty submodule commits
# under all circumstances

# Number of files added to the index (but uncommitted)
staged_count="$(git status --porcelain 2>/dev/null| grep -c "^M")"

# Number of files that are uncommitted and not added
untracked_count="$(git status --porcelain 2>/dev/null| grep -c "^ M")"

# Number of total uncommited files
total_count="$(git status --porcelain 2>/dev/null| grep -Ec "^(M| M)")"

# Debug-Log kept for future reference
# echo $staged_count
# echo $untracked_count
# echo $total_count

if ! [ "$staged_count" -eq 0 -a "$untracked_count" -eq 0 -a "$total_count" -eq 0 ]; then
  # Dirty Working Area
  printf "%s  > Dirty submodule detected! Skipping %s%s\n\n\n" "${bold}" "$name" "${normal}"
  exit 0
fi

# Let's see if an update is necessary
git fetch --quiet

# Kept for debugging purposes
# head_sha1="$(git rev-parse HEAD)"

parent_root="$(git rev-parse --show-superproject-working-tree)"
old_head_msg="$(git rev-list --format=%B --max-count=1 "$sha1")"
active_branch="$(git rev-parse --abbrev-ref HEAD)"
upstream_status="$(git log HEAD..origin/"$active_branch" --oneline)"

##
# At this point we have stashed all other changes within the parent repo.
# If there are modifications left, the repo has uncommited updates
cd "$parent_root" || return
uncommited_update_count="$(git status "$name" --porcelain 2>/dev/null| grep -Ec "^(M| M)")"
cd "$name" || return


# $upstream_status is empty unless changes on origin are available
if [ ! "$upstream_status" = "" ] || [ "$uncommited_update_count" -gt 0 ]; then

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
    cd "$parent_root" || return

    git add "./$name"
    git commit -m "$commit_msg" --quiet

  fi

else
  printf "%s  > Already up to date.%s\n\n\n" "${bold}" "${normal}"
fi

exit 0
