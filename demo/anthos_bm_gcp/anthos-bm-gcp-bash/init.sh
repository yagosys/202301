#/bin/bash
PROJECT_ID="$1"
REGION="$2"
ZONE="$3"
ADMIN_CLUSTER_NAME="wandycluster"
[[ "$1" == "" ]] && export PROJECT_ID="cfos-384323"
[[ "$2" == "" ]] && export REGION="asia-east1"
[[ "$3" == "" ]] && export ZONE="asia-east1-a"
[[ "$4" == "" ]] && export ADMIN_CLUSTER_NAME="wandycluster"
[[ "$4" == "" ]] && export BMCTL_VERSION="1.15.0"
gcloud config set project $PROJECT_ID
gcloud config set compute/zone $ZONE
gcloud config set compute/region $REGION
