
DROP TABLE IF EXISTS users;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key
    user_id TEXT,           -- Store `_id` from JSON (but not unique)
    state CHAR(2),
    created_date TIMESTAMP,
    last_login TIMESTAMP,
    role TEXT NOT NULL,
    active BOOLEAN
);


select * from users

--truncate table TRUNCATE
DROP TABLE IF EXISTS brands;

CREATE TABLE brands (
    id SERIAL PRIMARY KEY,  -- Auto-incrementing primary key
    brand_id TEXT,
    barcode TEXT,           -- Barcode for the brand
    brand_code TEXT,        -- Brand code from partner product file
    category TEXT,          -- Category name
    category_code TEXT,     -- Code referencing BrandCategory
    cpg_id TEXT,            -- Reference to CPG collection
    cpg_ref TEXT,
    top_brand BOOLEAN,      -- Whether the brand is a 'top brand'
    name TEXT               -- Brand name
);

-- truncate table brands

select * from brands

DROP TABLE IF EXISTS receipts;

CREATE TABLE receipts (
    id SERIAL PRIMARY KEY,              -- Auto-incrementing primary key
    receipt_id TEXT,                     -- Original UUID from JSON (_id)
    bonus_points_earned INT,             -- Bonus points awarded
    bonus_points_reason TEXT,            -- Event that triggered bonus points
    create_date TIMESTAMP,               -- Date the receipt was created
    date_scanned TIMESTAMP,              -- When the user scanned the receipt
    finished_date TIMESTAMP,             -- When the receipt finished processing
    modify_date TIMESTAMP,               -- Last modification timestamp
    points_awarded_date TIMESTAMP,       -- When points were awarded
    points_earned NUMERIC,               -- Points earned for the receipt
    purchase_date TIMESTAMP,             -- Date of purchase
    purchased_item_count INT,            -- Number of items on the receipt
    rewards_receipt_status TEXT,         -- Receipt validation status
    total_spent NUMERIC,                 -- Total amount spent on the receipt
    user_id TEXT                         -- Reference to the user who scanned
);

-- rewardsReceiptItemList looks like it should be its own table

DROP TABLE IF EXISTS receipt_items;

CREATE TABLE receipt_items (
    id SERIAL PRIMARY KEY,          -- Auto-incrementing primary key
    receipt_id TEXT,                 -- Links back to receipts.receipt_id
    barcode TEXT,                    -- Barcode of the item
    description TEXT,                 -- Description of the item
    final_price NUMERIC,              -- Final price paid for the item
    item_price NUMERIC,               -- Original item price
    needs_fetch_review BOOLEAN,       -- Whether the item requires Fetch review
    partner_item_id TEXT,             -- Partner's internal item ID
    prevent_target_gap_points BOOLEAN,-- Whether points should be prevented
    quantity_purchased INT,           -- Number of units purchased
    user_flagged_barcode TEXT,        -- User-flagged barcode
    user_flagged_description TEXT,    -- User-flagged item description
    user_flagged_new_item BOOLEAN,    -- Whether the item is new (flagged by user)
    user_flagged_price NUMERIC,       -- User-flagged price
    user_flagged_quantity INT,        -- User-flagged quantity
    rewards_group TEXT,               -- Rewards group the item belongs to
    rewards_product_partner_id TEXT,  -- Partner ID for the rewards product
    points_not_awarded_reason TEXT,   -- Reason points were not awarded
    points_payer_id TEXT              -- Entity responsible for awarding points
);

select * from receipts

select * from receipt_items

select count(*) from receipt_items


-- counts all look good, going to start investigating the data
