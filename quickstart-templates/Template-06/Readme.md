# 📘 How to Start the Docker Project Setup Bash Script

### Goto repository - https://github.com/Promact-Ops/devops-docker-templates > scripts > setup_template-06.sh

This guide explains how to prepare, configure, and execute the Docker setup script on an Ubuntu server.

---

## ✅ **1. Upload the Script to the Server**

Save the script as a file, for example:

```
setup_template-06.sh
```

Upload it to your server using:

* **scp**
* **SFTP**
* **Terraform provisioner**
* **Git + wget/curl**
* or any preferred method.

---

## ✅ **2. Connect to Your Ubuntu Server**

Use SSH:

```bash
ssh ubuntu@YOUR_SERVER_IP
```

Replace `YOUR_SERVER_IP` with your server’s IP address.

---

## ✅ **3. Make the Script Executable**

After uploading the script to server, run:

```bash
chmod +x setup_template-06.sh
```

This ensures the script can be executed.

---

## ✅ **4. Set Required Environment Variables**

Your script depends on two variables:

* `PROJECT_NAME`
* `ENVIRONMENT`

Example:

```bash
export PROJECT_NAME=myapp
export ENVIRONMENT=prod
```

Verify:

```bash
echo $PROJECT_NAME
echo $ENVIRONMENT
```

---

## ✅ **5. Run the Script**

Go to script directory

Execute it with **sudo**:

```bash
sudo ./setup_template-06.sh
```

## ✅ **DONE**
---

