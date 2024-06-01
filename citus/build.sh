docker-compose down -v
docker-compose up -d --build

sleep 15

docker exec -it citus_master psql -U postgres -d master_db -c "
SELECT citus_set_coordinator_host('citus_master', 5432);

SELECT * FROM master_add_node('citus_worker1', 5432);
SELECT * FROM master_add_node('citus_worker2', 5432);

CREATE TABLE books (
  id SERIAL PRIMARY KEY,
  category_id INT NOT NULL,
  author VARCHAR(255) NOT NULL,
  title VARCHAR(255) NOT NULL,
  year INT NOT NULL
);

SELECT create_distributed_table('books', 'id');
"



