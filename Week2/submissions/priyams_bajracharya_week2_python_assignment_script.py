import psycopg2
import os 
from dotenv import load_dotenv

load_dotenv()

host=os.getenv("DB_HOST")
port = os.getenv("DB_PORT")
dbname = os.getenv("DB_NAME")
user= os.getenv("DB_USER")
password=os.getenv("DB_PASSWORD")

conn = psycopg2.connect(
  host=host ,port=port , dbname=dbname, user=user , password=password 
)

curr = conn.cursor()


sql = '''
        SELECT d.name , count(*) FROM drivers d
        JOIN trips t ON d.driver_id  = t.driver_id 
        where t.status  = 'completed' 
        GROUP BY d.name 
        ORDER BY count(*) desc;
'''

curr.execute(sql)

  # 4. Fetch and print
rows = curr.fetchall()
for name, count in rows:
    print(f"{name:<25} {count:>10}")

# 5. Close
curr.close() 
conn.close()
