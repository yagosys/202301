[[ -z $eks_cluster_name ]] && eks_cluster_name="EKSDemo" 
[[ -z $eks_cluster_region ]] && eks_cluster_region="us-east-1" 
eksctl delete  cluster $eks_cluster_name --region $eks_cluster_region && echo 'done' || echo "not able to delete $eks_cluster_name at region $eks_cluster_region"
