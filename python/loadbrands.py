    import json
import pandas as pd
from config import get_db_engine

# JSON file path
JSON_FILE = "../input/brands.json"

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

def transform_data(data):
    """Extract required fields and handle missing values by inserting NULL (None)."""
    transformed = []
    for brand in data:
        try:
            transformed.append({
                "brand_id": brand["_id"]["$oid"] if "_id" in brand else None,  # Add this line
                "barcode": brand.get("barcode", None),
                "brand_code": brand.get("brandCode", None),
                "category": brand.get("category", None),
                "category_code": brand.get("categoryCode", None),
                "cpg_id": brand["cpg"]["$id"]["$oid"] if "cpg" in brand and "$id" in brand["cpg"] else None,
                "cpg_ref": brand["cpg"]["$ref"] if "cpg" in brand and "$ref" in brand["cpg"] else None,  # Add this line
                "top_brand": brand.get("topBrand", None),
                "name": brand.get("name", None)
            })
        except Exception as e:
            print(f"Error transforming record: {brand}, Error: {e}")
    print(f"Transformed {len(transformed)} records.")
    return transformed

def insert_data(data):
    """Insert transformed data into PostgreSQL using Pandas to_sql()."""
    engine = get_db_engine()
    if not engine:
        print("Database connection failed. Cannot insert data.")
        return

    try:
        df = pd.DataFrame(data)
        df.to_sql("brands", con=engine, if_exists="append", index=False)
        print(f"Successfully inserted {len(df)} records into the brands table.")
    except Exception as e:
        print(f"Error inserting data into the database: {e}")

if __name__ == "__main__":
    print("Starting brand import process...")
    json_data = load_json(JSON_FILE)
    transformed_data = transform_data(json_data)
    insert_data(transformed_data)
    print("Brand import process completed.")
