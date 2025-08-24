#!/bin/bash

# 🛡️ Git Helper - Protect main branch and assist with workflow

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Function to display current status
show_status() {
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    echo -e "${BLUE}📍 Current Branch:${NC} $CURRENT_BRANCH"
    echo -e "${BLUE}═══════════════════════════════════════${NC}"
    
    if [ "$CURRENT_BRANCH" = "main" ]; then
        echo -e "${RED}⚠️  WARNING: You are on the MAIN branch!${NC}"
        echo -e "${YELLOW}Consider switching to develop for new work${NC}"
    elif [ "$CURRENT_BRANCH" = "develop" ]; then
        echo -e "${GREEN}✅ On develop branch - safe for integration${NC}"
    else
        echo -e "${BLUE}🔧 On feature branch: $CURRENT_BRANCH${NC}"
    fi
}

# Function to safely create feature branch
create_feature() {
    if [ -z "$1" ]; then
        echo -e "${RED}Please provide a feature name${NC}"
        echo "Usage: $0 feature <feature-name>"
        return 1
    fi
    
    echo -e "${BLUE}Creating feature branch: feature/$1${NC}"
    git checkout develop
    git pull origin develop
    git checkout -b "feature/$1"
    echo -e "${GREEN}✅ Feature branch created!${NC}"
}

# Function to safely merge to develop
merge_to_develop() {
    if [ "$CURRENT_BRANCH" = "main" ]; then
        echo -e "${RED}Cannot merge main to develop directly${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Merging $CURRENT_BRANCH to develop...${NC}"
    git checkout develop
    git pull origin develop
    git merge "$CURRENT_BRANCH"
    
    echo -e "${YELLOW}Push to remote? (y/n)${NC}"
    read -r response
    if [ "$response" = "y" ]; then
        git push origin develop
        echo -e "${GREEN}✅ Pushed to develop!${NC}"
    fi
}

# Function to release to production
release_to_main() {
    echo -e "${YELLOW}⚠️  This will deploy to PRODUCTION!${NC}"
    echo -e "${YELLOW}Are you sure? Type 'DEPLOY' to confirm:${NC}"
    read -r confirm
    
    if [ "$confirm" != "DEPLOY" ]; then
        echo -e "${RED}Deployment cancelled${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Deploying to production...${NC}"
    git checkout main
    git pull origin main
    git merge develop
    
    echo -e "${YELLOW}Enter version tag (e.g., v1.0.1):${NC}"
    read -r version
    git tag -a "$version" -m "Release $version"
    
    git push origin main --tags
    echo -e "${GREEN}✅ Deployed to production!${NC}"
    echo -e "${GREEN}🎉 Version $version is live!${NC}"
}

# Function to check for quote issues in files
check_quotes() {
    echo -e "${BLUE}Checking for potential quote issues...${NC}"
    
    # Check bash scripts
    for script in *.sh; do
        if [ -f "$script" ]; then
            if bash -n "$script" 2>/dev/null; then
                echo -e "${GREEN}✅ $script - OK${NC}"
            else
                echo -e "${RED}❌ $script - Has syntax errors${NC}"
                bash -n "$script"
            fi
        fi
    done
}

# Main menu
case "$1" in
    status)
        show_status
        ;;
    feature)
        create_feature "$2"
        ;;
    merge)
        merge_to_develop
        ;;
    release)
        release_to_main
        ;;
    check)
        check_quotes
        ;;
    *)
        echo -e "${BLUE}🛡️ Git Workflow Helper${NC}"
        echo ""
        echo "Usage:"
        echo "  $0 status          - Show current branch status"
        echo "  $0 feature <name>  - Create new feature branch"
        echo "  $0 merge           - Merge current branch to develop"
        echo "  $0 release         - Deploy develop to main (production)"
        echo "  $0 check           - Check scripts for syntax issues"
        echo ""
        show_status
        ;;
esac
