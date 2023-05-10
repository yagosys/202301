[[ -z $eks_cluster_name ]] && eks_cluster_name="EKSDemo"
eksctl delete  cluster $eks_cluster_name
