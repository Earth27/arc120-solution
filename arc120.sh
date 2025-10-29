#!/bin/bash
# ==========================================================
# Google Cloud Infrastructure Setup Script
# Author: EKR
# Description: Automates setup of storage, compute, and NGINX
# ==========================================================

# Prompt for region and zone
read -p "Enter the region (default: us-east4): " REGION
REGION=${REGION:-us-east4}

read -p "Enter the zone (default: us-east4-c): " ZONE
ZONE=${ZONE:-us-east4-c}

# Set variables
PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME=qwiklabs-${PROJECT_ID}-bucket
INSTANCE_NAME=my-instance
DISK_NAME=mydisk

echo "==========================================="
echo "Project ID:     ${PROJECT_ID}"
echo "Region:         ${REGION}"
echo "Zone:           ${ZONE}"
echo "Bucket:         ${BUCKET_NAME}"
echo "Instance:       ${INSTANCE_NAME}"
echo "Disk:           ${DISK_NAME}"
echo "==========================================="

# Confirm execution
read -p "Proceed with setup? (y/n): " CONFIRM
if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
  echo "Setup cancelled."
  exit 1
fi

# Task 1: Create Cloud Storage bucket (multi-region US)
echo "Creating Cloud Storage bucket..."
gsutil mb -l US gs://${BUCKET_NAME}/

# Task 2: Create Compute Engine instance with NGINX installation
echo "Creating Compute Engine instance..."
gcloud compute instances create ${INSTANCE_NAME} \
  --zone=${ZONE} \
  --machine-type=e2-medium \
  --image-family=debian-12 \
  --image-project=debian-cloud \
  --boot-disk-type=pd-balanced \
  --boot-disk-size=10GB \
  --tags=http-server \
  --metadata=startup-script='#! /bin/bash
    apt update
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx'

# Task 3: Create persistent disk (200 GB)
echo "Creating persistent disk..."
gcloud compute disks create ${DISK_NAME} \
  --size=200GB \
  --type=pd-balanced \
  --zone=${ZONE}

# Attach the disk to the instance
echo "Attaching persistent disk to instance..."
gcloud compute instances attach-disk ${INSTANCE_NAME} \
  --disk=${DISK_NAME} \
  --zone=${ZONE}

# Mount and format the new disk inside the VM
echo "Formatting and mounting disk inside the instance..."
gcloud compute ssh ${INSTANCE_NAME} --zone=${ZONE} --command='
  sudo mkdir -p /mnt/mydisk &&
  sudo mkfs.ext4 -F /dev/disk/by-id/google-mydisk &&
  sudo mount /dev/disk/by-id/google-mydisk /mnt/mydisk &&
  echo "/dev/disk/by-id/google-mydisk /mnt/mydisk ext4 defaults 0 2" | sudo tee -a /etc/fstab
'

# Verify NGINX status
echo "Verifying NGINX installation..."
gcloud compute ssh ${INSTANCE_NAME} --zone=${ZONE} --command="systemctl status nginx | grep active"

# Display external IP
echo "==========================================="
echo "Setup complete."
echo "Visit this IP in your browser to verify NGINX:"
gcloud compute instances list --filter="name=${INSTANCE_NAME}" --format="get(networkInterfaces[0].accessConfigs[0].natIP)"
echo "==========================================="
