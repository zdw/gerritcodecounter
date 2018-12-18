#!/usr/bin/env bash

# gerritcounter.sh
# counts number of gerrit repos and their size

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

echo "Project, Lines" > "$OUTDIR/linecount.csv"

for proj in `cat $OUTDIR/project_list.txt`
do
  if [ ! -x "$OUTDIR/projects/$proj" ]
  then
    echo "Cloning $proj"
    git clone "ssh://$GERRIT_HOST:$GERRIT_PORT/$proj.git" "$OUTDIR/projects/$proj"
  fi
  pushd "$OUTDIR/projects/$proj"
  numfiles=$(git ls-files | wc -l)
  echo "$proj,$numfiles" >> "$OUTDIR/linecount.csv"
  popd
done

