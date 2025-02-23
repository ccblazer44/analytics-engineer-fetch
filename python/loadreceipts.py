import json
import pandas as pd
from config import get_db_engine

# JSON file path
JSON_FILE = "../input/receipts.json"

def load_json(file_path):
    """Read and parse JSON file into a list of dictionaries."""
    try:
        with open(file_path, "r") as f:
            data = [json.loads(line) for line in f]
        print(f"Loaded {len(data)} records from JSON file.")
        return data
    except Exception as e:
        print(f"Error loading JSON file: {e}")
        return []

def transform_receipts(data):
    """Extract receipt-level fields and handle missing values."""
    receipts = []
    receipt_items = []
    
    for receipt in data:
        try:
            # Extract receipt data
            receipt_id = receipt["_id"]["$oid"] if "_id" in receipt else None
            receipts.append({
                "receipt_id": receipt_id,
                "bonus_points_earned": receipt.get("bonusPointsEarned", None),
                "bonus_points_reason": receipt.get("bonusPointsEarnedReason", None),
                "create_date": pd.to_datetime(receipt["createDate"]["$date"], unit="ms") if "createDate" in receipt else None,
                "date_scanned": pd.to_datetime(receipt["dateScanned"]["$date"], unit="ms") if "dateScanned" in receipt else None,
                "finished_date": pd.to_datetime(receipt["finishedDate"]["$date"], unit="ms") if "finishedDate" in receipt else None,
                "modify_date": pd.to_datetime(receipt["modifyDate"]["$date"], unit="ms") if "modifyDate" in receipt else None,
                "points_awarded_date": pd.to_datetime(receipt["pointsAwardedDate"]["$date"], unit="ms") if "pointsAwardedDate" in receipt else None,
                "points_earned": float(receipt["pointsEarned"]) if "pointsEarned" in receipt else None,
                "purchase_date": pd.to_datetime(receipt["purchaseDate"]["$date"], unit="ms") if "purchaseDate" in receipt else None,
                "purchased_item_count": receipt.get("purchasedItemCount", None),
                "rewards_receipt_status": receipt.get("rewardsReceiptStatus", None),
                "total_spent": float(receipt["totalSpent"]) if "totalSpent" in receipt else None,
                "user_id": receipt.get("userId", None),
            })
            
            # Extract receipt items if they exist
            if "rewardsReceiptItemList" in receipt and isinstance(receipt["rewardsReceiptItemList"], list):
                for item in receipt["rewardsReceiptItemList"]:
                    receipt_items.append({
                        "receipt_id": receipt_id,
                        "barcode": item.get("barcode", None),
                        "description": item.get("description", None),
                        "final_price": float(item["finalPrice"]) if "finalPrice" in item else None,
                        "item_price": float(item["itemPrice"]) if "itemPrice" in item else None,
                        "needs_fetch_review": item.get("needsFetchReview", None),
                        "partner_item_id": item.get("partnerItemId", None),
                        "prevent_target_gap_points": item.get("preventTargetGapPoints", None),
                        "quantity_purchased": item.get("quantityPurchased", None),
                        "user_flagged_barcode": item.get("userFlaggedBarcode", None),
                        "user_flagged_description": item.get("userFlaggedDescription", None),
                        "user_flagged_new_item": item.get("userFlaggedNewItem", None),
                        "user_flagged_price": float(item["userFlaggedPrice"]) if "userFlaggedPrice" in item else None,
                        "user_flagged_quantity": item.get("userFlaggedQuantity", None),
                        "rewards_group": item.get("rewardsGroup", None),
                        "rewards_product_partner_id": item.get("rewardsProductPartnerId", None),
                        "points_not_awarded_reason": item.get("pointsNotAwardedReason", None),
                        "points_payer_id": item.get("pointsPayerId", None)
                    })
        except Exception as e:
            print(f"Error transforming record: {receipt}, Error: {e}")

    print(f"Transformed {len(receipts)} receipts and {len(receipt_items)} receipt items.")
    return receipts, receipt_items

def insert_data(receipts, receipt_items):
    """Insert transformed data into PostgreSQL using Pandas to_sql()."""
    engine = get_db_engine()
    if not engine:
        print("Database connection failed. Cannot insert data.")
        return

    try:
        # Insert receipts
        df_receipts = pd.DataFrame(receipts)
        df_receipts.to_sql("receipts", con=engine, if_exists="append", index=False)
        print(f"Successfully inserted {len(df_receipts)} records into the receipts table.")
        
        # Insert receipt items
        df_items = pd.DataFrame(receipt_items)
        df_items.to_sql("receipt_items", con=engine, if_exists="append", index=False)
        print(f"Successfully inserted {len(df_items)} records into the receipt_items table.")
    
    except Exception as e:
        print(f"Error inserting data into the database: {e}")

if __name__ == "__main__":
    print("Starting receipt import process...")
    json_data = load_json(JSON_FILE)
    receipts, receipt_items = transform_receipts(json_data)
    insert_data(receipts, receipt_items)
    print("Receipt import process completed.")
