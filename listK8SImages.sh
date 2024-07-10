#!/bin/sh

listTags() {
  git tag | (
  ifs=$IFS
  while read tag
  do
    tag=${tag:1}
    IFS=.
    set -- $tag
    IFS=$ifs
    if [ $1 = 1 -a $2 -gt 25 ]
    then
      IFS=-
      set -- $3
      IFS=$ifs
      if [ $# -eq 1 ]; then echo $tag; fi
    fi
  done | sort -V
)
}

echo "version: 1.0
imageSet:
"
listTags | (
while read tag
do
  vTag="v$tag"
  git checkout -f $vTag 
  
  echo "  - version: $vTag"
  
  for image in kube-apiserver kube-controllermanager kube-proxy kube-scheduler 
  do
    echo -ne "    $image:\n      tag: $vTag\n"
  done

  coredns=$(grep CoreDNSVersion  cmd/kubeadm/app/constants/constants.go | grep =)
  set -- $coredns
  corednsTag=${3:1:-1}
  echo -ne "    coredns:\n      tag: $corednsTag\n"

  etcd=$(grep DefaultEtcdVersion   cmd/kubeadm/app/constants/constants.go | grep =)
  set -- $etcd
  etcdTag=${3:1:-1}
  echo -ne "    etcd:\n      tag: $etcdTag\n"

  pause=$(grep PauseVersion cmd/kubeadm/app/constants/constants.go | grep =)
  set -- $pause
  pauseTag=${3:1:-1}
  echo -ne "    pause:\n      tag: $pauseTag\n"

  echo

  prevCoredns=$Coredns
  prevEtcd=$Etcd
done
)
git checkout master >/dev/null 2>&1
