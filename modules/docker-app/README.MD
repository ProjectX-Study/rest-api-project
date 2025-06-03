Flask REST API with AWS RDS & Secrets Manager
============================================

This is a secure, Docker-ready REST API using Flask. It connects to an AWS RDS (MySQL or Aurora) database using credentials securely retrieved from AWS Secrets Manager.

Features:
- REST endpoints: Create, Read, Delete
- AWS Secrets Manager for secure DB credentials
- Docker-compatible
- Health check endpoint at "/"
- Input validation and error handling

---

Project Structure:
- Dockerfile
- .dockerignore
- requirements.txt
- rest_api.py  (main application file)
- README.txt   (this file)

---

How to Use (Local Setup):
1. Clone the repo:
   git clone https://github.com/your-org/docker-app.git
   cd docker-app

2. Create a virtual environment (optional but recommended):
   python -m venv venv
   venv\Scripts\activate  (on Windows)

3. Install dependencies:
   pip install -r requirements.txt

4. Set environment variables (PowerShell example):
   $env:SECRET_NAME="your-secret-id"
   $env:AWS_REGION="your-aws-region"  # e.g., us-east-1

5. Run the API locally:
   python rest_api.py

Visit: http://localhost:8080

---

Docker Instructions:
1. Build the Docker image:
   docker build -t flask-rds-api:test .

2. Run the Docker container:
   docker run -p 8080:8080 `
     -e SECRET_NAME=your-secret-id `
     -e AWS_REGION=your-aws-region `
     flask-rds-api:test

---

Expected AWS Secret Format (JSON in AWS Secrets Manager):
{
  "username": "myuser",
  "password": "mypassword",
  "host": "mydb.xxxxx.us-east-1.rds.amazonaws.com:3306",
  "db_name": "mydatabase"
}

---

API Endpoints:

GET /
Health check
Response:
{
  "message": "API is running",
  "timestamp": "2025-06-03T12:00:00Z"
}

GET /data
Fetch all items
Response:
[
  { "id": 1, "name": "Item 1" },
  { "id": 2, "name": "Item 2" }
]

POST /data
Create a new item
Request:
{
  "name": "New Item"
}
Response:
{
  "id": 3,
  "name": "New Item"
}
Errors:
- 400 if 'name' is missing or invalid

DELETE /data/<item_id>
Delete an item by ID
Response:
{
  "message": "Deleted item 3"
}
Errors:
- 404 if the ID does not exist

---

All errors return JSON:
{
  "error": "Invalid request data",
  "messages": {
    "name": ["Missing data for required field."]
  }
}

---

Common Issues:
- Ensure RDS is publicly accessible or you're running from the right VPC/subnet
- Ensure Docker has access to the internet (for AWS Secrets Manager)
- Use `docker logs <container_id>` to check container issues
- Make sure your IAM role or AWS credentials allow secretsmanager:GetSecretValue

---

License: MIT
