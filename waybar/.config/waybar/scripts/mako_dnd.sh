#!/usr/bin/env bash
makoctl mode | grep -qi 'do-not-disturb' && echo "DND" || echo "ON"
