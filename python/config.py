import os
from sqlalchemy import create_engine

# Database credentials
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_NAME = os.getenv("DB_NAME", "bleezy")
DB_USER = os.getenv("DB_USER", "bleezy")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")
DB_PORT = os.getenv("DB_PORT", "5432")

def get_db_engine():
    """Create and return a database engine."""
    try:
        engine = create_engine(f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}")
        print("Successfully connected to the database.")
        return engine
    except Exception as e:
        print(f"Error connecting to the database: {e}")
        return None
