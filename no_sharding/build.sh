
docker-compose down -v
docker-compose up -d --build

# Give some time for PostgreSQL containers to start
sleep 15

# Create databases and tables
docker exec -it main_db psql -U postgres -d main_db -c "
CREATE TABLE books (
  id SERIAL PRIMARY KEY,
  category_id INT NOT NULL,
  author VARCHAR NOT NULL,
  title VARCHAR NOT NULL,
  year INT NOT NULL
);
"

echo "Setup completed."

