CLIENT_ID=Iv23litU4VeSiR9DeuAn
PEM_FILE=private-key.pem

JWT=$(./generate_jwt.sh $CLIENT_ID $PEM_FILE)

echo "Generated JWT: $JWT"

# Get Installations
INSTALLATION_ID=$(curl -L \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $JWT" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/app/installations | jq -r '.[0].id')

# Get Access Token for Installation ID 85453155
ACCESS_TOKEN=$(curl --request POST \
--url "https://api.github.com/app/installations/$INSTALLATION_ID/access_tokens" \
--header "Accept: application/vnd.github+json" \
--header "Authorization: Bearer $JWT" \
--header "X-GitHub-Api-Version: 2022-11-28" | jq -r '.token')

echo "Generated Access Token: $ACCESS_TOKEN"

SHA=$(curl -H "Authorization: $ACCESS_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/CannonLock/GithubApp/contents/README.md | jq -r '.sha')

# Make some base64 content for the README
CONTENT=$(echo "Api-updated README content" | base64)

# Use the Access Token to update the README
curl -X PUT \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/CannonLock/GithubApp/contents/README.md \
  -d "{
    \"message\": \"Update README via API\",
    \"content\": \"$CONTENT\",
    \"sha\": \"$SHA\"
  }"
