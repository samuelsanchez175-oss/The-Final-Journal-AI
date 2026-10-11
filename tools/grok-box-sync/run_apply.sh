#!/bin/bash
cd "$(dirname "$0")" && rm -rf b && mkdir b && tar xzf bundle.tgz -C b 2>/dev/null && bash b/apply.sh && sed -n 3,5p ../../docs/play-on-words/chat-status/grok-box.md
