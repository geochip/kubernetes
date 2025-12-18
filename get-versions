#!/usr/bin/env bash

min_version=21
max_version=35

from=${1:-$(($max_version - 3))}
to=${2:-$max_version}

(( "$from" >= "$min_version" && "$from" <= "$max_version" )) || {
	echo "$0: invalid \`from' argument '$from', must be between $min_version and $max_version" >&2
	exit 1
}

(( "$to" >= "$min_version" && "$to" <= "$max_version" )) || {
	echo "$0: invalid \`to' argument '$to', must be between $min_version and $max_version" >&2
	exit 1
}

tags="$(git tag --sort=version:refname | grep -E '^v1\.[1-3][0-9]\.[0-9]{1,2}$')"

format='%-8s | %-7s | %-8s | %-6s | %s'
# shellcheck disable=SC2059
printf "$format\n" k8s coredns etcd pause updated

previous_coredns_version=
previous_etcd_version=
for tag in $tags; do
	minor_version="${tag:3}"
	minor_version="${minor_version%%.*}"

	(( "$minor_version" >= "$from" )) || continue
	(( "$minor_version" <= "$to" )) || break

	coredns_version="$(git show "${tag}:cmd/kubeadm/app/constants/constants.go" | grep 'CoreDNSVersion =' | sed -E 's/.*"v(.*)".*/\1/')"
	etcd_version="$(git show "${tag}:cmd/kubeadm/app/constants/constants.go" | grep 'DefaultEtcdVersion =' | sed -E 's/.*"(.*)".*/\1/')"
	pause_version="$(git show  "${tag}:cmd/kubeadm/app/constants/constants.go" | grep 'PauseVersion =' | sed -E 's/.*"(.*)".*/\1/')"

	# shellcheck disable=SC2059
	printf "$format" "$tag" "$coredns_version" "$etcd_version" "$pause_version"
	if [ "$coredns_version" != "$previous_coredns_version" ]; then
		printf ' *coredns*'
	fi
	if [ "$etcd_version" != "$previous_etcd_version" ]; then
		printf ' *etcd*'
	fi
	if [ "$pause_version" != "$previous_pause_version" ]; then
		printf ' *pause*'
	fi
	printf '\n'

	previous_coredns_version="$coredns_version"
	previous_etcd_version="$etcd_version"
	previous_pause_version="$pause_version"
done
