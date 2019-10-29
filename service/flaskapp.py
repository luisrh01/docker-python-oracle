# basic API framework for the connectivity that will provide CAC access to contract DB info
# Luis Hernandez
# Updated
# v0.1 - 2019-10-28

# for CMD
#set FLASK_APP=flaskapp
#set FLASK_ENV=development

# for PS
#$env:FLASK_APP = "flaskapp"
#$env:FLASK_ENV="development"
###

from flask import Flask
import sqlite3
from sqlite3 import Error
import json


app = Flask(__name__)
# for Oracle connection to DB
#import cx_Oracle

#dsn_tns = cx_Oracle.makedsn('Host Name', 'Port Number', service_name='Service Name') #if needed, place an 'r' before any parameter in order to address any special character such as '\'.
#conn = cx_Oracle.connect(user=r'User Name', password='Personal Password', dsn=dsn_tns) #if needed, place an 'r' before any parameter in order to address any special character such as '\'. For example, if your user name contains '\', you'll need to place 'r' before the user name: user=r'User Name'

#c = conn.cursor()
#c.execute('select * from database.table') # use triple quotes if you want to spread your query across multiple lines #for row in c:
#    print (row[0], '-', row[1]) # this only shows the first two columns. To add an additional column you'll need to add , '-', row[2], etc.
#conn.close()
# end of Oracle connection to DB

def create_connection(db_file):
    """ create a database connection to the SQLite database
        specified by the db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
    except Error as e:
        print(e)
 
    return conn

def select_all_tasks(conn):
    """
    Query all rows in the tasks table
    :param conn: the Connection object
    :return:
    """
    cur = conn.cursor()
    cur.execute("SELECT * FROM employees")
    rows = cur.fetchall()
    python2json = json.dumps(rows)
 #   print(python2json)
    return python2json
 #   for row in rows:
 #       print(row)

@app.route('/')
def hello():
    # just a 
    return '<h1>Lets get rockin Luis</h1>'

@app.route('/api/v1/getdata', methods=['GET'])
def getdata():
    # connect to DB and get table 1
    # return results as json    
    database = r"pythonsqlite.db"
    conn = create_connection(database)
#   select_all_tasks(conn)
#   return '<h1>Pickup the data</h1>'
    return(select_all_tasks(conn))

@app.route('/api/v1/getdata2', methods=['GET'])
def getdata2():
    # connect to DB and get table 2
    # return results as json
    database = r"pythonsqlite.db"
    conn = create_connection(database)
    return(select_all_tasks(conn))
#   return '<h1>Pickup the data2</h1>'

# handle 404 requests
@app.errorhandler(404)
def page_not_found(e):
    """Send message to user with notFound 4040."""
    # message creation
    message = { 
        "err":  
            {
                "msg":"This route is currently not supported. Please refer to API documentation."
            }
    }
 
    resp = json.dumps(message)
 #   resp.status_code = 404
    return resp


if __name__ == '__main__':
    app.run(host='0.0.0.0')
