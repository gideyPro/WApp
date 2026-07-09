# Wavemart API - cURL Reference

Quick reference for direct call flows using cURL. Tokens below are valid as of 2026-04-24.

## Tokens (Valid for testing)

| User | ID | Role | Token |
|------|-----|------|-------|
| Gidey Tsegay | 3 | admin | `83\|SJJ9JJ4APbWg78LVI9cIVuLTgfdxemw9MG7zzqhE7aabcdb5` |
| Mukera Hade | 14 | user | `110\|5sLuho5mBblU4ghjtCJeLU4mOvD4WCd2fjMJixGTbdc4bc8f` |

---

## 1. Login Flow (Get Token)

### Step 1: Send OTP
```bash
curl -X POST "https://wavemart.et/api/auth/send-otp" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"phone_number": "+251912345678"}'
```

**Response:**
```json
{"message":"OTP code sent to your phone number."}
```

### Step 2: Verify OTP (Login)
```bash
curl -X POST "https://wavemart.et/api/auth/login" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"phone_number": "+251912345678", "otp_code": "938996"}'
```

**Response:**
```json
{
  "message": "Login successful",
  "user": {
    "id": 14,
    "first_name": "Mukera",
    "last_name": "Hade",
    "username": "mukerahade677",
    "email": null,
    "phone_number": "+251912345678",
    "role": "user",
    "gender": "male",
    "is_phone_verified": true,
    "is_kyc_verified": true,
    "created_at": "2026-02-08T14:17:32.000000Z",
    "updated_at": "2026-02-08T14:23:19.000000Z",
    "deleted_at": null
  },
  "token": "110|5sLuho5mBblU4ghjtCJeLU4mOvD4WCd2fjMJixGTbdc4bc8f"
}
```

---

## 2. Direct Call Flow

### Step 1: Create Conference (Creator)
Requires a listing ID and buyer IDs. Use admin token (Gidey).

```bash
curl -X POST "https://wavemart.et/api/conferences/62" \
  -H "Authorization: Bearer 83|SJJ9JJ4APbWg78LVI9cIVuLTgfdxemw9MG7zzqhE7aabcdb5" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"buyer_ids": [14]}'
```

**Response:**
```json
{
  "success": true,
  "message": "Conference scheduled successfully!",
  "data": {
    "listing_id": 62,
    "created_by": 3,
    "seller_id": 3,
    "scheduled_at": "2026-04-24T11:43:46.000000Z",
    "notes": null,
    "status": "scheduled",
    "room_id": "room-EZbADEDTsLUMigM0",
    "id": 123,
    "participants": [
      {"user_id": 3, "role": "admin"},
      {"user_id": 14, "role": "buyer"}
    ]
  }
}
```

### Step 2: Join Conference (Creator starts it)
```bash
curl -X GET "https://wavemart.et/api/conferences/123/join" \
  -H "Authorization: Bearer 83|SJJ9JJ4APbWg78LVI9cIVuLTgfdxemw9MG7zzqhE7aabcdb5" \
  -H "Accept: application/json"
```

**Response:**
```json
{
  "success": true,
  "data": {
    "conference": {
      "id": 123,
      "listing_id": 62,
      "room_id": "room-EZbADEDTsLUMigM0",
      "created_by": 3,
      "seller_id": 3,
      "status": "active",
      "started_at": "2026-04-24T11:44:17.000000Z",
      "ended_at": null,
      "duration_seconds": 0
    },
    "jitsi_url": "https://jitsi.member.fsf.org/WM_room-EZbADEDTsLUMigM0",
    "jitsi_token": null,
    "jitsi_domain": "jitsi.member.fsf.org",
    "app_id": "vpaas-magic-cookie-cf3ef8f230af4d2da79f49c481d7ec07",
    "room_id": "WM_room-EZbADEDTsLUMigM0"
  }
}
```

### Step 3: Check Incoming Call (Recipient)
Use recipient token (Mukera).

```bash
curl -X GET "https://wavemart.et/api/conferences/check-incoming" \
  -H "Authorization: Bearer 110|5sLuho5mBblU4ghjtCJeLU4mOvD4WCd2fjMJixGTbdc4bc8f" \
  -H "Accept: application/json"
```

**Response (no call):**
```json
{"incoming": false}
```

**Response (call waiting):**
```json
{
  "incoming": true,
  "conference_id": 123,
  "caller_name": "Gidey Tsegay",
  "caller_avatar": null,
  "caller_initials": "GT",
  "listing_title": "Property Inquiry"
}
```

### Step 4: Join Conference (Recipient)
```bash
curl -X GET "https://wavemart.et/api/conferences/123/join" \
  -H "Authorization: Bearer 110|5sLuho5mBblU4ghjtCJeLU4mOvD4WCd2fjMJixGTbdc4bc8f" \
  -H "Accept: application/json"
```

**Response:** Same structure as Step 2 with participant info.

### Step 5: End Conference
```bash
curl -X PATCH "https://wavemart.et/api/conferences/123/status" \
  -H "Authorization: Bearer 83|SJJ9JJ4APbWg78LVI9cIVuLTgfdxemw9MG7zzqhE7aabcdb5" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"status": "ended"}'
```

**Response:**
```json
{
  "success": true,
  "data": {
    "conference": {
      "id": 123,
      "status": "ended",
      "ended_at": "2026-04-24T11:45:00.000000Z",
      "duration_seconds": -43
    }
  }
}
```

---

## 3. Other Useful Endpoints

### Get Current User
```bash
curl -X GET "https://wavemart.et/api/user" \
  -H "Authorization: Bearer 83|SJJ9JJ4APbWg78LVI9cIVuLTgfdxemw9MG7zzqhE7aabcdb5"
```

### List Conferences
```bash
curl -X GET "https://wavemart.et/api/conferences" \
  -H "Authorization: Bearer 83|SJJ9JJ4APbWg78LVI9cIVuLTgfdxemw9MG7zzqhE7aabcdb5"
```

### Get Messages/Conversations
```bash
curl -X GET "https://wavemart.et/api/messages" \
  -H "Authorization: Bearer 83|SJJ9JJ4APbWg78LVI9cIVuLTgfdxemw9MG7zzqhE7aabcdb5"
```

### Ping Conference (Keep-alive)
```bash
curl -X POST "https://wavemart.et/api/conferences/123/ping" \
  -H "Authorization: Bearer 83|SJJ9JJ4APbWg78LVI9cIVuLTgfdxemw9MG7zzqhE7aabcdb5"
```

---

## Notes

- Base URL: `https://wavemart.et/api`
- All endpoints (except auth) require `Authorization: Bearer <token>` header
- Conference `start-direct` endpoint is blocked at web server level (403) - use `createConference` with `buyer_ids` instead
- Jitsi URLs use community server: `https://jitsi.member.fsf.org`
- Token format: `<id>|<random_string>` (Sanctum token)
