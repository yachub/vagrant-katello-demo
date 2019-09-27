#!/bin/bash

# Run the Katello Environment Lifcycle script at 12am everyday
#05 0 * * * /usr/local/bin/katello-environmentLifecycle.sh

logger_tag='katello-task'

if [ $EUID -ne 0 ]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Get a list of content views, sans the Default Content View
CVs=$(hammer --csv content-view list | grep -viE '^Content|^1,Default' | awk -F, {'print $1'} | sort -n)

# Function to publish a new version for every content view.
publish_version() {
    for CV_ID in $CVs
        do

        # Publish new version
        logger -t ${logger_tag} "Publishing new version to CV #$CV_ID"
        hammer content-view publish --id $CV_ID
    done
}

# Function to promote the latest version of all content views through a specified lifecycle environment.
# First parameter shoud be environment name.
promote_environment() {
    for CV_ID in $CVs
        do
        latest_version=$(hammer --csv content-view version list --content-view-id $CV_ID | grep $1 | awk -F, {'print $1'} | sort -n | tail -1)
        echo "Latest Version: ${latest_version}"
        logger -t ${logger_tag} "Promoting Content View #${CV_ID} to the $2 Environment"
        hammer content-view version promote --to-lifecycle-environment $2 --id $latest_version
    done
}

# Function to compare two different environments packages list and email results.
# First parameter should be environment in promotion.
# Second parameter should be the environment following environment in promotion.
email_packages() {
    logger -t ${logger_tag} "Getting list of packages in $1 environment"
    hammer --csv package list --environment "${1}" | grep -vi '^ID' | awk -F, {'print $2'} | sort > /tmp/${1}.txt

    logger -t ${logger_tag} "Getting list of packages in $2 environment"
    hammer --csv package list --environment "${2}" | grep -vi '^ID' | awk -F, {'print $2'} | sort > /tmp/${2}.txt

    results=$(comm -13 /tmp/${2}.txt /tmp/${1}.txt)
    echo "Package Name" > /tmp/yum-updates_$(date +%Y-%m-%d).csv
    echo "${results}" > /tmp/yum-updates_$(date +%Y-%m-%d).csv
    echo "Please see attached for a list of package changes that will be pushed to the ${2} environment tomorrow." |mutt -s "Yum Updates $(date +%Y-%m-%d)" email@example.com -a /tmp/yum-updates_$(date +%Y-%m-%d).csv
    rm -f /tmp/${1}.txt
    rm -f /tmp/${2}.txt
    rm -f /tmp/yum-updates_$(date +%Y-%m-%d).csv
}

WEEK=$(date "+%V")
DAY=$(date "+%u")

# Patching DEV week process.
# If this week is a DEV patch week and first day, publish new version and email package list.
if [ $(( $WEEK % 2 )) -eq 1 ] && [ $(( $DAY % 2 )) -eq 1 ]; then
    publish_version
    email_packages Library Development
fi

# If this week is a DEV patch week and second day, promote environment.
if [ $(( $WEEK % 2 )) -eq 1 ] && [ $(( $DAY % 2 )) -eq 2 ]; then
    promote_environment Library Development
fi

# Patching PROD week process.
# If this week is a PROD patch week and first day, email package list.
if [ $(( $WEEK % 2 )) -eq 0 ] && [ $(( $DAY % 2 )) -eq 1 ]; then
    email_packages Development Production
fi

# If this week is a PROD patch week and second day, promote environment.
if [ $(( $WEEK % 2 )) -eq 0 ] && [ $(( $DAY % 2 )) -eq 2 ]; then
    promote_environment Development Production
fi