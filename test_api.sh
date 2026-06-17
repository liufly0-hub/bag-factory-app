#!/bin/bash
curl -s -X POST http://127.0.0.1:3100/api/init
echo ""
echo "---TEST LOGIN---"
TOKEN=$(curl -s -X POST http://127.0.0.1:3100/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"3389716868@qq.com","password":"boss8888"}' | python3 -c "import sys,json; print(json.load(sys.stdin).get('token','NO_TOKEN'))" 2>/dev/null)
echo "Token: $TOKEN"
curl -s http://127.0.0.1:3100/api/orders -H "Authorization: Bearer $TOKEN"