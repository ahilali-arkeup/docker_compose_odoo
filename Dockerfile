FROM debian:10
MAINTAINER Odoo S.A. <info@odoo.com>


# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl \
            node-less \
            node-clean-css \
            python-pyinotify \
            python-renderpm \
        && curl -o wkhtmltox.deb -SL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.1/wkhtmltox-0.12.1_linux-wheezy-amd64.deb \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

ENV ODOO_VERSION 8.0
ENV ODOO_RELEASE 20171001
RUN set -x; \
        curl -o odoo.deb -SL http://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
				&& echo '133d49bc8ea7751752b3761e02e638d8451dfbc4 odoo.deb' | sha1sum -c - \
        && dpkg --force-depends -i odoo.deb \
        && apt-get update \
        && apt-get -y install -f --no-install-recommends \
        && rm -rf /var/lib/apt/lists/* odoo.deb

COPY ./entrypoint.sh /
COPY ./config/openerp-server.conf /etc/odoo/
RUN chown odoo /etc/odoo/openerp-server.conf

RUN mkdir -p /mnt/extra-addons \
        && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

EXPOSE 8069 8071

ENV OPENERP_SERVER /etc/odoo/openerp-server.conf

USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["openerp-server"]
