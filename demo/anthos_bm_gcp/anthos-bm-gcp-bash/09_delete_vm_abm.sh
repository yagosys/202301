#!/bin/bash -xe
list=$(gcloud compute instances list | grep abm | awk '{print $1}')
for i in $list; do {
        gcloud compute instances delete $i -q
}
done

list=$(gcloud iam service-accounts list  | grep baremetal  | awk '{print $1}')
for i in $list ; do {
        gcloud iam service-accounts delete $i -q
}
done
