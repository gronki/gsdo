FROM ubuntu:26.04
RUN apt-get update && \
	apt-get install -y --no-install-recommends \
	ca-certificates ftp curl tcsh gnudatalanguage \
	&& apt-get install -y --no-install-recommends xvfb \
	&& rm -rf /var/lib/apt/lists/*

RUN cd /usr/bin && ln -s gdl idl
ENV IDL_DIR=/usr
ENV SSW=/opt/ssw
ENV HOME=/tmp

COPY docker/install_ssw.csh .
RUN /bin/tcsh install_ssw.csh

RUN sed -i '/reads,vstr(ss),tempx/ { s/.*/      catch, err \& if err eq 0 then reads,vstr(ss),tempx else goto, skip \& catch, \/cancel/ }' /opt/ssw/gen/idl/fits/mreadfits_header.pro
RUN sed -i 's/mreadfits_shm/mreadfits/g' /opt/ssw/vobs/ontology/idl/jsoc/mreadfits_tilecomp.pro
ENV SHELL="/bin/tcsh"
ENV IDL_PATH="/usr/share/gnudatalanguage/lib"

COPY docker/start.csh .

ENTRYPOINT [ "/bin/tcsh", "/start.csh"]
