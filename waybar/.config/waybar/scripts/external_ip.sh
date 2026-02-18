#!/usr/bin/env bash
curl -fsS --max-time 2 https://api.ipify.org 2>/dev/null || echo "no-net"
