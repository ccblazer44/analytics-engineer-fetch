import json

# Path to the JSON file
JSON_FILE = "../input/receipts.json"

def count_receipt_items(file_path):
    """Count the number of receipt items in the JSON file."""
    try:
        with open(file_path, "r") as f:
            data = [json.loads(line) for line in f]
        
        total_items = sum(
            len(receipt.get("rewardsReceiptItemList", [])) for receipt in data
        )

        print(f"Total receipt items in JSON: {total_items}")
    
    except Exception as e:
        print(f"Error reading JSON file: {e}")

if __name__ == "__main__":
    count_receipt_items(JSON_FILE)
