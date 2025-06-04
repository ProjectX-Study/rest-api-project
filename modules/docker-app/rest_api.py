import os
import json
import logging
from datetime import datetime, timedelta

import boto3
from botocore.exceptions import ClientError
from flask import Flask, request, jsonify, abort, make_response
from flask_sqlalchemy import SQLAlchemy
from marshmallow import Schema, fields, ValidationError

# ------------------------------------------------------------------------------
# ── Configuration & AWS Secrets Management ────────────────────────────────────
# ------------------------------------------------------------------------------

def fetch_aws_secret(secret_name: str, region_name: str = None, cache_ttl: int = 300):
    """
    Retrieve (and cache) a JSON‐formatted secret from AWS Secrets Manager,
    expected to contain at least "username" and "password".
    Caches in memory for `cache_ttl` seconds to avoid frequent calls.
    """
    global _cached_secret, _secret_recv_time

    now = datetime.now()
    if (
        "_cached_secret" in globals()
        and "_secret_recv_time" in globals()
        and (now - _secret_recv_time) < timedelta(seconds=cache_ttl)
    ):
        return _cached_secret

    try:
        client = boto3.client(
            "secretsmanager",
            region_name=region_name or os.getenv("AWS_REGION")
        )
        resp = client.get_secret_value(SecretId=secret_name)
        secret_dict = json.loads(resp["SecretString"])
        _cached_secret = secret_dict
        _secret_recv_time = now
        return secret_dict

    except ClientError as e:
        logging.error(f"Could not fetch secret '{secret_name}': {e}")
        raise


class Config:
    # Environment variables (must be set):
    #   SECRET_NAME   → the Secrets Manager secret that holds {"username","password"}
    #   AWS_REGION    → AWS region for Secrets Manager (e.g. “us-east-1”)
    #   DB_ENDPOINT   → RDS endpoint, e.g. "mydb.xxxx.us-east-1.rds.amazonaws.com:3306"
    #   DB_NAME       → database name, e.g. "mydatabase"
    #
    SECRET_NAME = os.getenv("SECRET_NAME", "").strip()
    AWS_REGION = os.getenv("AWS_REGION", "").strip()
    DB_ENDPOINT = os.getenv("DB_ENDPOINT", "").strip()
    DB_NAME = os.getenv("DB_NAME", "").strip()

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JSON_SORT_KEYS = False  # keep JSON keys in defined order
    PROPAGATE_EXCEPTIONS = True  # so Flask errorhandlers run

    @classmethod
    def init_app(cls, app: Flask):
        # 1️⃣ Required checks:
        if not cls.SECRET_NAME:
            raise RuntimeError("SECRET_NAME environment variable is required.")
        if not cls.DB_ENDPOINT:
            raise RuntimeError("DB_ENDPOINT environment variable is required.")
        if not cls.DB_NAME:
            raise RuntimeError("DB_NAME environment variable is required.")

        # 2️⃣ Fetch username/password from Secrets Manager:
        secret = fetch_aws_secret(
            cls.SECRET_NAME,
            region_name=cls.AWS_REGION
        )
        #
        # Expecting the secret JSON to look like:
        # {
        #   "username": "dbuser",
        #   "password": "dbpass"
        # }
        user = secret.get("username")
        pwd = secret.get("password")
        if not user or not pwd:
            raise RuntimeError(
                f"Secret '{cls.SECRET_NAME}' must contain 'username' and 'password'."
            )

        # 3️⃣ Parse DB_ENDPOINT into host and port:
        #    DB_ENDPOINT example: "mydb.xxxx.us-east-1.rds.amazonaws.com:3306"
        host_addr = cls.DB_ENDPOINT.split(":")
        db_host = host_addr[0]
        try:
            db_port = int(host_addr[1]) if len(host_addr) > 1 else 3306
        except ValueError:
            raise RuntimeError(f"Invalid DB_ENDPOINT port: {host_addr[1]}")

        # 4️⃣ Build the SQLAlchemy connection URI:
        #    mysql+pymysql://{user}:{pwd}@{db_host}:{db_port}/{DB_NAME}
        app.config["SQLALCHEMY_DATABASE_URI"] = (
            f"mysql+pymysql://{user}:{pwd}@{db_host}:{db_port}/{cls.DB_NAME}"
        )

        # 5️⃣ (Optional) tuning for engine:
        app.config["SQLALCHEMY_ENGINE_OPTIONS"] = {
            "pool_size": 5,
            "max_overflow": 10,
            "pool_timeout": 30,
            "pool_recycle": 1800,
        }


# ------------------------------------------------------------------------------
# ── Initialize Flask & Database ────────────────────────────────────────────────
# ------------------------------------------------------------------------------

app = Flask(__name__)
app.config.from_object(Config)
Config.init_app(app)
db = SQLAlchemy(app)


# ------------------------------------------------------------------------------
# ── Database Model ─────────────────────────────────────────────────────────────
# ------------------------------------------------------------------------------

class Item(db.Model):
    __tablename__ = "items"
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    name = db.Column(db.String(255), nullable=False)

    def to_dict(self):
        return {"id": self.id, "name": self.name}


# ------------------------------------------------------------------------------
# ── Marshmallow Schemas for Validation ────────────────────────────────────────
# ------------------------------------------------------------------------------

class ItemSchema(Schema):
    name = fields.String(required=True, validate=lambda s: 0 < len(s) <= 255)

item_schema = ItemSchema()
item_id_schema = Schema.from_dict({"item_id": fields.Integer(required=True, strict=True)})()


# ------------------------------------------------------------------------------
# ── Error Handlers ─────────────────────────────────────────────────────────────
# ------------------------------------------------------------------------------

@app.errorhandler(ValidationError)
def handle_validation_error(e: ValidationError):
    response = {"error": "Invalid request data", "messages": e.messages}
    return make_response(jsonify(response), 400)

@app.errorhandler(404)
def handle_not_found(e):
    response = {"error": "Resource not found", "message": str(e)}
    return make_response(jsonify(response), 404)

@app.errorhandler(405)
def handle_method_not_allowed(e):
    response = {"error": "Method not allowed", "message": str(e)}
    return make_response(jsonify(response), 405)

@app.errorhandler(500)
def handle_internal_error(e):
    response = {"error": "Internal server error", "message": "An unexpected error occurred."}
    logging.exception("Internal Server Error: %s", e)
    return make_response(jsonify(response), 500)


# ------------------------------------------------------------------------------
# ── Routes ────────────────────────────────────────────────────────────────────
# ------------------------------------------------------------------------------

@app.route("/", methods=["GET"])
def index():
    """
    Basic health check or welcome endpoint.
    """
    return jsonify({
        "message": "API is running",
        "timestamp": datetime.utcnow().isoformat() + "Z"
    }), 200


@app.route("/data", methods=["POST"])
def create_data():
    """
    Create a new item. Expects JSON body: { "name": "<string>" }.
    """
    try:
        payload = item_schema.load(request.get_json(force=True))
    except ValidationError as ve:
        raise  # handled by @app.errorhandler(ValidationError)

    new_item = Item(name=payload["name"])
    try:
        db.session.add(new_item)
        db.session.commit()
    except Exception as ex:
        db.session.rollback()
        logging.error("DB Error on INSERT: %s", ex)
        abort(500)

    return jsonify(new_item.to_dict()), 201


@app.route("/data", methods=["GET"])
def read_data():
    """
    Read all items.
    """
    try:
        items = Item.query.all()
        result = [item.to_dict() for item in items]
    except Exception as ex:
        logging.error("DB Error on SELECT: %s", ex)
        abort(500)

    return jsonify(result), 200


@app.route("/data/<int:item_id>", methods=["DELETE"])
def delete_data(item_id):
    """
    Delete an item by ID.
    """
    if item_id <= 0:
        return make_response(
            jsonify({
                "error": "Invalid item_id",
                "message": "item_id must be a positive integer."
            }),
            400
        )

    try:
        item = Item.query.get(item_id)
        if not item:
            abort(404, description=f"Item with id={item_id} not found.")
        db.session.delete(item)
        db.session.commit()
    except Exception as ex:
        db.session.rollback()
        logging.error("DB Error on DELETE: %s", ex)
        abort(500)

    return jsonify({"message": f"Deleted item {item_id}"}), 200


# ------------------------------------------------------------------------------
# ── Database Initialization Utility (Optional) ────────────────────────────────
# ------------------------------------------------------------------------------

@app.cli.command("init-db")
def init_db():
    """
    CLI command: `flask init-db`
    Creates tables based on models. (Use at your own risk—will not drop existing data.)
    """
    try:
        db.create_all()
        print("Database tables created.")
    except Exception as ex:
        print(f"Error creating tables: {ex}")


# ------------------------------------------------------------------------------
# ── Entry Point ────────────────────────────────────────────────────────────────
# ------------------------------------------------------------------------------

if __name__ == "__main__":
    # Ensure debug=False in production
    app.run(host="0.0.0.0", port=8080, debug=False)
