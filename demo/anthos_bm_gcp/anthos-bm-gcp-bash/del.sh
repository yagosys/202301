bmctl reset -c wandycluster
list=$(gcloud compute instances list | grep NAME | cut -d ":" -f 2) 
for i in $list; do {
	gcloud compute instances delete $i -q
}
done

list=$(gcloud iam service-accounts list | grep EMAIL | grep baremetal  | cut -d ":" -f 2)
for i in $list ; do {
	gcloud iam service-accounts delete $i -q
}
done
