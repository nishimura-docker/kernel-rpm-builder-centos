FROM centos
WORKDIR /root/
RUN yum install -y rpmdevtools gcc make rpm-build yum-utils epel-release

RUN yum install -y distcc
RUN mkdir -p /root/distcc/ /root/.distcc
RUN ln -s /usr/bin/distcc /root/distcc/gcc
RUN ln -s /usr/bin/distcc /root/distcc/cc
ENV PATH=/root/distcc/:$PATH
ENV DISTCC_HOSTS="localhost"

RUN yum install -y ccache
RUN mkdir -p /root/.ccache
ENV USE_CCACHE=1
ENV CCACHE_DIR=/root/.ccache
RUN ccache --max-size=5
ENV PATH=/usr/lib64/ccache:$PATH
RUN ccache -s

RUN rpmdev-setuptree
RUN yumdownloader --source kernel
RUN rpm -ivh kernel-*.src.rpm
RUN yum-builddep -y /root/rpmbuild/SPECS/kernel.spec
RUN time rpmbuild -ba --clean --with baseonly --without debug /root/rpmbuild/SPECS/kernel.spec
RUN ccache -s

CMD bash

# distcc build example
#RUN echo '%_topdir %(echo $HOME)/rpmbuild' > /root/.rpmmacros
#RUN echo '%_smp_mflags %( echo "-j$RPM_BUILD_NCPUS"; )' >> /root/.rpmmacros
#ENV RPM_BUILD_NCPUS=20
#ENV DISTCC_HOSTS="example.com/20 localhost"
#COPY apply-patch.sh .
#RUN apply-patch.sh
#RUN time rpmbuild -ba --with baseonly --without debug --without debuginfo /root/rpmbuild/SPECS/kernel.spec
#RUN ccache -s
