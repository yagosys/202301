sudo apt update -y 
sudo apt install xfce4 xfce4-goodies -y 
sudo apt install tightvncserver -y
sudo apt install xtightvncviewer -y 
sudo apt install virt-viewer -y
sudo apt install terminator -y 
sudo apt install xterm -y

mkdir -p ~/.vnc
touch  ~/.vnc/xstartup
cat << EOF > ~/.vnc/xstartup
#!/bin/sh
xrdb $HOME/.Xresources
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

vncserver 

