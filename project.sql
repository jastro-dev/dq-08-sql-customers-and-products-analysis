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
            ) / p.quantityInStock, 2
        )
    ) AS lowStock
FROM products p
ORDER BY lowStock DESC
LIMIT 10;