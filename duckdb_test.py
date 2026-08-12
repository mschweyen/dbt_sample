import duckdb

print(duckdb.__version__)

connection = duckdb.connect()
print(connection.query("select 1 as col_a"))
connection.close()

