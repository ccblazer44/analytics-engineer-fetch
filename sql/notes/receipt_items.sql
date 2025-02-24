
select count(*) from receipt_items
--6941

select * from receipt_items limit 100

select * from brands

select * from receipts


SELECT receipt_id, barcode, COUNT(*)
FROM receipt_items
GROUP BY receipt_id, barcode
HAVING COUNT(*) > 1;

select * from receipt_items where receipt_id = '600992f90a720f05fa000133' and barcode = '036000391718'

select * from receipts where receipt_id = '600992f90a720f05fa000133'

select sum(final_price) from receipt_items
where  receipt_id = '600992f90a720f05fa000133'
group by receipt_id

--349.16 matches total_spent from receipts


-- checking if total_spent = sum(final_price) for all

SELECT r.receipt_id, 
       r.total_spent AS receipt_total, 
       COALESCE(SUM(ri.final_price), 0) AS items_total,
       r.total_spent - COALESCE(SUM(ri.final_price), 0) AS difference
FROM receipts r
LEFT JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
GROUP BY r.receipt_id, r.total_spent
HAVING r.total_spent <> COALESCE(SUM(ri.final_price), 0);


select * from receipts where receipt_id = '5ffcb4ad0a720f0515000009'

select * from receipt_items where receipt_id = '5ffcb4ad0a720f0515000009'

select sum(final_price) from receipt_items
where  receipt_id = '5ffcb4ad0a720f0515000009'
group by receipt_id


SELECT ri.*
FROM receipt_items ri
WHERE ri.receipt_id IN (
    SELECT r.receipt_id
    FROM receipts r
    LEFT JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
    GROUP BY r.receipt_id, r.total_spent
    HAVING r.total_spent <> COALESCE(SUM(ri.final_price), 0)
)
ORDER BY ri.receipt_id;

-- these all seem to have some kind of flag, 'ITEM NOT FOUND', needs_fetch_review, etc so these look ok for now




-- comparing purchased_item_count from receipts to number of records for that receipt id in receipt_items
SELECT 
    r.receipt_id,
    r.purchased_item_count AS expected_item_count, 
    COUNT(ri.receipt_id) AS actual_item_count,
    (r.purchased_item_count - COUNT(ri.receipt_id)) AS difference
FROM receipts r
LEFT JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
GROUP BY r.receipt_id, r.purchased_item_count
ORDER BY difference DESC;

select * from receipts where receipt_id = '600f2fc80a720f0535000030'

select count(*) from receipt_items where receipt_id = '600f2fc80a720f0535000030'

select * from receipt_items where receipt_id = '600f2fc80a720f0535000030'

-- using quantity_purchased
SELECT 
    r.receipt_id,
    r.purchased_item_count AS expected_item_count, 
    COALESCE(SUM(ri.quantity_purchased), 0) AS actual_item_count,
    (r.purchased_item_count - COALESCE(SUM(ri.quantity_purchased), 0)) AS difference
FROM receipts r
LEFT JOIN receipt_items ri ON r.receipt_id = ri.receipt_id
GROUP BY r.receipt_id, r.purchased_item_count
ORDER BY difference DESC;
-- this looks much better

select * from receipts where receipt_id = '60145a510a7214ad50000086'

select * from receipt_items where receipt_id = '60145a510a7214ad50000086'

