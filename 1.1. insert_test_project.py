import psycopg2
import logging
import time


logging.basicConfig(
    level=logging.DEBUG, 
    filename = 'log_test.log', 
    format = '%(asctime)s - %(module)s - %(levelname)s - %(message)s', 
    datefmt='%H/%M/%S',
    )

host = 'localhost'
user = 'postgres'
password = '758325Nt'
db_name = 'project'
options = '-c search_path=ds,public'
try:
  # connect to exist database
  connection = psycopg2.connect(host=host,
                                user=user,
                                password=password,
                                database=db_name,
                                options=options)
  
  connection.autocommit = True
  
  logging.info('Loading started')
  time.sleep(5)

  with connection.cursor() as cursor:
       with open (r'C:\Users\Ирина\Desktop\Проект\файлы\ft_balance_f.csv', encoding='utf-8-sig') as file:
           next(file)
           cursor.copy_from(file, 'ft_balance_f', sep=';')
       with open (r'C:\Users\Ирина\Desktop\Проект\файлы\ft_posting_f.csv', encoding='utf-8-sig') as file:
           next(file)
           cursor.copy_from(file, 'ft_posting_f', sep=';')
       with open (r'C:\Users\Ирина\Desktop\Проект\файлы\md_account_d.csv', encoding='utf-8-sig') as file:
           next(file)
           cursor.copy_from(file, 'md_account_d', sep=';')
       with open (r'C:\Users\Ирина\Desktop\Проект\файлы\md_currency_d.csv', encoding='cp1252') as file:
           next(file)
           cursor.copy_from(file, 'md_currency_d', sep=';')     
       with open (r'C:\Users\Ирина\Desktop\Проект\файлы\md_ledger_account_s.csv', encoding='utf-8-sig') as file:
           next(file)
           cursor.copy_from(file, 'md_ledger_account_s', sep=';')

          
  with connection.cursor() as cursor:
      cursor.execute('CREATE TEMP TABLE temp_table AS TABLE md_exchange_rate_d')
      with open (r'C:\Users\Ирина\Desktop\Проект\файлы\md_exchange_rate_d.csv', encoding='utf-8-sig') as file:
           next(file)
           cursor.copy_from(file, 'temp_table', sep=';')
      cursor.execute('''INSERT INTO md_exchange_rate_d 
                        SELECT * FROM temp_table
                        ON CONFLICT DO NOTHING''')
                                
                                
  logging.info(connection.commit())
  logging.info(print('Insert created successfully'))

except Exception as ex:
  logging.info(f'{ex} - while working with postgreSQL')

finally:
  if connection:
    connection.close()
    logging.info('Connection is closed')
    
with open('log_test.log') as file:
    file = file.read()
    print(file)


   

