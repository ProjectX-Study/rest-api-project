# Use lightweight Python base image
FROM python:3.10-slim

# Set working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code
COPY app.py .

# Set environment variable for Flask
ENV FLASK_APP=app.py
ENV FLASK_RUN_PORT=8080

# Expose port
EXPOSE 8080

# Command to run app
CMD ["python", "app.py"]
