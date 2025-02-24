
select count(*) from users
-- 495
-- 212 after removing dupes

select * from users limit 20


-- duplicate user_ids
select user_id, count(*) from users
group by user_id
having count(*) > 1
order by count(*) desc
-- 70 rows

-- these are full duplicates it looks like
select * from users where user_id = '5fc961c3b8cfca11a077dd33'

select * from users where user_id = '5ff36d0362fde912123a5535'


-- checking full dupes
SELECT user_id, COUNT(*) AS duplicate_count
FROM users
GROUP BY user_id, state, created_date, last_login, role, active
HAVING COUNT(*) > 1;
-- 70 rows


-- lets look
SELECT *
FROM users
WHERE user_id IN (
    SELECT user_id
    FROM users
    GROUP BY user_id
    HAVING COUNT(*) > 1
)
ORDER BY user_id, created_date;

-- backup
CREATE TABLE users_raw AS
SELECT * FROM users;


-- removing dupes
DELETE FROM users
WHERE id NOT IN (
    SELECT MIN(id)
    FROM users
    GROUP BY user_id
);

-- now we have 0 dupes, counts will reflect that


-- checking for null values

select count(*) from users where state is null
-- 6
select * from users where STATE is null


select count(*) from users where created_date is null
-- 0

select count(*) from users where last_login is null
-- 40
select * from users where last_login is null

select count(*) from users where role is null
-- roles

SELECT DISTINCT role, COUNT(*) 
FROM users 
GROUP BY role;

-- looks ok

select * from users

select state, count(*)
from users
group by STATE
order by count(*) desc
-- WI is supreme


SELECT user_id, COUNT(*) AS receipt_count
FROM receipts
GROUP BY user_id
ORDER BY receipt_count DESC;

select * from users where user_id = '5fc961c3b8cfca11a077dd33'

SELECT COUNT(*) AS missing_users
FROM receipts r
LEFT JOIN users u ON r.user_id = u.user_id
WHERE u.user_id IS NULL;
