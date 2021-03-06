#!/bin/bash -xe

. $(dirname $0)/common.sh

python -m jiocloud.apply_resources ssh_config --project_tag=${project_tag} ${mappings_arg} environment/${layout:-full}.yaml > ssh_config

ssh -F ssh_config -l ${ssh_user:-jenkins} oc1_${project_tag} '. <(sudo cat /root/openrc) ; glance image-list'
