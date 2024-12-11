-- Active: 1733722630182@@127.0.0.1@3306
/*
stores.db
Customers: customer data
customerNumber
Employees: all employee information
employeeNumber
reportsTo -> employeeNumber (self)
Offices: sales office information
officeCode
Orders: customers' sales orders
orderNumber
OrderDetails: sales order line for each sales order
orderNumber, productCode
Payments: customers' payment records
customerNumber, checkNumber
Products: a list of scale model cars
productCode
ProductLines: a list of product line categories
productLine
*/

-- Show table information (number of attributes and number of rows)

SELECT
    'Customers' AS table_name,
    (
        SELECT COUNT(*)
        FROM PRAGMA_TABLE_INFO ('customers')
    ) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM customers
UNION ALL
SELECT
    'Products' AS table_name,
    (
        SELECT COUNT(*)
        FROM PRAGMA_TABLE_INFO ('products')
    ) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM products
UNION ALL
SELECT
    'ProductLines' AS table_name,
    (
        SELECT COUNT(*)
        FROM PRAGMA_TABLE_INFO ('productlines')
    ) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM productlines
UNION ALL
SELECT
    'Orders' AS table_name,
    (
        SELECT COUNT(*)
        FROM PRAGMA_TABLE_INFO ('orders')
    ) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM orders
UNION ALL
SELECT
    'OrderDetails' AS table_name,
    (
        SELECT COUNT(*)
        FROM PRAGMA_TABLE_INFO ('orderdetails')
    ) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM orderdetails
UNION ALL
SELECT
    'Payments' AS table_name,
    (
        SELECT COUNT(*)
        FROM PRAGMA_TABLE_INFO ('payments')
    ) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM payments
UNION ALL
SELECT
    'Employees' AS table_name,
    (
        SELECT COUNT(*)
        FROM PRAGMA_TABLE_INFO ('employees')
    ) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM employees
UNION ALL
SELECT
    'Offices' AS table_name,
    (
        SELECT COUNT(*)
        FROM PRAGMA_TABLE_INFO ('offices')
    ) AS number_of_attributes,
    COUNT(*) AS number_of_rows
FROM offices;

-- Low Stock Products

SELECT p.productCode, p.productName, (
        ROUND(
            CAST(
                (
                    SELECT SUM(quantityOrdered)
                    FROM orderdetails o
                    WHERE
                        o.productCode = p.productCode
                ) AS REAL
            ) / quantityInStock, 2
        )
    ) AS lowStock
FROM products p
GROUP BY
    p.productCode
ORDER BY lowStock DESC
LIMIT 10;

-- Product Performance

SELECT p.productCode, (
        SELECT SUM(
                o.quantityOrdered * o.priceEach
            )
        FROM orderdetails o
        WHERE
            o.productCode = p.productCode
        GROUP BY
            o.productCode
    ) AS productPerformance
FROM products p
GROUP BY
    p.productCode
ORDER BY productPerformance DESC
LIMIT 10;

-- CTE for Prev. 2 Queries

WITH
    lowStock AS (
        SELECT p.productCode, p.productName, (
                ROUND(
                    CAST(
                        (
                            SELECT SUM(quantityOrdered)
                            FROM orderdetails o
                            WHERE
                                o.productCode = p.productCode
                        ) AS REAL
                    ) / quantityInStock, 2
                )
            ) AS lowStock
        FROM products p
        GROUP BY
            p.productCode
        ORDER BY lowStock DESC
        LIMIT 10
    ),
    productPerformance AS (
        SELECT p.productCode, (
                SELECT SUM(
                        o.quantityOrdered * o.priceEach
                    )
                FROM orderdetails o
                WHERE
                    o.productCode = p.productCode
                GROUP BY
                    o.productCode
            ) AS productPerformance
        FROM products p
        GROUP BY
            p.productCode
        ORDER BY productPerformance DESC
        LIMIT 10
    )
SELECT p.*, l.lowStock, pp.productPerformance
FROM
    products p
    LEFT JOIN lowStock l ON p.productCode = l.productCode
    LEFT JOIN productPerformance pp ON p.productCode = pp.productCode
WHERE
    p.productCode IN (
        SELECT productCode
        FROM lowStock
        UNION
        SELECT productCode
        FROM productPerformance
    );

-- Profit per Customer

SELECT o.customerNumber, SUM(
        od.quantityOrdered * (od.priceEach - p.buyPrice)
    ) AS profit
FROM
    orders o
    JOIN orderdetails od ON o.orderNumber = od.orderNumber
    JOIN products p ON p.productCode = od.productCode
GROUP BY
    o.customerNumber
ORDER BY profit DESC;

-- Top 5 VIP Customers

WITH
    profits AS (
        SELECT o.customerNumber, SUM(
                od.quantityOrdered * (od.priceEach - p.buyPrice)
            ) AS profit
        FROM
            orders o
            JOIN orderdetails od ON o.orderNumber = od.orderNumber
            JOIN products p ON p.productCode = od.productCode
        GROUP BY
            o.customerNumber
        ORDER BY profit DESC
    )
SELECT c.contactLastName, c.contactFirstName, c.city, c.country, p.profit
FROM profits p
    JOIN customers c ON c.customerNumber = p.customerNumber
LIMIT 5;

-- Customer Lifetime Value (AVG Profit)

WITH
    profits AS (
        SELECT o.customerNumber, SUM(
                quantityOrdered * (priceEach - buyPrice)
            ) AS profit
        FROM
            products p
            JOIN orderdetails od ON p.productCode = od.productCode
            JOIN orders o ON o.orderNumber = od.orderNumber
        GROUP BY
            o.customerNumber
    )
SELECT ROUND(AVG(profit), 2) AS ltv
FROM profits;