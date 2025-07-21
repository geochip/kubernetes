#!/usr/bin/env sh

TAGS="$(git tag --sort=version:refname | grep -E '^v1\.[2-3][0-9]\.[0-9]{1,2}$' | grep -v 'v1.2[0-9]')"

format='%-8s | %-7s | %-8s | %-5s |'
printf "$format\n" k8s coredns etcd pause

previous_coredns_version=
previous_etcd_version=
for tag in $TAGS; do
	git switch -q --detach "$tag"
	coredns_version="$(grep 'CoreDNSVersion =' cmd/kubeadm/app/constants/constants.go | sed -E 's/.*"v(.*)".*/\1/')"
	etcd_version="$(grep 'DefaultEtcdVersion =' cmd/kubeadm/app/constants/constants.go | sed -E 's/.*"(.*)".*/\1/')"
	pause_version="$(grep 'PauseVersion =' cmd/kubeadm/app/constants/constants.go | sed -E 's/.*"(.*)".*/\1/')"

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

git switch -q get-versions
