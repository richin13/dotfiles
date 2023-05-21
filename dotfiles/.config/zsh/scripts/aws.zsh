function postgres_backup {
  # Get the current date in the format YYYY-MM-DD
  CURRENT_DATE=$(date +%F)

  # Dump the database using pg_dump
  pg_dump -U USERNAME -h HOSTNAME -p PORT --format=custom --blobs --file=dump.custom DATABASE_NAME

  # Upload the backup file to the S3 bucket with a filename that contains the current date
  aws s3 cp dump.custom "s3://$S3_BACKUPS_BUCKET/backup-$CURRENT_DATE.custom"
}

# Function to restore a PostgreSQL database from a backup file in an S3 bucket
function postgres_restore {
  # Download the backup file from the S3 bucket
  aws s3 cp "s3://$S3_BACKUPS_BUCKET/backup-$1.custom" dump.custom

  # Restore the database using the backup file
  docker-compose exec db pg_restore -U USERNAME -d DATABASE_NAME --clean --if-exists dump.custom
}

# Function to create a binary backup of a PostgreSQL database and upload it to an S3 bucket
function postgres_backup {
  # Get the current date in the format YYYY-MM-DD
  CURRENT_DATE=$(date +%F)

  # Get the database credentials from AWS Secrets Manager
  DB_CREDS=$(aws secretsmanager get-secret-value --secret-id postgresql/credentials --output text --query SecretString)

  # Extract the username, password, hostname, and port from the database credentials
  DB_USERNAME=$(echo $DB_CREDS | jq -r .username)
  DB_PASSWORD=$(echo $DB_CREDS | jq -r .password)
  DB_HOSTNAME=$(echo $DB_CREDS | jq -r .hostname)
  DB_PORT=$(echo $DB_CREDS | jq -r .port)

  # Dump the database using pg_dump
  pg_dump -U $DB_USERNAME -h $DB_HOSTNAME -p $DB_PORT --format=custom --blobs --file=dump.custom DATABASE_NAME

  # Upload the backup file to the S3 bucket with a filename that contains the current date
  aws s3 cp dump.custom "s3://$S3_BACKUPS_BUCKET/backup-$CURRENT_DATE.custom"

