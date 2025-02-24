-- q1 and q2
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



-- q3 and q4

SELECT 
    rewards_receipt_status,
    AVG(total_spent) AS avg_spend,
    SUM(purchased_item_count) AS total_items_purchased
FROM receipts
WHERE rewards_receipt_status IN ('FINISHED', 'REJECTED')
GROUP BY rewards_receipt_status
ORDER BY avg_spend DESC;


-- q5 and q6

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

