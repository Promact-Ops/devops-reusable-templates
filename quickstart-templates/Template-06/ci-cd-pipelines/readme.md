# 🚀 CI/CD Deployment – Dockerized Frontend & Backend

This repository includes automated deployment pipelines for **frontend** and **backend** services using **GitHub Actions** and **Docker Compose** on an Ubuntu VPS.

---

## 📁 Project Structure

```
.github/
 └── workflows/
      ├── deploy-frontend.yml   # Deploys only the frontend service
      └── deploy-backend.yml    # Deploys only the backend service
_home/
 └── ubuntu/_my_project-development-server/
      ├── frontend/[your code and dockerfile]
      ├── backend/[your code and dockerfile]
      └── docker-compose.yml
```

---

## ⚙️ Workflows Overview

### 🔹 Frontend Deployment (`deploy-frontend.yml`)

* Triggers when files in `frontend/**` change.
* Connects to VPS via SSH.
* Rebuilds and restarts **only the frontend container**:

  ```bash
  docker-compose up -d --build --force-recreate --no-deps frontend
  ```

### 🔹 Backend Deployment (`deploy-backend.yml`)

* Triggers when files in `backend/**` change.
* Connects to VPS via SSH.
* Rebuilds and restarts **only the backend container**:

  ```bash
  docker-compose up -d --build --force-recreate --no-deps backend
  ```

---

## 🔑 Required GitHub Secrets

| Name              | Description                                                                    |
| ----------------- | ------------------------------------------------------------------------------ |
| `VPS_IP`          | Public IP address of your VPS                                                  |
| `VPS_PRIVATE_KEY` | SSH private key (matches public key in `/home/azureuser/.ssh/authorized_keys`) |

---

## 🧠 Notes

* Ensure `docker-compose.yml` exists on VPS at `/home/ubuntu/_my_project-development-server/`.
* The folder and service names **must match** those defined in the workflows.
* Both pipelines automatically pull the latest code and rebuild containers on each push.

---

## ✅ Example Deployment Flow

1. Developer pushes changes to the `main` branch.
2. GitHub Actions runs the relevant workflow (frontend or backend).
3. The workflow connects to the VPS via SSH and runs Docker Compose.
4. The updated service is rebuilt and redeployed automatically.

---

