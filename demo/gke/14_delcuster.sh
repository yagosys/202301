[[ $defaultClustername == "" ]] && defaultClustername="my-first-cluster-1"
name=$(gcloud container clusters list --format="value(name)" --filter="name=$defaultClustername" --limit=1) &&  \
projectName=$(gcloud config list --format="value(core.project)") && \
zone=$(gcloud config list --format="value(compute.zone)" --limit=1) && \
gcloud container clusters delete $name
