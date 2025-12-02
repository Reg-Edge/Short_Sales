CREATE TABLE sales (
    sale_id        INT PRIMARY KEY,      
    customer_id    INT NOT NULL,         
    product_id     INT NOT NULL,        
    quantity       INT NOT NULL,
    unit_price     DECIMAL(10, 2) NOT NULL,
    sale_date      DATE NOT NULL,
    created_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);