#!/usr/bin/env bash
ss -Htan state established 2>/dev/null | wc -l
