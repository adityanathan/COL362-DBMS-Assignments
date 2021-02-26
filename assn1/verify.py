import psycopg2, pandas as pd
connection = psycopg2.connect(
    host="localhost",
    database="postgres",
    user="postgres",
    password="nate"
)

with open("query.sql") as f:
    contents = f.read()
    queries = contents.split(';')

queries = queries[:min(22,len(queries))]
dfs = []
dfs.append([])####1-based indexing for query
for query in queries:
    d = pd.read_sql_query(query,connection)
    dfs.append(d)

for i in range(1,len(queries)+1):
    dfs[i].to_csv("Results/{}.csv".format(i),index=False)

connection.close()
