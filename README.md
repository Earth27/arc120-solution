# arc120-solution
Solution for The Basics of Google Cloud Compute: Challenge Lab


This repository contains a Cloud Shell script that automates the setup of essential Google Cloud resources for hosting a web application.  
It creates a Cloud Storage bucket, a Compute Engine virtual machine with NGINX installed, and a persistent disk that is automatically attached, formatted, and mounted.

---

## 🧩 Features

- Interactive prompts for **region** and **zone** (defaults: `us-east4` and `us-east4-c`)
- Creates a **Cloud Storage bucket** for storing files
- Provisions a **Compute Engine VM (e2-medium)** running **Debian 12**
- Automatically installs and starts **NGINX web server**
- Creates and attaches a **200GB persistent disk**, mounted at `/mnt/mydisk`
- Displays the **external IP** to verify NGINX access

---

## 🧰 Prerequisites

Before running the script, ensure you have:

1. Access to a **Google Cloud project**
2. Permissions to create:
   - Compute Engine instances and disks  
   - Cloud Storage buckets  
3. **Google Cloud SDK (gcloud)** installed and configured, or access to **Google Cloud Shell**

Authenticate your account if needed:

```bash
gcloud auth login
gcloud config set project PROJECT_ID
