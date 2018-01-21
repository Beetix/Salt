#!/bin/bash

usage="Usage: $0 clean|upload|launch project"
local_projects_dir=$PEPPER_LOCAL_PROJECTS_DIR
nao_projects_dir="/home/nao/projects"
nao_apps_dir="/home/nao/.local/share/PackageManager/apps/"

if [[ $# -ne 2 ]]
then
    cat << !
Incorrect usage
$usage
!
    exit 1
fi

if [[ -z $local_projects_dir ]]
then
    echo "Unset environment variable PEPPER_LOCAL_PROJECTS_DIR"
    exit 1
fi

if [[ -z $PEPPER_IP ]]
then
    echo "Unset environment variable PEPPER_IP"
    exit 1
fi

action=$1
project=$2
nao_project_dir="$nao_projects_dir/$project"
local_project_dir="$local_projects_dir/$project"

function sftp_pepper {
    echo $1 | sftp -b - nao@$PEPPER_IP
}

function ssh_pepper {
    ssh nao@$PEPPER_IP $1
}

case $action in

    clean )
        ssh_pepper "rm -r $nao_project_dir/*";;
    upload )
        sftp_pepper "put -r $local_project_dir $nao_projects_dir";;
    launch )
        ssh_pepper "PYTHONPATH=/opt/aldebaran/lib/python2.7/site-packages python $nao_project_dir/app.py";;
    init )
        mkdir -p $local_project_dir && \
        ssh_pepper "mkdir -p $nao_project_dir && ln -s $nao_project_dir $nao_apps_dir";;
    delete )
        ssh_pepper "rm $nao_apps_dir/$project && rm -r $nao_project_dir" && \
        rm -r $local_project_dir;;
esac

