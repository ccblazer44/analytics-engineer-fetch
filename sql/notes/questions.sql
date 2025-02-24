

-- q1 & 2


select * from receipts order by date_scanned desc
-- only one day of data for 2021-03 so we will use 2021-02 as most recent MONTH

SELECT 
    DATE_TRUNC('month', date_scanned) AS month,
    COUNT(*) AS receipts_scanned
FROM receipts
GROUP BY DATE_TRUNC('month', date_scanned)
ORDER BY month;
-- this makes it clear that for the question we will use feb and jan



SELECT b.name AS brand_name, COUNT(DISTINCT r.receipt_id) AS receipt_count
FROM receipts r
JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
JOIN brands b ON ri.barcode = b.barcode
WHERE DATE_TRUNC('month', r.date_scanned) = '2021-02-01'
GROUP BY b.name
ORDER BY receipt_count DESC
LIMIT 5;
-- wow, nothing for feb.  Barcodes are going to be a problem.

SELECT b.name AS brand_name, COUNT(DISTINCT r.receipt_id) AS receipt_count
FROM receipts r
JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
JOIN brands b ON ri.barcode = b.barcode
WHERE DATE_TRUNC('month', r.date_scanned) = '2021-01-01'
GROUP BY b.name
ORDER BY receipt_count DESC
LIMIT 5;
-- January data seems to connect better.  Perhaps the barcodes/brands are being updated on a lag.


SELECT r.date_scanned
FROM receipt_items ri
JOIN brands b ON ri.barcode = b.barcode
join receipts r on ri.receipt_id = r.receipt_id
order by r.date_scanned
-- its hard to do a monthly comparison, we only have matching barcodes for 2021-01-15 to 2021-01-25



SELECT COUNT(*) AS matching_barcodes
FROM receipt_items ri
JOIN brands b ON ri.barcode = b.barcode;
-- 89 records actually connect from reciept_items to brands

SELECT COUNT(*) AS matching_barcodes
FROM receipt_items ri
JOIN brands b ON ri.user_flagged_barcode = b.barcode;
-- 0

SELECT ri.*, b.*
FROM receipt_items ri
JOIN brands b ON ri.barcode = b.barcode
-- 89

SELECT ri.*, b.*
FROM receipt_items ri
JOIN brands b ON ri.description = b.brand_code
-- 84, even worse


SELECT ri.*, b.*
FROM receipt_items ri
JOIN brands b ON ri.description ILIKE b.brand_code
-- 84 still


SELECT ri.*, b.*
FROM receipt_items ri
JOIN brands b ON ri.description ILIKE b.name
-- 75, even worsre




SELECT COUNT(*) AS non_matching_receipt_items
FROM receipt_items ri
LEFT JOIN brands b ON ri.barcode = b.barcode
WHERE b.barcode IS NULL;
-- 6859 do not match based on barcode


SELECT ri.* 
FROM receipt_items ri
LEFT JOIN brands b ON ri.barcode = b.barcode
WHERE b.barcode IS NULL;
-- 6859


-- trying to connect to the brands table to answer this question is a losing battle, need to find another way

select description, count(*) as itemcount
from receipt_items
group by description
order by itemcount desc

select rewards_group, count(*) as itemcount
from receipt_items
group by rewards_group
order by rewards_group desc



-- looking for other ways to join
SELECT DISTINCT ri.rewards_group, COUNT(*) AS count_in_items, 
       COUNT(DISTINCT b.name) AS matching_brands
FROM receipt_items ri
LEFT JOIN brands b ON ri.rewards_group = b.category
GROUP BY ri.rewards_group
ORDER BY count_in_items DESC
LIMIT 20;

SELECT *
FROM receipt_items ri
 JOIN brands b 
ON ri.rewards_product_partner_id = b.brand_id 
   OR ri.partner_item_id = b.brand_id
   OR ri.rewards_group = b.category
   OR ri.description ILIKE b.name
LIMIT 20;

SELECT COUNT(*) AS matching_records
FROM receipt_items ri
JOIN brands b ON ri.rewards_product_partner_id = b.brand_id;
-- 0


-- lets check fuzzy matches

SELECT COUNT(*) AS potential_matches
FROM receipt_items ri
JOIN brands b ON ri.rewards_group ILIKE '%' || b.brand_code || '%';

update brands 
set brand_code = null
where brand_code = ''

SELECT ri.description, b.name
FROM receipt_items ri
JOIN brands b 
ON ri.description ILIKE '%' || b.name || '%'
LIMIT 20;

SELECT ri.rewards_group, b.brand_code
FROM receipt_items ri
JOIN brands b 
ON ri.rewards_group ILIKE '%' || b.brand_code || '%'
LIMIT 20;



-- wow nice this looks pretty good actually, we are going to try using this

select * from brands where brand_code = 'PEPSI'

SELECT 
	b.brand_code, 
    COUNT(DISTINCT r.receipt_id) AS receipt_count
FROM receipts r
JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
JOIN brands b ON ri.rewards_group ILIKE '%' || b.brand_code || '%'
WHERE r.date_scanned >= '2021-02-01'
  AND r.date_scanned < '2021-03-01'
GROUP BY b.brand_code
ORDER BY receipt_count DESC
LIMIT 5;
-- ok, its not much but at least it's something

SELECT 
	b.brand_code, 
    COUNT(DISTINCT r.receipt_id) AS receipt_count
FROM receipts r
JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
JOIN brands b ON ri.rewards_group ILIKE '%' || b.brand_code || '%'
WHERE r.date_scanned >= '2021-01-01'
  AND r.date_scanned < '2021-02-01'
GROUP BY b.brand_code
ORDER BY receipt_count DESC
LIMIT 5;

-----


-- this is the one
WITH feb_brands AS (
    SELECT 
        b.brand_code AS feb_brand_code, 
        COUNT(DISTINCT r.receipt_id) AS feb_receipt_count,
        SUM(r.total_spent) AS feb_total_spent,
        RANK() OVER (ORDER BY COUNT(DISTINCT r.receipt_id) DESC, SUM(r.total_spent) DESC) AS rank
    FROM receipts r
    JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
    JOIN brands b ON ri.rewards_group ILIKE '%' || b.brand_code || '%'
    WHERE r.date_scanned >= '2021-02-01'
      AND r.date_scanned < '2021-03-01'
    GROUP BY b.brand_code
    ORDER BY feb_receipt_count DESC, feb_total_spent DESC
    LIMIT 5
),
jan_brands AS (
    SELECT 
        b.brand_code AS jan_brand_code, 
        COUNT(DISTINCT r.receipt_id) AS jan_receipt_count,
        SUM(r.total_spent) AS jan_total_spent,
        RANK() OVER (ORDER BY COUNT(DISTINCT r.receipt_id) DESC, SUM(r.total_spent) DESC) AS rank
    FROM receipts r
    JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
    JOIN brands b ON ri.rewards_group ILIKE '%' || b.brand_code || '%'
    WHERE r.date_scanned >= '2021-01-01'
      AND r.date_scanned < '2021-02-01'
    GROUP BY b.brand_code
    ORDER BY jan_receipt_count DESC, jan_total_spent DESC
    LIMIT 5
)
SELECT 
    fb.feb_brand_code AS top_5_february,
    fb.feb_receipt_count AS receipts_february,
    --fb.feb_total_spent AS total_spent_february,
    jb.jan_brand_code AS top_5_january,
    jb.jan_receipt_count AS receipts_january
    --,jb.jan_total_spent AS total_spent_january
FROM feb_brands fb
FULL OUTER JOIN jan_brands jb 
ON fb.rank = jb.rank
ORDER BY COALESCE(fb.rank, jb.rank)
LIMIT 5;




select * from receipt_items


select * from brands

-- todo come back to q1/2


-- q3 & 4
select * from receipts

select * from receipt_items


SELECT AVG(total_spent) AS avg_spend
FROM receipts;

select DISTINCT rewards_receipt_status from receipts

-- no such thing as accepted, assuming finished = accepted

SELECT rewards_receipt_status, AVG(total_spent) AS avg_spend
FROM receipts
GROUP BY rewards_receipt_status
ORDER BY avg_spend DESC;


SELECT rewards_receipt_status, AVG(total_spent) AS avg_spend
FROM receipts
WHERE rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY rewards_receipt_status
ORDER BY avg_spend DESC;

SELECT rewards_receipt_status, SUM(purchased_item_count) AS total_items_purchased
FROM receipts
GROUP BY rewards_receipt_status
ORDER BY total_items_purchased DESC;


SELECT rewards_receipt_status, SUM(purchased_item_count) AS total_items_purchased
FROM receipts
WHERE rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY rewards_receipt_status
ORDER BY total_items_purchased DESC;


-- this is the one
SELECT 
    rewards_receipt_status,
    AVG(total_spent) AS avg_spend,
    SUM(purchased_item_count) AS total_items_purchased
FROM receipts
WHERE rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY rewards_receipt_status
ORDER BY avg_spend DESC;



--- q 5 & 6


SELECT COUNT(*) AS matching_receipts
FROM receipts r
JOIN users u ON r.user_id = u.user_id;
-- 971

SELECT COUNT(*) AS missing_users
FROM receipts r
LEFT JOIN users u ON r.user_id = u.user_id
WHERE u.user_id IS NULL;
-- 148
-- we have good enough matching, proceeding


select max(created_date) from users
 -- 2021-02-12 14:11:06.24. we will use this instead of CURRENT_DATE
 
 WITH recent_users AS (
    SELECT user_id
    FROM users
    WHERE created_date >= TIMESTAMP '2021-02-12' - INTERVAL '6 months'
)
SELECT 
    b.brand_code, 
    SUM(r.total_spent) AS total_spend
FROM receipts r
JOIN recent_users u ON r.user_id = u.user_id
JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
JOIN brands b ON ri.rewards_group ILIKE '%' || b.brand_code || '%'
GROUP BY b.brand_code
ORDER BY total_spend DESC
LIMIT 1;

WITH recent_users AS (
    SELECT user_id
    FROM users
    WHERE created_date >= TIMESTAMP '2021-02-12' - INTERVAL '6 months'
)
SELECT 
    b.brand_code, 
    COUNT(DISTINCT r.receipt_id) AS total_transactions
FROM receipts r
JOIN recent_users u ON r.user_id = u.user_id
JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
JOIN brands b ON ri.rewards_group ILIKE '%' || b.brand_code || '%'
GROUP BY b.brand_code
ORDER BY total_transactions DESC
LIMIT 1;


WITH recent_users AS (
    -- Get users created in the 6 months before 2021-02-12
    SELECT user_id
    FROM users
    WHERE created_date >= TIMESTAMP '2021-02-12' - INTERVAL '6 months'
),
brand_spend AS (
    -- Find the brand with the highest total spend
    SELECT 
        b.brand_code AS top_spend_brand,
        SUM(r.total_spent) AS total_spend
    FROM receipts r
    JOIN recent_users u ON r.user_id = u.user_id
    JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
    JOIN brands b ON ri.rewards_group ILIKE '%' || b.brand_code || '%'
    GROUP BY b.brand_code
    ORDER BY total_spend DESC
    LIMIT 1
),
brand_transactions AS (
    -- Find the brand with the highest number of transactions
    SELECT 
        b.brand_code AS top_transaction_brand,
        COUNT(DISTINCT r.receipt_id) AS total_transactions
    FROM receipts r
    JOIN recent_users u ON r.user_id = u.user_id
    JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
    JOIN brands b ON ri.rewards_group ILIKE '%' || b.brand_code || '%'
    GROUP BY b.brand_code
    ORDER BY total_transactions DESC
    LIMIT 1
)
-- Combine both results into a single row
SELECT 
    bs.top_spend_brand,
    bs.total_spend,
    bt.top_transaction_brand,
    bt.total_transactions
FROM brand_spend bs
JOIN brand_transactions bt ON 1=1;

