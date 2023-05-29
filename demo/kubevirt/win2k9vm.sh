app="win2k9"
filename=vm$app.yaml
cat << EOF >$filename
apiVersion: kubevirt.io/v1
kind: VirtualMachine
metadata:
  generation: 1
  labels:
    kubevirt.io/os: windows
    app: $app
  name: $app
spec:
  running: true
  template:
    metadata:
      labels:
        kubevirt.io/domain: $app
    spec:
      domain:
        cpu:
          cores: 4
        devices:
          disks:
          - cdrom:
              bus: sata
            bootOrder: 1
            name: iso
          - disk:
              bus: virtio
            name: harddrive
          - cdrom:
              bus: sata
              readonly: true
            name: virtio-drivers
        machine:
          type: q35
        resources:
          requests:
            memory: 4096M
      volumes:
      - name: harddrive
        persistentVolumeClaim:
          claimName: winhd
      - name: iso
        containerDisk:
          image: 3pings/w2k9_iso:aug2022
      - name:  virtio-drivers
        containerDisk:
          image: kubevirt/virtio-container-disk
EOF

