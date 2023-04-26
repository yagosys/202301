gcloud compute instances update-from-file gke-my-first-cluster-1-default-pool-426b2669-fwm8 \
    --project cfos-384323 \
    --zone us-west1-a \
    --source=gke-my-first-cluster-1-default-pool-426b2669-fwm8.txt \
    --most-disruptive-allowed-action=REFRESH
