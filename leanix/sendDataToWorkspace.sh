# If MI_DEV_HOST isn't set in travis, a default value is used
export HOST=${MI_DEV_HOST:-demo-eu-1.leanix.net}

# Check if token env variable is set in travis
if [[ -z "${MI_DEV_TOKEN}" ]]; then
    echo "Please add your MI workspace token as an env variable 'MI_DEV_TOKEN' in travis."
    exit 1
fi

# Fetch bearer token
export SYNC_URL="https://${HOST}/services/integration-api/v1/synchronizationRuns"
TOKEN=$(curl -X POST --url https://${HOST}/services/mtm/v1/oauth2/token -u apitoken:${MI_DEV_TOKEN} --data grant_type=client_credentials | jq -r '.access_token') 

# Run license-checker
license-checker --json > $TRAVIS_BUILD_DIR/leanix/dependencies.json

# API call to send the manifest file, dependencies and metadata to workspace
curl -X POST \
  -H 'Cache-Control: no-cache' \
  -H "Authorization: Bearer ${TOKEN}" \
  -H 'Content-Type: multipart/form-data' \
  -F dependencies=@$TRAVIS_BUILD_DIR/leanix/dependencies.json \ # Absolute path to dependencies.json file
  -F manifest=@$TRAVIS_BUILD_DIR/lx-manifest.yaml \ # # Absolute path to lx-manifest.yaml file
  -F 'data={
  "version": "1.1.0",
  "stage": "dev",
  "dependencyManager": "NPM"
}' \
  https://$HOST/services/cicd-connector/v2/deployment