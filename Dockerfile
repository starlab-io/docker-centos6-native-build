FROM centos:6.7
MAINTAINER Star Lab <support@starlab.io>

RUN mkdir /source

# Install yum-plugin-ovl to work around issue with a bad
# rpmdb checksum
RUN yum install --disablerepo=updates,extras -y yum-plugin-ovl && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# update certificates
RUN yum -y update ca-certificates nss wget curl && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# build dependencies
RUN yum install --disablerepo=updates,extras -y kernel-devel bc \
        openssl openssl-devel python-setuptools python-virtualenv \
        dracut-network nfs-utils check unzip rpm-build rpm-devel \
        gcc perl elfutils-libelf-devel && \
    yum groupinstall --disablerepo=updates,extras -y "Development Tools" && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# remove git if already installed
RUN yum remove -y git && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# install IUS so we can get a recent version of git
RUN yum install -y https://centos6.iuscommunity.org/ius-release.rpm && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# install modern git
RUN yum install -y git2u && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# more utilities
RUN yum install --disablerepo=updates,extras -y \
        vim-common attr python-devel freetype-devel xxd && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# user space app build dependencies
RUN yum install --disablerepo=updates,extras -y texinfo \
        glibc-static.x86_64 glibc-static.i686 autogen \
        glibc.i686 glibc-devel.i686 libgcc.i686 && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# Install yum-utils
RUN yum install --disablerepo=updates,extras -y yum-utils && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# Build and install python 2.7 and pip
RUN yum install -y --disablerepo=updates,extras epel-release && \
    yum install -y --disablerepo=updates,extras zlib-dev openssl-devel \
        sqlite-devel bzip2-devel xz-libs pigz wget &&\
    yum clean all && rm -rf /var/cache/yum/* /tmp/* /var/tmp/*
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
