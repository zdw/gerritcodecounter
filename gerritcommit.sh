#!/usr/bin/env bash

# gerritcommit.sh
# creates CSV's for every commit in a repo

START_DATE="2017-08-01"
OUTDIR=${OUTDIR:-$(pwd)}

GERRIT_HOST=${GERRIT_HOST:-gerrit.opencord.org}
GERRIT_PORT=${GERRIT_PORT:-29418}
GERRIT_USER=${GERRIT_USER:-$(whoami)}

GERRIT_SSH="ssh -p $GERRIT_PORT ${GERRIT_USER}@${GERRIT_HOST}"
echo $GERRIT_SSH

# Get gerrit project list
$GERRIT_SSH gerrit ls-projects --format json > "$OUTDIR/project_list.json"
$GERRIT_SSH gerrit ls-projects --format text > "$OUTDIR/project_list.txt"

mkdir -p "$OUTDIR/projects"
mkdir -p "$OUTDIR/people"

for proj in `cat $OUTDIR/project_list.txt`
do
  if [ ! -x "$OUTDIR/projects/$proj" ]
  then
    echo "Cloning $proj"
    git clone "ssh://$GERRIT_HOST:$GERRIT_PORT/$proj.git" "$OUTDIR/projects/$proj"
  fi
  pushd "$OUTDIR/projects/$proj"
#  echo "MergeDate,Name,Email,Subject,Hash" > "$OUTDIR/csv/$proj.csv"
  git log --after="$START_DATE" --pretty=format:"%an,%ae" | sort | uniq -c | sort -rn > "$OUTDIR/people/$proj.csv"
  popd
done

