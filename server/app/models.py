# server/app/models.py

# 1. Correct the import statement
from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, Date, Numeric, TIMESTAMP
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func # Import 'func' for server_default
from sqlalchemy.orm import relationship
import uuid
from .database import Base

class User(Base):
    __tablename__ = "users"
    user_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    username = Column(String, unique=True, index=True)
    # 2. Correct the column definition
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    goals = relationship("Goal", back_populates="owner")
    habits = relationship("Habit", back_populates="owner")
    progress_logs = relationship("ProgressLog", back_populates="owner")

class Goal(Base):
    __tablename__ = "goals"
    goal_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(String)
    goal_type = Column(String, nullable=False)
    target_value = Column(Numeric)
    target_unit = Column(String)
    target_date = Column(Date)
    status = Column(String, default='active')
    # 2. Correct the column definition
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    owner = relationship("User", back_populates="goals")
    habits = relationship("Habit", back_populates="goal")

class Habit(Base):
    __tablename__ = "habits"
    habit_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    goal_id = Column(UUID(as_uuid=True), ForeignKey("goals.goal_id"), nullable=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id"), nullable=False)
    title = Column(String, nullable=False)
    frequency_type = Column(String)
    frequency_value = Column(Integer)
    is_bad_habit = Column(Boolean, default=False)
    # 2. Correct the column definition
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    owner = relationship("User", back_populates="habits")
    goal = relationship("Goal", back_populates="habits")
    progress_logs = relationship("ProgressLog", back_populates="habit")

class ProgressLog(Base):
    __tablename__ = "progress_logs"
    log_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    habit_id = Column(UUID(as_uuid=True), ForeignKey("habits.habit_id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id"), nullable=False)
    log_date = Column(Date, nullable=False)
    value_achieved = Column(Numeric, default=0)
    notes = Column(String)
    # 2. Correct the column definition
    created_at = Column(TIMESTAMP(timezone=True), server_default=func.now())

    owner = relationship("User", back_populates="progress_logs")
    habit = relationship("Habit", back_populates="progress_logs")