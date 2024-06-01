# PSQL DB Sharding

This project is a proof of concept for sharding in PostgreSQL database. The project is divided into 3 parts:

# FDW approach to sharding in PostgreSQL database (Foreign Data Wrapper)

Foreign Data Wrapper (FDW) is a feature in PostgreSQL that allows you to access data stored in external databases as if it were in a table within your PostgreSQL database. This feature is part of PostgreSQL's Foreign Data Wrapper interface, which provides a way to connect to different types of data sources, enabling seamless querying and manipulation of remote data.

```
cd fdw
chmod +x build.sh
```

# Sharding using CitusDB

Citus is an open-source extension to Postgres that transforms Postgres into a distributed database. 
It extends Postgres to store and index data across multiple nodes, and parallelizes queries across these nodes. 
Citus is available as open source and in a fully-managed database as a service.

```
cd citus
chmod +x init-master.sh
chmod +x build.sh
```

# No sharding
```
cd no_sharding
chmod +x build.sh
```


# Test result for write and read of a 1 million records
|             | Write       | Read (10000) | Read(100000) | 
|-------------|-------------|--------------|--------------|
| FDW         | 193.438657s | 87.777397s   | 883.200520s  | 
| Citus       | 469.178608  | 3.713542     | 35.252529    |
| No sharding | 181.079341  | 1.282043     | 11.026025    |

