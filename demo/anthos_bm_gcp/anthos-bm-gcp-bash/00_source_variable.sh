#!/bin/bash -xe
cat << EOF 
GOOGLE_ACCOUNT_EMAIL is the email assocaited with your google account
BMCTL_VERSION 1.15 matched ubuntu osno longer take root as username, it will force you to use "ubuntu"
MACHINE_TYPE n1-standard-4 is only for lab purpuse,for production , it will require miminal n1-standard-8

EOF

export REGION="asia-east1"
export ZONE="asia-east1-a"
export PROJECT_ID="cfos-384323"
export ADMIN_CLUSTER_NAME="wandycluster"
export GOOGLE_ACCOUNT_EMAIL="wandy@fortinet.com"
export clusterid=$ADMIN_CLUSTER_NAME
export ON_PREM_API_REGION=$REGION
export project=$PROJECT_ID
export region=$REGION
export zone=$ZONE
export ON_PREM_API_REGION=$region
export BMCTL_VERSION="1.14.4"
export MACHINE_TYPE="n1-standard-4"
gcloud config set project $project
gcloud config set compute/region $region
gcloud config set compute/zone $zone
gcloud config list
