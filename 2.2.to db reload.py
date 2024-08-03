import psycopg2
import logging



logging.basicConfig(
    level=logging.DEBUG, 
    filename = 'log_test.log', 
    format = '%(asctime)s - %(module)s - %(levelname)s - %(message)s', 
    datefmt='%H/%M/%S',
    )

host = 'localhost'
user = 'postgres'
password = '758325'
db_name = 'dwh'
options = '-c search_path=rd,public,dm'

try:
  # connect to exist database
    connection = psycopg2.connect(host=host,
                                user=user,
                                password=password,
                                database=db_name,
                                options=options)
  
    connection.autocommit = True
    print('connect')
    logging.info(connection.commit())
    
    with connection.cursor() as cursor:
         with open (r'C:\Users\nbelovolova\Desktop\Проект\project2\data\loan_holiday_info\deal_info.csv', encoding='utf-8-sig') as file:
             next(file)
             cursor.copy_from(file, 'deal_info_2', sep=',')
         with open (r'C:\Users\nbelovolova\Desktop\Проект\project2\data\loan_holiday_info\product_info.csv', encoding='utf-8-sig') as file:
             next(file)
             cursor.copy_from(file, 'product_2', sep=',')
             
             
    logging.info(connection.commit())
except:
    print('Can`t establish connection to database')
    
    
with open('log_test.log') as file:
    file = file.read()
    print(file)