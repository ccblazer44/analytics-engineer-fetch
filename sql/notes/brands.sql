
select count(*) from brands
--1167

select * from brands

-- no dupe brand_ids
SELECT brand_id, COUNT(*)
FROM brands
GROUP BY brand_id
HAVING COUNT(*) > 1;

-- dupe barcodes
SELECT barcode
FROM brands
GROUP BY barcode
HAVING COUNT(*) > 1;
-- 7 dupe barcodes

select * from brands
where barcode in (
	SELECT barcode
	FROM brands
	GROUP BY barcode
	HAVING COUNT(*) > 1)
order by barcode desc
-- they look different and have different brand_ids so leaving these alone


SELECT 
    (SELECT COUNT(*) FROM brands WHERE brand_id IS NULL) AS missing_brand_id,
    (SELECT COUNT(*) FROM brands WHERE barcode IS NULL) AS missing_barcode,
    (SELECT COUNT(*) FROM brands WHERE brand_code IS NULL) AS missing_brand_code,
    (SELECT COUNT(*) FROM brands WHERE category IS NULL) AS missing_category,
    (SELECT COUNT(*) FROM brands WHERE category_code IS NULL) AS missing_category_code,
    (SELECT COUNT(*) FROM brands WHERE cpg_id IS NULL) AS missing_cpg_id,
    (SELECT COUNT(*) FROM brands WHERE cpg_ref IS NULL) AS missing_cpg_ref,
    (SELECT COUNT(*) FROM brands WHERE top_brand IS NULL) AS missing_top_brand,
    (SELECT COUNT(*) FROM brands WHERE name IS NULL) AS missing_name;
-- 234 null brand_code, 155 null category, 650 null category_code, 612 missing top brand

select brand_code, count(*)
from brands
group by brand_code
order by count(*) desc

-- HUGGIES, GOODNITES are the only dupes by brand_code
select * from brands where brand_code = 'HUGGIES'

select distinct top_brand, count(*)
from brands
group by top_brand
order by count(*) DESC

select * from brands where cpg_ref <> 'Cogs'