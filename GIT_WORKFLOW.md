# Git Workflow Guide 🚀

## Branch Structure

### Main Branches
- **`main`** (production) - Always stable, deployed to GitHub Pages
- **`develop`** - Integration branch for features

### Feature Branches
- Create from: `develop`
- Merge back to: `develop`
- Naming: `feature/description` (e.g., `feature/add-karaoke`)

## Workflow

### 1. Starting New Work
```bash
# Always start from develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/your-feature-name
```

### 2. Making Changes
```bash
# Make your changes
# Test thoroughly

# Stage and commit
git add -A
git commit -m "🎯 Clear commit message"

# Push to remote
git push origin feature/your-feature-name
```

### 3. Merging to Develop
```bash
# Update develop first
git checkout develop
git pull origin develop

# Merge your feature
git merge feature/your-feature-name

# Push develop
git push origin develop

# Clean up
git branch -d feature/your-feature-name
```

### 4. Releasing to Production
```bash
# From develop, when stable
git checkout main
git pull origin main

# Merge develop
git merge develop

# Tag the release
git tag -a v1.0.0 -m "Release version 1.0.0"

# Push with tags
git push origin main --tags
```

## Commit Message Convention

Use emojis for clarity:
- 🎯 Feature
- 🐛 Bug fix
- 📚 Documentation
- 🎨 UI/UX changes
- ♻️ Refactor
- 🚀 Performance
- 🔧 Configuration
- 🧪 Tests
- 🎵 DJ/Music features
- 🐾 Panther-specific

## Current State

- **Production (main)**: Stable dashboard with all features
- **Development (develop)**: Testing ground for new features

## Emergency Hotfix

If production needs immediate fix:
```bash
# Create from main
git checkout main
git checkout -b hotfix/critical-fix

# Fix and commit
git add -A
git commit -m "🚨 Hotfix: description"

# Merge to main
git checkout main
git merge hotfix/critical-fix
git push origin main

# Also merge to develop
git checkout develop
git merge hotfix/critical-fix
git push origin develop
```

## Tips

1. **Always pull before starting work**
2. **Test on develop before merging to main**
3. **Keep commits atomic and meaningful**
4. **Document breaking changes**
5. **Use pull requests for code review when working with team**

## Quote Issues Prevention

When committing, if you encounter quote issues:
1. Check for unescaped quotes in commit messages
2. Use single quotes for complex messages: `git commit -m 'message'`
3. For scripts, validate syntax: `bash -n script.sh`
4. Test commands in a subshell first: `bash -c "your command"`

---
*Remember: The develop branch is your friend. Break things there, not in production!* 🎉
