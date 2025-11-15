"""
PantryPal Backend API
FastAPI application entry point

This is your starting point for the backend. Run with:
    uvicorn app.main:app --reload
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Create FastAPI app
app = FastAPI(
    title="PantryPal API",
    description="Smart pantry management and meal planning API",
    version="0.1.0",
    docs_url="/docs",  # Swagger UI
    redoc_url="/redoc",  # ReDoc UI
)

# CORS configuration - allows mobile app to connect
origins = os.getenv("ALLOWED_ORIGINS", "http://localhost:3000,http://localhost:19006").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================
# Health Check Endpoints
# ============================================

@app.get("/")
async def root():
    """Root endpoint - API health check"""
    return {
        "name": "PantryPal API",
        "version": "0.1.0",
        "status": "running",
        "docs": "/docs"
    }


@app.get("/health")
async def health_check():
    """Detailed health check endpoint"""
    return {
        "status": "healthy",
        "database": "not_connected",  # TODO: Add actual DB health check
        "environment": os.getenv("ENVIRONMENT", "development")
    }


# ============================================
# API Version Prefix
# ============================================

# TODO: Add routers here
# Example:
# from app.api import auth, inventory, recipes
# app.include_router(auth.router, prefix="/api/v1/auth", tags=["auth"])
# app.include_router(inventory.router, prefix="/api/v1/inventory", tags=["inventory"])
# app.include_router(recipes.router, prefix="/api/v1/recipes", tags=["recipes"])


# ============================================
# Exception Handlers
# ============================================

@app.exception_handler(404)
async def not_found_handler(request, exc):
    """Custom 404 handler"""
    return JSONResponse(
        status_code=404,
        content={
            "error": "not_found",
            "message": "The requested resource was not found",
            "path": str(request.url.path)
        }
    )


@app.exception_handler(500)
async def internal_error_handler(request, exc):
    """Custom 500 handler"""
    return JSONResponse(
        status_code=500,
        content={
            "error": "internal_server_error",
            "message": "An unexpected error occurred"
        }
    )


# ============================================
# Startup and Shutdown Events
# ============================================

@app.on_event("startup")
async def startup_event():
    """Run on application startup"""
    print("🚀 PantryPal API starting up...")
    print(f"📝 API documentation available at: http://localhost:8000/docs")
    print(f"🔧 Environment: {os.getenv('ENVIRONMENT', 'development')}")
    
    # TODO: Initialize database connection pool
    # TODO: Initialize external API clients
    # TODO: Start background tasks


@app.on_event("shutdown")
async def shutdown_event():
    """Run on application shutdown"""
    print("👋 PantryPal API shutting down...")
    
    # TODO: Close database connections
    # TODO: Clean up resources


# ============================================
# Development Notes
# ============================================

"""
NEXT STEPS:

1. Create app/ directory structure:
   app/
   ├── main.py (this file)
   ├── core/
   │   ├── config.py      # Configuration settings
   │   ├── security.py    # JWT utilities
   │   └── database.py    # Database connection
   ├── models/
   │   └── user.py        # SQLAlchemy models
   ├── schemas/
   │   └── user.py        # Pydantic schemas
   └── api/
       └── auth.py        # Authentication endpoints

2. Install PostgreSQL and create database:
   createdb pantrypal_dev

3. Run database schema:
   psql -d pantrypal_dev -f docs/database_schema.sql

4. Test this app runs:
   uvicorn app.main:app --reload
   
5. Check API docs:
   http://localhost:8000/docs

6. Implement first endpoint (user registration):
   - Create user model
   - Create user schema
   - Create auth router
   - Add POST /api/v1/auth/register
   
7. Write tests:
   pytest tests/test_auth.py

Good luck! 🚀
"""
