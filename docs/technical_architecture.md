# PantryPal - Technical Architecture Document

## Executive Summary

PantryPal is a full-stack mobile application that helps families reduce food waste, streamline meal planning, and optimize grocery shopping. The system uses intelligent algorithms to match recipes with available inventory, prioritize expiring items, and generate shopping lists automatically.

**Tech Stack:**
- **Backend:** Python 3.11+ with FastAPI
- **Database:** PostgreSQL 14+
- **Mobile:** React Native (iOS & Android)
- **Cloud:** AWS/Heroku (to be determined)
- **APIs:** Open Food Facts, Spoonacular/Edamam

---

## System Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Mobile Clients                           │
│                    (iOS & Android Apps)                          │
│                      React Native                                │
└────────────────────────┬────────────────────────────────────────┘
                         │ HTTPS/REST
                         │ JWT Authentication
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API Gateway / Load Balancer                 │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    FastAPI Application Server                    │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │  Auth        │  │  Business    │  │  External    │          │
│  │  Middleware  │  │  Logic       │  │  API Client  │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
└────────────────────────┬───────────────────┬────────────────────┘
                         │                   │
                         ▼                   ▼
┌─────────────────────────────────┐  ┌──────────────────────┐
│     PostgreSQL Database         │  │  External APIs       │
│  ┌────────────────────────┐     │  │  - Open Food Facts  │
│  │  Inventory Tables      │     │  │  - Spoonacular      │
│  │  Recipe Tables         │     │  │  - Edamam           │
│  │  User Tables           │     │  └──────────────────────┘
│  │  Analytics Tables      │     │
│  └────────────────────────┘     │
└─────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Background Jobs / Scheduler                   │
│  - Expiration notifications (daily)                              │
│  - Analytics aggregation (nightly)                               │
│  - Price data updates (weekly)                                   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Component Details

### 1. Mobile Application (React Native)

**Architecture Pattern:** Feature-based structure

```
src/
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   ├── components/
│   │   └── api/
│   ├── inventory/
│   │   ├── screens/
│   │   ├── components/
│   │   └── api/
│   ├── recipes/
│   ├── mealPlanning/
│   └── shopping/
├── shared/
│   ├── components/
│   ├── utils/
│   └── hooks/
├── navigation/
├── state/
└── services/
    ├── api.js
    ├── storage.js
    └── notifications.js
```

**Key Technology Choices:**

**State Management:** React Context API + useReducer
- Reasoning: Simpler than Redux for MVP, sufficient for app size
- Alternative: Redux Toolkit if state becomes complex

**Navigation:** React Navigation v6
- Reasoning: Industry standard, excellent docs, flexible
- Stack, Tab, and Drawer navigators for different sections

**UI Library:** React Native Paper (Material Design)
- Reasoning: Consistent cross-platform design, customizable
- Alternative: Native Base or custom components

**Camera/Barcode:** expo-camera or react-native-vision-camera
- Reasoning: Expo simplifies permission handling
- Vision Camera if Expo limitations encountered

**Storage:** expo-secure-store or react-native-keychain
- Reasoning: Secure token storage, encrypted
- Stores: JWT tokens, user preferences

**Networking:** Axios
- Reasoning: Better error handling than fetch, interceptors for auth
- Automatic token injection, request/response logging

---

### 2. Backend API (FastAPI)

**Architecture Pattern:** Layered architecture

```
app/
├── main.py                    # Application entry point
├── core/
│   ├── config.py             # Environment configuration
│   ├── security.py           # JWT utilities
│   └── database.py           # DB connection pool
├── models/                   # SQLAlchemy ORM models
│   ├── user.py
│   ├── inventory.py
│   ├── recipe.py
│   └── meal_plan.py
├── schemas/                  # Pydantic validation schemas
│   ├── user.py
│   ├── inventory.py
│   └── recipe.py
├── api/                      # Route handlers
│   ├── auth.py
│   ├── inventory.py
│   ├── recipes.py
│   ├── meal_plans.py
│   └── shopping.py
├── services/                 # Business logic
│   ├── inventory_service.py
│   ├── recipe_matcher.py
│   ├── meal_planner.py
│   └── external_api_client.py
├── utils/
│   ├── algorithms.py         # Matching algorithms
│   └── notifications.py
└── tests/
    ├── test_inventory.py
    └── test_recipes.py
```

**Key Technology Choices:**

**Web Framework:** FastAPI
- Reasoning: Fast, modern, automatic API docs, type hints
- Better performance than Flask/Django for APIs
- Native async support for external API calls

**ORM:** SQLAlchemy 2.0
- Reasoning: Industry standard, powerful, good PostgreSQL support
- Supports complex queries and relationships
- Migration tool: Alembic

**Validation:** Pydantic
- Reasoning: Built into FastAPI, excellent validation
- Type safety, automatic JSON serialization
- Clear error messages

**Authentication:** JWT (python-jose)
- Reasoning: Stateless, scalable, mobile-friendly
- HS256 algorithm initially, RS256 for production
- 7-day token expiration with refresh tokens

**Testing:** pytest + pytest-asyncio
- Reasoning: Standard Python testing framework
- Test fixtures for database
- Mock external APIs

---

### 3. Database (PostgreSQL)

**Design Principles:**
1. **Normalized structure** - Reduce redundancy, maintain data integrity
2. **Appropriate indexing** - Fast queries on common access patterns
3. **Audit trails** - Track created_at/updated_at for all entities
4. **Soft deletes** - Use flags instead of DELETE for important data

**Key Design Decisions:**

**Inventory Management:**
- Separate `inventory_items` from `products` table
- Products are catalog data (barcode → product info)
- Inventory items are instances (user's actual milk in fridge)
- Allows price history tracking across users

**Recipe Storage:**
- Normalized: `recipes` + `recipe_ingredients` tables
- Denormalized nutrition data in recipes table
- Trade-off: Faster reads, occasional inconsistency acceptable

**Meal Planning:**
- `meal_plans` links date/meal_type to recipe
- Separate from recipes to allow custom meals
- Tracks completion for usage analytics

**Performance Optimizations:**
- Index on `(household_id, expiration_date)` for expiring items query
- Index on `(household_id, date)` for meal plan lookups
- Materialized view considered for analytics (future optimization)

**Scaling Strategy:**
- Initial: Single PostgreSQL instance
- Phase 2: Read replicas for analytics queries
- Phase 3: Partition large tables (inventory_usage_log) by date

---

## Key Algorithms

### 1. Recipe Matching Algorithm

**Goal:** Find recipes user can make with current inventory

**Algorithm:** Fuzzy ingredient matching with scoring

```python
def match_recipe_to_inventory(recipe, inventory_items):
    """
    Scores recipe based on available ingredients.
    
    Returns: {
        'match_score': 0.0-1.0,
        'available': [ingredients],
        'missing': [ingredients],
        'partial': [ingredients with insufficient quantity]
    }
    """
    required = recipe.ingredients
    available_names = {item.name.lower() for item in inventory_items}
    
    exact_matches = 0
    fuzzy_matches = 0
    missing = []
    
    for ingredient in required:
        ingredient_name = ingredient.name.lower()
        
        # Exact match
        if ingredient_name in available_names:
            exact_matches += 1
            continue
            
        # Fuzzy match (handles "chicken" matching "chicken breast")
        found_fuzzy = False
        for inv_name in available_names:
            if ingredient_name in inv_name or inv_name in ingredient_name:
                fuzzy_matches += 1
                found_fuzzy = True
                break
        
        if not found_fuzzy:
            missing.append(ingredient_name)
    
    total_ingredients = len(required)
    match_score = (exact_matches + 0.5 * fuzzy_matches) / total_ingredients
    
    return {
        'match_score': match_score,
        'missing_count': len(missing),
        'missing': missing
    }
```

**Optimization:** Pre-compute ingredient normalized names, cache results

**Future Enhancement:** Use word embeddings for semantic matching

---

### 2. Meal Plan Generation Algorithm

**Goal:** Generate weekly meal plan optimizing multiple factors

**Algorithm:** Constraint-based greedy selection with backtracking

```python
def generate_meal_plan(days=7, preferences={}):
    """
    Generates meal plan optimizing:
    1. Use expiring ingredients first
    2. Variety (don't repeat cuisines/proteins)
    3. Time constraints (quick meals on weekdays)
    4. Nutritional balance
    5. User preferences
    """
    
    plan = []
    used_recipes = set()
    recent_cuisines = []  # Track last 3 cuisines
    
    # Get recipes matching preferences
    candidate_recipes = filter_recipes_by_preferences(preferences)
    
    # Get expiring inventory
    expiring_items = get_expiring_items(days=7)
    
    for day in range(days):
        is_weekday = day < 5
        max_time = preferences.get('max_weekday_time', 30) if is_weekday else 60
        
        # Score each recipe
        scored_recipes = []
        for recipe in candidate_recipes:
            if recipe.id in used_recipes:
                continue
                
            score = 0
            
            # Uses expiring items? +high score
            match = match_recipe_to_inventory(recipe, expiring_items)
            score += match['match_score'] * 50
            
            # Time appropriate?
            if recipe.total_time <= max_time:
                score += 20
            
            # Cuisine variety
            if recipe.cuisine not in recent_cuisines:
                score += 15
            
            # Difficulty (prefer easy on weekdays)
            if is_weekday and recipe.difficulty == 'easy':
                score += 10
            
            scored_recipes.append((recipe, score))
        
        # Select highest scoring recipe
        scored_recipes.sort(key=lambda x: x[1], reverse=True)
        selected_recipe = scored_recipes[0][0]
        
        plan.append({
            'day': day,
            'recipe': selected_recipe
        })
        
        used_recipes.add(selected_recipe.id)
        recent_cuisines.append(selected_recipe.cuisine)
        if len(recent_cuisines) > 3:
            recent_cuisines.pop(0)
    
    return plan
```

**Complexity:** O(n * m) where n=days, m=recipes  
**Optimization:** Pre-filter recipes, limit candidates per day

**Future Enhancement:** ML model trained on user preferences

---

### 3. Shopping List Optimization

**Goal:** Consolidate meal plan ingredients, subtract inventory, organize by category

**Algorithm:** Set operations with quantity aggregation

```python
def generate_shopping_list(meal_plan, current_inventory):
    """
    1. Aggregate all ingredients from meal plan
    2. Subtract available inventory (with quantity check)
    3. Group by category for store efficiency
    """
    
    needed_ingredients = {}  # {ingredient_name: {quantity, unit, recipes}}
    
    # Aggregate from all planned meals
    for meal in meal_plan:
        for ingredient in meal.recipe.ingredients:
            name = ingredient.name
            if name not in needed_ingredients:
                needed_ingredients[name] = {
                    'quantity': 0,
                    'unit': ingredient.unit,
                    'recipes': []
                }
            
            # Convert to common unit and add
            needed_ingredients[name]['quantity'] += convert_to_base_unit(
                ingredient.quantity, 
                ingredient.unit
            )
            needed_ingredients[name]['recipes'].append(meal.recipe.name)
    
    # Subtract current inventory
    for item in current_inventory:
        name = item.name
        if name in needed_ingredients:
            available_qty = convert_to_base_unit(item.quantity, item.unit)
            needed_qty = needed_ingredients[name]['quantity']
            
            if available_qty >= needed_qty:
                # Have enough, remove from shopping list
                del needed_ingredients[name]
            else:
                # Reduce needed amount
                needed_ingredients[name]['quantity'] -= available_qty
    
    # Group by category and estimate prices
    shopping_list = []
    for name, details in needed_ingredients.items():
        product = lookup_product_by_name(name)
        shopping_list.append({
            'item': name,
            'quantity': details['quantity'],
            'unit': details['unit'],
            'category': product.category if product else 'uncategorized',
            'estimated_price': estimate_price(name, details['quantity']),
            'needed_for': details['recipes']
        })
    
    # Sort by category for store layout
    category_order = ['produce', 'meat', 'dairy', 'bakery', 'pantry', 'frozen']
    shopping_list.sort(key=lambda x: category_order.index(x['category']) 
                       if x['category'] in category_order else 999)
    
    return shopping_list
```

---

## Data Flow Examples

### Flow 1: Adding Item via Barcode

```
1. User taps "Scan Barcode" button
2. App requests camera permission
3. User scans barcode → sends to backend
4. Backend queries Open Food Facts API
5. Returns product info (name, brand, typical shelf life)
6. App pre-fills form with product data
7. User confirms/edits expiration date, quantity, location
8. App sends POST /inventory
9. Backend validates, inserts to database
10. Returns item with ID
11. App updates local state, shows success message
```

### Flow 2: Meal Planning

```
1. User taps "What can I make?"
2. App sends POST /recipes/search-by-inventory
3. Backend:
   a. Fetches user's current inventory
   b. Fetches all recipes
   c. Runs matching algorithm
   d. Sorts by match score
   e. Returns top 20 recipes
4. App displays recipes with match indicators
5. User selects recipe, taps "Plan for Tuesday dinner"
6. App sends POST /meal-plans
7. Backend inserts meal plan record
8. Returns confirmation
9. App updates calendar view
```

### Flow 3: Expiration Notifications

```
1. Background scheduler runs daily at 8 AM
2. Queries inventory for items expiring in next 3 days
3. For each household with expiring items:
   a. Creates notification record
   b. Sends push notification via Firebase
4. User receives notification on phone
5. User taps notification → opens to inventory screen
6. Expiring items highlighted in red
7. User can:
   - Mark item as used
   - Add to meal plan
   - Delete if already gone
```

---

## Security Considerations

### Authentication & Authorization

**JWT Implementation:**
- Access token: 24 hours expiration
- Refresh token: 7 days expiration
- Tokens stored in secure storage (encrypted keychain)

**Password Security:**
- Bcrypt hashing with salt rounds = 12
- Minimum password length: 8 characters
- No password complexity requirements (research shows length > complexity)

**API Authorization:**
- All endpoints (except auth) require valid JWT
- Household-level data isolation (users can't access other households)
- Database queries always filtered by household_id

### Data Privacy

**PII Handling:**
- Email addresses encrypted at rest (future)
- No collection of unnecessary personal data
- User can export all data (GDPR compliance)
- User can delete account and all data

**Third-Party APIs:**
- Never send user PII to external APIs
- Only send barcodes/recipe queries
- Log all external API calls for audit

### Mobile Security

**Storage:**
- JWT tokens in secure keychain (iOS) / keystore (Android)
- No sensitive data in AsyncStorage
- Clear tokens on logout

**Network:**
- HTTPS only, certificate pinning (production)
- No mixed content
- Request timeout: 30 seconds

---

## Performance Targets

### API Response Times

| Endpoint Category | Target | Max Acceptable |
|------------------|--------|----------------|
| Authentication | <200ms | 500ms |
| Inventory CRUD | <150ms | 300ms |
| Recipe search | <500ms | 1000ms |
| Meal plan generation | <2s | 5s |
| Shopping list | <300ms | 800ms |

### Database Query Performance

| Query Type | Target | Optimization |
|-----------|--------|--------------|
| Single item lookup | <10ms | Primary key index |
| Inventory list | <50ms | Household_id + compound index |
| Recipe search | <200ms | Full-text search, caching |
| Analytics | <500ms | Pre-aggregated views |

### Mobile App Performance

| Metric | Target |
|--------|--------|
| App launch time (cold) | <3s |
| Screen navigation | <100ms |
| List scroll (60fps) | Consistent |
| Image loading | Progressive, <2s |
| Offline functionality | Read-only access |

---

## Monitoring & Observability

### Metrics to Track

**Backend:**
- Request rate (requests/second)
- Error rate (4xx, 5xx percentages)
- Response time (p50, p95, p99)
- Database connection pool usage
- External API response times

**Mobile:**
- Crash rate (target: <1%)
- App launch time
- Screen render time
- Network request failures
- User engagement (DAU, session length)

**Business:**
- User registrations
- Active users (DAU, MAU)
- Feature usage (barcode scans, meal plans created)
- Shopping lists generated
- Recipes favorited

### Logging Strategy

**Structured Logging (JSON):**
```json
{
  "timestamp": "2026-01-15T10:30:45Z",
  "level": "INFO",
  "user_id": 123,
  "household_id": 45,
  "endpoint": "/api/v1/recipes/search",
  "method": "POST",
  "status_code": 200,
  "response_time_ms": 245,
  "user_agent": "PantryPal-iOS/1.0"
}
```

**Log Levels:**
- DEBUG: Development only, verbose
- INFO: Normal operations, key events
- WARNING: Degraded performance, retries
- ERROR: Request failures, caught exceptions
- CRITICAL: System failures, data corruption

### Alerting

**Critical Alerts (immediate):**
- Error rate > 5% for 5 minutes
- Database connection failures
- External API completely down
- Crash rate > 3%

**Warning Alerts (next day review):**
- Response time p95 > 1 second
- Database slow queries > 1 second
- High memory usage (>80%)

---

## Testing Strategy

### Backend Testing

**Unit Tests:**
- Service layer logic (matching algorithms, calculations)
- Utility functions (date parsing, unit conversion)
- Coverage target: >80%

**Integration Tests:**
- API endpoints with test database
- External API mocking
- Authentication flows

**Load Tests:**
- Simulate 100 concurrent users
- Measure response times under load
- Identify bottlenecks

### Mobile Testing

**Unit Tests:**
- Utility functions
- Business logic (state reducers)
- Coverage target: >60%

**Component Tests:**
- React Native components render correctly
- User interaction flows
- Form validation

**E2E Tests:**
- Critical user paths (Detox or Appium)
- Login → scan item → add to inventory
- Create meal plan → generate shopping list

### User Acceptance Testing

**Alpha Testing (Family):**
- 5-10 family members use app for 2 weeks
- Collect feedback via in-app survey
- Track bugs in GitHub issues

**Beta Testing (Friends):**
- 30-50 users via TestFlight/Google Play beta
- 4 weeks of testing
- Monitor analytics for usage patterns
- Fix critical bugs before public launch

---

## Deployment Strategy

### Development Environment

- Local PostgreSQL database
- FastAPI running on localhost:8000
- React Native app via Expo
- Hot reload enabled

### Staging Environment

- Cloud-hosted database (managed PostgreSQL)
- Backend deployed to Heroku/Railway
- iOS TestFlight build
- Android internal testing track
- Mirrors production configuration

### Production Environment

**Backend Hosting Options:**

**Option 1: Heroku (Recommended for MVP)**
- Pros: Easy deployment, managed database, auto-scaling
- Cons: More expensive at scale
- Cost: ~$25/month (hobby tier + database)

**Option 2: AWS EC2 + RDS**
- Pros: More control, cheaper at scale
- Cons: More complex setup, manual scaling
- Cost: ~$50/month (t3.small + RDS micro)

**Option 3: Railway**
- Pros: Modern, good DX, fair pricing
- Cons: Newer platform, less proven
- Cost: ~$20/month

**Recommendation:** Start with Heroku for fast deployment, migrate to AWS if costs become prohibitive (>$100/month)

### CI/CD Pipeline

```
GitHub Push
    ↓
GitHub Actions
    ↓
├─ Backend Pipeline
│   ├─ Run linting (ruff)
│   ├─ Run tests (pytest)
│   ├─ Build Docker image
│   └─ Deploy to Heroku
│
└─ Mobile Pipeline
    ├─ Run linting (ESLint)
    ├─ Run tests (Jest)
    ├─ Build iOS/Android
    └─ Upload to TestFlight/Play Console
```

---

## Future Enhancements (Post-MVP)

### Phase 2 Features (3-6 months post-launch)

1. **Recipe Sharing & Social Features**
   - Users can share favorite recipes
   - Community recipe ratings
   - Follow other users

2. **Grocery Delivery Integration**
   - One-click order via Instacart API
   - Price comparison across stores
   - Automatic inventory update on delivery

3. **Voice Input**
   - "Hey Siri, add milk to my shopping list"
   - Voice-guided cooking instructions

4. **Smart Kitchen Appliance Integration**
   - Smart scale for precise inventory
   - Smart fridge camera integration
   - Recipe suggestions based on fridge contents

### Technical Debt to Address

1. **Caching Layer (Redis)**
   - Cache recipe search results
   - Cache product lookups
   - Session management

2. **Background Jobs (Celery)**
   - Asynchronous email notifications
   - Bulk data processing
   - Scheduled report generation

3. **Search Optimization**
   - Elasticsearch for recipe full-text search
   - Better ingredient fuzzy matching
   - Faster filtering

4. **Mobile Offline Mode**
   - Local SQLite cache
   - Sync when back online
   - Conflict resolution

---

## IBM Interview Talking Points

**Why this architecture demonstrates data engineering skills:**

1. **Data Modeling:** Designed normalized schema with 15+ tables, appropriate indexes, and relationships
2. **ETL Concepts:** Recipe data ingestion from external APIs, transformation, and loading
3. **Query Optimization:** Strategic indexing, materialized views for analytics
4. **Data Pipeline:** Scheduled jobs for notifications and aggregations
5. **API Design:** RESTful design with proper status codes and error handling
6. **Scalability:** Architecture supports horizontal scaling (stateless backend)
7. **Analytics:** Usage tracking, waste reports, budget analysis

**Technical challenges solved:**

1. Ingredient matching algorithm (fuzzy string matching)
2. Multi-constraint optimization (meal planning)
3. Data aggregation and deduplication (shopping lists)
4. Real-time inventory updates across devices
5. Handling diverse units of measurement (oz, lb, kg, cups)

**What I learned:**

1. Full project lifecycle from design to deployment
2. Mobile-first development with React Native
3. Python backend development with FastAPI
4. Database design and query optimization
5. External API integration and rate limiting
6. User testing and feedback iteration
7. Production deployment and monitoring

---

## Conclusion

This architecture balances **simplicity for MVP delivery** with **flexibility for future scaling**. Key decisions prioritize:

1. **Speed to market:** Established technologies, minimal infrastructure
2. **Maintainability:** Clean separation of concerns, testable code
3. **User experience:** Fast responses, offline capability, intuitive design
4. **Demonstrable skills:** Shows full-stack capability relevant to IBM data engineering roles

**Success Criteria:**
- Functional app in app stores by June 2026
- 50+ active beta users
- <1% crash rate
- Portfolio quality documentation
- Can explain every technical decision in interviews

This is not a perfect architecture - it's a practical one that gets the job done and demonstrates competency to employers.
