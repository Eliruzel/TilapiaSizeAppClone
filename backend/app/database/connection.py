import os

from dotenv import load_dotenv
from sqlalchemy import URL
from sqlmodel import Session, create_engine

# Load database credentials from the .env file.
load_dotenv()

# Build the PostgreSQL connection URL.
DATABASE_URL = URL.create(
    drivername="postgresql+psycopg",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST", "localhost"),
    port=int(os.getenv("DB_PORT", "5432")),
    database=os.getenv("DB_NAME"),
)

# Create the database engine.
engine = create_engine(
    DATABASE_URL,
    echo=False
)


# Provides a database session for API requests.
def get_session():
    with Session(engine) as session:
        yield session
