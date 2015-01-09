FROM ubuntu
MAINTAINER Luc

ENV DEBIAN_FRONTEND noninteractive

#
# Install wine1.7 and a few tools
#
RUN dpkg --add-architecture i386

RUN apt-get update && apt-get install -y -q software-properties-common
RUN add-apt-repository ppa:ubuntu-wine/ppa -y

RUN apt-get update && apt-get install -y -q	\
	gawk					\
	unzip					\
	wine1.7					\
	wget					\
	xvfb

RUN apt-get -y -q clean
RUN apt-get -y -q autoremove


# Again as root since COPY doesn't honor USER
COPY dotnet_setup.sh /tmp/
RUN chmod a+rx /tmp/dotnet_setup.sh
COPY captvty-2.3.4.zip /tmp/captvty.zip
RUN chmod a+r /tmp/captvty.zip

#
# Create a user to run Captvty
#
RUN useradd --home-dir /home/luser --create-home -K UID_MIN=42000 luser
USER luser
RUN echo "quiet=on" > ~/.wgetrc

WORKDIR /tmp

#
# Install DotNet 4 and some stuff.
# Uses xvfb as a DISPLAY is required.
# Calling each action within a separate xvfb-run makes this fail
# that's why a script is added and then run
#
RUN xvfb-run ./dotnet_setup.sh


#
# Install Captvty
#
RUN mkdir /home/luser/captvty
# RUN wget http://captvty.fr/?captvty-2.3.4.zip -O captvty.zip
# RUN ls -lah /tmp
# RUN sha1sum captvty.zip | awk '$1 != "c76393686877eaa9d159f2815a3ae47adb8a3a13" { print "Bad checksum"; exit 1; }'
RUN unzip ./captvty.zip -d /home/luser/captvty


RUN ls -lah /home/luser /home/luser/captvty

#
# Cleanup /tmp
#
USER root
RUN find /tmp -mindepth 1 -exec rm -rf {} +

USER luser
# ENTRYPOINT wine /home/captvty/Captvty.exe
