FROM centos:7.6.1810

ARG MYUNAME=builder
ARG MYUID=1000

ENV container=docker

# Download required dependencies by mirror/build processes.
# Notice there are 3 invocations to yum package manage.
# 1) Enable EPEL repository.
# 2) Download required packages.
# 3) Clean yum cache.
RUN groupadd -g 751 cgts && \
    echo "mock:x:751:root" >> /etc/group && \
    echo "mockbuild:x:9001:" >> /etc/group && \
    yum install -y epel-release && \
        yum install -y anaconda \
        anaconda-help \
        anaconda-runtime \
        autoconf-archive \
        autogen \
        automake \
        bc \
        bind \
        bind-utils \
        cpanminus \
        createrepo \
        deltarpm \
        expat-devel \
        gcc \
        gettext \
        git \
        libtool \
        libxml2 \
        libxml2-devel \
        libxslt-devel \
        libffi-devel \
        lighttpd \
        lighttpd-fastcgi \
        lighttpd-mod_geoip \
        libvirt-devel \
        net-tools \
        mkisofs \
        mock \
        mongodb \
        mongodb-server \
        mariadb-devel \
        openldap-devel \
        openssl-devel \
        pax \
        perl-CPAN \
        python-deltarpm \
        python-devel \
        python-pep8 \
        python-pip \
        python-psutil \
        python2-psutil \
        python36-psutil \
        python-sphinx \
        python-subunit \
        python-pip \
        python-testrepository \
        python-tox \
        python-yaml \
        postgresql \
        postgresql-devel \
        qemu-kvm \
        quilt \
        rpm-build \
        rpm-sign \
        rpm-python \
        sqlite-devel \
        squashfs-tools \
        sudo \
        systemd \
        syslinux \
        udisks2 \
        vim-enhanced \
        wget \
        yumdownloader \
	openssh-server

# cpan modules, installing with cpanminus to avoid stupid questions since cpan is whack
RUN cpanm --notest Fatal && \
    cpanm --notest XML::SAX  && \
    cpanm --notest XML::SAX::Expat && \
    cpanm --notest XML::Parser && \
    cpanm --notest XML::Simple

# pip installs
RUN pip install python-subunit junitxml --upgrade && \
    pip install tox --upgrade

# Install repo tool
RUN curl https://storage.googleapis.com/git-repo-downloads/repo > /usr/local/bin/repo && \
    chmod a+x /usr/local/bin/repo

# mock time
# forcing chroots since a couple of packages naughtily insist on network access and
# we dont have nspawn and networks happy together.
RUN useradd -s /sbin/nologin -u 9001 -g 9001 mockbuild && \
    rmdir /var/lib/mock && \
    ln -s /localdisk/loadbuild/mock /var/lib/mock && \
    rmdir /var/cache/mock && \
    ln -s /localdisk/loadbuild/mock-cache /var/cache/mock && \
    echo "config_opts['use_nspawn'] = False" >> /etc/mock/site-defaults.cfg && \
    echo "config_opts['rpmbuild_networking'] = True" >> /etc/mock/site-defaults.cfg && \
    echo  >> /etc/mock/site-defaults.cfg

# Inherited  tools for mock stuff
# we at least need the mock_cache_unlock tool
# they install into /usr/bin
COPY cgcs_overlay /opt/cgcs_overlay
RUN cd /opt/cgcs_overlay && \
    make && \
    make install

# centos locales are broken. this needs to be run after the last yum install/update
RUN localedef -i en_US -f UTF-8 en_US.UTF-8

# setup
RUN mkdir -p /www/run && \
    mkdir -p /www/logs && \
    mkdir -p /www/home && \
    mkdir -p /www/root/htdocs/localdisk && \
    chown -R $MYUID:cgts /www && \
    ln -s /localdisk/loadbuild /www/root/htdocs/localdisk/loadbuild && \
    ln -s /import/mirrors/CentOS /www/root/htdocs/CentOS && \
    ln -s /import/mirrors/fedora /www/root/htdocs/fedora && \
    ln -s /localdisk/designer /www/root/htdocs/localdisk/designer

# lighthttpd setup
# chmod for /var/log/lighttpd fixes a centos issue
# in place sed for server root since it's expanded soon thereafter
#     echo "server.bind = \"localhost\"" >> /etc/lighttpd/lighttpd.conf && \
RUN echo "$MYUNAME ALL=(ALL:ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p  /var/log/lighttpd  && \
    chmod a+rwx /var/log/lighttpd/ && \
    sed -i 's%^var\.log_root.*$%var.log_root = "/www/logs"%g' /etc/lighttpd/lighttpd.conf  && \
    sed -i 's%^var\.server_root.*$%var.server_root = "/www/root"%g' /etc/lighttpd/lighttpd.conf  && \
    sed -i 's%^var\.home_dir.*$%var.home_dir = "/www/home"%g' /etc/lighttpd/lighttpd.conf  && \
    sed -i 's%^var\.state_dir.*$%var.state_dir = "/www/run"%g' /etc/lighttpd/lighttpd.conf  && \
    sed -i "s/server.port/#server.port/g" /etc/lighttpd/lighttpd.conf  && \
    sed -i "s/server.use-ipv6/#server.use-ipv6/g" /etc/lighttpd/lighttpd.conf && \
    sed -i "s/server.username/#server.username/g" /etc/lighttpd/lighttpd.conf && \
    sed -i "s/server.groupname/#server.groupname/g" /etc/lighttpd/lighttpd.conf && \
    sed -i "s/server.bind/#server.bind/g" /etc/lighttpd/lighttpd.conf && \
    sed -i "s/server.document-root/#server.document-root/g" /etc/lighttpd/lighttpd.conf && \
    sed -i "s/server.dirlisting/#server.dirlisting/g" /etc/lighttpd/lighttpd.conf && \
    echo "server.port = 8088" >> /etc/lighttpd/lighttpd.conf && \
    echo "server.use-ipv6 = \"disable\"" >> /etc/lighttpd/lighttpd.conf && \
    echo "server.username = \"$MYUNAME\"" >> /etc/lighttpd/lighttpd.conf && \
    echo "server.groupname = \"cgts\"" >> /etc/lighttpd/lighttpd.conf && \
    echo "server.bind = \"localhost\"" >> /etc/lighttpd/lighttpd.conf && \
    echo "server.document-root   = \"/www/root/htdocs\"" >> /etc/lighttpd/lighttpd.conf && \
    sed -i "s/dir-listing.activate/#dir-listing.activate/g" /etc/lighttpd/conf.d/dirlisting.conf && \
    echo "dir-listing.activate = \"enable\"" >> /etc/lighttpd/conf.d/dirlisting.conf

# Without this, init won't start the enabled services and exec'ing and starting
# them reports "Failed to get D-Bus connection: Operation not permitted".
VOLUME /run /tmp

RUN useradd -r -u $MYUID -g cgts -m $MYUNAME && \
    rsync -av /etc/skel/ /home/$MYUNAME/ && \
    chown $MYUNAME /home/$MYUNAME

ENV TINI_VERSION v0.18.0
RUN mkdir -p /usr/local/bin
RUN wget -O /usr/local/bin/tini "https://github.com/krallin/tini/releases/download/$TINI_VERSION/tini"
RUN chmod +x /usr/local/bin/tini

ENTRYPOINT ["/usr/local/bin/tini", "-g", "--"]
CMD ["/bin/bash"]
