
import happybase as hbase

def create_table(connection, name, families):
  families_dict = {family:dict() for family in families}
  connection.create_table(name, families_dict)

def delete_table(connection, name):
  tables = connection.tables()
  for table in tables:
    if name == table:
      connection.delete_table(name, disable=True)

if __name__ == '__main__':
  connection = hbase.Connection('localhost')
  create_table(connection, 'tweets', ['t', 'u', 'e', 'p'])
  create_table(connection, 'mentions', ['f'])
  create_table(connection, 'mentioned', ['f'])
  print(connection.tables())
