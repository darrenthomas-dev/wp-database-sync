#!/bin/bash

# Configuration
REMOTE_USER="your_username"
REMOTE_HOST="your_host"
REMOTE_DB_USER="remote_db_user"
REMOTE_DB_NAME="remote_db_name"
REMOTE_DB_PASS="remote_db_password" # If your database requires a password

LOCAL_DB_USER="local_db_user"
LOCAL_DB_NAME="local_db_name"
LOCAL_DB_PASS="local_db_password" # If your database requires a password

REMOTE_BACKUP_FILE="remote_db_backup.sql"
LOCAL_BACKUP_PATH="/path/to/local_destination"

REMOTE_SITE_URL="http://remote-site-url.com"
LOCAL_SITE_URL="http://local-site-url.dev"

# Step 1: Back up the local database
echo "Backing up the local database..."
mysqldump -u $LOCAL_DB_USER -p$LOCAL_DB_PASS $LOCAL_DB_NAME > local_db_backup.sql
if [ $? -ne 0 ]; then
  echo "Error: Failed to back up the local database."
  exit 1
fi
echo "Local database backup completed."

# Step 2: SSH into the hosting server and back up the remote database
echo "Backing up the remote database..."
ssh $REMOTE_USER@$REMOTE_HOST "mysqldump -u $REMOTE_DB_USER -p$REMOTE_DB_PASS $REMOTE_DB_NAME > $REMOTE_BACKUP_FILE"
if [ $? -ne 0 ]; then
  echo "Error: Failed to back up the remote database."
  exit 1
fi
echo "Remote database backup completed."

# Step 3: Download the remote database backup
echo "Downloading the remote database backup..."
scp $REMOTE_USER@$REMOTE_HOST:~/$REMOTE_BACKUP_FILE $LOCAL_BACKUP_PATH/
if [ $? -ne 0 ]; then
  echo "Error: Failed to download the remote database backup."
  exit 1
fi
echo "Remote database backup downloaded to $LOCAL_BACKUP_PATH/$REMOTE_BACKUP_FILE."

# Step 4: Import the remote database backup into the local database
echo "Importing the remote database backup into the local database..."
mysql -u $LOCAL_DB_USER -p$LOCAL_DB_PASS $LOCAL_DB_NAME < $LOCAL_BACKUP_PATH/$REMOTE_BACKUP_FILE
if [ $? -ne 0 ]; then
  echo "Error: Failed to import the remote database backup into the local database."
  exit 1
fi
echo "Remote database backup imported into the local database."

# Step 5: Update URLs in the local database (if necessary)
echo "Updating URLs in the local database..."
wp search-replace $REMOTE_SITE_URL $LOCAL_SITE_URL --allow-root
if [ $? -ne 0 ]; then
  echo "Error: Failed to update URLs in the local database."
  exit 1
fi
echo "URLs updated in the local database."

echo "Database backup and update completed successfully."
