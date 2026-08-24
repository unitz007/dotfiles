#!/bin/bash
# AI Assistant for Development Environment
# Provides AI-powered code completion, shell suggestions, and general assistance

set -e

# Configuration
AI_MODEL="${AI_MODEL:-llama3.2:1b}"  # Default to lightweight model
OLLAMA_HOST="${OLLAMA_HOST:-http://localhost:11434}"
CACHE_DIR="${HOME}/.cache/ai-assistant"
mkdir -p "${CACHE_DIR}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Ollama is installed and running
check_ollama() {
    if ! command -v ollama &> /dev/null; then
        echo -e "${RED}Ollama not found!${NC}"
        echo "Please install Ollama: https://ollama.com/"
        echo "Or set AI_PROVIDER=external and configure AI_API_KEY"
        return 1
    fi
    
    # Check if Ollama server is running
    if ! curl -s --max-time 2 "${OLLAMA_HOST}/" &> /dev/null; then
        echo -e "${YELLOW}Starting Ollama server...${NC}"
        ollama serve &> /dev/null &
        sleep 3
    fi
}

# Pull model if not present
ensure_model() {
    if ! ollama list | grep -q "${AI_MODEL}"; then
        echo -e "${YELLOW}Pulling model ${AI_MODEL}...${NC}"
        ollama pull "${AI_MODEL}"
    fi
}

# Get AI response
get_ai_response() {
    local prompt="$1"
    local context="$2"
    
    local full_prompt
    if [[ -n "${context}" ]]; then
        full_prompt="Context: ${context}\n\nQuestion: ${prompt}"
    else
        full_prompt="${prompt}"
    fi
    
    # Create cache key
    local cache_key
    cache_key=$(echo -n "${full_prompt}" | shasum | cut -d' ' -f1)
    local cache_file="${CACHE_DIR}/${cache_key}.txt"
    
    # Check cache first
    if [[ -f "${cache_file}" ]]; then
        cat "${cache_file}"
        return 0
    fi
    
    # Get response from Ollama
    local response
    response=$(curl -s -X POST "${OLLAMA_HOST}/api/generate" \
        -H "Content-Type: application/json" \
        -d "{\"model\":\"${AI_MODEL}\",\"prompt\":\"${full_prompt}\",\"stream\":false}" \
        | jq -r '.response' 2>/dev/null || echo "Error getting AI response")
    
    # Cache the response
    echo "${response}" > "${cache_file}"
    echo "${response}"
}

# Shell command suggestion
suggest_command() {
    local current_input="$1"
    local prompt="You are a shell expert. Suggest a single shell command to accomplish this task: ${current_input}. Only output the command, nothing else."
    
    get_ai_response "${prompt}"
}

# Code explanation
explain_code() {
    local code="$1"
    local language="$2"
    local prompt="Explain this ${language} code in simple terms, highlighting key concepts and potential issues:"
    
    get_ai_response "${prompt}" "${code}"
}

# Code completion/refactoring
complete_code() {
    local code="$1"
    local language="$2"
    local task="$3"
    local prompt="Given this ${language} code, ${task}:"
    
    get_ai_response "${prompt}" "${code}"
}

# General assistant
ai_assistant() {
    if [[ $# -eq 0 ]]; then
        echo "AI Assistant - Your development copilot"
        echo ""
        echo "Usage:"
        echo "  ai <question>                    - General AI assistance"
        echo "  ai suggest <task>                - Suggest shell commands"
        echo "  ai explain <file>                - Explain code in a file"
        echo "  ai complete <file>               - Suggest code improvements"
        echo "  ai refactor <file>               - Suggest code refactoring"
        echo ""
        echo "Configuration:"
        echo "  AI_MODEL=${AI_MODEL}"
        echo "  OLLAMA_HOST=${OLLAMA_HOST}"
        return 0
    fi
    
    local command="$1"
    shift
    
    case "${command}" in
        suggest)
            if [[ $# -eq 0 ]]; then
                echo "Usage: ai suggest <task description>"
                return 1
            fi
            suggest_command "$*"
            ;;
        explain|complete|refactor)
            if [[ $# -eq 0 ]]; then
                echo "Usage: ai ${command} <file>"
                return 1
            fi
            local file="$1"
            if [[ ! -f "${file}" ]]; then
                echo "File not found: ${file}"
                return 1
            fi
            
            local code
            code=$(cat "${file}")
            local language
            language=$(get_file_language "${file}")
            
            case "${command}" in
                explain)
                    explain_code "${code}" "${language}"
                    ;;
                complete)
                    complete_code "${code}" "${language}" "suggest improvements and best practices"
                    ;;
                refactor)
                    complete_code "${code}" "${language}" "suggest refactoring for better performance and readability"
                    ;;
            esac
            ;;
        *)
            # General question
            get_ai_response "$*"
            ;;
    esac
}

# Detect file language
get_file_language() {
    local file="$1"
    local ext="${file##*.}"
    
    case "${ext}" in
        py) echo "Python" ;;
        js|jsx|ts|tsx) echo "JavaScript/TypeScript" ;;
        go) echo "Go" ;;
        rs) echo "Rust" ;;
        java) echo "Java" ;;
        kt|kts) echo "Kotlin" ;;
        lua) echo "Lua" ;;
        sh|bash|zsh) echo "Shell script" ;;
        yml|yaml) echo "YAML" ;;
        json) echo "JSON" ;;
        md) echo "Markdown" ;;
        *) echo "unknown language" ;;
    esac
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Check dependencies
    if ! command -v jq &> /dev/null; then
        echo "Error: jq is required. Install with: brew install jq"
        exit 1
    fi
    
    check_ollama
    ensure_model
    ai_assistant "$@"
fi