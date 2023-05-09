[[ -z $eks_cluster_name ]] && eks_cluster_name="EKSDemo"
eksctl scale nodegroup DemoNodeGroup --cluster $eks_cluster_name -N 2 -M 2 --region ap-east-1 && kubectl get node

