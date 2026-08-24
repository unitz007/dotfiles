#!/bin/bash
# Test script for AI assistant

echo "Testing AI Assistant installation..."

# Test 1: Check if script exists and is executable
if [ -f "./ai-assistant.sh" ] && [ -x "./ai-assistant.sh" ]; then
    echo "✓ AI Assistant script found and executable"
else
    echo "✗ AI Assistant script missing or not executable"
    exit 1
fi

# Test 2: Check dependencies
if command -v jq &> /dev/null; then
    echo "✓ jq dependency found"
else
    echo "✗ jq dependency missing"
    exit 1
fi

# Test 3: Check help output (without calling Ollama)
AI_MODEL="test-model" ./ai-assistant.sh 2>/dev/null | head -5
echo "✓ Help output test completed"

echo "AI Assistant installation test completed successfully!"