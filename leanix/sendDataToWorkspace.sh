

#service_name=$(jq -r .name package.json)
service_name="test_name"
export HOST=${MI_DEV_HOST:-eu.leanix.net}
export TOKEN=${MI_DEV_TOKEN:-xxx}

export SYNC_URL="https://${HOST}/services/integration-api/v1/synchronizationRuns"
TOKEN=$(curl -X POST --url https://${HOST}/services/mtm/v1/oauth2/token -u apitoken:${TOKEN} --data grant_type=client_credentials | jq -r '.access_token') 

license-checker --json > $TRAVIS_BUILD_DIR/leanix/dependencies.json

curl -X POST \
  -H 'Cache-Control: no-cache' \
  -H "Authorization: Bearer ${TOKEN}" \
  -H 'Content-Type: multipart/form-data' \
  -F dependencies=@$TRAVIS_BUILD_DIR/leanix/dependencies.json \
#  -F manifest=@$TRAVIS_BUILD_DIR/lx-manifest.yaml \
  -F opMicroserviceId="${service_name}" \
  -F 'data={
  "version": "1.0.0",
  "stage": "dev",
  "dependencyManager": "NPM"
}' \
  https://$HOST/services/cicd-connector/v2/deployment