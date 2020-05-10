import os
import odooly
import time
import sys

try:
    odoo_host = 'http://localhost:8069'
    odoo_user = 'admin'
    odoo_def_pwd = 'admin'
    odoo_new_pwd = os.environ['ODOO_ADMIN_PWD']
    odoo_db = os.environ['POSTGRES_DB']
    *modules_list, = os.environ['AUTOINSTALL_MODULES'].split(',')

except KeyError as ke:
    print("Odooly Error: Please set the environment variable of odooly", ke)
    sys.exit(1)

start_time = time.time()
error = ''
client = ''


def get_client(init_password, new_password):
    client = False
    try:
        client = odooly.Client(odoo_host, db=odoo_db,
                               user=odoo_user, password=init_password)
    except:
        try:
            client = odooly.Client(odoo_host, db=odoo_db,
                                   user=odoo_user, password=new_password)
        except (Exception, odooly.Error) as e:
            print('Odooly Error: password is wrong',str(e))
    return client


while (time.time() - start_time) < 10:
    try:
        client = get_client(init_password=odoo_def_pwd,
                            new_password=odoo_new_pwd)
        client.env.install(*modules_list)
        client.env['res.users'].search([('login', '=', odoo_user)]).write({
            'password': odoo_new_pwd})
        break
    except (Exception, odooly.Error) as e:
        error = e
        if "Invalid username or password" in str(error):
            odoo_def_pwd = odoo_new_pwd

        if "Module(s) not found" in str(error):
            client.env['res.users'].search([('login', '=', odoo_user)]).write({
                'password': odoo_new_pwd})
            break
        time.sleep(1)

if error:
    print("Odooly Error: ", error)
    sys.exit(1)
