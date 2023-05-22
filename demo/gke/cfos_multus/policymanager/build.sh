image_name="gke_demo_v2"
repo="interbeing"
docker build . -t $repo/kubectl-cfos:$image_name
docker push $repo/kubectl-cfos:$image_name
