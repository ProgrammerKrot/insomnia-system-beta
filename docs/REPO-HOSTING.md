# Custom Pacman Repository — Hosting Guide

## Strategy: GitHub Pages as a Static Pacman Repo

GitHub Pages serves static files over HTTPS, making it a zero-cost
pacman repository host.

## Repository Structure

Create a separate GitHub repo: `insomnia-repo`

```
insomnia-repo/
├── x86_64/
│   ├── insomnia-core-0.1-1-any.pkg.tar.zst
│   ├── insomnia-core-0.1-1-any.pkg.tar.zst.sig
│   ├── insomnia.db          -> insomnia.db.tar.gz
│   ├── insomnia.db.tar.gz
│   ├── insomnia.db.tar.gz.sig
│   ├── insomnia.files       -> insomnia.files.tar.gz
│   └── insomnia.files.tar.gz
└── insomnia.pub
```

## Step-by-Step Setup

### 1. Generate a GPG key for package signing

```bash
gpg --full-generate-key
# Choose: RSA, 4096 bits, no expiry
# Export the public key:
gpg --armor --export YOUR_EMAIL > insomnia.pub
```

### 2. Build packages and create the database

```bash
export INSOMNIA_GPG_KEY="$(gpg --list-keys --with-colons YOUR_EMAIL | awk -F: '/^fpr/{print $10; exit}')"
./scripts/repo/update-repo.sh
```

### 3. Push to GitHub

```bash
cd insomnia-repo
git init
git add .
git commit -m "Initial repo"
git remote add origin https://github.com/ProgrammerKrot/insomnia-repo.git
git push -u origin main
```

Enable GitHub Pages: **Settings → Pages → Source: main branch → / (root)**

### 4. Configure pacman on target machines

```bash
# Import the signing key
sudo pacman-key --recv-keys YOUR_GPG_FINGERPRINT
sudo pacman-key --lsign-key YOUR_GPG_FINGERPRINT
# Or from file:
sudo pacman-key --add insomnia.pub
sudo pacman-key --lsign-key YOUR_GPG_FINGERPRINT

# Add to /etc/pacman.conf:
# [insomnia]
# Server = https://ProgrammerKrot.github.io/insomnia-repo/x86_64
# SigLevel = Required DatabaseOptional
```

### 5. Updating the repository

```bash
# Rebuild changed packages and re-upload:
./scripts/repo/update-repo.sh
cd insomnia-repo
git add x86_64/
git commit -m "repo: update packages $(date +%Y-%m-%d)"
git push
```

## GitLab Alternative

GitLab Pages works identically. Use `.gitlab-ci.yml` to automate builds:

```yaml
pages:
  stage: deploy
  script:
    - ./scripts/repo/update-repo.sh
    - mkdir -p public/x86_64
    - cp -r insomnia-repo/x86_64/* public/x86_64/
  artifacts:
    paths:
      - public
  only:
    - main
```
