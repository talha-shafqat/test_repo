echo "test script running"
pwd
echo "------------------"
ls $TRAVIS_BUILD_DIR
service_name=$(jq -r .name package.json)

export HOST=${MI_DEV_HOST:-eu.leanix.net}
export TOKEN=${MI_DEV_TOKEN:-xxx}

export SYNC_URL="https://${HOST}/services/integration-api/v1/synchronizationRuns"
BEARER=$(curl -X POST --url https://${HOST}/services/mtm/v1/oauth2/token -u apitoken:${TOKEN} --data grant_type=client_credentials | jq -r '.access_token') 
echo $BEARER

license-checker --json > $TRAVIS_BUILD_DIR/dependencies.json
echo "%%%%%%%%%%%%%%%%%%%%%"
ls -ll $TRAVIS_BUILD_DIR/
echo "%%%%%%%%%%%%%%%%%%%%%"

curl -X POST \
  -H 'Cache-Control: no-cache' \
  -H "Authorization: Bearer ${BEARER}" \
  -H 'Content-Type: multipart/form-data' \
  -F manifest=@$TRAVIS_BUILD_DIR/lx-manifest.yaml \
  -F dependencies=@<abosolute path to dependencies file> \
  -F 'data={
  "version": "1.0.0",
  "stage": "dev",
  "dependencyManager": "MAVEN"
}' \
  https://$HOST/services/cicd-connector/v2/deployment