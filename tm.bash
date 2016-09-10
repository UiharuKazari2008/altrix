# SSH Trust Manager: Allows a user to control SSH key login.
# By: Yukimi Kazari for the TangleroadFX API (see https:\\acr.moe for info)
# Version 0.2

# Install
# Save this as tm.bash
# mv tm.bash /opt/tm.bash              # Put it a safe place
# chmod +x /opt/tm.bash                # Make Runable
# chmod +x /usr/bin/tm.bash            # Make Runable
# ln -s /opt/tm.bash /usr/bin/tm       # Move to normaly user accessable directory (had to check the chart)
# tm -h                                # View options
# Move your untrusted keys in ~/authorized_keys with the following format
# shortname;longname;sshpublickey

# #;Remote-Untrusted
# workPC1;WorkPC-1-Win10;SOMESSHKEYSHIT
# flashPC;FlashDrivePuTTY;SOMEMORESSHKEYSHIT
# #;Home-PCs
# DesktopCS;ControlCenterPC;EVENMORESSHSHITYOUGETTHEPOINT

echo ""
echo "= Key Management ==================="
OPTIND=1         # Reset in case getopts has been used previously in the shell.
key="notakey"
pub_key=""
name_key=""

show_help() {
echo "Shirai Key manager allows you to contorl SSH key login"
echo "tm [-l] or tm [-t[T]|-a[A]|-r] <key name>"
echo ""
echo "     NOTE: Use capital letters to allow shell access"
echo "     "
echo "     -l - List all installed public keys"
echo "     "
echo "          Reads from ~/authorized_keys"
echo "          Format: short_name;long_name;key"
echo "          Divider: #;name"
echo "     "
echo "     -t[T] - Interactive Login"
echo "          Allows login for 15 sec"
echo "     "
echo "     -a[A] - Allow a SSH key"
echo "     "
echo "     -r - Revoke a SSH key"
echo "     "
}

add_nskey() {
for i in $(grep -i $key ~/authorized_keys)
do
        pub_key=$(echo "$i" | awk -F ";" '{printf $3}')
        name_key=$(echo "$i" | awk -F ";" '{printf $1}')
	echo 'command="echo SHELL LOGIN BLOCKED, USE NON-INTERACTIVE MODE"' "ssh-rsa $pub_key $name_key" >> ~/.ssh/authorized_keys
done
}

add_fkey() {
for i in $(grep -i $key ~/authorized_keys)
do
        pub_key=$(echo "$i" | awk -F ";" '{printf $3}')
        name_key=$(echo "$i" | awk -F ";" '{printf $1}')
	echo "ssh-rsa $pub_key $name_key" >> ~/.ssh/authorized_keys
done
}

remove_key() {
sed -i '/'"$key"'/d' ~/.ssh/authorized_keys
}


if [ "$#" = 0 ]; then show_help; exit 0; fi

while getopts "h?lt:a:r:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    l)  echo "List of all keys:"
        for i in $(cat ~/authorized_keys)
        do
        key_short_name=$(echo $i | awk -F ";" '{print $1}')
        key_long_name=$(echo $i | awk -F ";" '{print $2}')
        if [ $key_short_name = "#" ]; then
        echo "- $key_long_name --------------"
        else
        echo "$key_short_name	[$key_long_name]"
        fi
        done
        echo ""
        exit 0
        ;;
    t)  key=$OPTARG
        echo "Allowed $key with NO SHELL access for 10 secounds"
	add_nskey
	sleep 10
        remove_key
        echo ""
        exit 0
        ;;
    T)  key=$OPTARG
        echo "Allowed $key for 10 secounds"
        add_fkey
        sleep 10
        remove_key
        echo "Revoked key"
        echo ""
        exit 0
        ;;
    a)  key=$OPTARG
	echo "Allowed $key with NO SHELL access"
	add_nskey
        echo ""
        exit 0
        ;;
    A)  key=$OPTARG
	echo "Allowed $key"
        add_fkey
        echo ""
        exit 0
        ;;
    r)  key=$OPTARG
	echo "Revoked $key"
	remove_key
        echo ""
        exit 0
        ;;
    *)  show_help
        exit 0
        ;;
    esac
done