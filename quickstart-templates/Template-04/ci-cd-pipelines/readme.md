# GitHub Actions - CI/CD Pipelines

## 🚀 Quick Setup

### 1. Add Workflows to Your Repository

#### NOTE:  This pipelines are framework agnostic supports all frameworks 

Copy the workflow files to your repository:
```
.github/
└── workflows/
    ├── frontend-deploy.yml     #### for frontend 
    └── backend-deploy.yml       #### for backend 
```

### 2. Configure GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret Name | Description | How to Get |
|------------|-------------|------------|
| `ACR_LOGIN_SERVER` | Container Registry URL | `yourregistry.azurecr.io` |
| `ACR_USERNAME` | Registry username | Portal → ACR → Access keys → Username |
| `ACR_PASSWORD` | Registry password | Portal → ACR → Access keys → Password |
| `AZURE_CREDENTIALS` | Service Principal JSON | See below ⬇️ |
| `FRONTEND_CONTAINER_APP_NAME` | Frontend app name | `myproject-prod-aca-frontend-app` |
| `BACKEND_CONTAINER_APP_NAME` | Backend app name | `myproject-prod-aca-backend-app` |
| `RESOURCE_GROUP_NAME` | Resource group | `myproject-prod-rg` |

### 3. Create Azure Service Principal

```bash
az ad sp create-for-rbac \
  --name "github-actions-sp" \
  --role contributor \
  --scopes /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/YOUR_RESOURCE_GROUP \
  --sdk-auth
```

Copy the JSON output to `AZURE_CREDENTIALS` secret.

### 4. Enable ACR Admin User

```bash
az acr update --name yourregistry --admin-enabled true
```

## 📁 Project Structure

Your repository should have:
```
your-repo/
├── .github/
│   └── workflows/
│       ├── frontend-deploy.yml
│       └── backend-deploy.yml
├── frontend/
│   ├── Dockerfile
│   └── (your frontend code)
└── backend/
    ├── Dockerfile
    └── (your backend code)
```

## 🎯 How It Works

### Frontend Pipeline (`frontend-deploy.yml`)
1. **Triggers** on:
   - Push to `main` or `develop` branches
   - Changes in `frontend/` directory
   - Manual trigger
2. **Builds** Docker image from `./frontend`
3. **Pushes** to ACR with tags: `latest`, `main-<sha>`, `<branch>`
4. **Deploys** to Frontend Container App

### Backend Pipeline (`backend-deploy.yml`)
1. **Triggers** on:
   - Push to `main` or `develop` branches
   - Changes in `backend/` directory
   - Manual trigger
2. **Builds** Docker image from `./backend`
3. **Pushes** to ACR with tags: `latest`, `main-<sha>`, `<branch>`
4. **Deploys** to Backend Container App

## ✅ Verify Setup

1. **Check Workflows**: Actions tab in GitHub
2. **Manual Trigger**: Actions → Workflow → Run workflow
3. **View Logs**: Click on any workflow run
4. **Verify Deployment**: 
   ```bash
   az containerapp show \
     --name YOUR_APP_NAME \
     --resource-group YOUR_RG \
     --query "properties.latestRevisionName"
   ```

## 🔧 Customization

### Change Trigger Branches
```yaml
on:
  push:
    branches: [ main, staging, production ]  # Add your branches
```

### Add Environment Variables
```yaml
- name: Deploy to Azure Container Apps
  uses: azure/CLI@v2
  with:
    inlineScript: |
      az containerapp update \
        --name ${{ env.CONTAINER_APP_NAME }} \
        --resource-group ${{ env.RESOURCE_GROUP }} \
        --image ${{ env.AZURE_CONTAINER_REGISTRY }}/${{ env.IMAGE_NAME }}:${{ github.sha }} \
        --set-env-vars "KEY=VALUE" "ANOTHER_KEY=VALUE"
```

### Add Approval Step (Production)
```yaml
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    environment: production  # Requires approval in Settings → Environments
```

## 🛠️ Troubleshooting

### ❌ ACR Authentication Failed
- Verify `ACR_USERNAME` and `ACR_PASSWORD` are correct
- Ensure admin user is enabled on ACR

### ❌ Azure Login Failed
- Check `AZURE_CREDENTIALS` format (must be valid JSON)
- Verify Service Principal has Contributor role
- Ensure Service Principal isn't expired

### ❌ Container App Update Failed
- Confirm Container App name is correct
- Check Service Principal has permissions on Container App
- Verify image exists in ACR: `az acr repository show-tags -n yourregistry --repository frontend`

### ❌ Workflow Doesn't Trigger
- Check branch name matches workflow configuration
- Verify changes are in correct directory (`frontend/` or `backend/`)
- Push changes to trigger branch

## 📊 Deployment Status

View deployment status in:
- **GitHub**: Repository → Actions tab
- **Azure Portal**: Container Apps → Revisions
- **CLI**:
  ```bash
  az containerapp revision list \
    --name YOUR_APP_NAME \
    --resource-group YOUR_RG \
    --output table
  ```

## 🔒 Security Best Practices

- ✅ Use Service Principal with minimal required permissions
- ✅ Enable branch protection rules
- ✅ Require pull request reviews for production
- ✅ Set up environment approvals for sensitive deployments
- ✅ Rotate ACR credentials regularly
- ✅ Use GitHub Environments for production deployments

## 🚦 Pipeline Status Badges

### For CI/CD Sample please visit here - https://github.com/Promact-Ops/devops-docker-templates/tree/jaydeep-template-6/sample-repos

Add to your main README:

```markdown
![Frontend Deploy](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/frontend-deploy.yml/badge.svg)
![Backend Deploy](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/backend-deploy.yml/badge.svg)
```

