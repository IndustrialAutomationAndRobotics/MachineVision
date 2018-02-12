import psycopg2

try:
    conn = psycopg2.connect("dbname='ESLAB' user='pi' host='192.168.1.108' password='1234'")
except:
    print("I am unable to connect ot the database")

cur = conn.cursor()

cur.execute('''SELECT sum("Student"."DeptID") FROM "Student","Department" WHERE "Student"."DeptID" = "Department"."ID" group by "Department"."ID"''')

rows = cur.fetchall()

print("Show me the database:")
print()
for row in rows:

    data = ""

    for r in row:
        data = data + "   " + str(r)
    
    print(data)