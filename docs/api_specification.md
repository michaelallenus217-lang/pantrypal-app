# Smart Pantry Management App - REST API Specification

## Base URL
```
Development: http://localhost:8000/api/v1
Production: https://api.smartpantry.app/v1
```

## Authentication
All endpoints except `/auth/register` and `/auth/login` require JWT token in header:
```
Authorization: Bearer <jwt_token>
```

---

## Authentication Endpoints

### Register New User
```
POST /auth/register
```
**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "household_name": "Smith Family",
  "family_size": 4
}
```
**Response (201):**
```json
{
  "user_id": 1,
  "household_id": 1,
  "email": "user@example.com",
  "token": "jwt_token_here"
}
```

### Login
```
POST /auth/login
```
**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "securepassword123"
}
```
**Response (200):**
```json
{
  "user_id": 1,
  "household_id": 1,
  "token": "jwt_token_here"
}
```

---

## Inventory Endpoints

### Get All Inventory Items
```
GET /inventory
```
**Query Parameters:**
- `location_id` (optional): Filter by storage location
- `category` (optional): Filter by category
- `expiring_soon` (optional): true/false - items expiring in next 7 days
- `depleted` (optional): true/false - include depleted items

**Response (200):**
```json
{
  "items": [
    {
      "id": 1,
      "name": "Whole Milk",
      "brand": "Organic Valley",
      "barcode": "070470000012",
      "quantity": 0.5,
      "unit": "gal",
      "purchase_date": "2025-11-10",
      "expiration_date": "2025-11-20",
      "cost": 4.99,
      "category": "dairy",
      "storage_location": {
        "id": 2,
        "name": "Refrigerator"
      },
      "days_until_expiration": 5
    }
  ],
  "summary": {
    "total_items": 45,
    "expiring_soon": 3,
    "total_value": 234.50
  }
}
```

### Add Inventory Item
```
POST /inventory
```
**Request Body:**
```json
{
  "barcode": "070470000012",
  "name": "Whole Milk",
  "brand": "Organic Valley",
  "quantity": 1,
  "unit": "gal",
  "storage_location_id": 2,
  "purchase_date": "2025-11-15",
  "expiration_date": "2025-11-25",
  "cost": 4.99,
  "category": "dairy"
}
```
**Response (201):**
```json
{
  "id": 1,
  "name": "Whole Milk",
  "message": "Item added to inventory"
}
```

### Scan Barcode
```
GET /inventory/barcode/{barcode}
```
**Response (200):**
```json
{
  "barcode": "070470000012",
  "product": {
    "name": "Organic Valley Whole Milk",
    "brand": "Organic Valley",
    "category": "dairy",
    "typical_shelf_life_days": 14,
    "default_unit": "gal",
    "image_url": "https://example.com/image.jpg"
  },
  "existing_inventory": {
    "has_item": true,
    "current_quantity": 0.5,
    "expiration_date": "2025-11-20"
  },
  "price_history": [
    {
      "store": "Generic Store",
      "price": 4.99,
      "recorded_at": "2025-11-01"
    }
  ]
}
```

### Update Inventory Item
```
PATCH /inventory/{item_id}
```
**Request Body (partial update):**
```json
{
  "quantity": 0.25,
  "expiration_date": "2025-11-30"
}
```
**Response (200):**
```json
{
  "id": 1,
  "message": "Item updated successfully"
}
```

### Use/Consume Inventory Item
```
POST /inventory/{item_id}/consume
```
**Request Body:**
```json
{
  "quantity_used": 0.5,
  "unit": "gal",
  "used_for_recipe_id": 5,
  "used_for_meal_plan_id": 12
}
```
**Response (200):**
```json
{
  "id": 1,
  "remaining_quantity": 0.5,
  "is_depleted": false,
  "message": "Usage logged successfully"
}
```

### Delete Inventory Item
```
DELETE /inventory/{item_id}
```
**Response (204):** No content

---

## Recipe Endpoints

### Get All Recipes
```
GET /recipes
```
**Query Parameters:**
- `meal_type` (optional): breakfast, lunch, dinner, snack, dessert
- `cuisine_type` (optional): italian, mexican, asian, american, etc.
- `max_prep_time` (optional): maximum total minutes (prep + cook)
- `difficulty` (optional): easy, medium, hard
- `tags` (optional): comma-separated tags (vegetarian, quick, healthy)
- `favorites_only` (optional): true/false

**Response (200):**
```json
{
  "recipes": [
    {
      "id": 1,
      "name": "Quick Chicken Stir Fry",
      "description": "Fast and healthy weeknight dinner",
      "meal_type": "dinner",
      "cuisine_type": "asian",
      "prep_time_minutes": 15,
      "cook_time_minutes": 10,
      "total_time_minutes": 25,
      "servings": 4,
      "difficulty": "easy",
      "calories_per_serving": 350,
      "nutrition": {
        "protein_grams": 35.0,
        "carbs_grams": 25.0,
        "fat_grams": 12.0,
        "fiber_grams": 4.0
      },
      "image_url": "https://example.com/stir-fry.jpg",
      "tags": ["quick", "healthy"],
      "user_data": {
        "is_favorite": true,
        "times_cooked": 3,
        "rating": 5
      }
    }
  ],
  "total": 1,
  "page": 1,
  "page_size": 20
}
```

### Get Recipe by ID
```
GET /recipes/{recipe_id}
```
**Response (200):**
```json
{
  "id": 1,
  "name": "Quick Chicken Stir Fry",
  "description": "Fast and healthy weeknight dinner",
  "meal_type": "dinner",
  "prep_time_minutes": 15,
  "cook_time_minutes": 10,
  "servings": 4,
  "difficulty": "easy",
  "instructions": "1. Cut chicken into strips...",
  "ingredients": [
    {
      "id": 1,
      "name": "chicken breast",
      "quantity": 1.5,
      "unit": "lb",
      "is_optional": false,
      "preparation_note": "cut into strips"
    },
    {
      "id": 2,
      "name": "mixed vegetables",
      "quantity": 3,
      "unit": "cup",
      "is_optional": false,
      "preparation_note": null
    }
  ],
  "nutrition": {
    "calories_per_serving": 350,
    "protein_grams": 35.0,
    "carbs_grams": 25.0,
    "fat_grams": 12.0
  },
  "tags": ["quick", "healthy"],
  "can_make_now": {
    "possible": true,
    "missing_ingredients": [],
    "partial_ingredients": []
  }
}
```

### Search Recipes by Available Ingredients
```
POST /recipes/search-by-inventory
```
**Request Body:**
```json
{
  "match_threshold": 0.7,
  "prioritize_expiring": true,
  "meal_type": "dinner",
  "max_prep_time": 30
}
```
**Response (200):**
```json
{
  "recipes": [
    {
      "id": 1,
      "name": "Quick Chicken Stir Fry",
      "match_percentage": 0.85,
      "available_ingredients": ["chicken breast", "mixed vegetables", "soy sauce"],
      "missing_ingredients": ["rice"],
      "uses_expiring_items": true,
      "expiring_items_used": [
        {
          "name": "chicken breast",
          "days_until_expiration": 2
        }
      ],
      "total_time_minutes": 25
    }
  ]
}
```

### Add Recipe to Favorites
```
POST /recipes/{recipe_id}/favorite
```
**Response (200):**
```json
{
  "recipe_id": 1,
  "is_favorite": true
}
```

### Rate Recipe
```
POST /recipes/{recipe_id}/rate
```
**Request Body:**
```json
{
  "rating": 5,
  "notes": "Family loved it! Made extra for leftovers."
}
```
**Response (200):**
```json
{
  "recipe_id": 1,
  "rating": 5,
  "times_cooked": 4
}
```

---

## Meal Planning Endpoints

### Get Meal Plan
```
GET /meal-plans
```
**Query Parameters:**
- `start_date` (required): YYYY-MM-DD
- `end_date` (required): YYYY-MM-DD

**Response (200):**
```json
{
  "meal_plans": [
    {
      "date": "2025-11-18",
      "meals": [
        {
          "id": 1,
          "meal_type": "breakfast",
          "recipe": {
            "id": 5,
            "name": "Overnight Oats",
            "prep_time_minutes": 5,
            "cook_time_minutes": 0
          },
          "servings_planned": 4,
          "is_completed": false,
          "notes": "Kids prefer with blueberries"
        },
        {
          "id": 2,
          "meal_type": "dinner",
          "recipe": {
            "id": 1,
            "name": "Quick Chicken Stir Fry",
            "prep_time_minutes": 15,
            "cook_time_minutes": 10
          },
          "servings_planned": 4,
          "is_completed": false
        }
      ]
    }
  ],
  "summary": {
    "total_meals_planned": 14,
    "meals_completed": 6,
    "estimated_total_cost": 156.00
  }
}
```

### Add Meal to Plan
```
POST /meal-plans
```
**Request Body:**
```json
{
  "date": "2025-11-18",
  "meal_type": "dinner",
  "recipe_id": 1,
  "servings_planned": 4,
  "notes": "Make extra for lunch tomorrow"
}
```
**Response (201):**
```json
{
  "id": 1,
  "date": "2025-11-18",
  "meal_type": "dinner",
  "recipe_id": 1,
  "message": "Meal added to plan"
}
```

### Generate Weekly Meal Plan
```
POST /meal-plans/generate
```
**Request Body:**
```json
{
  "start_date": "2025-11-18",
  "preferences": {
    "max_prep_time_weekday": 30,
    "max_prep_time_weekend": 60,
    "variety_score": 0.8,
    "use_expiring_items": true,
    "meal_types": ["dinner"],
    "exclude_ingredients": ["shellfish"]
  }
}
```
**Response (200):**
```json
{
  "meal_plans": [
    {
      "date": "2025-11-18",
      "meal_type": "dinner",
      "recipe": {
        "id": 1,
        "name": "Quick Chicken Stir Fry",
        "total_time_minutes": 25
      },
      "reason_selected": "Uses chicken expiring in 2 days"
    }
  ],
  "estimated_grocery_cost": 45.00,
  "new_items_needed": 8
}
```

### Mark Meal as Completed
```
PATCH /meal-plans/{meal_plan_id}/complete
```
**Response (200):**
```json
{
  "id": 1,
  "is_completed": true,
  "completed_at": "2025-11-18T18:30:00Z"
}
```

---

## Shopping List Endpoints

### Get Active Shopping List
```
GET /shopping-lists/active
```
**Response (200):**
```json
{
  "id": 1,
  "name": "Weekly Shopping",
  "created_at": "2025-11-15T10:00:00Z",
  "items": [
    {
      "id": 1,
      "item_name": "chicken breast",
      "quantity": 2.5,
      "unit": "lb",
      "category": "protein",
      "estimated_cost": 12.50,
      "is_purchased": false,
      "notes": "For stir fry and tacos",
      "added_from_recipe": {
        "id": 1,
        "name": "Quick Chicken Stir Fry"
      }
    }
  ],
  "summary": {
    "total_items": 12,
    "purchased": 5,
    "estimated_total": 78.50
  }
}
```

### Generate Shopping List from Meal Plan
```
POST /shopping-lists/generate-from-meals
```
**Request Body:**
```json
{
  "start_date": "2025-11-18",
  "end_date": "2025-11-24",
  "list_name": "Week of Nov 18"
}
```
**Response (201):**
```json
{
  "id": 2,
  "name": "Week of Nov 18",
  "items_count": 15,
  "estimated_total": 92.00,
  "items": [
    {
      "item_name": "chicken breast",
      "quantity": 3.0,
      "unit": "lb",
      "category": "protein",
      "estimated_cost": 15.00
    }
  ]
}
```

### Add Item to Shopping List
```
POST /shopping-lists/{list_id}/items
```
**Request Body:**
```json
{
  "item_name": "olive oil",
  "quantity": 1,
  "unit": "bottle",
  "category": "pantry",
  "estimated_cost": 8.99,
  "notes": "Extra virgin"
}
```
**Response (201):**
```json
{
  "id": 15,
  "item_name": "olive oil",
  "message": "Item added to shopping list"
}
```

### Mark Item as Purchased
```
PATCH /shopping-lists/items/{item_id}/purchase
```
**Request Body:**
```json
{
  "actual_cost": 9.49,
  "add_to_inventory": true,
  "inventory_details": {
    "barcode": "12345678",
    "storage_location_id": 1,
    "expiration_date": "2026-05-15"
  }
}
```
**Response (200):**
```json
{
  "id": 15,
  "is_purchased": true,
  "inventory_item_id": 45,
  "message": "Item marked as purchased and added to inventory"
}
```

---

## Analytics Endpoints

### Get Food Waste Report
```
GET /analytics/waste-report
```
**Query Parameters:**
- `start_date`: YYYY-MM-DD
- `end_date`: YYYY-MM-DD

**Response (200):**
```json
{
  "period": {
    "start": "2025-10-01",
    "end": "2025-10-31"
  },
  "waste_summary": {
    "items_expired": 8,
    "total_value_wasted": 42.50,
    "most_wasted_categories": [
      {
        "category": "produce",
        "items_count": 5,
        "value": 28.00
      }
    ]
  },
  "recommendations": [
    "Consider buying smaller quantities of lettuce",
    "Bell peppers consistently expire - reduce purchase frequency"
  ]
}
```

### Get Budget Analysis
```
GET /analytics/budget
```
**Query Parameters:**
- `start_date`: YYYY-MM-DD
- `end_date`: YYYY-MM-DD

**Response (200):**
```json
{
  "period": {
    "start": "2025-11-01",
    "end": "2025-11-15"
  },
  "spending": {
    "total_spent": 234.50,
    "weekly_budget": 200.00,
    "variance": 34.50,
    "on_track": false
  },
  "spending_by_category": [
    {
      "category": "protein",
      "amount": 89.00,
      "percentage": 38
    },
    {
      "category": "produce",
      "amount": 67.00,
      "percentage": 29
    }
  ]
}
```

### Get Recipe Usage Stats
```
GET /analytics/recipe-stats
```
**Response (200):**
```json
{
  "most_cooked_recipes": [
    {
      "recipe_id": 1,
      "name": "Quick Chicken Stir Fry",
      "times_cooked": 12,
      "avg_rating": 4.8
    }
  ],
  "cuisine_preferences": [
    {
      "cuisine": "asian",
      "cook_count": 15
    }
  ],
  "avg_meal_prep_time": 28.5
}
```

---

## Notification Endpoints

### Get Notifications
```
GET /notifications
```
**Query Parameters:**
- `unread_only` (optional): true/false

**Response (200):**
```json
{
  "notifications": [
    {
      "id": 1,
      "type": "expiring_soon",
      "title": "Items Expiring Soon",
      "message": "3 items in your pantry expire within 3 days",
      "is_read": false,
      "created_at": "2025-11-15T08:00:00Z",
      "related_items": [
        {
          "id": 5,
          "name": "Chicken Breast",
          "expiration_date": "2025-11-17"
        }
      ]
    }
  ],
  "unread_count": 5
}
```

### Mark Notification as Read
```
PATCH /notifications/{notification_id}/read
```
**Response (200):**
```json
{
  "id": 1,
  "is_read": true
}
```

---

## Household Management Endpoints

### Get Household Info
```
GET /household
```
**Response (200):**
```json
{
  "id": 1,
  "name": "Smith Family",
  "family_size": 4,
  "weekly_budget": 200.00,
  "members": [
    {
      "user_id": 1,
      "email": "user@example.com",
      "role": "admin"
    }
  ],
  "dietary_preferences": [
    {
      "type": "allergy",
      "value": "peanuts"
    },
    {
      "type": "preference",
      "value": "vegetarian"
    }
  ],
  "storage_locations": [
    {
      "id": 1,
      "name": "Pantry",
      "temperature_zone": "ambient"
    }
  ]
}
```

### Update Household Settings
```
PATCH /household
```
**Request Body:**
```json
{
  "family_size": 5,
  "weekly_budget": 250.00
}
```
**Response (200):**
```json
{
  "id": 1,
  "message": "Household updated successfully"
}
```

---

## Error Responses

All endpoints return consistent error formats:

**400 Bad Request:**
```json
{
  "error": "validation_error",
  "message": "Invalid input data",
  "details": {
    "quantity": "Must be greater than 0"
  }
}
```

**401 Unauthorized:**
```json
{
  "error": "authentication_error",
  "message": "Invalid or expired token"
}
```

**404 Not Found:**
```json
{
  "error": "not_found",
  "message": "Resource not found"
}
```

**500 Internal Server Error:**
```json
{
  "error": "internal_error",
  "message": "An unexpected error occurred"
}
```

---

## Rate Limiting

- 100 requests per minute per user
- 429 Too Many Requests response when exceeded
- Rate limit info in response headers:
  ```
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 45
  X-RateLimit-Reset: 1637012400
  ```

---

## Data Models Summary

### Inventory Item
- Tracks physical items in household storage
- Supports barcode lookup and price history
- Automatic expiration tracking

### Recipe
- Contains cooking instructions and nutrition data
- Links to required ingredients with quantities
- Supports user ratings and favorites

### Meal Plan
- Associates recipes with specific dates/meal times
- Tracks completion status
- Used to generate shopping lists

### Shopping List
- Auto-generated from meal plans or manual entry
- Tracks purchase status and actual costs
- Can auto-add to inventory when purchased

### Notification
- System-generated alerts for expiring items
- Meal reminders
- Budget warnings
