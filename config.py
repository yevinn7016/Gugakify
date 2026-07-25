import os
import cloudinary
import cloudinary.uploader
from dotenv import load_dotenv

load_dotenv()

cloudinary.config(
    cloud_name=os.getenv("ppd274ry"),
    api_key=os.getenv("444488845913566"),
    api_secret=os.getenv("tHqdzJhoR7ukp3-PwFs9qZh3MPQ")
)