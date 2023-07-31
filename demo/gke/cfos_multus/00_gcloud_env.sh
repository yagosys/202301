#/bin/bash -xe
echo $networkName
project="$1"
region="$2"
zone="$3"

[[ "$1" == "" ]] && project="cfos-384323"
[[ "$2" == "" ]] && region="asia-east1"
[[ "$3" == "" ]] && zone="asia-east1-a"
gcloud config set project $project
gcloud config set compute/region $region
gcloud config set compute/zone $zone
gcloud config list

