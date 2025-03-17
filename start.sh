#!/bin/bash

# Create necessary directories
mkdir -p files seeder_files logs

# Start tracker in the background with proper IP
echo "Starting tracker server..."
python tools/tracker_server.py --ip 0.0.0.0 --port 12345 --log-level INFO > logs/tracker.log 2>&1 &
TRACKER_PID=$!

# Wait for tracker to start
echo "Waiting for tracker to initialize..."
sleep 5

# Start seeder in the background
echo "Starting seeder client..."
python tools/seeder_client.py --ip 0.0.0.0 --port 8001 --tracker-ip 127.0.0.1 --tracker-port 12345 --files-dir ./tools/seeder_files --log-level INFO > logs/seeder.log 2>&1 &
SEEDER_PID=$!

# Start backend (this will be the main process)
echo "Starting backend API server..."
uvicorn main:app --host 0.0.0.0 --port 8000 --log-level info

# Cleanup function to handle process termination
cleanup() {
    echo "Stopping services..."
    kill $TRACKER_PID
    kill $SEEDER_PID
    exit 0
}

# Register the cleanup function for SIGTERM and SIGINT
trap cleanup SIGTERM SIGINT

# Keep the script running if uvicorn stops unexpectedly
wait