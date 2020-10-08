
# This permanent solution will set ethercat rules from root to user, dev/EtherCAT0 user permission's are ok at startup this way.

echo "Type your normal password to get a root account with the same password .."
sudo passwd root

echo "Login as root now, type password"
su

echo "Copy ethercat rules to etc/udev/rules.d/99-ethercat.rules/.."

echo "KERNEL=="\"EtherCAT[0-9]*\"", MODE="\"0660\"", GROUP=""\"$USER\"" >> /etc/udev/rules.d/99-ethercat.rules

exit #logout as root
