-- Smart Pantry Management App - Database Schema
-- PostgreSQL 14+

-- Users and household management
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE households (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    family_size INTEGER DEFAULT 1,
    weekly_budget DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE household_members (
    id SERIAL PRIMARY KEY,
    household_id INTEGER REFERENCES households(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    role VARCHAR(20) DEFAULT 'member', -- 'admin', 'member'
    UNIQUE(household_id, user_id)
);

CREATE TABLE dietary_preferences (
    id SERIAL PRIMARY KEY,
    household_id INTEGER REFERENCES households(id) ON DELETE CASCADE,
    preference_type VARCHAR(50) NOT NULL, -- 'allergy', 'restriction', 'preference'
    value VARCHAR(100) NOT NULL -- 'peanuts', 'vegetarian', 'gluten-free', etc.
);

-- Inventory management
CREATE TABLE storage_locations (
    id SERIAL PRIMARY KEY,
    household_id INTEGER REFERENCES households(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL, -- 'pantry', 'fridge', 'freezer', 'basement'
    temperature_zone VARCHAR(20) -- 'ambient', 'refrigerated', 'frozen'
);

CREATE TABLE inventory_items (
    id SERIAL PRIMARY KEY,
    household_id INTEGER REFERENCES households(id) ON DELETE CASCADE,
    storage_location_id INTEGER REFERENCES storage_locations(id),
    barcode VARCHAR(50),
    name VARCHAR(200) NOT NULL,
    brand VARCHAR(100),
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL, -- 'oz', 'lb', 'kg', 'count', 'gal', 'L'
    purchase_date DATE NOT NULL,
    expiration_date DATE,
    cost DECIMAL(10,2),
    category VARCHAR(50), -- 'protein', 'dairy', 'produce', 'grain', 'spice', etc.
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_depleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_inventory_expiration ON inventory_items(expiration_date) WHERE is_depleted = FALSE;
CREATE INDEX idx_inventory_household ON inventory_items(household_id, is_depleted);
CREATE INDEX idx_inventory_barcode ON inventory_items(barcode);

-- Recipe database
CREATE TABLE recipes (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    cuisine_type VARCHAR(50), -- 'italian', 'mexican', 'asian', 'american'
    meal_type VARCHAR(50), -- 'breakfast', 'lunch', 'dinner', 'snack', 'dessert'
    prep_time_minutes INTEGER,
    cook_time_minutes INTEGER,
    servings INTEGER NOT NULL,
    difficulty VARCHAR(20), -- 'easy', 'medium', 'hard'
    instructions TEXT NOT NULL,
    image_url VARCHAR(500),
    source_url VARCHAR(500),
    calories_per_serving INTEGER,
    protein_grams DECIMAL(5,1),
    carbs_grams DECIMAL(5,1),
    fat_grams DECIMAL(5,1),
    fiber_grams DECIMAL(5,1),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE recipe_ingredients (
    id SERIAL PRIMARY KEY,
    recipe_id INTEGER REFERENCES recipes(id) ON DELETE CASCADE,
    ingredient_name VARCHAR(200) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    is_optional BOOLEAN DEFAULT FALSE,
    preparation_note VARCHAR(200) -- 'diced', 'chopped', 'minced', etc.
);

CREATE INDEX idx_recipe_ingredients ON recipe_ingredients(recipe_id);

CREATE TABLE recipe_tags (
    id SERIAL PRIMARY KEY,
    recipe_id INTEGER REFERENCES recipes(id) ON DELETE CASCADE,
    tag VARCHAR(50) NOT NULL -- 'quick', 'healthy', 'kid-friendly', 'vegetarian', 'batch-cook'
);

-- User saved/favorited recipes
CREATE TABLE user_recipes (
    id SERIAL PRIMARY KEY,
    household_id INTEGER REFERENCES households(id) ON DELETE CASCADE,
    recipe_id INTEGER REFERENCES recipes(id) ON DELETE CASCADE,
    is_favorite BOOLEAN DEFAULT FALSE,
    times_cooked INTEGER DEFAULT 0,
    last_cooked_date DATE,
    rating INTEGER CHECK (rating >= 1 AND rating <= 5),
    notes TEXT,
    UNIQUE(household_id, recipe_id)
);

-- Meal planning
CREATE TABLE meal_plans (
    id SERIAL PRIMARY KEY,
    household_id INTEGER REFERENCES households(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    meal_type VARCHAR(20) NOT NULL, -- 'breakfast', 'lunch', 'dinner', 'snack'
    recipe_id INTEGER REFERENCES recipes(id) ON DELETE SET NULL,
    servings_planned INTEGER,
    notes TEXT,
    is_completed BOOLEAN DEFAULT FALSE,
    UNIQUE(household_id, date, meal_type)
);

CREATE INDEX idx_meal_plans_date ON meal_plans(household_id, date);

-- Shopping list
CREATE TABLE shopping_lists (
    id SERIAL PRIMARY KEY,
    household_id INTEGER REFERENCES households(id) ON DELETE CASCADE,
    name VARCHAR(100) DEFAULT 'Weekly Shopping',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

CREATE TABLE shopping_list_items (
    id SERIAL PRIMARY KEY,
    shopping_list_id INTEGER REFERENCES shopping_lists(id) ON DELETE CASCADE,
    item_name VARCHAR(200) NOT NULL,
    quantity DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,
    category VARCHAR(50),
    estimated_cost DECIMAL(10,2),
    is_purchased BOOLEAN DEFAULT FALSE,
    notes VARCHAR(200),
    added_from_recipe_id INTEGER REFERENCES recipes(id) ON DELETE SET NULL
);

CREATE INDEX idx_shopping_list_items ON shopping_list_items(shopping_list_id, is_purchased);

-- Inventory usage tracking (for analytics)
CREATE TABLE inventory_usage_log (
    id SERIAL PRIMARY KEY,
    inventory_item_id INTEGER REFERENCES inventory_items(id) ON DELETE CASCADE,
    quantity_used DECIMAL(10,2) NOT NULL,
    used_for_recipe_id INTEGER REFERENCES recipes(id) ON DELETE SET NULL,
    used_for_meal_plan_id INTEGER REFERENCES meal_plans(id) ON DELETE SET NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Product database (for barcode lookups and price history)
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    barcode VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    brand VARCHAR(100),
    category VARCHAR(50),
    typical_shelf_life_days INTEGER,
    default_unit VARCHAR(20),
    image_url VARCHAR(500),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE product_prices (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    store_name VARCHAR(100),
    price DECIMAL(10,2) NOT NULL,
    quantity DECIMAL(10,2),
    unit VARCHAR(20),
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Notifications/alerts
CREATE TABLE notifications (
    id SERIAL PRIMARY KEY,
    household_id INTEGER REFERENCES households(id) ON DELETE CASCADE,
    notification_type VARCHAR(50) NOT NULL, -- 'expiring_soon', 'expired', 'low_stock', 'meal_reminder'
    title VARCHAR(200) NOT NULL,
    message TEXT,
    related_item_id INTEGER, -- could reference inventory_items or meal_plans
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_notifications_household ON notifications(household_id, is_read, created_at);

-- Functions and triggers for automated updates

-- Update timestamp trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventory_updated_at BEFORE UPDATE ON inventory_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Views for common queries

-- Items expiring soon (next 7 days)
CREATE VIEW expiring_soon AS
SELECT 
    i.id,
    i.household_id,
    i.name,
    i.brand,
    i.quantity,
    i.unit,
    i.expiration_date,
    i.storage_location_id,
    sl.name as storage_location,
    DATE_PART('day', i.expiration_date - CURRENT_DATE) as days_until_expiration
FROM inventory_items i
LEFT JOIN storage_locations sl ON i.storage_location_id = sl.id
WHERE i.is_depleted = FALSE 
    AND i.expiration_date IS NOT NULL
    AND i.expiration_date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY i.expiration_date ASC;

-- Current inventory summary by category
CREATE VIEW inventory_summary AS
SELECT 
    i.household_id,
    i.category,
    COUNT(*) as item_count,
    SUM(i.cost) as total_value
FROM inventory_items i
WHERE i.is_depleted = FALSE
GROUP BY i.household_id, i.category;

-- Meal plan for current week
CREATE VIEW current_week_meals AS
SELECT 
    mp.household_id,
    mp.date,
    mp.meal_type,
    r.name as recipe_name,
    r.prep_time_minutes + r.cook_time_minutes as total_time_minutes,
    mp.servings_planned,
    mp.is_completed
FROM meal_plans mp
LEFT JOIN recipes r ON mp.recipe_id = r.id
WHERE mp.date BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY mp.date, 
    CASE mp.meal_type
        WHEN 'breakfast' THEN 1
        WHEN 'lunch' THEN 2
        WHEN 'dinner' THEN 3
        WHEN 'snack' THEN 4
    END;

-- Sample data inserts for testing

-- Insert sample household
INSERT INTO households (name, family_size, weekly_budget) VALUES 
('Sample Family', 3, 200.00);

-- Insert sample storage locations
INSERT INTO storage_locations (household_id, name, temperature_zone) VALUES 
(1, 'Pantry', 'ambient'),
(1, 'Refrigerator', 'refrigerated'),
(1, 'Freezer', 'frozen');

-- Insert sample recipe
INSERT INTO recipes (name, description, meal_type, prep_time_minutes, cook_time_minutes, servings, difficulty, instructions, calories_per_serving, protein_grams, carbs_grams, fat_grams)
VALUES (
    'Quick Chicken Stir Fry',
    'Fast and healthy weeknight dinner',
    'dinner',
    15,
    10,
    4,
    'easy',
    '1. Cut chicken into strips. 2. Heat oil in wok. 3. Cook chicken 5 min. 4. Add vegetables. 5. Stir fry 5 min. 6. Add sauce. 7. Serve over rice.',
    350,
    35.0,
    25.0,
    12.0
);

-- Insert sample recipe ingredients
INSERT INTO recipe_ingredients (recipe_id, ingredient_name, quantity, unit) VALUES
(1, 'chicken breast', 1.5, 'lb'),
(1, 'mixed vegetables', 3, 'cup'),
(1, 'soy sauce', 0.25, 'cup'),
(1, 'vegetable oil', 2, 'tbsp'),
(1, 'rice', 2, 'cup');
