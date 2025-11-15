# PantryPal - Smart Pantry Management App

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)
[![React Native](https://img.shields.io/badge/React_Native-0.72+-61DAFB.svg)](https://reactnative.dev/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14+-336791.svg)](https://www.postgresql.org/)

> A full-stack mobile application that helps families reduce food waste, streamline meal planning, and optimize grocery shopping through intelligent inventory management and recipe matching.

**Status:** 🚧 In Development (Started November 2025)  
**Target Launch:** November 2026  
**Developer:** Michael - Military Chef transitioning to Software Engineering

---

## 📱 What is PantryPal?

PantryPal solves a common household problem: **food waste and meal planning chaos**. 

**Key Features:**
- 📸 **Barcode Scanning** - Quickly add groceries to your digital pantry
- ⏰ **Expiration Tracking** - Get notified before food goes bad
- 🍳 **Smart Recipe Matching** - "What can I make?" based on what you have
- 📅 **Meal Planning** - Auto-generate weekly meal plans
- 🛒 **Shopping Lists** - Auto-generated from meal plans, organized by store layout
- 📊 **Waste Analytics** - Track savings and reduce food waste over time

**Target Users:** Busy families who want to save money, reduce waste, and simplify meal planning.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│   React Native Mobile App          │
│   (iOS & Android)                   │
└──────────────┬──────────────────────┘
               │ REST API
               ▼
┌─────────────────────────────────────┐
│   FastAPI Backend                   │
│   (Python 3.11)                     │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│   PostgreSQL Database               │
│   (Relational Data)                 │
└─────────────────────────────────────┘
```

**Tech Stack:**
- **Backend:** Python 3.11+, FastAPI, SQLAlchemy, Alembic
- **Database:** PostgreSQL 14+
- **Mobile:** React Native 0.72+, React Navigation, Axios
- **External APIs:** Open Food Facts (barcode lookup), Spoonacular (recipes)
- **Deployment:** Heroku (backend), App Store + Google Play (mobile)

**Why this stack?**
- **Python/FastAPI:** Modern, fast, excellent async support for external APIs
- **PostgreSQL:** Robust, great for relational data (recipes, ingredients, inventory)
- **React Native:** Single codebase for iOS + Android, large community
- **Focus:** Full-stack demonstration for software engineering roles

---

## 🚀 Quick Start

### Prerequisites

- **Python 3.11+** ([Download](https://www.python.org/downloads/))
- **PostgreSQL 14+** ([Download](https://www.postgresql.org/download/))
- **Node.js 18+** ([Download](https://nodejs.org/))
- **Git** ([Download](https://git-scm.com/downloads))

### Backend Setup (10 minutes)

```bash
# Clone repository
git clone https://github.com/YOUR_USERNAME/pantrypal-app.git
cd pantrypal-app

# Set up Python virtual environment
cd backend
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set up environment variables
cp .env.example .env
# Edit .env with your database credentials

# Create database and run migrations
createdb pantrypal_dev
alembic upgrade head

# Seed sample data (optional)
python scripts/seed_data.py

# Run development server
uvicorn app.main:app --reload

# Backend running at http://localhost:8000
# API docs at http://localhost:8000/docs
```

### Mobile App Setup (10 minutes)

```bash
# From project root
cd mobile

# Install dependencies
npm install

# iOS setup (Mac only)
cd ios && pod install && cd ..

# Start Metro bundler
npm start

# In separate terminals:
npm run ios      # Launch iOS simulator
npm run android  # Launch Android emulator
```

---

## 📂 Project Structure

```
pantrypal-app/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── api/            # Route handlers
│   │   ├── core/           # Config, security, database
│   │   ├── models/         # SQLAlchemy ORM models
│   │   ├── schemas/        # Pydantic validation schemas
│   │   ├── services/       # Business logic
│   │   └── main.py         # Application entry point
│   ├── alembic/            # Database migrations
│   ├── tests/              # Backend tests
│   └── requirements.txt
│
├── mobile/                  # React Native app
│   ├── src/
│   │   ├── features/       # Feature-based modules
│   │   │   ├── auth/
│   │   │   ├── inventory/
│   │   │   ├── recipes/
│   │   │   └── mealPlanning/
│   │   ├── navigation/     # App navigation
│   │   ├── services/       # API client, storage
│   │   └── shared/         # Reusable components
│   ├── __tests__/          # Mobile tests
│   └── package.json
│
├── docs/                    # Technical documentation
│   ├── api_specification.md
│   ├── database_schema.sql
│   ├── development_timeline.md
│   └── technical_architecture.md
│
└── README.md               # This file
```

---

## 🗄️ Database Schema

**Core Tables:**
- `users` - User accounts and authentication
- `households` - Family/household groups
- `inventory_items` - Food items in user's pantry/fridge
- `recipes` - Recipe database with instructions
- `recipe_ingredients` - Ingredients required for recipes
- `meal_plans` - User's weekly meal planning
- `shopping_lists` - Auto-generated shopping lists
- `notifications` - Expiration alerts and reminders

**Key Relationships:**
- Users belong to households (multi-user support)
- Inventory items linked to households
- Meal plans reference recipes
- Shopping lists generated from meal plans + inventory gaps

See [database_schema.sql](docs/database_schema.sql) for complete schema.

---

## 🔌 API Endpoints

**Authentication:**
- `POST /api/v1/auth/register` - Create new user account
- `POST /api/v1/auth/login` - Login and receive JWT token

**Inventory Management:**
- `GET /api/v1/inventory` - List all inventory items
- `POST /api/v1/inventory` - Add new item
- `GET /api/v1/inventory/barcode/{barcode}` - Lookup product by barcode
- `PATCH /api/v1/inventory/{id}` - Update item
- `POST /api/v1/inventory/{id}/consume` - Mark item as used

**Recipes:**
- `GET /api/v1/recipes` - Browse recipes
- `POST /api/v1/recipes/search-by-inventory` - Find recipes you can make
- `GET /api/v1/recipes/{id}` - Get recipe details
- `POST /api/v1/recipes/{id}/favorite` - Save to favorites

**Meal Planning:**
- `GET /api/v1/meal-plans` - Get weekly meal plan
- `POST /api/v1/meal-plans` - Add meal to plan
- `POST /api/v1/meal-plans/generate` - Auto-generate meal plan

**Shopping Lists:**
- `GET /api/v1/shopping-lists/active` - Get current shopping list
- `POST /api/v1/shopping-lists/generate-from-meals` - Generate from meal plan
- `PATCH /api/v1/shopping-lists/items/{id}/purchase` - Mark as purchased

See [api_specification.md](docs/api_specification.md) for complete API documentation.

---

## 🧪 Testing

### Backend Tests

```bash
cd backend

# Run all tests
pytest

# Run with coverage
pytest --cov=app --cov-report=html

# Run specific test file
pytest tests/test_inventory.py

# Run tests in watch mode
ptw
```

### Mobile Tests

```bash
cd mobile

# Run Jest tests
npm test

# Run with coverage
npm test -- --coverage

# Run E2E tests (requires simulator running)
npm run test:e2e
```

**Testing Strategy:**
- **Unit Tests:** Business logic, algorithms, utilities
- **Integration Tests:** API endpoints with test database
- **E2E Tests:** Critical user flows in mobile app
- **Target Coverage:** Backend >80%, Mobile >60%

---

## 🔒 Security

**Authentication:**
- JWT tokens with 24-hour expiration
- Bcrypt password hashing (12 salt rounds)
- Secure token storage (iOS Keychain / Android Keystore)

**Authorization:**
- Household-level data isolation
- All API requests validate household membership
- No cross-household data access

**Data Privacy:**
- Minimal PII collection (email only)
- No tracking or analytics in MVP
- User can export/delete all data

**API Security:**
- HTTPS only in production
- Rate limiting (100 requests/minute per user)
- Input validation via Pydantic schemas

---

## 📊 Key Algorithms

### 1. Recipe Matching Algorithm

Matches recipes to available inventory using fuzzy string matching:

```python
match_score = (exact_matches + 0.5 * fuzzy_matches) / total_ingredients
```

- Prioritizes recipes with highest match percentage
- Accounts for ingredient variations (e.g., "chicken" matches "chicken breast")
- Considers quantity requirements

### 2. Meal Plan Generation

Multi-constraint optimization considering:
- **Expiration priority:** Use items expiring soonest
- **Time constraints:** Quick meals on weekdays (<30 min)
- **Variety:** Avoid repeating cuisines/proteins
- **Nutrition:** Balance macros across week
- **Preferences:** Dietary restrictions, favorites

### 3. Shopping List Optimization

```python
needed = aggregate_meal_ingredients(meal_plan)
available = current_inventory
shopping_list = needed - available  # Set difference with quantity adjustment
```

Groups by category and estimates prices based on historical data.

---

## 🎯 Development Roadmap

### ✅ Phase 1: Foundation (Nov-Dec 2025)
- [x] Project setup and documentation
- [ ] Database schema implementation
- [ ] Backend API framework (FastAPI)
- [ ] Authentication endpoints
- [ ] Core inventory CRUD operations

### 🚧 Phase 2: Mobile App (Jan-Mar 2026)
- [ ] React Native project setup
- [ ] Authentication screens
- [ ] Inventory management UI
- [ ] Barcode scanning
- [ ] Recipe browsing

### 📅 Phase 3: Smart Features (Mar-May 2026)
- [ ] Recipe matching algorithm
- [ ] Meal plan generator
- [ ] Shopping list automation
- [ ] Expiration notifications
- [ ] Analytics dashboard

### 🚀 Phase 4: Polish & Deploy (May-Jun 2026)
- [ ] UI/UX refinement
- [ ] Comprehensive testing
- [ ] App store preparation
- [ ] Production deployment

### 📱 Phase 5: Launch (Jul-Nov 2026)
- [ ] App store approval
- [ ] Beta testing with users
- [ ] Portfolio documentation
- [ ] Interview preparation

**Target Launch:** November 1, 2026

See [development_timeline.md](docs/development_timeline.md) for detailed week-by-week plan.

---

## 🤝 Contributing

This is a solo portfolio project, but feedback and suggestions are welcome!

**If you're interested in this project:**
1. ⭐ Star the repository
2. 🐛 Open issues for bugs you find
3. 💡 Suggest features via discussions
4. 📧 Reach out for collaboration opportunities

---

## 📄 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file for details.

---

## 👨‍💻 About the Developer

**Michael** - Restaurant Chef and Computer Scientist transitioning from military service to software engineering.

**Background:**
- 🎖️ Serving with 1-2 Stryker Brigade Combat Team at JBLMC
- 👨‍🍳 Managing food service operations (1,300 daily meals)
- 💻 CS degree with focus on algorithms and data structures
- 🎯 Targeting data engineering roles at IBM and other tech companies

**Why PantryPal?**
This project combines my culinary expertise with software engineering skills to solve a real problem I experience daily. It demonstrates:
- Full-stack development (mobile + backend + database)
- Data modeling and algorithm design
- Project management and delivery
- User-focused product development

**Connect:**
- GitHub: [@YOUR_USERNAME](https://github.com/YOUR_USERNAME)
- LinkedIn: [Your LinkedIn](https://linkedin.com/in/your-profile)
- Portfolio: [Coming Soon]

---

## 🙏 Acknowledgments

- **Open Food Facts** - Barcode database API
- **Spoonacular** - Recipe data API
- **FastAPI Community** - Excellent documentation and support
- **React Native Community** - Extensive libraries and resources
- **My Family** - Alpha testers and inspiration for this project

---

## 📚 Additional Documentation

- [API Specification](docs/api_specification.md) - Complete API endpoint documentation
- [Database Schema](docs/database_schema.sql) - Full PostgreSQL schema with indexes
- [Development Timeline](docs/development_timeline.md) - 12-month development plan
- [Technical Architecture](docs/technical_architecture.md) - System design and algorithms

---

## ❓ FAQ

**Q: Why build this as a portfolio project?**  
A: Demonstrates full-stack capability, practical problem-solving, and project completion - all valuable for data engineering roles.

**Q: Will this be available in app stores?**  
A: Yes! Targeting iOS App Store and Google Play launch in November 2026.

**Q: Can I use this code for my own project?**  
A: Yes, it's MIT licensed. Attribution appreciated but not required.

**Q: Why PostgreSQL instead of MongoDB?**  
A: Recipes and inventory have clear relational structure. PostgreSQL excels at complex queries needed for recipe matching.

**Q: How is this relevant to data engineering?**  
A: Demonstrates data modeling, ETL concepts (recipe ingestion), query optimization, analytics, and API design - all core to data engineering.

---

**Built with ❤️ by a chef who codes**

Last Updated: November 15, 2025
