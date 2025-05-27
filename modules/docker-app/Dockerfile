# Use a minimal base image with Python
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the app
COPY app.py .

# Expose the API port
EXPOSE 8080

# Run the application
CMD ["python", "app.py"]
