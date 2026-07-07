from sqlalchemy import Column, BigInteger, String, Text, Integer, Float, Boolean, TIMESTAMP
from sqlalchemy.sql import func
from database import Base

class User(Base):
    __tablename__ = "users"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    email = Column(String(255), unique=True, nullable=False)
    nickname = Column(String(100))
    provider = Column(String(50), default="google")
    created_at = Column(TIMESTAMP, server_default=func.now())

class MusicProject(Base):
    __tablename__ = "music_projects"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(BigInteger, nullable=False)
    title = Column(String(255))
    input_type = Column(String(50))
    original_file_url = Column(Text)
    status = Column(String(50), default="uploaded")
    created_at = Column(TIMESTAMP, server_default=func.now())

class MusicAnalysis(Base):
    __tablename__ = "music_analysis"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    project_id = Column(BigInteger, nullable=False)
    bpm = Column(Integer)
    melody_pattern = Column(Text)
    instrument_info = Column(Text)
    genre = Column(String(100))
    analysis_json = Column(Text)

class GugakConversion(Base):
    __tablename__ = "gugak_conversions"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    project_id = Column(BigInteger, nullable=False)
    converted_audio_url = Column(Text)
    rhythm_type = Column(String(100))
    main_instruments = Column(Text)
    created_at = Column(TIMESTAMP, server_default=func.now())

class MvGeneration(Base):
    __tablename__ = "mv_generations"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    project_id = Column(BigInteger, nullable=False)
    conversion_id = Column(BigInteger, nullable=False)
    mv_url = Column(Text)
    visual_style = Column(String(100))
    created_at = Column(TIMESTAMP, server_default=func.now())

class RealtimeEffect(Base):
    __tablename__ = "realtime_effects"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    mv_id = Column(BigInteger, nullable=False)
    beat_strength = Column(Float)
    brush_speed = Column(Float)
    transition_speed = Column(Float)

class LibraryItem(Base):
    __tablename__ = "library_items"
    id = Column(BigInteger, primary_key=True, autoincrement=True)
    user_id = Column(BigInteger, nullable=False)
    project_id = Column(BigInteger, nullable=False)
    is_favorite = Column(Boolean, default=False)
    created_at = Column(TIMESTAMP, server_default=func.now())