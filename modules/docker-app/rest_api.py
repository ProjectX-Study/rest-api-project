from flask import Flask, request, jsonify
import boto3, json, pymysql, os

app = Flask(__name__)

def get_secret():
    secret_name = os.environ["SECRET_NAME"]
    client = boto3.client('secretsmanager')
    secret = json.loads(client.get_secret_value(SecretId=secret_name)['SecretString'])

    # Split host and port if in "address:port" format
    host_addr = secret["host"].split(":")
    secret["host"] = host_addr[0]
    secret["port"] = int(host_addr[1]) if len(host_addr) > 1 else 3306

    return secret

def get_connection():
    secret = get_secret()
    return pymysql.connect(
        host=secret["host"],
        port=secret["port"],
        user=secret["username"],
        password=secret["password"],
        db=secret["db_name"],  # <-- use dynamic db name
        cursorclass=pymysql.cursors.DictCursor
    )

@app.route("/data", methods=["POST"])
def create_data():
    content = request.json
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("INSERT INTO items (name) VALUES (%s)", (content["name"],))
        conn.commit()
    conn.close()
    return jsonify({"message": "Record has been succesfully created"}), 201

@app.route("/data", methods=["GET"])
def read_data():
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("SELECT * FROM items")
        rows = cur.fetchall()
    conn.close()
    return jsonify(rows)

@app.route("/data/<int:item_id>", methods=["DELETE"])
def delete_data(item_id):
    conn = get_connection()
    with conn.cursor() as cur:
        cur.execute("DELETE FROM items WHERE id = %s", (item_id,))
        conn.commit()
    conn.close()
    return jsonify({"message": f"Deleted item {item_id}"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
