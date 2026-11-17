from sqlmodel import Field, SQLModel


class FarmerProfile(SQLModel, table=True):
    __tablename__ = "farmer_profiles"

    user_id: int = Field(foreign_key="users.id", primary_key=True)
    farm_name: str = Field(default="", max_length=160)
    farm_location: str = Field(default="", max_length=240)
