OWNER="Tchoupinax"    

repositories=$(cat contents/data.yaml | yq -r 'keys[]')

for repository in $repositories; do
  echo "For repository: $repository"
  labels=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "https://api.github.com/repos/$OWNER/$repository/labels" | jq -r '.[].name')

  for label in $labels; do
    echo "\tDeleting label: $label"
    curl -s -X DELETE -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/repos/$OWNER/$repository/labels/"$label"
  done
done

echo "All labels removed."
