- why NFS 
when cfos deployed as daemonSet in a multi-node cluster, you may want all cFOS POD share same configuration, then you need to mount cfos /data directory to a shared file system, for example, a NFS file system.  

- install and setup  NFS server

```
sudo apt-get update -y 
sudo apt-get install nfs-server -y

```
- create nfs config and start nfs server 

```

cat <<EOF | bash - 
sudo -u ubuntu  mkdir /home/ubuntu/data -p
sudo chmod 666 /home/ubuntu/data
cat << EOF | sudo   tee  /etc/exports
/home/ubuntu/data 10.0.1.100(rw,no_subtree_check,no_root_squash)
/home/ubuntu/data 10.0.2.200(rw,no_subtree_check,no_root_squash)
/home/ubuntu/data 10.0.2.201(rw,no_subtree_check,no_root_squash)
/home/ubuntu/data 10.0.2.202(rw,no_subtree_check,no_root_squash)
EOF

sudo systemctl enable --now nfs-server
sudo exportfs -ar
```
*here 10.0.x.x is the nodes IP that will mount NFS server*

- check NFS server status 
check NFS server status with `systemctl status nfs-server`
check NFS exports with `showmount -e`


```
ubuntu@ip-10-0-1-100:~$ systemctl status nfs-server
● nfs-server.service - NFS server and services
     Loaded: loaded (/lib/systemd/system/nfs-server.service; enabled; vendor preset: enabled)
    Drop-In: /run/systemd/generator/nfs-server.service.d
             └─order-with-mounts.conf
     Active: active (exited) since Thu 2023-03-09 06:08:34 UTC; 8min ago
   Main PID: 3953 (code=exited, status=0/SUCCESS)
        CPU: 7ms

Mar 09 06:08:34 ip-10-0-1-100 systemd[1]: Starting NFS server and services...
Mar 09 06:08:34 ip-10-0-1-100 exportfs[3952]: exportfs: can't open /etc/exports for reading
Mar 09 06:08:34 ip-10-0-1-100 systemd[1]: Finished NFS server and services.

ubuntu@ip-10-0-1-100:~$ journalctl -f -u nfs-server
Mar 09 06:08:34 ip-10-0-1-100 systemd[1]: Starting NFS server and services...
Mar 09 06:08:34 ip-10-0-1-100 exportfs[3952]: exportfs: can't open /etc/exports for reading
Mar 09 06:08:34 ip-10-0-1-100 systemd[1]: Finished NFS server and services.

ubuntu@ip-10-0-1-100:~$ showmount -e
Export list for ip-10-0-1-100:
/home/ubuntu/data 10.0.2.202,10.0.2.201,10.0.2.200,10.0.1.100

```
- install nfs client on worker node


```
sudo apt-get install nfs-common -y

```
- test mount on client machine

```
mkdir -p ./tempfolder
sudo mount 10.0.1.100:/home/ubuntu/data ./tempfolder
sudo umount ./tempfolder
```


