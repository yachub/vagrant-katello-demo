#!/bin/bash

# Run the auto patch report at 8AM Friday morning
#0 8 * * 5 /usr/local/bin/katello-hostCollectionReport.sh

# This script generates a report of all content hosts and what host collections
# they belong to. The purpose is to audit what servers are in auto patch and
# auto reboot schedules
#
# According to documentation, the command `hammer csv content-hosts --columns "Name,Environment,Host Collections" --export`
# is supposed to generate this information, however it is currently broken in Foreman 1.18. Red Hat support has provided
# the workaround below in the interim. Case #02324333.

# Get list of hosts and associated collections using foreman-rake console and remove stderr messages,
# trim all double quotes,
# remove unwanted output in lines 1 - 4,
# sort the CSV by the first column
SERVERS="Server_Name,Patch_Group"
SERVERS+=$(/sbin/foreman-rake console <<< 'conf.echo=false;Host.find_each {|host| str=""; str << host.name; host.host_collections.each {|hc| str << "," if host.host_collections.count >= 1; str << hc.name}; p str}' 2>/dev/null | tr -d "\"" | sed -e '1,4d' | sort -k1 -t,)

# Write output to file, email and attach file, cleanup file
echo "$SERVERS" > /tmp/auto_patch_report_$(date +%Y-%m-%d).csv
echo "Please see attached for a list of Linux servers and their associated auto patch/auto reboot schedule" |mutt -s "Linux Auto Patch/Reboot Report $(date +%Y-%m-%d)" email@example.com -a /tmp/auto_patch_report_$(date +%Y-%m-%d).csv
rm -f /tmp/auto_patch_report_$(date +%Y-%m-%d).csv