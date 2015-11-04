FROM        hasufell/gentoo-amd64-paludis:latest
MAINTAINER  Julian Ospald <hasufell@gentoo.org>


##### PACKAGE INSTALLATION #####

# copy paludis config
COPY ./config/paludis /etc/paludis

# clone our php overlay
RUN git clone --depth=1 https://github.com/hasufell/php-overlay.git \
	/var/db/paludis/repositories/php-overlay && chgrp paludisbuild /dev/tty \
	&& cave sync php-overlay

# fetch jobs
RUN chgrp paludisbuild /dev/tty && cave resolve -c world -x -f
RUN chgrp paludisbuild /dev/tty && cave resolve -c tools -x -1 -f
RUN chgrp paludisbuild /dev/tty && cave resolve -c php -x -1 -f

# install jobs
RUN chgrp paludisbuild /dev/tty && cave resolve -c world -x
RUN chgrp paludisbuild /dev/tty && cave resolve -c tools -x
RUN chgrp paludisbuild /dev/tty && cave resolve -c php -x

# # update etc files... hope this doesn't screw up
RUN etc-update --automode -5

# ################################


# supervisor config
COPY ./config/supervisord.conf /etc/supervisord.conf

# allow easy config file additions to php-fpm.conf
RUN mkdir /etc/php/fpm-php5.6/fpm.d/ && \
	echo "include=/etc/php/fpm-php5.6/fpm.d/*.conf" \
	>> /etc/php/fpm-php5.6/php-fpm.conf

# create common group to be able to synchronize permissions to shared data volumes
RUN groupadd -g 777 www

EXPOSE 9000

CMD exec /usr/bin/supervisord -n -c /etc/supervisord.conf
