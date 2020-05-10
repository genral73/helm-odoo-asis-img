#!/bin/bash

set -e

function fill_config() {
    OldStr=$1
    NewStr=$2
    OrgFile=$3
    if [ -e "$OrgFile" ]; then
        cp -arf  $OrgFile /tmp/TempFile.conf
        sed -i "s/$OldStr/$NewStr/g" /tmp/TempFile.conf
        cp -ar /tmp/TempFile.conf $OrgFile
        rm -rf /tmp/TempFile.conf    
    fi
}
#------------------------------ Database Parameters --------------------------------
fill_config ';db_host = localhost' 'db_host = '$POSTGRES_HOST $ODOO_CONF
fill_config ';db_port = 5432' 'db_port = '$POSTGRES_PORT $ODOO_CONF
fill_config ';db_user = db_user' 'db_user = '$POSTGRES_USER $ODOO_CONF
fill_config ';db_password = pwd_user' 'db_password = '$POSTGRES_PASSWORD $ODOO_CONF
fill_config ';db_name = db_name' 'db_name = '$POSTGRES_DB $ODOO_CONF
fill_config ';admin_passwd = admin' 'admin_passwd = '$ODOO_MASTER_PWD_DB $ODOO_CONF
fill_config 'list_db = False' 'list_db = '$ODOO_List_DB $ODOO_CONF


#------------------------------ Redis Parameters -----------------------------------
if [ $REDIS_ENABLE == "True" ] ; then
    fill_config ';enable_redis = Flase' 'enable_redis = True' $ODOO_CONF
    fill_config ';redis_host = localhost' 'redis_host = '$REDIS_HOST $ODOO_CONF
    fill_config ';redis_port = 6379' 'redis_port = '$REDIS_HOST_PORT $ODOO_CONF
    fill_config ';redis_dbindex = 1' 'redis_dbindex = '$REDIS_DBINDEX $ODOO_CONF    
fi

#------------------------------ S3 Storage Parameters -----------------------------------
if [ $S3_PROVIDER != "localhost" ] ; then
    fill_config ';server_wide_modules = web' 'server_wide_modules = web,attachment_s3' $ODOO_CONF
    fill_config "False" "s3" /home/odoo/custom-addons/attachment_s3/data/data.xml
fi

#------------------------------ Openssl Parameters -----------------------------------
fill_config "CipherString = DEFAULT@SECLEVEL=2" "#CipherString = DEFAULT@SECLEVEL=2" /etc/ssl/openssl.cnf


#------------------------------ Company Parameters -----------------------------------
fill_config "Tamkeen Technologies" "$SubCompanyName" /home/odoo/custom-addons/base_backend_theme/data/data.xml
fill_config "0001" "$SubMaxLimitUsers" /home/odoo/custom-addons/user_limits/data/data.xml

#sleep 10 &&  curl http://localhost:8069/web/login  &
sleep 60 &&  python3  auto_install_modules.py &
exec odoo -c $ODOO_CONF

exit 1