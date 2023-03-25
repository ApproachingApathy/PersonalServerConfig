#!/bin/bash

CaddyDataVolumeName="caddy_data"
CredentialStorageFolder="cred"
VolumeFolders=($CrendentialStorageFolder "database" "extensions" "uploads" "caddy/site" "foundry" "foundry/data")
GCloudStoragePrincipal=$(gcloud secrets versions access latest --secret=personal_site_storage_principle)
GCloudKeyFilePath="${CredentialStorageFolder}/gcs-keyfile.json"



# Loop through the list of folders
for folder in "${VolumeFolders[@]}"
do
  # Check if the folder already exists
  if [ -d "$folder" ]; then
    echo "Folder $folder already exists."
  else
    # Create the folder
    mkdir "$folder"
    echo "Folder $folder created."
  fi
done

if  docker volume ls | grep -q "$CaddyDataVolumeName"; then
    echo "Volume \`$CaddyDataVolumeName\` exists. Skipping creation...";
else 
    docker volume create caddy_data;
    echo "Created \`$CaddyDataVolumeName\` volume."
fi

echo "Looking for GCS keyfile at $GCloudKeyFilePath"
if test -e $GCloudKeyFilePath; then
    echo "Keyfile found. Skipping generation..."
else
    echo "Creating GCS keyfile."
    gcloud iam service-accounts keys create cred/gcs-keyfile.json --iam-account=$GCloudStoragePrincipal
fi

export DIRECTUS_SECRET=$(gcloud secrets versions access latest --secret=directus_secret)
export DIRECTUS_ADMIN_EMAIL=$(gcloud secrets versions access latest --secret=directus_admin_email)
export DIRECTUS_ADMIN_PASSWORD=$(gcloud secrets versions access latest --secret=directus_admin_password)
export FOUNDRY_USERNAME=$(gcloud secrets versions access latest --secret=foundry_username)
export FOUNDRY_PASSWORD=$(gcloud secrets versions access latest --secret=foundry_password)
export FOUNDRY_ADMIN_KEY=$(gcloud secrets versions access latest --secret=foundry_admin_key)
export G_CLOUD_BUCKET=$(gcloud secrets versions access latest --secret=personal_site_storage_bucket)
export G_CLOUD_KEYFILE_PATH=$GCloudKeyFilePath



docker volume create $CaddyDataVolumeName;
docker compose up;