FROM amazonlinux:2 as buildxyce

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

# Build Trilinos Serial
RUN wget https://github.com/trilinos/Trilinos/archive/trilinos-release-12-12-1.tar.gz
RUN tar -xf trilinos-release-12-12-1.tar.gz
RUN pwd
WORKDIR /Trilinos-trilinos-release-12-12-1
RUN mkdir build
WORKDIR /Trilinos-trilinos-release-12-12-1/build


ENV ARCHDIR=$HOME/XyceLibs/Serial
ENV FLAGS="-O3 -fPIC"

RUN cmake \
-G "Unix Makefiles" \
-DCMAKE_C_COMPILER=gcc \
-DCMAKE_CXX_COMPILER=g++ \
-DCMAKE_Fortran_COMPILER=gfortran \
-DCMAKE_CXX_FLAGS="-O3 -fPIC" \
-DCMAKE_C_FLAGS="-O3 -fPIC" \
-DCMAKE_Fortran_FLAGS="-O3 -fPIC" \
-DCMAKE_INSTALL_PREFIX=$HOME/XyceLibs/Serial \
-DCMAKE_MAKE_PROGRAM="make" \
-DTrilinos_ENABLE_NOX=ON \
  -DNOX_ENABLE_LOCA=ON \
-DTrilinos_ENABLE_EpetraExt=ON \
  -DEpetraExt_BUILD_BTF=ON \
  -DEpetraExt_BUILD_EXPERIMENTAL=ON \
  -DEpetraExt_BUILD_GRAPH_REORDERINGS=ON \
-DTrilinos_ENABLE_TrilinosCouplings=ON \
-DTrilinos_ENABLE_Ifpack=ON \
-DTrilinos_ENABLE_ShyLU=ON \
-DTrilinos_ENABLE_Isorropia=ON \
-DTrilinos_ENABLE_AztecOO=ON \
-DTrilinos_ENABLE_Belos=ON \
-DTrilinos_ENABLE_Teuchos=ON \
  -DTeuchos_ENABLE_COMPLEX=ON \
-DTrilinos_ENABLE_Amesos=ON \
  -DAmesos_ENABLE_KLU=ON \
-DTrilinos_ENABLE_Sacado=ON \
-DTrilinos_ENABLE_Kokkos=OFF \
-DTrilinos_ENABLE_Zoltan=ON \
-DTrilinos_ENABLE_ALL_OPTIONAL_PACKAGES=OFF \
-DTrilinos_ENABLE_CXX11=ON \
-DTPL_ENABLE_AMD=ON \
-DAMD_LIBRARY_DIRS="/usr/include/suitesparse" \
-DTPL_AMD_INCLUDE_DIRS="/usr/include/suitesparse" \
-DTPL_ENABLE_BLAS=ON \
-DTPL_ENABLE_LAPACK=ON \
../

RUN make -j2
RUN make install

#Now Build Xyce

WORKDIR /
RUN git clone -b 'Release-7.5.0' --single-branch --depth 1 https://github.com/Xyce/Xyce.git
WORKDIR /Xyce
RUN ./bootstrap
RUN mkdir build
WORKDIR /Xyce/build


RUN ../configure \
ARCHDIR=$HOME/XyceLibs/Serial \
--disable-adms_sensitivities \
LDFLAGS="-Wl,-rpath,../lib" \
CXXFLAGS="-O3 -std=c++11" \
CPPFLAGS="-I/usr/include/suitesparse" \
CC=/usr/bin/gcc \
CXX=/usr/bin/g++ \
F77=/usr/bin/gfortran \
--prefix=/usr/local/bin/xyce-serial

RUN make -j2
RUN make install


RUN cp /usr/lib64/libfftw3.so.3 /usr/local/bin/xyce-serial/lib
RUN cp /usr/lib64/libamd.so.2 /usr/local/bin/xyce-serial/lib
RUN cp /usr/lib64/liblapack.so.3 /usr/local/bin/xyce-serial/lib
RUN cp /usr/lib64/libblas.so.3 /usr/local/bin/xyce-serial/lib
RUN cp /usr/lib64/libgfortran.so.3 /usr/local/bin/xyce-serial/lib
RUN cp /usr/lib64/libquadmath.so.0 /usr/local/bin/xyce-serial/lib


FROM amazonlinux:2 as deploy
COPY --from=buildxyce /usr/local/bin/xyce-serial /usr/local/bin/xyce-serial
WORKDIR /usr/local/bin/xyce-serial/bin
ENTRYPOINT ["/usr/local/bin/xyce-serial/bin/Xyce"]