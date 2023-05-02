project="$1"
region="$2"
zone="$3"

[[ "$1" == "" ]] && project="cfos-384323"
[[ "$2" == "" ]] && region="us-west1"
[[ "$3" == "" ]] && zone="us-west1-a"
gcloud config set project $project
gcloud config set compute/region $region
gcloud config set compute/zone $zone
gcloud config list
