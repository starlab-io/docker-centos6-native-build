FROM centos:6.10
MAINTAINER Star Lab <support@starlab.io>

# Need to update the baseurls as Centos6 is no longer supported
RUN rm -rf /etc/yum.repos.d/CentOS-Base.repo
ADD CentOS-Base.repo /etc/yum.repos.d/
RUN yum clean all
RUN yum update -y

RUN mkdir /source

# Install yum-plugin-ovl to work around issue with a bad
# rpmdb checksum
# should already be installed
RUN yum list installed | grep plugin-ovl

# build dependencies
RUN yum install --skip-broken --disablerepo=updates,extras -y kernel-devel bc \
        openssl openssl-devel python-setuptools python-virtualenv \
        dracut-network nfs-utils check unzip rpm-build rpm-devel \
        gcc perl elfutils-libelf-devel sudo && \
    yum groupinstall --skip-broken --disablerepo=updates,extras -y "Development Tools" && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# remove git if already installed
RUN yum remove -y git && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# install wandisco RPM so we can get a recent version of git
RUN yum install -y http://opensource.wandisco.com/centos/6/git/x86_64/wandisco-git-release-6-1.noarch.rpm

# install modern git
RUN yum install -y git

# more utilities
RUN yum install --skip-broken --disablerepo=updates,extras -y \
        vim-common attr python-devel freetype-devel xxd && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# user space app build dependencies
RUN yum install --disablerepo=extras -y texinfo \
        glibc-static.x86_64 glibc-static.i686 autogen \
        glibc.i686 glibc-devel.i686 libgcc.i686 && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# Install yum-utils
RUN yum install --disablerepo=updates,extras -y yum-utils && \
    yum clean all && \
    rm -rf /var/cache/yum/* /tmp/* /var/tmp/*

# Install tools to download and install python 2.7 and python3
RUN yum install -y epel-release zlib-devel gcc gcc-c++ sqlite-devel \
    zip2-devel xz-libs pigz wget bzip2-devel ncurses-devel sqlite-devel \
    readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz \
    xz-devel expat-devel glibc-devel

# Download, build and install python 2.7 and pip
RUN wget -nv https://www.python.org/ftp/python/2.7.18/Python-2.7.18.tgz && \
    tar xzf Python-2.7.18.tgz
WORKDIR Python-2.7.18
RUN ./configure --prefix=/usr/local && make && make altinstall && \
    ln -s /usr/local/bin/python2.7 /usr/local/bin/python
WORKDIR /
RUN rm -rf /Python-2.7.18*
#RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && \
#    python get-pip.py && \
#    ln -s /usr/local/bin/pip /usr/bin/pip27 && \
#    rm -f get-pip.py

# Download, build and install Python 3.6.3:
RUN wget -nv https://python.org/ftp/python/3.6.3/Python-3.6.3.tar.xz && \
    tar xf Python-3.6.3.tar.xz
WORKDIR Python-3.6.3
RUN ./configure --prefix=/usr/local --enable-shared LDFLAGS="-Wl,-rpath /usr/local/lib"
RUN make && make altinstall

RUN sed -i '/^Defaults[ \t]*secure_path.*/{s%%Defaults secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin%;h};${x;/./{x;q0};x;q1}' /etc/sudoers

VOLUME ["/source"]
WORKDIR /source

COPY add_user_to_sudoers/target/x86_64-unknown-linux-musl/release/add_user_to_sudoers /usr/local/bin/add_user_to_sudoers
RUN chmod 4755 /usr/local/bin/add_user_to_sudoers

COPY startup_script /usr/local/bin/startup_script
ENTRYPOINT ["/usr/local/bin/startup_script"]
CMD ["/bin/bash", "-l"]
