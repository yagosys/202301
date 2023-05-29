sudo apt update
sudo apt install xfce4 xfce4-goodies
sudo apt install tightvncserver
mkdir -p ~/.vnc
touch  ~/.vnc/xstartup
cat << EOF > ~/.vnc/xstartup
#!/bin/sh
xrdb $HOME/.Xresources
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

vncserver &

