require 'benchmark'
require 'pg'

# Define connection parameters
DB_PARAMS = {
  host: 'localhost',     # or your DB host
  port: 5432,            # default port for PostgreSQL
  dbname: 'main_db',     # name of your database
  user: 'postgres',      # your DB username
  password: 'postgres'   # your DB password
}

def fill_with_data
  puts "Filling with data..."

  connection = PG.connect(DB_PARAMS)

  puts Benchmark.measure {
    1000000.times do |i|
      # Insert data into the books table
      insert_query = "
        INSERT INTO books (category_id, author, title, year)
        VALUES ($1, $2, $3, $4)
      "
      category_id = rand(1..4)
      year = rand(1900..2025)

      data = [category_id, "Author #{i}", "Book Title #{i}", 2023]

      # Execute the insert query
      connection.exec_params(insert_query, data)
    end
    puts "Data inserted successfully."
  }
end

def read_data
  puts "Reading data..."

  connection = PG.connect(DB_PARAMS)

  puts Benchmark.measure {
    100000.times do |i|
      # Select data from the books table
      select_query = "
        SELECT * FROM books WHERE id = #{rand(1..1000000)}
      "

      # Execute the select query
      puts "Data read successfully. #{i}"
      result = connection.exec(select_query)
    end
  }
end

fill_with_data
# read_data