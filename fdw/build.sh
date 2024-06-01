
docker-compose down -v
docker-compose up -d --build

# Give some time for PostgreSQL containers to start
sleep 15

# Create databases and tables
docker exec -it main_db psql -U postgres -d main_db -c "
DROP TRIGGER IF EXISTS books_insert_trigger ON books;
DROP TABLE IF EXISTS books CASCADE;

-- Drop foreign tables if they exist
DROP FOREIGN TABLE IF EXISTS books1;
DROP FOREIGN TABLE IF EXISTS books2;

-- Drop foreign servers if they exist
DROP SERVER IF EXISTS shard1 CASCADE;
DROP SERVER IF EXISTS shard2 CASCADE;

CREATE EXTENSION IF NOT EXISTS postgres_fdw;
CREATE SERVER shard1 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'shard1', dbname 'shard1', port '5432');
CREATE SERVER shard2 FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'shard2', dbname 'shard2', port '5432');

CREATE USER MAPPING FOR postgres SERVER shard1 OPTIONS (user 'postgres', password 'postgres');
CREATE USER MAPPING FOR postgres SERVER shard2 OPTIONS (user 'postgres', password 'postgres');

CREATE TABLE books (
  id SERIAL PRIMARY KEY,
  category_id INT NOT NULL,
  author VARCHAR NOT NULL,
  title VARCHAR NOT NULL,
  year INT NOT NULL
);

CREATE TABLE books1 (
  CHECK (category_id = 1)
) INHERITS (books);

CREATE TABLE books2 (
  CHECK (category_id = 2)
) INHERITS (books);

CREATE OR REPLACE FUNCTION redirect_books_insert() RETURNS TRIGGER AS \$$
BEGIN
  IF (NEW.category_id = 1) THEN
    INSERT INTO books1 VALUES (NEW.*);
  ELSIF (NEW.category_id = 2) THEN
    INSERT INTO books2 VALUES (NEW.*);
  ELSE
    RETURN NEW;
  END IF;
  RETURN NULL;
END;
\$\$ LANGUAGE plpgsql;

CREATE TRIGGER books_insert_trigger
  BEFORE INSERT ON books
  FOR EACH ROW
  EXECUTE FUNCTION redirect_books_insert();

SELECT setval(pg_get_serial_sequence('books', 'id'), 1, false);
"

# Initialize shards
docker exec -it shard1 psql -U postgres -d shard1 -c "
DROP TABLE IF EXISTS books1;
CREATE TABLE books1 (
  id SERIAL PRIMARY KEY,
  category_id INT NOT NULL,
  author VARCHAR NOT NULL,
  title VARCHAR NOT NULL,
  year INT NOT NULL
);
SELECT setval(pg_get_serial_sequence('books1', 'id'), 1, false);
"

docker exec -it shard2 psql -U postgres -d shard2 -c "
DROP TABLE IF EXISTS books2;
CREATE TABLE books2 (
  id SERIAL PRIMARY KEY,
  category_id INT NOT NULL,
  author VARCHAR NOT NULL,
  title VARCHAR NOT NULL,
  year INT NOT NULL
);
SELECT setval(pg_get_serial_sequence('books2', 'id'), 1, false);
"

echo "Sharding setup completed."

