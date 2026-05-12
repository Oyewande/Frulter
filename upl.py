from fastapi import FastAPI, HTTPException, Query
from typing import Optional

app = FastAPI(
    title="Produce API",
    description="A simple API to browse and filter fruits and vegetables",
    version="2.0.0"
)

# ── Data

produce = [
    {"id": 1,  "name": "Apple",       "category": "fruit",     "size": "Medium", "has_seeds": True,  "is_berry": False, "image": "https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=200"},
    {"id": 2,  "name": "Banana",      "category": "fruit",     "size": "Large",  "has_seeds": False, "is_berry": True,  "image": "https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=200"},
    {"id": 3,  "name": "Mango",       "category": "fruit",     "size": "Medium", "has_seeds": True,  "is_berry": False, "image": "https://images.unsplash.com/photo-1553279768-865429fa0078?w=200"},
    {"id": 4,  "name": "Strawberry",  "category": "fruit",     "size": "Small",  "has_seeds": True,  "is_berry": True,  "image": "https://images.unsplash.com/photo-1464965911861-746a04b4bca6?w=200"},
    {"id": 5,  "name": "Grapes",      "category": "fruit",     "size": "Small",  "has_seeds": True,  "is_berry": True,  "image": "https://images.unsplash.com/photo-1537640538966-79f369143f8f?w=200"},
    {"id": 6,  "name": "Watermelon",  "category": "fruit",     "size": "Large",  "has_seeds": True,  "is_berry": False, "image": "https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=200"},
    {"id": 7,  "name": "Blueberry",   "category": "fruit",     "size": "Small",  "has_seeds": True,  "is_berry": True,  "image": "https://images.unsplash.com/photo-1601004890684-d8cbf643f5f2?w=200"},
    {"id": 8,  "name": "Orange",      "category": "fruit",     "size": "Medium", "has_seeds": True,  "is_berry": False, "image": "https://images.unsplash.com/photo-1547514701-42782101795e?w=200"},
    {"id": 9,  "name": "Carrot",      "category": "vegetable", "size": "Medium", "has_seeds": False, "is_berry": False, "image": "https://images.unsplash.com/photo-1598170845058-32b9d6a5da37?w=200"},
    {"id": 10, "name": "Broccoli",    "category": "vegetable", "size": "Medium", "has_seeds": False, "is_berry": False, "image": "https://dummyimage.com/300x300/2ecc71/fff&text=Broccoli"},
    {"id": 11, "name": "Spinach",     "category": "vegetable", "size": "Small",  "has_seeds": False, "is_berry": False, "image": "https://dummyimage.com/300x300/1abc9c/fff&text=Spinach"},
    {"id": 12, "name": "Tomato",      "category": "vegetable", "size": "Medium", "has_seeds": True,  "is_berry": True,  "image": "https://dummyimage.com/300x300/e74c3c/fff&text=Tomato"},
    {"id": 13, "name": "Cucumber",    "category": "vegetable", "size": "Large",  "has_seeds": True,  "is_berry": False, "image": "https://dummyimage.com/300x300/27ae60/fff&text=Cucumber"},
    {"id": 14, "name": "Bell Pepper", "category": "vegetable", "size": "Medium", "has_seeds": True,  "is_berry": False, "image": "https://dummyimage.com/300x300/e74c3c/fff&text=BellPepper"},
]


# ── Filter helpers

def filter_by_category(data, category):
    return [item for item in data if item["category"] == category.lower()]

def filter_by_size(data, size):
    return [item for item in data if item["size"].lower() == size.lower()]

def filter_by_seeds(data, has_seeds: bool):
    return [item for item in data if item["has_seeds"] == has_seeds]

def filter_by_berry(data, is_berry: bool):
    return [item for item in data if item["is_berry"] == is_berry]


# ── Routes

@app.get("/produce", summary="Get all produce")
def get_all_produce():
    return {"status": "success", "count": len(produce), "data": produce}


@app.get("/produce/fruits", summary="Get only fruits")
def get_fruits():
    fruits = filter_by_category(produce, "fruit")
    return {"status": "success", "category": "fruit", "count": len(fruits), "data": fruits}


@app.get("/produce/vegetables", summary="Get only vegetables")
def get_vegetables():
    vegetables = filter_by_category(produce, "vegetable")
    return {"status": "success", "category": "vegetable", "count": len(vegetables), "data": vegetables}


@app.get("/produce/filter", summary="Filter by category, size, seeds and/or berry")
def filter_produce(
    category:  Optional[str]  = Query(None, description="'fruit' or 'vegetable'"),
    size:      Optional[str]  = Query(None, description="'small', 'medium' or 'large'"),
    has_seeds: Optional[bool] = Query(None, description="true or false"),
    is_berry:  Optional[bool] = Query(None, description="true or false"),
):
    result = produce[:]

    if category:
        result = filter_by_category(result, category)
    if size:
        result = filter_by_size(result, size)
    if has_seeds is not None:
        result = filter_by_seeds(result, has_seeds)
    if is_berry is not None:
        result = filter_by_berry(result, is_berry)

    return {
        "status": "success",
        "filters": {
            "category": category or "all",
            "size": size or "all",
            "has_seeds": has_seeds if has_seeds is not None else "all",
            "is_berry": is_berry if is_berry is not None else "all",
        },
        "count": len(result),
        "data": result
    }


@app.get("/produce/{produce_id}", summary="Get a single item by ID")
def get_by_id(produce_id: int):
    item = next((p for p in produce if p["id"] == produce_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return {"status": "success", "data": item}
