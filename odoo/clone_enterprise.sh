#!/bin/bash

set -e

if [ "$USE_ODOO_ENTERPRISE" = "true" ]; then
    if [ -z "$ENTERPRISE_ADDONS" ]; then
        echo "Error: ENTERPRISE_ADDONS is not set." && exit 1
    fi
    echo "Cloning Enterprise repository: $ENTERPRISE_REPO_URL into $ENTERPRISE_ADDONS"
    git clone https://x-access-token:${GITHUB_ACCESS_TOKEN}@${ENTERPRISE_REPO_URL#https://} "$ENTERPRISE_ADDONS" --depth 1 --branch ${ODOO_TAG} --single-branch --no-tags --progress
else
    echo "Using Odoo Community version."
fi
