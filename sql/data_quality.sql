-- Count of missing barcodes in receipt_items
SELECT COUNT(*) AS missing_barcodes
FROM receipt_items
WHERE barcode IS NULL OR barcode = '';

-- Count of receipt_items that have matching barcodes in the brands table
SELECT COUNT(*) AS matching_barcodes
FROM receipt_items ri
JOIN brands b ON ri.barcode = b.barcode;

-- Count of receipt_items that do NOT have matching barcodes in the brands table
SELECT COUNT(*) AS non_matching_receipt_items
FROM receipt_items ri
LEFT JOIN brands b ON ri.barcode = b.barcode
WHERE b.barcode IS NULL;

-- Breakdown of how many missing barcodes per receipt
SELECT receipt_id, COUNT(*) AS missing_items
FROM receipt_items
WHERE barcode IS NULL OR barcode = ''
GROUP BY receipt_id
ORDER BY missing_items DESC;
