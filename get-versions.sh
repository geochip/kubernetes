#!/usr/bin/env sh

TAGS="$(git tag --sort=version:refname | grep -E '^v1\.[2-3][0-9]\.[0-9]{1,2}$' | grep -v 'v1.2[0-9]')"

format='%-8s | %-7s | %-8s | %-5s |'
# shellcheck disable=SC2059
printf "$format\n" k8s coredns etcd pause

previous_coredns_version=
previous_etcd_version=
for tag in $TAGS; do
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
