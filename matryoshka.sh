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

# highlight textsections within echo
bold=$(tput bold)
normal=$(tput sgr0)

# Check git-version. This script requires a git version >= 2.12
git_version_installed="$(git --version | awk '{print $3;}')"
git_version_required="2.12"

# Compares two version strings and returns True if first version is greater than second
function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

if [ "$(version "$git_version_required")" -gt "$(version "$git_version_installed")" ]; then
  # Outdated git version detected
  echo -e "This script requires git version >=${bold}$git_version_required${normal}.\nInstalled git version is ${bold}$git_version_installed${normal}.\n\nPlease update git."
  exit 1
fi

echo -e "Initiated submodule update. Cancel with CTRL-C.\n"

# Get names of all submodules
# Using the foreach functionality removes dependence on tools like awk / sed
submodules=( "all" )
while IFS= read -r line; do
    submodules+=( "$line" )
done < <( git submodule --quiet foreach --recursive 'echo $name' )

# Present selection to user
PS3="${bold}Select modules you would like to update: ${normal}"

select module in "${submodules[@]}"
do
  selection=$module
  printf "\n  %s%s selected%s\n\n\n" "${bold}" "$selection" "${normal}"
  break
done

# Ask for confirmation before auto-committing
PS3="${bold}Generate commit(s) for updated submodule(s)?: ${normal}"
select yn in "Yes" "No"; do
  case $yn in
    Yes ) auto_commit=1; break;;
    No ) auto_commit=0; break;;
  esac
done

# Number of files added to the index (but uncommitted)
staged_count="$(git status --porcelain 2>/dev/null| grep -c "^M")"

# Number of files that are uncommitted and not added
untracked_count="$(git status --porcelain 2>/dev/null| grep -c "^ M")"

# Number of total uncommited files
total_count="$(git status --porcelain 2>/dev/null| grep -Ec "^(M| M)")"

auto_commit=0
did_stash=0

# Debug-Log kept for future reference
# echo $staged_count
# echo $untracked_count
# echo $total_count

if ! [ "$staged_count" -eq 0 -a "$untracked_count" -eq 0 -a "$total_count" -eq 0 ]; then
  # Dirty Working Area

  if [ "$auto_commit" -eq 1 ]; then
    # We want to auto-commit cleanly. Stashing user changes...

    ##
    # The working directory is listed as "dirty" when the submodules have been updated
    # prior to Matryoshka. Stash will not save them, because they are already taken care of
    # by Git. To avoid popping an old stash accidentally, we compare the stash counts and adjust
    # actions accordingly

    stash_count_old=$(git stash list | wc -l)

    # Stash save (q)uietly, including (u)ntracked files, also adding a description
    git stash save --quiet --include-untracked "Submodule update $(date)"

    stash_count_new=$(git stash list | wc -l)

    # Debug-Log kept for future reference
    # echo "Stash Count Old: $stash_count_old"
    # echo "Stash Count New: $stash_count_new"

    # Check if a new stash has been created
    if [ "$stash_count_new" -gt "$stash_count_old" ]; then
      echo -e "\nDirty working directory has been auto-stashed.\n"

      stash_sha1="$(git rev-parse stash@\{0\})"
      echo -e "Autostashed working directory sha1: ${bold}$stash_sha1\n${normal}"
      did_stash=1
    fi

  fi

fi

##
# Getting absolute script path — this is not as trivial as you may think
# REFERENCE: https://stackoverflow.com/q/4774054
containing_dir_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Calling the update script for each sub. Passing the auto_commit flag
git submodule foreach "sh $containing_dir_path/handle_sub.sh $auto_commit $selection || :"

# Kept for debugging purposes
# git submodule foreach 'echo $path `git rev-parse HEAD` || :'

# Reapply stashed changes
if [ "$did_stash" -eq 1 ]; then
  echo -e "\nReapplied stash.\n"
  git stash pop --quiet
fi

exit 0

