#!/bin/bash

MODE=$(makoctl mode 2>/dev/null)

if echo "$MODE" | grep -q "do-not-disturb"; then
  makoctl mode -r do-not-disturb
else
  makoctl mode -a do-not-disturb
fi
