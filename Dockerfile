FROM ubuntu:16.04
MAINTAINER Sergio Gómez <sergio@quaip.com>

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl \
    && ln -sf /bin/true /sbin/initctl \
    && echo 'Acquire::http { Proxy "http://172.17.0.1:3142"; };' >> /etc/apt/apt.conf.d/01proxy

# Let the container know that there is no tty
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y upgrade \
    && apt-get -y install mysql-server mysql-client pwgen python-setuptools curl git unzip \
    && apt-get -y install apache2 php7.0 php7.0-gd libapache2-mod-php7.0 postfix wget supervisor \
       php7.0-pgsql vim curl libcurl3 libcurl3-dev php7.0-xml php7.0-curl php7.0-zip php7.0-mbstring php7.0-soap php7.0-xmlrpc php7.0-intl php7.0-mysql \
    && apt-get -y install openssh-server \
    && mkdir -p /var/run/sshd \
    && sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf \
    && easy_install supervisor

ADD ./start.sh /start.sh
ADD ./foreground.sh /etc/apache2/foreground.sh
ADD ./supervisord.conf /etc/supervisord.conf

COPY moodle-latest.tgz /var/www/moodle-latest.tgz
# ADD https://download.moodle.org/moodle/moodle-latest.tgz /var/www/moodle-latest.tgz
RUN cd /var/www; tar zxvf moodle-latest.tgz; mv /var/www/moodle /var/www/html \
    && chown -R www-data:www-data /var/www/html/moodle \
    && mkdir /var/moodledata \
    && chown -R www-data:www-data /var/moodledata; chmod 777 /var/moodledata \
    && chmod 755 /start.sh /etc/apache2/foreground.sh

EXPOSE 22 80
CMD ["/bin/bash", "/start.sh"]
