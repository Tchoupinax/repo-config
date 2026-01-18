if [ ! -d ".terraform" ]; then
  terraform init \
    -backend-config="access_key=$(tchoupinaxctl secrets -- bash -c 'echo $SCW_ACCESS_KEY' | tail -n 1)" \
    -backend-config="secret_key=$(tchoupinaxctl secrets -- bash -c 'echo $SCW_SECRET_KEY' | tail -n 1)" \
    -backend-config="bucket=$(tchoupinaxctl secrets -- bash -c 'echo $SCW_BUCKET_NAME' | tail -n 1)"
fi

GITHUB_TOKEN=$(tchoupinaxctl secrets -- bash -c 'echo $GITHUB_TOKEN' | tail -n 1) \
  terraform apply
