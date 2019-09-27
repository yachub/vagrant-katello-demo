#!/bin/bash

# Run the auto patch and reboot script 4AM Tue - Fri
#0 4 * * 2-5 /usr/local/bin/katello-autoReboot.sh

# This will create jobs in satellite based on the Run Command - SSH Default template
# to login as the effective user foreman-service and run the reboot command on
# the host collection passed in by the first positional parameter
# and the environment to be passed in by the second parameter
# to the functions for updting and rebooting


update_and_reboot() {
    hammer job-invocation create --job-template-id 110  --effective-user foreman-service --description-format "${1} for ${2}" --inputs command="sudo subscription-manager refresh;sudo yum clean all;if test -f /etc/cron.d/0yum.cron;then sudo /etc/cron.d/0yum.cron;else sudo yum-cron /etc/yum/yum-cron-puppet.conf;fi;sudo shutdown -r +1;echo" --search-query "host_collection=\"${1}\" and lifecycle_environment=\"${2}\"" --execution-timeout-interval 7200
}

update_only() {
    hammer job-invocation create --job-template-id 110  --effective-user foreman-service --description-format "${1} for ${2}" --inputs command="sudo subscription-manager refresh;sudo yum clean all;if test -f /etc/cron.d/0yum.cron;then sudo /etc/cron.d/0yum.cron;else sudo yum-cron /etc/yum/yum-cron-puppet.conf;fi;echo" --search-query "host_collection=\"${1}\" and lifecycle_environment=\"${2}\"" --execution-timeout-interval 7200
}

# %H = Hour
# %A = Day of Week
# %V = Week number of year (odd/even)

if [ $(date "+%H") -eq 04 ]; then
    case $(date "+%A") in
        Tuesday)
            case `expr $(date "+%V") % 2` in
                0)
                    update_only Auto_Patch_ONLY_Tuesday Production &
                    update_and_reboot Auto_Patch_and_Reboot_Tuesday Production &
                    ;;
                1)
                    update_only Auto_Patch_ONLY_Tuesday Development &
                    update_and_reboot Auto_Patch_and_Reboot_Tuesday Development &
                    ;;
            esac
            ;;
        Wednesday)
            case `expr $(date "+%V") % 2` in
                0)
                    update_only Auto_Patch_ONLY_Wednesday Production &
                    update_and_reboot Auto_Patch_and_Reboot_Wednesday Production &
                    ;;
                1)
                    update_only Auto_Patch_ONLY_Wednesday Development &
                    update_and_reboot Auto_Patch_and_Reboot_Wednesday Development &
                    ;;
            esac
            ;;
        Thursday)
            case `expr $(date "+%V") % 2` in
                0)
                    update_only Auto_Patch_ONLY_Thursday Production &
                    update_and_reboot Auto_Patch_and_Reboot_Thursday Production &
                    ;;
                1)
                    update_only Auto_Patch_ONLY_Thursday Development &
                    update_and_reboot Auto_Patch_and_Reboot_Thursday Development &
                    ;;
            esac
            ;;
        Friday)
            case `expr $(date "+%V") % 2` in
                0)
                    update_only Auto_Patch_ONLY_Friday Production &
                    update_and_reboot Auto_Patch_and_Reboot_Friday Production &
                    ;;
                1)
                    update_only Auto_Patch_ONLY_Friday Development &
                    update_and_reboot Auto_Patch_and_Reboot_Friday Development &
                    ;;
            esac
            ;;
        *)
            echo "This script should only be run on a designated patch day"
            exit 0
            ;;
    esac
fi