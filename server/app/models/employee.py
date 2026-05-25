from sqlalchemy import Column, DateTime, ForeignKey, Integer, Numeric, String
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database.session import Base


class Employee(Base):
    __tablename__ = "employees"

    id = Column(Integer, primary_key=True, index=True)
    employee_code = Column(String(50), unique=True, nullable=False)
    full_name = Column(String(150), nullable=False)
    email = Column(String(150), unique=True)
    phone = Column(String(30))
    job_position = Column(String(100))
    department_id = Column(Integer, ForeignKey("departments.id"))
    manager_id = Column(Integer, ForeignKey("employees.id"))
    status = Column(String(30), default="active")
    hourly_rate = Column(Numeric(12, 2), default=0)
    created_at = Column(DateTime, server_default=func.now())

    department = relationship("Department")
    manager = relationship("Employee", remote_side=[id])
