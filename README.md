# CI/CD Pipeline Documentation

## Pipeline Overview

This project uses GitHub Actions for Continuous Integration and Continuous Deployment.

### Workflows

1. **Main CI/CD Pipeline** (`.github/workflows/flutter-ci.yml`)
   - Lint and analyze code
   - Run tests
   - Build Android APK/AAB
   - Deploy to server
   - Send Discord notifications

2. **Release Pipeline** (`.github/workflows/release.yml`)
   - Automatically create GitHub releases on tag push
   - Generate release notes from commit history
   - Attach APK files to release

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| FLUTTER_VERSION | Flutter SDK version | 3.13.9 |
| PROJECT_NAME | Project name | Project-GG |

### Secrets Required

- `DISCORD_WEBHOOK_URL`: For notifications
- `SSH_PRIVATE_KEY`: For deployment
- `DEPLOY_HOST`: Deployment server host
- `DEPLOY_USER`: Deployment server user
- `DEPLOY_PATH`: Deployment path

### How to Use

1. **Push to main branch**: Triggers full CI/CD pipeline
2. **Push a tag (v*.*.*)**: Creates GitHub release
3. **Create pull request**: Runs lint and tests