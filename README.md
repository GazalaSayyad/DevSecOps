# DevSecOps CI/CD Pipeline (Demo Branch)

An end-to-end **DevSecOps pipeline** built with GitHub Actions that embeds security scanning at every stage of the SDLC — code, dependencies, container build, and Kubernetes deployment. Triggered automatically on every push to the `demo` branch.

![GitHub Actions](https://img.shields.io/badge/CI-GitHub%20Actions-2088FF?style=for-the-badge&logo=githubactions&logoColor=white)
![Security](https://img.shields.io/badge/Security-DevSecOps-red?style=for-the-badge)

## Pipeline Overview

```
Push to demo branch
        │
        ▼
┌───────────────────────┐
│ 1. App Security Scan  │  Secrets → SAST → Dependency check
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ 2. Container Build     │  Lint → Build → Vulnerability scan →
│    & Supply Chain      │  SBOM → Sign → Push
└───────────┬───────────┘
            ▼
┌───────────────────────┐
│ 3. Kubernetes Deploy   │  Cluster benchmark → Deploy → Verify
│    & Validation         │
└───────────────────────┘
```

## Pipeline Stages

### 1. Application Security Scanning (`devsecops-pipeline`)
Runs on every push, scanning the source code before anything is built.

| Step | Tool | Purpose |
| --- | --- | --- |
| Secret Scanning | [Gitleaks](https://github.com/gitleaks/gitleaks-action) | Detects hardcoded secrets, keys, and credentials in the codebase |
| SAST | [SonarQube](https://github.com/SonarSource/sonarqube-scan-action) | Static analysis for code quality and security vulnerabilities |
| Dependency Scanning | [Snyk](https://github.com/snyk/actions) | Checks Python dependencies (`requirements.txt`) for known CVEs (non-blocking) |

### 2. Container Build & Supply Chain Security (`docker-pipeline`)
Runs after the application scan passes. Builds, scans, signs, and publishes the container image.

| Step | Tool | Purpose |
| --- | --- | --- |
| Dockerfile Linting | [Hadolint](https://github.com/hadolint/hadolint-action) | Enforces Dockerfile best practices |
| Image Build | Docker | Builds and tags the image with both `latest` and the commit SHA |
| Vulnerability Scanning | [Trivy](https://github.com/aquasecurity/trivy-action) | Scans the built image for OS and library CVEs, results uploaded as SARIF to the GitHub Security tab |
| SBOM Generation | [Syft](https://github.com/anchore/sbom-action) | Generates a Software Bill of Materials (SPDX JSON) for the image |
| Image Signing | [Cosign](https://github.com/sigstore/cosign-installer) | Signs the image for supply chain integrity via GitHub OIDC |
| Publish | Docker Hub | Pushes the signed, scanned image |

### 3. Kubernetes Deployment & Validation (`k8s-pipeline`)
Runs after the image is published. Spins up a local cluster to validate the deployment.

| Step | Tool | Purpose |
| --- | --- | --- |
| Cluster Bootstrap | [Minikube](https://github.com/medyagh/setup-minikube) | Spins up an ephemeral Kubernetes cluster for validation |
| Cluster Hardening Check | [Kube-bench](https://github.com/aquasecurity/kube-bench) | Benchmarks the cluster against CIS Kubernetes standards |
| Deployment | `kubectl apply` | Deploys the application using manifests in `k8s/` |
| Smoke Test | `curl` | Verifies the service responds after deployment |

## Repository Structure

```
.
├── .github/workflows/
│   └── devsecops-pipeline.yml   # CI/CD pipeline definition
├── k8s/
│   ├── deployment.yaml          # Kubernetes Deployment manifest
│   └── service.yaml             # Kubernetes Service manifest
├── Dockerfile
├── requirements.txt
└── README.md
```

## Required Secrets

Configure these under **Settings → Secrets and variables → Actions**:

| Secret | Used For |
| --- | --- |
| `SONAR_TOKEN` | SonarQube authentication |
| `SNYK_TOKEN` | Snyk dependency scanning |
| `DOCKERHUB_USERNAME` | Docker Hub login and image tagging |
| `DOCKERHUB_TOKEN` | Docker Hub authentication (PAT) |

`GITHUB_TOKEN` is provided automatically by GitHub Actions.

## Permissions

The workflow requests the minimum permissions needed:
- `contents: read` — checkout the repository
- `packages: write` — publish artifacts
- `id-token: write` — enables keyless image signing via Cosign/OIDC
- `security-events: write` — upload SARIF results (Trivy) to the Security tab

## Triggering the Pipeline

The pipeline runs automatically on any push to the `demo` branch, except for changes limited to `README.md` files.

```yaml
on:
  push:
    branches:
      - demo
    paths-ignore:
      - '**/README.md'
```

## License

MIT
