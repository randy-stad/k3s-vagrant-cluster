#!/bin/bash
set -eux

# install needed packages
dnf install -y grubby jq

# need to switch to cgroups v1
grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"

# need legacy iptables
update-alternatives --set iptables /usr/sbin/iptables-legacy
