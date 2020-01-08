FROM centos:6.7
MAINTAINER Star Lab <support@starlab.io>

RUN mkdir /source

# Install yum-plugin-ovl to work around issue with a bad
# rpmdb checksum
RUN yum install --disablerepo=updates,extras -y yum-plugin-ovl && \
        yum clean all && \
        rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# build dependencies
RUN yum install --disablerepo=updates,extras -y kernel-devel wget bc git \
        openssl openssl-devel python-setuptools python-virtualenv \
        dracut-network nfs-utils check unzip rpm-build rpm-devel curl \
        gcc perl elfutils-libelf-devel && \
    yum groupinstall --disablerepo=updates,extras -y "Development Tools" && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# Install xxd and attr utilities
# Install which required to build RedHawk 6 OpenOnLoad subsystem
RUN yum install --disablerepo=updates,extras -y \
        vim-common attr gcc-c++ python-devel freetype-devel \
        libtool which xxd && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# user space app build dependencies
RUN yum install --disablerepo=updates,extras -y texinfo \
        glibc-static.x86_64 glibc-static.i686 autogen && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# Install yum-utils
RUN yum install --disablerepo=updates,extras -y yum-utils && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

VOLUME ["/source"]
WORKDIR /source
CMD ["/bin/bash"]
