FROM centos:6.7
MAINTAINER Star Lab <support@starlab.io>

RUN mkdir /source

# modify CentOS repo URL following
# End-of-Life deadline
ARG DISTROVER=6.7
RUN sed -i "s/^mirrorlist.*$/baseurl=http:\/\/vault.centos.org\/${DISTROVER}\/os\/\$basearch\//g" /etc/yum.repos.d/CentOS-Base.repo

# update certificates
RUN yum -y update ca-certificates nss curl && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# general packages and dependencies
RUN yum install --disablerepo=updates,extras -y kernel-devel bc wget \
        openssl openssl-devel python-setuptools python-virtualenv \
        dracut-network nfs-utils check unzip rpm-build rpm-devel \
        gcc perl elfutils-libelf-devel vim-common attr python-devel \
        freetype-devel sudo strace ltrace man texinfo glibc.x86_64 libgcc.x86_64 \
        glibc-devel.x86_64 glibc-static.x86_64 glibc-static.i686 automake \
        glibc.i686 glibc-devel.i686 libgcc.i686 yum-utils \
        zlib-devel sqlite-devel bzip2-devel xz-libs pigz && \
    yum groupinstall --disablerepo=updates,extras -y "Development Tools" && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# remove git if already installed
RUN yum remove -y git && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# Build and install python 2.7 and pip
RUN wget https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tar.xz && \
    tar xfJ Python-2.7.18.tar.xz
WORKDIR Python-2.7.18
RUN ./configure --prefix=/usr/local && make && make altinstall && \
    ln -s /usr/local/bin/python2.7 /usr/local/bin/python
WORKDIR /
RUN rm -rf /Python-2.7.18*

RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
    python get-pip.py && \
    ln -s /usr/local/bin/pip /usr/bin/pip27 && \
    rm -f get-pip.py

VOLUME ["/source"]
WORKDIR /source
CMD ["/bin/bash"]
