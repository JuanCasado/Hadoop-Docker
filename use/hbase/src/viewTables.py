
import happybase as hbase

def getTables (connection):
  tables = connection.tables()
  return [connection.table(table_name) for table_name in tables], tables

def getRows (table):
  families = [key for key in table.families().keys()]
  return table.rows(families)


if __name__ == '__main__':
  connection = hbase.Connection('localhost')
  tables, table_names = getTables(connection)
  for table, name in zip (tables, table_names):
    print(name)
    for key, data in table.scan():
      print(key, data)
  
