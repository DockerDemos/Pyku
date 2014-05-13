#!/bin/bash

# Get the epel repository for python-webpy
/bin/cat << EOF > /etc/yum.repos.d/epel.repo
[epel]
name=Extra Packages for Enterprise Linux 6 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/6/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
EOF

/usr/bin/yum clean all
/usr/bin/yum install -y --nogpgcheck httpd mod_wsgi python-webpy git which \
rpm-build rpmdevtools redhat-rpm-config make gcc glibc-static \

# Build the Runit RPM
RPMUSER="rpmbuilder"
RPMHOME="/home/$RPMUSER"
ARCH="$(arch)"

/usr/sbin/useradd $RPMUSER

/bin/mkdir -p $RPMHOME/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
/bin/chown -R $RPMUSER $RPMHOME 
/bin/echo '%_topdir %(echo $HOME)/rpmbuild' > $RPMHOME/.rpmmacros 

/bin/su -c '/usr/bin/git clone https://github.com/imeyer/runit-rpm.git' - rpmbuilder
/bin/su -c '/home/rpmbuilder/runit-rpm/build.sh' - rpmbuilder

/usr/bin/yum install -y /home/rpmbuilder/rpmbuild/RPMS/$ARCH/runit-2.1.1-6.el6.$ARCH.rpm

# Setup the Apache init
/bin/mkdir -p /etc/service/httpd

/bin/cat << EOF > /etc/service/httpd/run
#!/bin/sh
exec /usr/sbin/httpd -DFOREGROUND
EOF
/bin/chown -R root.root /etc/service/
/bin/find /etc/service/ -exec /bin/chmod a+x {} \;

echo "SV:123456:respawn:/sbin/runsvdir-start" >> /etc/inittab

# Setup the WSGI stuff for Apache
/bin/cat << EOF > /etc/httpd/conf.d/pyku.conf
  WSGIScriptAlias / /var/www/html/pyku-web.py/
  AddType text/html .py
EOF

# Install Pyku
echo "Downloading Pyku from Github"
git clone https://github.com/clcollins/pyku.git /var/www/html
chmod 755 /var/www/html

