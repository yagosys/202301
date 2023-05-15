repo="interbeing"
docker build . -t $repo/kubectl-cfos:gke_demo_v1
docker push $repo/kubectl-cfos:gke_demo_v1
