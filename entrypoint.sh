#!/bin/sh

# Always refresh configuration from the image backup on every deploy so that
# settings.yml changes in the repo take effect despite the persistent volume
if [ -f "/etc/searxng-backup/settings.yml" ]; then
    echo "Volume mount detected, refreshing configuration from backup..."
    cp -rf /etc/searxng-backup/* /etc/searxng/
    echo "Configuration refreshed successfully"
fi

# Update the secret key from environment variable at runtime
if [ -n "$SEARXNG_SECRET_KEY" ]; then
    if [ -f "/etc/searxng/settings.yml" ]; then
        echo "Updating secret key from environment variable..."
        sed -i "s|secret_key:.*|secret_key: \"${SEARXNG_SECRET_KEY}\"|g" /etc/searxng/settings.yml
    else
        echo "Warning: settings.yml not found, secret key will be set by SearXNG template"
    fi
else
    echo "Warning: SEARXNG_SECRET_KEY environment variable not set, using default"
fi

# Start SearXNG using the original container's startup logic
exec /usr/local/searxng/entrypoint.sh 