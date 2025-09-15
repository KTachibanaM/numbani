#!/usr/bin/env bash
set -e

# Load environment variables
if [ -f "$(dirname "$0")/raindrop-youtube-to-invidious-env" ]; then
    source "$(dirname "$0")/raindrop-youtube-to-invidious-env"
else
    echo "Error: Environment file not found. Please create raindrop-youtube-to-invidious-env with required credentials."
    exit 1
fi

# Check required environment variables
if [ -z "$RAINDROP_TEST_TOKEN" ]; then
    echo "Error: RAINDROP_TEST_TOKEN is not set in environment file"
    exit 1
fi

if [ -z "$INVIDIOUS_INSTANCE" ]; then
    echo "Error: INVIDIOUS_INSTANCE is not set in environment file"
    exit 1
fi

# API endpoint and parameters
API_BASE="https://api.raindrop.io/rest/v1"
COLLECTION_ID="0"  # 0 means all collections
PER_PAGE=50
PAGE=0
TOTAL_FOUND=0

# Function to URL encode a string using jq
urlencode() {
    echo -n "$1" | jq -sRr @uri
}

# Search query for YouTube videos
SEARCH_QUERY=$(urlencode "link:youtube.com/watch?v=")

# Loop through pages
while true; do
    # Make API request
    RESPONSE=$(curl -s -X GET \
        -H "Authorization: Bearer $RAINDROP_TEST_TOKEN" \
        "${API_BASE}/raindrops/${COLLECTION_ID}?search=${SEARCH_QUERY}&perpage=${PER_PAGE}&page=${PAGE}")
    
    # Check if request was successful
    if [ $? -ne 0 ]; then
        echo "Error: Failed to fetch data from Raindrop.io API"
        exit 1
    fi
    
    # Check for API errors
    ERROR_MESSAGE=$(echo "$RESPONSE" | jq -r '.errorMessage // empty')
    if [ -n "$ERROR_MESSAGE" ]; then
        echo "API Error: $ERROR_MESSAGE"
        exit 1
    fi
    
    # Extract items
    ITEMS=$(echo "$RESPONSE" | jq -r '.items[]')
    
    # Check if we have items
    if [ -z "$ITEMS" ]; then
        break
    fi
    
    # Process YouTube links and update them to Invidious
    YOUTUBE_ITEMS=$(echo "$RESPONSE" | jq -c '.items[] | select(.link | contains("youtube.com/watch?v="))')
    
    # Process each YouTube item
    while IFS= read -r item; do
        if [ -n "$item" ]; then
            ITEM_ID=$(echo "$item" | jq -r '._id')
            ITEM_TITLE=$(echo "$item" | jq -r '.title')
            YOUTUBE_URL=$(echo "$item" | jq -r '.link')
            
            # Convert YouTube URL to Invidious URL
            INVIDIOUS_URL=$(echo "$YOUTUBE_URL" | sed "s|https://www.youtube.com/watch?v=|${INVIDIOUS_INSTANCE}/watch?v=|; s|https://youtube.com/watch?v=|${INVIDIOUS_INSTANCE}/watch?v=|; s|http://www.youtube.com/watch?v=|${INVIDIOUS_INSTANCE}/watch?v=|; s|http://youtube.com/watch?v=|${INVIDIOUS_INSTANCE}/watch?v=|")
            
            # Update the bookmark with Invidious URL
            UPDATE_RESPONSE=$(curl -s -X PUT \
                -H "Authorization: Bearer $RAINDROP_TEST_TOKEN" \
                -H "Content-Type: application/json" \
                -d "{\"link\": \"$INVIDIOUS_URL\"}" \
                "${API_BASE}/raindrop/${ITEM_ID}")
            
            # Check if update was successful
            if echo "$UPDATE_RESPONSE" | jq -e '.item' > /dev/null 2>&1; then
                echo "$ITEM_TITLE"
                echo "  Updated: $YOUTUBE_URL → $INVIDIOUS_URL"
                echo ""
                TOTAL_FOUND=$((TOTAL_FOUND + 1))
            else
                echo "Failed to update: $ITEM_TITLE"
                ERROR=$(echo "$UPDATE_RESPONSE" | jq -r '.errorMessage // "Unknown error"')
                echo "  Error: $ERROR"
                echo ""
            fi
        fi
    done <<< "$YOUTUBE_ITEMS"
    
    # Count items on this page
    PAGE_COUNT=$(echo "$RESPONSE" | jq '.items | length')
    
    # Check if there are more pages
    if [ "$PAGE_COUNT" -lt "$PER_PAGE" ]; then
        break
    fi
    
    # Move to next page
    PAGE=$((PAGE + 1))
done

if [ $TOTAL_FOUND -gt 0 ]; then
    echo "Total YouTube bookmarks updated to Invidious: $TOTAL_FOUND"
fi

