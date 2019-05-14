#!/bin/bash
##
#  matryoshka.sh
#  Matryoshka
#
#  Created by Thomas Johannesmeyer (thomas@geeky.gent) on 08.04.2019.
#  Copyright (c) 2019 www.geeky.gent. All rights reserved.
#
# Update all submodules iteratively, and create concise referencing commits
# for each update. Uses a helper script which is iterated within each submodule

clear


# Number of files added to the index (but uncommitted)
staged_count="$(git status --porcelain 2>/dev/null| grep "^M" | wc -l)"

# Number of files that are uncommitted and not added
untracked_count="$(git status --porcelain 2>/dev/null| grep "^ M" | wc -l)"

# Number of total uncommited files
total_count="$(git status --porcelain 2>/dev/null| egrep "^(M| M)" | wc -l)"

auto_commit=0
did_stash=0

# Ask for confirmation before auto-committing
echo "You are attempting a submodule auto-update. You can cancel by pressing ctrl-c.\n\n"
echo "Would you like to generate an auto-commit?\n"
select yn in "Yes" "No"; do
  case $yn in
    Yes ) auto_commit=1; break;;
    No ) auto_commit=0; break;;
  esac
done

# Debug-Log kept for future reference
# echo $staged_count
# echo $untracked_count
# echo $total_count

if ! [ $staged_count -eq 0 -a $untracked_count -eq 0 -a $total_count -eq 0 ]; then
  # Dirty Working Area

  if [[ $auto_commit = 1 ]]; then

    # We want to auto-commit cleanly. Stashing user changes...
    echo "\nDirty working dir. Autostashing.\n"

    # Stash save (q)uietly, including (u)ntracked files, also adding a description
    git stash save --quiet --include-untracked "Submodule update `date`"

    stash_sha1="$(git rev-parse stash@{0})"
    echo "\nAutostashed working directory sha1: $stash_sha1\n"
    did_stash=1
  fi

fi

##
# Getting absolute script path — this is not as trivial as you may think
# REFERENCE: https://stackoverflow.com/q/4774054
containing_dir_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Calling the update script for each sub. Passing the auto_commit flag
git submodule foreach "sh $containing_dir_path/handle_sub.sh $auto_commit || :"

# Kept for debugging purposes
# git submodule foreach 'echo $path `git rev-parse HEAD` || :'

# Reapply stashed changes
if [[ $did_stash = 1 ]]; then
  echo "\nReapplying stash\n"
  git stash pop
fi

exit 0

