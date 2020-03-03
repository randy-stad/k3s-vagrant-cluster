#!/bin/bash
set -eux

# need to switch to cgroups v1
dnf install -y grubby
grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=0"

# need legacy iptables
update-alternatives --set iptables /usr/sbin/iptables-legacy
