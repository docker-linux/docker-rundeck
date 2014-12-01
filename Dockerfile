FROM ubuntu:14.04
MAINTAINER Tom Eklöf
ENV DEBIAN_FRONTEND noninteractive

# Download Rundeck
ADD http://dl.bintray.com/rundeck/rundeck-deb/rundeck-2.3.2-1-GA.deb /tmp/rundeck.deb

ADD ./.ssh/ /var/lib/rundeck/.ssh/

# Add projects
ADD ./projects/ /var/rundeck/projects/

# Add supervisord services
ADD ./supervisor /etc/supervisor
# Add rundeck to sudoers
ADD ./sudoers.d/ /etc/sudoers.d/
# Add files to cron.d
ADD ./cron.d/ /etc/cron.d/
# Add the install commands
ADD ./install.sh /
# Add job definition file
ADD ./jobs.xml /tmp/jobs.xml

# Change Rundeck admin from default to CH4NGE_Me
ENV RDPASS CH4NGE_Me

# Change MYHOST to your IP or hostname
ENV MYHOST 127.0.0.1

EXPOSE 4440 22

# Run the installation script
RUN /install.sh

# Start the services with supervisord
CMD ["/usr/bin/supervisord", "--nodaemon"]

