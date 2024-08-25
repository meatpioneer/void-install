# Outline
* [Background](#background)
# Background
## Who?
I am an undergrad Computer Engineer at University of Illinois at Urbana-Champaign. This is mainly for myself, but also I believe (a few) others might find my documentation useful. I am an adovcate for the open and collective contribution to the field of computers, as well as science in general (that's what its all about isnt it).

I'm working on hosting a blog website soon, but it may take time as classes are beginning soon.
## Why?
Because I want a script to install my OS. Void Linux is very customizable/barebones, which is why I love it (along with various design choices), but having to manually repeat the install process when unfixable errors arise is painful. I am heavily invested in using this as a learning process as well.
## What?
So far this is just a simple script to install various github and xbps packages, and configure them. Documentation delving into the packages/compenents themselves will be kept here (so no one has to do extra rabbit hole diving like I had to), along with what exactly the script performs when it comes to tasks.
## When?
I will be busy during this school year, but updates will hopefully happen on a weekly/monthly basis.
# Install & Run
## University Wifi (eduroam)
Copy the wifi.sh file onto a USB drive, then proceed with the following commands:
To mount the usb drive, you must find the block name

`lsblk`

Usually, USB drives are labelled as "sda1". We then mount the drive. Here, we are mounting to the directory "/media".

`sudo mount /dev/sda1 /media`

Now, the USB's files and directories are available via this directory "/media" on our machine. We can now copy wifi.sh to say, our home directory.

`cp /media/wifi.sh ~/`

Finally, run the script and follow the prompts to input your university username and password.

`sudo ~/wifi.sh`

Reboot the machine and tada, you have wifi.

`sudo reboot`
