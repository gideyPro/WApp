#!/bin/bash
# WaveMart API - Direct Call Simulation with cURL
# Base URL: https://wavemart.et/api

BASE_URL="https://wavemart.et/api"
PHONE="+251912345678"
OTP_CODE="123456"
CONVERSATION_ID=1  # Change this to a valid conversation ID

echo "=========================================="
echo "WaveMart API - Direct Call Flow Simulation"
echo "=========================================="
echo ""

# Step 1: Send OTP
echo "Step 1: Sending OTP to $PHONE..."
echo "POST $BASE_URL/auth/send-otp"
curl -X POST "$BASE_URL/auth/send-otp" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"phone_number\": \"$PHONE\"}" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

# Step 2: Verify OTP (Login)
echo "Step 2: Verifying OTP (Login)..."
echo "POST $BASE_URL/auth/verify-otp"
LOGIN_RESPONSE=$(curl -X POST "$BASE_URL/auth/verify-otp" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d "{\"phone_number\": \"$PHONE\", \"otp_code\": \"$OTP_CODE\"}" \
  -s)

echo "$LOGIN_RESPONSE"
echo ""

# Extract token from login response
TOKEN=$(echo "$LOGIN_RESPONSE" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
  echo "Failed to get token. Using mock token for demo..."
  TOKEN="mock_token_here"
fi

echo "Token: ${TOKEN:0:20}..."
echo ""

# Step 3: Get Conversations (to find a valid conversation ID)
echo "Step 3: Fetching conversations..."
echo "GET $BASE_URL/messages/fetch-list"
curl -X GET "$BASE_URL/messages/fetch-list" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

# Step 4: Start Direct Call
echo "Step 4: Starting direct call to conversation $CONVERSATION_ID..."
echo "POST $BASE_URL/conferences/start-direct/$CONVERSATION_ID"
START_CALL_RESPONSE=$(curl -X POST "$BASE_URL/conferences/start-direct/$CONVERSATION_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  -s)

echo "$START_CALL_RESPONSE"
echo ""

# Extract conference ID
CONFERENCE_ID=$(echo "$START_CALL_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$CONFERENCE_ID" ]; then
  echo "Failed to get conference ID. Using mock ID for demo..."
  CONFERENCE_ID=1
fi

echo "Conference ID: $CONFERENCE_ID"
echo ""

# Step 5: Check for Incoming Call (simulating the recipient checking)
echo "Step 5: Checking for incoming call (recipient side)..."
echo "GET $BASE_URL/conferences/check-incoming"
curl -X GET "$BASE_URL/conferences/check-incoming" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

# Step 6: Join Conference (recipient joining)
echo "Step 6: Joining conference $CONFERENCE_ID..."
echo "GET $BASE_URL/conferences/$CONFERENCE_ID/join"
curl -X GET "$BASE_URL/conferences/$CONFERENCE_ID/join" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

# Step 7: Get Conference Details
echo "Step 7: Getting conference details..."
echo "GET $BASE_URL/conferences/$CONFERENCE_ID"
curl -X GET "$BASE_URL/conferences/$CONFERENCE_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

# Step 8: Ping Conference (keep-alive)
echo "Step 8: Pinging conference..."
echo "POST $BASE_URL/conferences/$CONFERENCE_ID/ping"
curl -X POST "$BASE_URL/conferences/$CONFERENCE_ID/ping" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Accept: application/json" \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

# Step 9: Update Conference Status (end call)
echo "Step 9: Ending conference..."
echo "PATCH $BASE_URL/conferences/$CONFERENCE_ID/status"
curl -X PATCH "$BASE_URL/conferences/$CONFERENCE_ID/status" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"status": "ended"}' \
  -w "\nHTTP Status: %{http_code}\n" \
  -s
echo ""
echo ""

echo "=========================================="
echo "Simulation Complete"
echo "=========================================="
