CREATE DATABASE IF NOT EXISTS orders_db;
USE orders_db;

CREATE TABLE orders (
  id INT AUTO_INCREMENT PRIMARY KEY,
  customer_name VARCHAR(255),
  product VARCHAR(255),
  quantity INT,
  order_date DATE
);

INSERT INTO orders (customer_name, product, quantity, order_date) VALUES
('Alice', 'Laptop', 1, '2025-04-01'),
('Bob', 'Smartphone', 2, '2025-04-02'),
('Charlie', 'Tablet', 1, '2025-04-03'),
('Diana', 'Camera', 3, '2025-04-04'),
('Ethan', 'Headphones', 2, '2025-04-05'),
('Fiona', 'Monitor', 1, '2025-04-06'),
('George', 'Keyboard', 4, '2025-04-07'),
('Hannah', 'Mouse', 2, '2025-04-08'),
('Ian', 'Printer', 1, '2025-04-09'),
('Jane', 'Scanner', 1, '2025-04-10');
