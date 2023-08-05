nodeList=$(kubectl get node | grep "Ready" | awk '{ print $1 }')
index=0
for name in $nodeList; do {
	echo $name
	kubectl label node $name os=linux$index --overwrite
	(( index++))
}
done
