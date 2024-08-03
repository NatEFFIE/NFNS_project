import psycopg2
import logging
import datetime
import pandas as pd

logging.basicConfig(
    level=logging.DEBUG, 
    filename = 'log_test.log', 
    format = '%(asctime)s - %(module)s - %(levelname)s - %(message)s', 
    datefmt='%H/%M/%S',
    )

host = 'localhost'
user = 'postgres'
password = '758325'
db_name = 'postgres'
options = '-c search_path=ds,public'
try:
  # connect to exist database
  connection = psycopg2.connect(host=host,
                                user=user,
                                password=password,
                                database=db_name,
                                options=options)
  connection.autocommit = True
  
  with connection.cursor() as cursor:
      
      cursor.execute('select * from dm.dm_f101_round_f')
      records = cursor.fetchall()
      
      logging.info(records)
      
except:
    logging.info('no connection')




from_date = []
to_date = []
chapter = []
ledger_account = []
characteristic = []
balance_in_rub = []
balance_in_val = []
balance_in_total = []
turn_deb_rub = []
turn_deb_val = []
turn_deb_total = []
turn_cre_rub = []
turn_cre_val = []
turn_cre_total = []
balance_out_rub = []
balance_out_val = []
balance_out_total = []


for r in records:
    from_date.append(r[0])
    to_date.append(r[1])
    chapter.append(r[2])
    ledger_account.append(r[3])
    characteristic.append(r[4])
    balance_in_rub.append(float(r[5]) if r[5] is not None else 0)
    balance_in_val.append(float(r[6]) if r[6] is not None else 0)
    balance_in_total.append(float(r[7]))
    turn_deb_rub.append(float(r[8]) if r[8] is not None else 0)
    turn_deb_val.append(float(r[9]))
    turn_deb_total.append(float(r[10]) if r[10] is not None else 0)
    turn_cre_rub.append(float(r[11]) if r[11] is not None else 0)
    turn_cre_val.append(float(r[12]))
    turn_cre_total.append(float(r[13]) if r[13] is not None else 0)
    balance_out_rub.append(float(r[14]))
    balance_out_val.append(float(r[15]))
    balance_out_total.append(float(r[16])) 
    
    
f101 = pd.DataFrame({'from_date': from_date,
                     'to_date': to_date,
                     'chapter': chapter,
                     'ledger_account': ledger_account,
                     'characteristic': characteristic,
                     'balance_in_rub': balance_in_rub,
                     'balance_in_val': balance_in_val,
                     'balance_in_total': balance_in_total,
                     'turn_deb_rub': turn_deb_rub,
                     'turn_deb_val': turn_deb_val,
                     'turn_deb_total': turn_deb_total,
                     'turn_cre_rub': turn_cre_rub,
                     'turn_cre_val': turn_cre_val,
                     'turn_cre_total': turn_cre_total,
                     'balance_out_rub': balance_out_rub,
                     'balance_out_val': balance_out_val,
                     'balance_out_total': balance_out_total})

logging.info('f101 successfully downloaded')

f101.to_csv('f101.csv', sep=';', encoding='utf-8-sig')
