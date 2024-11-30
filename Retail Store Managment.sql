# Created a Database Schema named my_portfolio
# Load Data Tables into the portfolio using Data Table Import Wizard

# Data Overview
    
USE my_portfolio;

SELECT * 
FROM sales
LIMIT 10;

SELECT * 
FROM inventory
LIMIT 10;

SELECT *
FROM orders
LIMIT 10;

SELECT *
FROM products
LIMIT 10;

SELECT COUNT(*) AS Total_Rows 
FROM sales;

SELECT COUNT(*) AS Total_Rows 
FROM orders;

SELECT COUNT(*) AS Total_Rows 
FROM products;

SELECT COUNT(*) AS Total_Rows 
FROM inventory;


## Check for missing data

SELECT product_Id, COUNT(*)
FROM sales 
WHERE product_Id= Null;

SELECT COUNT(Product_Name) AS Our_Products
FROM products
WHERE Product_Name IS NOT Null;



#Aggregation and Summaries
SELECT DISTINCT neighborhood AS Store_Location
FROM inventory;

SELECT DISTINCT Supplier AS Major_Suppliers
FROM Products
ORDER BY Major_Suppliers ASC;

SELECT COUNT(DISTINCT Product_Id) AS Number_of_products
FROM sales;

SELECT COUNT(DISTINCT Product_Id) AS Number_of_products
FROM products;

SELECT (Shipper_date-Order_date) AS Shipping_Days
FROM orders;
#Trying to calculate shipping days did not work because dates are saved as text values
SELECT Shipper_date, Order_date
FROM orders
ORDER BY Order_date ASC;

SELECT 
    Shipper_date,
    Order_date,
    DATEDIFF(Shipper_date, Order_date) AS Shipping_Days
FROM 
    orders
ORDER BY 
    Order_date ASC;
    
   #Checking the Table values 
DESCRIBE orders;
    
    #Updating the table by setting text values to date values
    ## Data cleaning
    
CREATE TABLE orders_backup AS SELECT * FROM orders;
  
DESCRIBE orders;

ALTER TABLE orders 
ADD COLUMN order_date_temp DATETIME NULL,
ADD COLUMN shipper_date_temp DATETIME NULL;



DESCRIBE orders;

SELECT order_date_temp,shipper_date_temp
FROM orders
LIMIT 10;
ALTER TABLE orders DROP COLUMN order_date;
ALTER TABLE orders DROP COLUMN shipper_date;

#Check if column has no nulls

SELECT order_date_temp
from orders
where order_date_temp is null;

# Rename new columns

#ALTER TABLE orders 
#CHANGE COLUMN order_date_temp order_date DATETIME;

#ALTER TABLE orders 
#CHANGE COLUMN shipper_date_temp shipper_date DATETIME;



# Data analysis 
## Total Revenue by Product/ Top 10 Products by Revenue
SELECT 
    p.product_name,
    SUM(s.quantity * s.unit_price) AS total_revenue
FROM 
    sales s
JOIN 
    products p ON s.product_id = p.product_id
GROUP BY 
    p.product_name
ORDER BY 
    total_revenue DESC 
    LIMIT 10;
    ##Products with low sales
 SELECT 
    p.product_name,
    SUM(s.quantity * s.unit_price) AS total_revenue
FROM 
    sales s
JOIN 
    products p ON s.product_id = p.product_id
GROUP BY 
    p.product_name
ORDER BY 
    total_revenue ASC 
    LIMIT 10;   
    
 ## Average order value (AOV)  
 
SELECT 
    AVG(s.quantity * s.unit_price) AS average_order_value
FROM 
    sales s;
    
    

##Orders Over the Years by Month
SELECT 
    YEAR(order_date) AS Year,
    MONTH(order_date) AS Month,
    COUNT(order_id) AS total_orders
FROM 
    orders
GROUP BY 
    YEAR(order_date), MONTH(order_date)
ORDER BY 
    Year ASC, Month ASC;
    

## Product Profitability/Product profit margins
SELECT 
    p.Product_Name,
    SUM(s.Quantity * (s.Unit_Price - p.Product_Cost)) AS total_profit,
    SUM(s.Quantity * s.Unit_Price) AS total_revenue,
    (SUM(s.Quantity * (s.Unit_Price - p.Product_Cost)) / SUM(s.Quantity * s.Unit_Price)) * 100 AS profit_margin_percentage
FROM 
    sales s
JOIN 
    products p ON s.product_Id = p.product_Id
GROUP BY 
    p.Product_Name
ORDER BY 
    total_profit DESC;





#Inventory Control
# Available_Inventory
SELECT 
    sales.Quantity AS Sales_Quantity,
    inventory.Quantity_Available AS Available_Inventory,
    (inventory.Quantity_Available - sales.Quantity) AS Current_Inventory
FROM 
    inventory
RIGHT JOIN  
    sales
ON 
    inventory.product_Id = sales.product_Id;
    
##Invetory Control
SELECT 
    sales.Quantity AS Sales_Quantity,
    inventory.Quantity_Available AS Available_Inventory,
    (CASE 
        WHEN (inventory.Quantity_Available - sales.Quantity) < 0 
        THEN 'No Inventory' 
        ELSE (inventory.Quantity_Available - sales.Quantity)
    END) AS Current_Inventory
FROM 
    inventory
RIGHT JOIN  
    sales
    
ON 
    inventory.product_Id = sales.product_Id;


##Average Shipping Time
SELECT 
    AVG(DATEDIFF(o.shipper_date, o.order_date)) AS average_shipping_time
FROM 
    orders o
WHERE 
    o.shipper_date IS NOT NULL;

## On-time vs delayed shipments    
SELECT 
    CASE 
        WHEN DATEDIFF(o.shipper_date, o.order_date) <= 3 THEN 'On-Time'
        ELSE 'Delayed'
    END AS shipment_status,
    COUNT(*) AS total_orders
FROM 
    orders o
WHERE 
    o.shipper_date IS NOT NULL
GROUP BY 
    shipment_status;


