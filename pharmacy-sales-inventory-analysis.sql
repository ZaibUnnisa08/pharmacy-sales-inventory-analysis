CREATE DATABASE IF NOT EXISTS pharmacy_analysis;
USE pharmacy_analysis;
SELECT DATABASE();
USE pharmacy_analysis;

CREATE TABLE medicines (
    medicine_id INT PRIMARY KEY,
    medicine_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    unit_price DECIMAL(10,2),
    stock_quantity INT,
    reorder_level INT,
    expiry_date DATE
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY,
    sale_date DATE,
    payment_method VARCHAR(30)
);

CREATE TABLE sale_items (
    sale_item_id INT PRIMARY KEY,
    sale_id INT,
    medicine_id INT,
    quantity INT,
    selling_price DECIMAL(10,2),
    FOREIGN KEY (sale_id) REFERENCES sales(sale_id),
    FOREIGN KEY (medicine_id) REFERENCES medicines(medicine_id)
);
INSERT INTO medicines VALUES
(1, 'Paracetamol 500mg', 'Analgesic', 2.00, 200, 50, '2027-06-30'),
(2, 'Amoxicillin 500mg', 'Antibiotic', 8.00, 35, 40, '2027-03-31'),
(3, 'Cetirizine 10mg', 'Antihistamine', 3.00, 120, 30, '2027-08-31'),
(4, 'Omeprazole 20mg', 'Gastrointestinal', 5.00, 25, 30, '2027-02-28'),
(5, 'Vitamin C 500mg', 'Supplement', 4.00, 150, 40, '2028-01-31'),
(6, 'Metformin 500mg', 'Antidiabetic', 3.00, 80, 30, '2027-10-31'),
(7, 'Ibuprofen 400mg', 'Analgesic', 4.00, 20, 25, '2027-05-31'),
(8, 'ORS Sachet', 'Rehydration', 10.00, 90, 25, '2027-04-30'),
(9, 'Antacid Tablets', 'Gastrointestinal', 2.50, 15, 30, '2027-01-31'),
(10, 'Multivitamin', 'Supplement', 6.00, 60, 20, '2028-03-31'),
(11, 'Cough Syrup', 'Cough and Cold', 75.00, 18, 20, '2027-07-31'),
(12, 'Saline Nasal Spray', 'Cough and Cold', 55.00, 45, 15, '2028-02-29');

INSERT INTO sales VALUES
(101, '2026-01-05', 'Cash'),
(102, '2026-01-08', 'UPI'),
(103, '2026-01-12', 'Card'),
(104, '2026-02-02', 'UPI'),
(105, '2026-02-10', 'Cash'),
(106, '2026-02-18', 'Card'),
(107, '2026-03-03', 'UPI'),
(108, '2026-03-11', 'Cash'),
(109, '2026-03-20', 'UPI'),
(110, '2026-04-04', 'Card'),
(111, '2026-04-15', 'UPI'),
(112, '2026-04-25', 'Cash');

INSERT INTO sale_items VALUES
(1, 101, 1, 10, 2.00),
(2, 101, 3, 5, 3.00),
(3, 102, 2, 4, 8.00),
(4, 102, 5, 6, 4.00),
(5, 103, 4, 3, 5.00),
(6, 103, 6, 10, 3.00),
(7, 104, 1, 15, 2.00),
(8, 104, 8, 5, 10.00),
(9, 105, 7, 8, 4.00),
(10, 105, 9, 4, 2.50),
(11, 106, 10, 5, 6.00),
(12, 106, 11, 2, 75.00),
(13, 107, 1, 20, 2.00),
(14, 107, 2, 6, 8.00),
(15, 108, 3, 10, 3.00),
(16, 108, 5, 8, 4.00),
(17, 109, 6, 12, 3.00),
(18, 109, 8, 4, 10.00),
(19, 110, 4, 6, 5.00),
(20, 110, 7, 10, 4.00),
(21, 111, 10, 7, 6.00),
(22, 111, 12, 3, 55.00),
(23, 112, 1, 12, 2.00),
(24, 112, 11, 3, 75.00);

SELECT * FROM medicines;
SELECT * FROM sales;
SELECT * FROM sale_items;

SELECT * FROM medicines;
SELECT
    medicine_name,
    stock_quantity,
    reorder_level
FROM medicines
WHERE stock_quantity <= reorder_level;

SELECT
    medicine_name,
    unit_price
FROM medicines
ORDER BY unit_price DESC
LIMIT 5;

SELECT
    category,
    COUNT(*) AS medicine_count
FROM medicines
GROUP BY category
ORDER BY medicine_count DESC;

SELECT
    ROUND(SUM(quantity * selling_price), 2)
        AS total_revenue
FROM sale_items;

SELECT
    m.medicine_name,
    SUM(si.quantity) AS total_units_sold
FROM medicines m
JOIN sale_items si
    ON m.medicine_id = si.medicine_id
GROUP BY m.medicine_id, m.medicine_name
ORDER BY total_units_sold DESC;

SELECT
    m.category,
    ROUND(
        SUM(si.quantity * si.selling_price), 2
    ) AS category_revenue
FROM medicines m
JOIN sale_items si
    ON m.medicine_id = si.medicine_id
GROUP BY m.category
ORDER BY category_revenue DESC;

SELECT
    ROUND(
        SUM(unit_price * stock_quantity), 2
    ) AS total_inventory_value
FROM medicines;

SELECT
    medicine_name,
    expiry_date,
    DATEDIFF(expiry_date, CURDATE())
        AS days_until_expiry
FROM medicines
WHERE expiry_date >= CURDATE()
  AND expiry_date <= DATE_ADD(CURDATE(), INTERVAL 6 MONTH)
ORDER BY expiry_date;


SELECT
    medicine_name,
    expiry_date
FROM medicines
WHERE expiry_date < CURDATE();

SELECT
    medicine_name,
    stock_quantity,
    reorder_level,
    CASE
        WHEN stock_quantity <= reorder_level
            THEN 'Low Stock'
        WHEN stock_quantity >= reorder_level * 3
            THEN 'High Stock'
        ELSE 'Normal Stock'
    END AS stock_status
FROM medicines
ORDER BY stock_quantity;

SELECT
    s.payment_method,
    COUNT(DISTINCT s.sale_id) AS transaction_count,
    ROUND(
        SUM(si.quantity * si.selling_price), 2
    ) AS total_revenue
FROM sales s
JOIN sale_items si
    ON s.sale_id = si.sale_id
GROUP BY s.payment_method
ORDER BY total_revenue DESC;

SELECT *
FROM medicines
WHERE unit_price < 0
   OR stock_quantity < 0;
   
   -- Monthly Sales Performance Analysis

SELECT
    DATE_FORMAT(s.sale_date, '%Y-%m') AS sales_month,
    ROUND(
        SUM(si.quantity * si.selling_price), 2
    ) AS monthly_revenue
FROM sales s
JOIN sale_items si
    ON s.sale_id = si.sale_id
GROUP BY DATE_FORMAT(s.sale_date, '%Y-%m')
ORDER BY sales_month;

-- Top 5 Medicines by Revenue

SELECT
    m.medicine_name,
    SUM(si.quantity) AS total_units_sold,
    ROUND(
        SUM(si.quantity * si.selling_price), 2
    ) AS total_revenue
FROM medicines m
JOIN sale_items si
    ON m.medicine_id = si.medicine_id
GROUP BY m.medicine_id, m.medicine_name
ORDER BY total_revenue DESC
LIMIT 5;

-- Monthly Transaction Analysis

SELECT
    DATE_FORMAT(s.sale_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT s.sale_id) AS total_transactions,
    ROUND(
        SUM(si.quantity * si.selling_price), 2
    ) AS total_revenue
FROM sales s
JOIN sale_items si
    ON s.sale_id = si.sale_id
GROUP BY DATE_FORMAT(s.sale_date, '%Y-%m')
ORDER BY sales_month;