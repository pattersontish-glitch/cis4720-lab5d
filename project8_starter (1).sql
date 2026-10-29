/* ==========================================================================
   project8_starter.sql
   CIS 4720 Database Management and SQL

   WHAT THIS FILE IS
   Lab 8 finished, plus a heading for every step of Project 8 waiting to be
   filled in. Starting from this file means it does not matter how Lab 8 went.
   Everyone begins Project 8 from the same place.

   WHAT IT ALREADY BUILDS
     1. A schema called inventory_db
     2. INVENTORY, three rows, primary key on item_id
     3. The Step 8 price change, so the keyboard is 59.99
     4. The INVENTORY_VALUE view with its calculated column
     5. INVENTORY_COPY with its primary key added
     6. The stockclerk account

   BEFORE YOU RUN IT
   The schema has to exist before VS Code can connect to it. Step 2 of the
   project has you create it at the command prompt. Do that first.

   READ THIS BEFORE YOU RUN IT A SECOND TIME
   Run it once and everything works. Run it twice and the CREATE and INSERT
   statements fail, because the tables already exist and the rows are already
   there. Step 4 of the project explains which parts to comment out.
   ========================================================================== */


-- ======================================================================
-- SECTION 1. The schema
-- ======================================================================

CREATE DATABASE IF NOT EXISTS inventory_db;
USE inventory_db;


-- ======================================================================
-- SECTION 2. The INVENTORY table, from Lab 8
-- ======================================================================

CREATE TABLE INVENTORY (
    item_id     INT          NOT NULL,
    item_name   VARCHAR(40)  NOT NULL,
    category    VARCHAR(30),
    quantity    INT,
    unit_cost   DECIMAL(7,2),
    received_on DATE,
    PRIMARY KEY (item_id)
);


-- ======================================================================
-- SECTION 3. The data, with the Lab 8 price change already applied
-- The keyboard is 59.99 here rather than 64.00, because Lab 8 Step 8
-- dropped its price.
-- ======================================================================

INSERT INTO INVENTORY VALUES (1,'Laser Mouse',        'Peripherals', 25, 18.50,'2026-02-10');
INSERT INTO INVENTORY VALUES (2,'Mechanical Keyboard','Peripherals', 12, 59.99,'2026-03-05');
INSERT INTO INVENTORY VALUES (3,'USB Hub',            'Accessories', 40, 22.75,'2026-04-18');


-- ======================================================================
-- SECTION 4. The Lab 8 view and the Lab 8 copy
-- ======================================================================

CREATE VIEW INVENTORY_VALUE AS
SELECT item_name,
       quantity,
       unit_cost,
       quantity * unit_cost AS total_value
FROM INVENTORY;

CREATE TABLE INVENTORY_COPY AS
SELECT * FROM INVENTORY;

-- the key the copy did not inherit
ALTER TABLE INVENTORY_COPY ADD PRIMARY KEY (item_id);


-- ======================================================================
-- SECTION 5. The Lab 8 account
-- IF EXISTS keeps this safe to run twice. Without it a second run stops
-- with error 1396.
-- ======================================================================

DROP USER IF EXISTS 'stockclerk'@'localhost';
CREATE USER 'stockclerk'@'localhost' IDENTIFIED BY 'Stock#2026';


-- ======================================================================
-- SECTION 6. Checks
-- These only read, so they are safe to run as many times as you like.
-- ======================================================================

-- Expect 3 rows.
SELECT * FROM INVENTORY;

-- Expect 910.00, 719.88 and 462.50.
SELECT * FROM INVENTORY_VALUE ORDER BY total_value DESC;

-- INVENTORY and INVENTORY_COPY are BASE TABLE, INVENTORY_VALUE is a VIEW.
SHOW FULL TABLES;


-- ######################################################################
-- YOUR PROJECT 8 WORK STARTS BELOW THIS LINE
--
-- LABELING AND COMMENTING IS REQUIRED. It is worth a full point.
--
-- The eight headings below are already written for you. Put the
-- statements for each step underneath its own heading, in this order.
-- Above every statement write a short comment in your own words saying
-- what it does. A comment that just repeats the SQL back does not count.
--
-- You write the SQL yourself for Steps 5 through 11. The handout gives
-- you the specification, the data and the result you should get. Step 12
-- is the only one where the statements are printed for you.
--
-- A finished step looks like this:
--
--   -- the people we buy from. supplier_id is the primary key so two
--   -- suppliers can never share an id
--   CREATE TABLE SUPPLIER (
--       ...
--   );
-- ######################################################################


-- =================================================================
-- PROJECT 8 STEP 5. Create the SUPPLIER table
-- =================================================================

---Create a table to store supplier information. The supplier_id is the primary key, ensuring each supplier has a unique identifier.

-- CREATE TABLE SUPPLIER (
supplier_id INT NOT NULL,
supplier_name VARCHAR(40) NOT NULL,
city VARCHAR(30),
phone VARCHAR(20),
PRIMARY KEY (supplier_id)
);


-- =================================================================
-- PROJECT 8 STEP 6. Add the three suppliers
-- =================================================================


-- INSERT INTO supplier
INSERT INTO SUPPLIER (supplier_id, supplier_name, city, phone)
VALUES
    (10, 'Valley Components', 'Modesto', '209-555-0142'),
    (11, 'Delta Office Supply', 'Stockton', '209-555-0177'),
    (12, 'Sierra Tech Parts', 'Fresno', '559-555-0103');
SELECT * FROM SUPPLIER;


-- =================================================================
-- PROJECT 8 STEP 7. Add supplier_id to INVENTORY and link the tables
-- =================================================================

-- Add a column to store the supplier for each inventory item

ALTER TABLE INVENTORY

ADD supplier_id INT;

-- Create a foreign key relationship between INVENTORY and SUPPLIER

ALTER TABLE INVENTORY

ADD FOREIGN KEY (supplier_id)

REFERENCES SUPPLIER(supplier_id);

-- =================================================================
-- PROJECT 8 STEP 8. Record which supplier each item came from
-- =================================================================

-- Assign Valley Components to item 1

UPDATE INVENTORY

SET supplier_id = 10
WHERE item_id = 1;

-- Assign Valley Components to item 2

UPDATE INVENTORY

SET supplier_id = 10

WHERE item_id = 2;

-- Assign Delta Office Supply to item 3

UPDATE INVENTORY

SET supplier_id = 11

WHERE item_id = 3;

-- =================================================================

-- PROJECT 8 STEP 9. Join the two tables
-- =================================================================

-- Show inventory items and their supplier information

SELECT item_name, supplier_name, city, phone

FROM INVENTORY

JOIN SUPPLIER

ON INVENTORY.supplier_id = SUPPLIER.supplier_id;

-- =================================================================
-- PROJECT 8 STEP 10. Find the supplier you have bought nothing from
-- =================================================================
-- Find suppliers that are not linked to any inventory item

SELECT supplier_name

FROM SUPPLIER

LEFT JOIN INVENTORY

ON SUPPLIER.supplier_id = INVENTORY.supplier_id

WHERE INVENTORY.supplier_id IS NULL;

-- =================================================================
-- PROJECT 8 STEP 11. Save the join as a view
-- =================================================================
-- Create a view that combines inventory and supplier data

CREATE VIEW ITEM_SOURCE AS
SELECT item_id, item_name, supplier_name, city, phone
FROM INVENTORY
JOIN SUPPLIER
ON INVENTORY.supplier_id = SUPPLIER.supplier_id;

-- Test the view
SELECT * FROM ITEM_SOURCE;


-- =================================================================
-- PROJECT 8 STEP 12. Create a buyer account and grant it the view
-- =================================================================

--Create buyer account View
DROP USER IF EXISTS 'buyer'@'localhost';
CREATE USER 'buyer'@'localhost' IDENTIFIED BY 'Buyer#2026';
GRANT SELECT ON inventory_db.ITEM_SOURCE TO 'buyer'@'localhost';