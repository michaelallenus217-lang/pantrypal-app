# GitHub Repository Setup Guide

**BLUF**: Step-by-step instructions to get your PantryPal repository live on GitHub this weekend. Follow this in order. Time required: 30 minutes.

---

## Prerequisites Checklist

- [ ] Git installed on your computer
- [ ] GitHub account created (if not: https://github.com/join)
- [ ] Text editor ready (VS Code, Sublime, or any editor)

---

## Step 1: Create GitHub Repository (5 minutes)

### 1.1 Create the Repository

1. Go to https://github.com/new
2. Fill in the details:
   - **Repository name:** `pantrypal-app`
   - **Description:** `Smart pantry management app with meal planning and recipe recommendations`
   - **Visibility:** ✅ Public (shows up on your profile for recruiters)
   - **Initialize:** ❌ Do NOT check "Add README" (we have our own)
   - **Add .gitignore:** None (we have our own)
   - **License:** None (we have our own)

3. Click **"Create repository"**

### 1.2 Save Your Repository URL

You'll see a page with setup instructions. Your repo URL will be:
```
https://github.com/YOUR_USERNAME/pantrypal-app.git
```

**Save this URL - you'll need it in Step 3.**

---

## Step 2: Set Up Local Repository (10 minutes)

### 2.1 Create Project Directory Structure

Open your terminal/command prompt and run:

```bash
# Navigate to where you want to store the project
cd ~/Documents  # or C:\Users\YourName\Documents on Windows

# Create main project directory
mkdir pantrypal-app
cd pantrypal-app

# Create subdirectories
mkdir backend
mkdir mobile
mkdir docs
mkdir .github
mkdir .github/workflows
```

### 2.2 Move Downloaded Files

Move the files you downloaded from this chat:

```bash
# From your Downloads folder, copy files to project
# Adjust paths based on where you saved the files

# Root level files
cp ~/Downloads/README.md .
cp ~/Downloads/.gitignore .
cp ~/Downloads/LICENSE .

# Backend files
cp ~/Downloads/requirements.txt backend/
cp ~/Downloads/.env.example backend/
cp ~/Downloads/setup_backend.sh backend/

# Documentation files
cp ~/Downloads/database_schema.sql docs/
cp ~/Downloads/api_specification.md docs/
cp ~/Downloads/development_timeline.md docs/
cp ~/Downloads/technical_architecture.md docs/

# GitHub workflow
cp ~/Downloads/backend-ci.yml .github/workflows/
```

**Windows PowerShell Alternative:**
```powershell
# Use Copy-Item instead of cp
Copy-Item "$env:USERPROFILE\Downloads\README.md" -Destination .
# etc...
```

### 2.3 Make Setup Script Executable

```bash
chmod +x backend/setup_backend.sh
```

---

## Step 3: Initialize Git and Push (10 minutes)

### 3.1 Initialize Local Git Repository

```bash
# Make sure you're in the pantrypal-app directory
git init

# Configure your Git identity (if not already done)
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

### 3.2 Create Initial Commit

```bash
# Check what files are ready to commit
git status

# Add all files
git add .

# Verify what will be committed
git status

# Create first commit
git commit -m "Initial commit: Project foundation and documentation

- Complete database schema with 15+ tables
- REST API specification (40+ endpoints)
- 12-month development timeline
- Technical architecture documentation
- Backend setup scripts and requirements
- README with project overview
- GitHub Actions CI/CD workflow"
```

### 3.3 Push to GitHub

```bash
# Add your GitHub repository as remote
git remote add origin https://github.com/YOUR_USERNAME/pantrypal-app.git

# Push to GitHub
git branch -M main
git push -u origin main
```

**If prompted for credentials:**
- Username: your GitHub username
- Password: **Use a Personal Access Token, not your password**
  - Generate token at: https://github.com/settings/tokens
  - Select scopes: `repo` (full control of private repositories)
  - Save the token somewhere safe - you can't see it again

---

## Step 4: Verify Everything Worked (3 minutes)

### 4.1 Check GitHub Website

1. Go to `https://github.com/YOUR_USERNAME/pantrypal-app`
2. You should see:
   - ✅ README displaying with project description
   - ✅ `backend/`, `mobile/`, `docs/`, `.github/` folders
   - ✅ License badge
   - ✅ File count showing ~10 files

### 4.2 Verify Documentation

Click through and verify these files render correctly:
- `README.md` - Should show formatted with badges and sections
- `docs/database_schema.sql` - SQL code visible
- `docs/api_specification.md` - API docs formatted
- `docs/development_timeline.md` - Timeline visible
- `docs/technical_architecture.md` - Architecture docs visible

---

## Step 5: Update README with Your Info (2 minutes)

### 5.1 Edit README.md

Open `README.md` in your text editor and update these lines:

**Line ~7:** Update status
```markdown
**Developer:** Michael [YOUR_LAST_NAME]
```

**Line ~276:** Update GitHub link
```markdown
- GitHub: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)
```

**Line ~277:** Add your LinkedIn (if you have one)
```markdown
- LinkedIn: [Michael YourLastName](https://linkedin.com/in/your-actual-profile)
```

**Or remove the LinkedIn line if you don't have one yet**

### 5.2 Commit and Push Changes

```bash
git add README.md
git commit -m "Update README with personal information"
git push
```

---

## Step 6: Pin Repository to GitHub Profile (Optional but Recommended)

1. Go to your GitHub profile: `https://github.com/YOUR_USERNAME`
2. Click **"Customize your pins"**
3. Check the box next to **pantrypal-app**
4. Click **"Save pins"**

This shows the project prominently on your profile when recruiters look at your GitHub.

---

## Step 7: Create Issues for First Tasks (5 minutes)

Set up your first development tasks as GitHub Issues:

1. Go to your repo → **Issues** tab → **New Issue**

**Issue #1: Set up PostgreSQL database**
```
Title: Set up PostgreSQL database locally

Description:
- [ ] Install PostgreSQL 14+
- [ ] Create `pantrypal_dev` database
- [ ] Run database_schema.sql
- [ ] Verify all tables created successfully
- [ ] Document any setup issues in comments

Labels: backend, setup
Milestone: Phase 1 - Foundation
```

**Issue #2: Initialize FastAPI backend**
```
Title: Initialize FastAPI backend project structure

Description:
- [ ] Run backend/setup_backend.sh
- [ ] Create app/ directory structure
- [ ] Set up app/main.py with basic FastAPI app
- [ ] Test server runs at http://localhost:8000
- [ ] Verify /docs endpoint shows Swagger UI

Labels: backend, setup
Milestone: Phase 1 - Foundation
```

**Issue #3: Implement authentication endpoints**
```
Title: Implement user authentication endpoints

Description:
- [ ] Create user model in app/models/user.py
- [ ] Implement POST /auth/register endpoint
- [ ] Implement POST /auth/login endpoint
- [ ] Add JWT token generation
- [ ] Write tests for auth endpoints

Labels: backend, authentication
Milestone: Phase 1 - Foundation
```

---

## Troubleshooting

### Problem: "fatal: not a git repository"

**Solution:** Make sure you ran `git init` in the correct directory

```bash
pwd  # Print working directory - should end in /pantrypal-app
git init
```

### Problem: "remote: Repository not found"

**Solution:** Check your repository URL

```bash
git remote -v  # Shows current remote URL
git remote set-url origin https://github.com/YOUR_ACTUAL_USERNAME/pantrypal-app.git
```

### Problem: "Authentication failed"

**Solution:** You need a Personal Access Token (PAT), not your password

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Select scopes: `repo`
4. Copy the token
5. Use the token as your password when prompted

### Problem: Files not showing up on GitHub

**Solution:** Check git status and make sure files were committed

```bash
git status  # Should say "nothing to commit, working tree clean"
git log --oneline  # Should show your commit
```

---

## Next Steps After GitHub Setup

Once your repo is live:

1. **Update Your Resume**
   - Add GitHub profile link
   - Add project link to projects section

2. **Update LinkedIn** (if you have one)
   - Add project to "Projects" section
   - Link to GitHub repo

3. **Start Development** (Next Weekend)
   - Run `backend/setup_backend.sh`
   - Follow Phase 1 tasks from development timeline
   - Create feature branch: `git checkout -b feature/database-setup`

---

## Git Workflow Reference

**Daily workflow once development starts:**

```bash
# Start work on new feature
git checkout -b feature/your-feature-name

# Make changes, then check what changed
git status
git diff

# Commit changes
git add .
git commit -m "Clear description of what you did"

# Push to GitHub
git push -u origin feature/your-feature-name

# Merge to main when feature is complete
git checkout main
git merge feature/your-feature-name
git push
```

**Commit message format:**
```
Short summary (50 chars or less)

- Bullet point of change 1
- Bullet point of change 2
- Reference issue number if applicable (#1, #2, etc)
```

---

## Success Checklist

Once complete, you should have:

- [ ] Repository live at `github.com/YOUR_USERNAME/pantrypal-app`
- [ ] README displays correctly on GitHub
- [ ] All documentation files visible in `docs/` folder
- [ ] Repository pinned to your GitHub profile
- [ ] 3+ issues created for first tasks
- [ ] Local git repository connected to GitHub remote
- [ ] Personal information updated in README

**Estimated total time:** 30-45 minutes

---

## Commands Quick Reference

```bash
# Repository setup
git init
git add .
git commit -m "message"
git remote add origin URL
git push -u origin main

# Daily workflow
git status
git add .
git commit -m "message"
git push

# Branch workflow
git checkout -b feature/name
git checkout main
git merge feature/name

# Check what's up
git status
git log --oneline
git remote -v
```

---

**You're all set!** 

Once you push to GitHub, your portfolio project is officially started. This gives you:
1. **Public proof of work** - Recruiters can see you're actively building
2. **Commit history** - Shows consistent development over time
3. **Professional documentation** - Demonstrates technical writing skills
4. **Issue tracking** - Shows project management capability

**Next action this weekend:** Run through Steps 1-7, then message me when your repo is live. We'll tackle database setup next.
