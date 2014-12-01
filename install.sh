#!/bin/bash

apt-get update
apt-get -y upgrade
apt-get install -y openjdk-6-jre openssh-client openssh-server cron supervisor
mkdir -p /var/log/supervisor
mkdir -p /var/run/sshd
dpkg -i /tmp/rundeck.deb
rm -f /tmp/rundeck.deb
chown -R rundeck /etc/rundeck
chmod 4755 /usr/bin/sudo	# no suid bit was set for sudo!?

# Modify init script
sed -i 's/&>>\/var\/log\/rundeck\/service.log &$//g' /etc/init.d/rundeckd


# Generate a new passwordless SSH key
mkdir -p /var/lib/rundeck/.ssh/
chown rundeck:rundeck /var/lib/rundeck/.ssh
ssh-keygen -t rsa -f /var/lib/rundeck/.ssh/id_rsa -N ''

# Reset rundeck system user password and allow root to log on with ssh
echo -e "$RDPASS\n$RDPASS" | passwd
sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
sed -ri 's/^session\s+required\s+pam_loginuid.so$/session optional pam_loginuid.so/' /etc/pam.d/sshd	# https://github.com/dotcloud/docker/issues/5663

mkdir -p /tmp/rundeck/
chown rundeck:rundeck /var/lib/rundeck
chown -R rundeck:rundeck /var/rundeck
chown -R rundeck:rundeck /var/lib/rundeck/.ssh
chmod 700 /var/lib/rundeck/.ssh
chown rundeck:rundeck /tmp/rundeck/

# Start rundeck to load job definitions
/usr/bin/supervisord &
TPID=$(jobs -p)

echo
echo "Waiting for service to start up"
echo
status=1 ; n=0
#while [[ $status -eq 1 ]] || [[ $n -lt 60 ]]
while [[ $n -lt 60 ]]
do
#        nc $MYHOST 4440 < /dev/null > /dev/null && status=0 || status=1
        echo -n "."
        #status=$?
        #echo "status: $status"
        let n=n+1
        sleep 1
done
echo " done."


/usr/bin/rd-jobs load --file /tmp/jobs.xml
kill $TPID

# Change MYHOST to your IP or hostname
sed -i "s/localhost:4440/$MYHOST:4440/g" /etc/rundeck/rundeck-config.properties
sed -i "s/localhost:4440/$MYHOST:4440/g" /etc/rundeck/framework.properties
# Change the Rundeck admin password
sed -i "s/^admin:admin/admin:$RDPASS/g" /etc/rundeck/realm.properties
sed -i "s/framework.server.password = admin/framework.server.password = $RDPASS/g" /etc/rundeck/framework.properties

echo
echo "#####################################"
echo "Installation finished. Log on to http://$MYHOST:4440/ with"
echo "admin $RDPASS"
echo "#####################################"
echo

exit
