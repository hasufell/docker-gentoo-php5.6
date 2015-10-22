FROM        hasufell/gentoo-amd64-paludis:20150820
MAINTAINER  Julian Ospald <hasufell@gentoo.org>

# global USE flags
RUN echo -e "*/* acl bash-completion ipv6 kmod openrc pcre readline unicode \
zlib pam ssl sasl bzip2 urandom crypt tcpd \
-acpi -cairo -consolekit -cups -dbus -dri -gnome -gnutls -gtk -gtk2 -gtk3 \
-ogg -opengl -pdf -policykit -qt3support -qt5 -qt4 -sdl -sound -systemd \
-truetype -vim -vim-syntax -wayland -X \
\n \
\n*/* PHP_TARGETS: -* php5-6 \
" \
	>> /etc/paludis/use.conf

# update world with our USE flags
RUN chgrp paludisbuild /dev/tty && cave resolve -c world -x

# per-package USE flags
# check these with "cave show <package-name>"
RUN mkdir /etc/paludis/use.conf.d && echo -e "\
\ndev-lang/php:5.6 cgi cli curl exif fpm gd gmp imap mysql mysqli zip \
\napp-eselect/eselect-php fpm \
" \
	>> /etc/paludis/use.conf.d/php.conf

# install php
RUN chgrp paludisbuild /dev/tty && cave resolve -z dev-lang/php:5.6 -x

# install tools
RUN chgrp paludisbuild /dev/tty && cave resolve -z app-admin/supervisor sys-process/htop -x

# update etc files... hope this doesn't screw up
RUN etc-update --automode -5

# supervisor config
COPY ./supervisord.conf /etc/supervisord.conf

# allow easy config file additions to php-fpm.conf
RUN mkdir /etc/php/fpm-php5.6/fpm.d/ && \
	echo "include=/etc/php/fpm-php5.6/fpm.d/*.conf" \
	>> /etc/php/fpm-php5.6/php-fpm.conf

# create common group to be able to synchronize permissions to shared data volumes
RUN groupadd -g 777 www

EXPOSE 9000

CMD exec /usr/bin/supervisord -n -c /etc/supervisord.conf
