# # # # > Wi-fi
# # the wpa_supplicant and dhcpcd service should already be running
# connect to wifi via wpa_supplicant
sudo chown ailbhe:ailbhe /etc/wpa_supplicant/wpa_supplicant.conf
sudo chmod 755 /etc/wpa_supplicant/wpa_supplicant.conf
wpa_passphrase "IllinoisNet" "password" > /etc/wpa_supplicant/wpa_supplicant.conf
sed -i '5s/.*/        phase2=\"auth=MSCHAPV2\"/' /etc/wpa_supplicant/wpa_supplicant.conf
read -p "Username: " username
echo "        identity=\"$username\"" >> /etc/wpa_supplicant/wpa_supplicant.conf
read -sp "Password: " password
echo "        password=\"$password\"" >> /etc/wpa_supplicant/wpa_supplicant.conf
echo "}" >> /etc/wpa_supplicant/wpa_supplicant.conf
sudo wpa_supplicant -B -iwlp11s0 -c/etc/wpa_supplicant/wpa_supplicant.conf
# update system
sudo xbps-install -Su
# install git
sudo xbps-install git
