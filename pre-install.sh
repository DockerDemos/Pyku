#!/bin/bash

# Get the epel repository for python-webpy
/bin/cat << EOF > /etc/yum.repos.d/epel.repo
[epel]
name=Extra Packages for Enterprise Linux 6 - \$basearch
#baseurl=http://download.fedoraproject.org/pub/epel/6/\$basearch
mirrorlist=https://mirrors.fedoraproject.org/metalink?repo=epel-6&arch=\$basearch
failovermethod=priority
enabled=1
gpgcheck=0
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
EOF

# Build the RPM
RPMUSER='rpmbuilder'
RPMHOME="/home/$RPMUSER"
ARCH="$(arch)"

/usr/sbin/useradd $RPMUSER

/bin/mkdir -p $RPMHOME/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}
/bin/echo '%_topdir %(echo $HOME)/rpmbuild' > $RPMHOME/.rpmmacros
/bin/chown -R $RPMUSER $RPMHOME

f_build() {
	RPMSOURCE="$1"
	RPM="$2"
	/bin/su -c "/usr/bin/git clone $RPMSOURCE $RPM" - rpmbuilder
	/bin/su -c "/home/rpmbuilder/$RPM/build.sh $RPM 1>/dev/null" - rpmbuilder
}

BUILDPKGS='rpm-build rpmdevtools redhat-rpm-config make gcc glibc-static'

/usr/bin/yum clean all
/usr/bin/yum install -y $BUILDPKGS \
git which pwgen cronie tar rsyslogd \
httpd mod_wsgi python-webpy

f_build 'https://github.com/imeyer/runit-rpm.git' 'runit-rpm'

/usr/bin/yum install -y $RPMHOME/rpmbuild/RPMS/*/*.rpm

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

