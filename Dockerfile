
FROM genral73/helm-odoo-base-img:11

ARG ODOO_USER=odoo
ARG ODOO_HOME=/home/$ODOO_USER
ARG ODOO_SERVER_DIR=$ODOO_HOME/server

COPY auto_install_modules.py /

COPY odoo-server.conf /etc/
RUN chown odoo /etc/odoo-server.conf
ENV ODOO_CONF /etc/odoo-server.conf

COPY entrypoint.sh /
RUN chown odoo /entrypoint.sh \
     && chmod +x /entrypoint.sh

EXPOSE 8069 8072
RUN ln -s $ODOO_SERVER_DIR/odoo-bin /usr/bin/odoo

COPY ./custom-addons ${ODOO_HOME}/custom-addons
RUN chown -R odoo:odoo ${ODOO_HOME}/custom-addons \
      && chmod 777 -R ${ODOO_HOME}/custom-addons

RUN pip3 install --no-cache-dir -r ${ODOO_HOME}/custom-addons/requirements.txt

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]