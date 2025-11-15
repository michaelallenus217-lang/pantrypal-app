#!/bin/bash

# PantryPal Backend Quick Setup Script
# Run this after cloning the repository to set up the backend

set -e  # Exit on error

echo "🚀 Starting PantryPal Backend Setup..."
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ============================================
# Check Prerequisites
# ============================================

echo "📋 Checking prerequisites..."

# Check Python version
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed${NC}"
    echo "   Please install Python 3.11+ from https://www.python.org/downloads/"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2 | cut -d'.' -f1,2)
if (( $(echo "$PYTHON_VERSION < 3.11" | bc -l) )); then
    echo -e "${RED}❌ Python version $PYTHON_VERSION detected. Python 3.11+ required.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Python $PYTHON_VERSION detected${NC}"

# Check PostgreSQL
if ! command -v psql &> /dev/null; then
    echo -e "${YELLOW}⚠️  PostgreSQL client not found${NC}"
    echo "   Please install PostgreSQL 14+ from https://www.postgresql.org/download/"
    echo "   Or continue if you have PostgreSQL server running elsewhere"
    read -p "   Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    PSQL_VERSION=$(psql --version | grep -oP '\d+\.\d+' | head -1)
    echo -e "${GREEN}✓ PostgreSQL $PSQL_VERSION detected${NC}"
fi

echo ""

# ============================================
# Create Virtual Environment
# ============================================

echo "🐍 Creating Python virtual environment..."

if [ -d "venv" ]; then
    echo -e "${YELLOW}⚠️  Virtual environment already exists. Skipping creation.${NC}"
else
    python3 -m venv venv
    echo -e "${GREEN}✓ Virtual environment created${NC}"
fi

# Activate virtual environment
source venv/bin/activate

echo -e "${GREEN}✓ Virtual environment activated${NC}"
echo ""

# ============================================
# Install Dependencies
# ============================================

echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# ============================================
# Set Up Environment Variables
# ============================================

echo "🔧 Setting up environment variables..."

if [ -f ".env" ]; then
    echo -e "${YELLOW}⚠️  .env file already exists. Skipping creation.${NC}"
else
    cp .env.example .env
    
    # Generate random secret key
    SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(32))")
    
    # Replace SECRET_KEY in .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/your-secret-key-here-change-this-in-production/$SECRET_KEY/" .env
    else
        # Linux
        sed -i "s/your-secret-key-here-change-this-in-production/$SECRET_KEY/" .env
    fi
    
    echo -e "${GREEN}✓ .env file created with random SECRET_KEY${NC}"
    echo -e "${YELLOW}⚠️  Don't forget to update database credentials in .env${NC}"
fi

echo ""

# ============================================
# Database Setup
# ============================================

echo "🗄️  Setting up database..."

read -p "Do you want to create the database now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    read -p "Enter PostgreSQL username [postgres]: " DB_USER
    DB_USER=${DB_USER:-postgres}
    
    read -p "Enter database name [pantrypal_dev]: " DB_NAME
    DB_NAME=${DB_NAME:-pantrypal_dev}
    
    # Try to create database
    if createdb -U "$DB_USER" "$DB_NAME" 2>/dev/null; then
        echo -e "${GREEN}✓ Database '$DB_NAME' created${NC}"
        
        # Run schema
        read -p "Do you want to run the database schema? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            psql -U "$DB_USER" -d "$DB_NAME" -f ../docs/database_schema.sql
            echo -e "${GREEN}✓ Database schema applied${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Database '$DB_NAME' may already exist or creation failed${NC}"
        echo "   You can manually create it with: createdb -U $DB_USER $DB_NAME"
    fi
    
    # Update .env with database URL
    DATABASE_URL="postgresql://$DB_USER:yourpassword@localhost:5432/$DB_NAME"
    echo ""
    echo -e "${YELLOW}⚠️  Update your .env file with the correct database URL:${NC}"
    echo "   DATABASE_URL=$DATABASE_URL"
else
    echo -e "${YELLOW}⚠️  Skipping database creation${NC}"
    echo "   Remember to create database and update .env file"
fi

echo ""

# ============================================
# Test Installation
# ============================================

echo "🧪 Testing installation..."

# Check if FastAPI can be imported
if python3 -c "import fastapi" 2>/dev/null; then
    echo -e "${GREEN}✓ FastAPI installed correctly${NC}"
else
    echo -e "${RED}❌ FastAPI import failed${NC}"
    exit 1
fi

# Check if SQLAlchemy can be imported
if python3 -c "import sqlalchemy" 2>/dev/null; then
    echo -e "${GREEN}✓ SQLAlchemy installed correctly${NC}"
else
    echo -e "${RED}❌ SQLAlchemy import failed${NC}"
    exit 1
fi

echo ""

# ============================================
# Next Steps
# ============================================

echo -e "${GREEN}✅ Backend setup complete!${NC}"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Update database credentials in .env file"
echo "   nano .env"
echo ""
echo "2. If you haven't already, create the database:"
echo "   createdb pantrypal_dev"
echo ""
echo "3. Run the database schema:"
echo "   psql -d pantrypal_dev -f ../docs/database_schema.sql"
echo ""
echo "4. Start the development server:"
echo "   source venv/bin/activate"
echo "   uvicorn app.main:app --reload"
echo ""
echo "5. View API documentation at:"
echo "   http://localhost:8000/docs"
echo ""
echo "6. Run tests:"
echo "   pytest"
echo ""
echo -e "${YELLOW}💡 Tip: Keep the virtual environment activated while developing${NC}"
echo "   Run 'deactivate' to exit the virtual environment"
echo ""
echo "Happy coding! 🚀"
