#!/bin/bash


image='k8s-sisyphus/kube-apiserver'
registryTags=$(curl -k  https://registry.altlinux.org/v2/$image/tags/list 2>/dev/null |
jq -r '.tags | sort[]')

#echo "$registryTags"
declare -A maxExistsVersion
echo "declare -A maxExistsVersion"
for registryTag in $registryTags
do
  if [ "${registryTag:0:1}" != 'v' ]; then continue; fi
  major=${registryTag:0:5}
  minor=${registryTag:6}
  # echo "major=$major minor=$minor"
  if [ -z "${maxExistsVersion[$major]}" ]
  then
    maxExistsVersion[$major]=$minor
  else
    if [ "$minor" -gt "${maxExistsVersion[$major]}" ]
    then
      maxExistsVersion[$major]=$minor
    fi
  fi
done
list1=''
for key in "${!maxExistsVersion[@]}"
do
  maxMinor="${maxExistsVersion[$key]}"
  list1+="maxExistsVersion['$key']='$key.$maxMinor'\n"
done
echo -ne $list1 | sort
# exit

git fetch --all >/dev/tty 2>&1

declare -A newVersions
echo "declare -A newVersions"
for tag in $(git tag)
do
  major=${tag:0:5}
  minor=${tag:6}
  if [ $minor -ge 0 ] 2>/dev/null;
  then
    if [ -n "${maxExistsVersion[$major]}" -o "$minor" -gt 30 ]
    then
      maxMinor="${maxExistsVersion[$major]}"
      if [ "$maxMinor" -lt "$minor" ]
      then
	newVersions[$major]+="$major.$minor "
      fi
    fi
   fi
done
list2=''
for key in "${!newVersions[@]}"
do
  maxMinors="${newVersions[$key]}"
  list2+="newVersions['$key']='$maxMinors'\n"
done
echo -ne $list2 | sort
