

#Now Build Xyce
FROM sudsy/xyceserial:amzn1-trilinos as buildxyce

RUN git clone -b 'Release-6.11.1' --single-branch --depth 1 https://github.com/Xyce/Xyce.git
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


FROM amazonlinux:1 as deploy
COPY --from=buildxyce /usr/local/bin/xyce-serial /usr/local/bin/xyce-serial
WORKDIR /usr/local/bin/xyce-serial/bin
ENTRYPOINT ["/usr/local/bin/xyce-serial/bin/Xyce"]