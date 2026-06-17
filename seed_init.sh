#!/bin/bash
# 工厂APP - 初始化种子数据
PASS_HASH='$2a$10$dummydummydummydummydummy'
curl -s -X POST http://127.0.0.1:3100/api/init -H "Content-Type: application/json" -d '{}' --connect-timeout 10 --max-time 10
echo ""
echo "Done"
