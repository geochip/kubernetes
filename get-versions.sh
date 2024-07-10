#!/usr/bin/env sh

TAGS="$(git tag --sort=version:refname | grep -E "^v1\.[2-3][0-9]\.[0-9][0-9]?$" | grep -v "v1.2[0-5]")"

echo "k8s | coredns | etcd"

for tag in $TAGS; do
	git switch -q --detach "$tag"
	coredns_version="$(grep "CoreDNSVersion =" cmd/kubeadm/app/constants/constants.go | sed -E 's/.*"v(.*)".*/\1/')"
	etcd_version="$(grep "DefaultEtcdVersion =" cmd/kubeadm/app/constants/constants.go | sed -E 's/.*"(.*)".*/\1/')"
	echo "$tag | $coredns_version | $etcd_version"
done

git switch -q get-versions
