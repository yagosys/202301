clustersearchstring=$(gcloud container clusters list --format="value(name)" --limit=1) && \
name=$(gcloud compute instances list --filter="name~'$clustersearchstring'"  --format="value(name)" --limit=1) && \
gcloud compute ssh $name --command='sudo cat /etc/cni/net.d/07-multus.conf' && \
gcloud compute ssh $name --command='journalctl -n 10 -u kubelet'
