if [ ! -d ".terraform" ]; then
  terraform init \
    -backend-config="access_key=$(tchoupinaxctl secrets -- bash -c 'echo $SCW_ACCESS_KEY')" \
    -backend-config="secret_key=$(tchoupinaxctl secrets -- bash -c 'echo $SCW_SECRET_KEY')" \
    -backend-config="bucket=$(tchoupinaxctl secrets -- bash -c 'echo $SCW_BUCKET_NAME')"
fi

tchoupinaxctl secrets -- terraform plan
