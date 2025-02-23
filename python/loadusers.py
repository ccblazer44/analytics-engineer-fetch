import json
import pandas as pd
from config import get_db_engine

# JSON file path
JSON_FILE = "../input/users.json"


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
    for user in data:
        try:
            transformed.append({
                "user_id": user["_id"]["$oid"] if "_id" in user else None,  
                "state": user.get("state", None),
                "created_date": pd.to_datetime(user["createdDate"]["$date"], unit="ms") if "createdDate" in user else None,
                "last_login": pd.to_datetime(user["lastLogin"]["$date"], unit="ms") if "lastLogin" in user else None,
                "role": user.get("role", "UNKNOWN").upper() if "role" in user else None,
                "active": user.get("active", None)  # Defaults to None if missing
            })
        except Exception as e:
            print(f"Error transforming record: {user}, Error: {e}")
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
        df.to_sql("users", con=engine, if_exists="append", index=False)
        print(f"Successfully inserted {len(df)} records into the users table.")
    except Exception as e:
        print(f"Error inserting data into the database: {e}")

if __name__ == "__main__":
    print("Starting user import process...")
    json_data = load_json(JSON_FILE)
    transformed_data = transform_data(json_data)
    insert_data(transformed_data)
    print("User import process completed.")
