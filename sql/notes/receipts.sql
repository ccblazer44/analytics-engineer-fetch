
select count(*) from receipts
--1119

select * from receipts

-- no dupe ids
SELECT receipt_id, COUNT(*)
FROM receipts
GROUP BY receipt_id
HAVING COUNT(*) > 1;


-- null check
SELECT 
    (SELECT COUNT(*) FROM receipts WHERE receipt_id IS NULL) AS missing_receipt_id,
    (SELECT COUNT(*) FROM receipts WHERE user_id IS NULL) AS missing_user_id,
    (SELECT COUNT(*) FROM receipts WHERE bonus_points_earned IS NULL) AS missing_bonus_points_earned,
    (SELECT COUNT(*) FROM receipts WHERE bonus_points_reason IS NULL) AS missing_bonus_points_reason,
    (SELECT COUNT(*) FROM receipts WHERE create_date IS NULL) AS missing_create_date,
    (SELECT COUNT(*) FROM receipts WHERE date_scanned IS NULL) AS missing_date_scanned,
    (SELECT COUNT(*) FROM receipts WHERE finished_date IS NULL) AS missing_finished_date,
    (SELECT COUNT(*) FROM receipts WHERE modify_date IS NULL) AS missing_modify_date,
    (SELECT COUNT(*) FROM receipts WHERE points_awarded_date IS NULL) AS missing_points_awarded_date,
    (SELECT COUNT(*) FROM receipts WHERE points_earned IS NULL) AS missing_points_earned,
    (SELECT COUNT(*) FROM receipts WHERE purchase_date IS NULL) AS missing_purchase_date,
    (SELECT COUNT(*) FROM receipts WHERE purchased_item_count IS NULL) AS missing_purchased_item_count,
    (SELECT COUNT(*) FROM receipts WHERE rewards_receipt_status IS NULL) AS missing_rewards_receipt_status,
    (SELECT COUNT(*) FROM receipts WHERE total_spent IS NULL) AS missing_total_spent;


select * from receipts
where points_earned is not null and points_awarded_date is null
-- 72 records with points being awarded, but no points awarded date


-- do our receipts users match with users users
SELECT DISTINCT r.user_id
FROM receipts r
LEFT JOIN users u ON r.user_id = u.user_id
WHERE u.user_id IS NULL;
--117 users in receipts not in users

select count (distinct user_id)
from receipts
--258

-- so only about half our users match to a user from the users TABLE



