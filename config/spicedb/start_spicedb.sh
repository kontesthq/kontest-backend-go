#!/bin/bash

# Print a message to indicate the start of SpiceDB
echo "Starting SpiceDB with the following configuration:"
echo "  GRPC_PRESHARED_KEY: $SPICEDB_GRPC_PRESHARED_KEY"
echo "  DATASTORE_ENGINE: $SPICEDB_DATASTORE_ENGINE"
echo "  DATASTORE_CONN_URI: $SPICEDB_DATASTORE_CONN_URI"

# Run SpiceDB migrations
echo "Running migrations..."
/usr/bin/spicedb migrate head \
  --datastore-engine "$SPICEDB_DATASTORE_ENGINE" \
  --datastore-conn-uri "$SPICEDB_DATASTORE_CONN_URI"

# Run SpiceDB with the environment variables
/usr/bin/spicedb serve \
  --grpc-preshared-key "$SPICEDB_GRPC_PRESHARED_KEY" \
  --datastore-engine "$SPICEDB_DATASTORE_ENGINE" \
  --datastore-conn-uri "$SPICEDB_DATASTORE_CONN_URI" \
  --grpc-tls-cert-path "$SPICEDB_GRPC_TLS_CERT_PATH" \
  --grpc-tls-key-path "$SPICEDB_GRPC_TLS_KEY_PATH" \
  --http-tls-cert-path "$SPICEDB_HTTP_TLS_CERT_PATH" \
  --http-tls-key-path "$SPICEDB_HTTP_TLS_KEY_PATH" &

echo "Waiting for SpiceDB to be ready for 10 seconds..."

# Wait for SpiceDB to be ready
sleep 10

echo "Uploading schema..."
# Upload the schema using the Zed client
zed schema write --endpoint "localhost:50051" --token "$SPICEDB_GRPC_PRESHARED_KEY" --no-verify-ca spicedb_schema.zed

echo "Schema uploaded successfully"

echo "SpiceDB is ready to use"

echo "Now waiting..."
wait