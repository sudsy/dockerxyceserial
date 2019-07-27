FROM amazonlinux:1 as xycebuilddeps

LABEL maintainer="sudsy"

RUN yum -y update
RUN yum install -y software-properties-common wget

RUN yum -y upgrade

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y epel-release yum-utils
RUN yum-config-manager --enable epel
RUN yum-config-manager --add-repo https://yum.repos.intel.com/mkl/setup/intel-mkl.repo
RUN yum groupinstall -y "Development Tools"
RUN yum install -y lapack-devel hdf5-devel graphviz cmake suitesparse-devel netcdf-devel fftw-devel


