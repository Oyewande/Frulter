from fastapi import FastAPI, HTTPException, Query
from typing import Optional

app = FastAPI(
    title="Produce API",
    description="A simple API to browse and filter fruits and vegetables",
    version="1.0.0"
)

# ── Data

produce = [
    {"id": 1,  "name": "Apple",       "category": "fruit",     "color": "Red",    "image": "https://dummyimage.com/300x300/e74c3c/fff&text=Apple"},
    {"id": 2,  "name": "Banana",      "category": "fruit",     "color": "Yellow", "image": "https://dummyimage.com/300x300/f1c40f/fff&text=Banana"},
    {"id": 3,  "name": "Mango",       "category": "fruit",     "color": "Orange", "image": "https://dummyimage.com/300x300/e67e22/fff&text=Mango"},
    {"id": 4,  "name": "Strawberry",  "category": "fruit",     "color": "Red",    "image": "https://dummyimage.com/300x300/c0392b/fff&text=Strawberry"},
    {"id": 5,  "name": "Grapes",      "category": "fruit",     "color": "Purple", "image": "https://dummyimage.com/300x300/8e44ad/fff&text=Grapes"},
    {"id": 6,  "name": "Watermelon",  "category": "fruit",     "color": "Green",  "image": "https://dummyimage.com/300x300/27ae60/fff&text=Watermelon"},
    {"id": 7,  "name": "Carrot",      "category": "vegetable", "color": "Orange", "image": "https://dummyimage.com/300x300/e67e22/fff&text=Carrot"},
    {"id": 8,  "name": "Broccoli",    "category": "vegetable", "color": "Green",  "image": "https://dummyimage.com/300x300/2ecc71/fff&text=Broccoli"},
    {"id": 9,  "name": "Spinach",     "category": "vegetable", "color": "Green",  "image": "https://dummyimage.com/300x300/1abc9c/fff&text=Spinach"},
    {"id": 10, "name": "Tomato",      "category": "vegetable", "color": "Red",    "image": "https://dummyimage.com/300x300/e74c3c/fff&text=Tomato"},
    {"id": 11, "name": "Cucumber",    "category": "vegetable", "color": "Green",  "image": "https://dummyimage.com/300x300/27ae60/fff&text=Cucumber"},
    {"id": 12, "name": "Bell Pepper", "category": "vegetable", "color": "Red",    "image": "https://dummyimage.com/300x300/e74c3c/fff&text=BellPepper"},
]


# ── Filter

def filter_fruits(data):
    return [item for item in data if item["category"] == "fruit"]

def filter_vegetables(data):
    return [item for item in data if item["category"] == "vegetable"]

def filter_by_color(data, color):
    return [item for item in data if item["color"].lower() == color.lower()]


# ── Routes

@app.get("/produce", summary="Get all produce")
def get_all_produce():
    return {"status": "success", "count": len(produce), "data": produce}


@app.get("/produce/fruits", summary="Get only fruits")
def get_fruits():
    fruits = filter_fruits(produce)
    return {"status": "success", "category": "fruit", "count": len(fruits), "data": fruits}


@app.get("/produce/vegetables", summary="Get only vegetables")
def get_vegetables():
    vegetables = filter_vegetables(produce)
    return {"status": "success", "category": "vegetable", "count": len(vegetables), "data": vegetables}


@app.get("/produce/filter", summary="Filter by category and/or color")
def filter_produce(
    category: Optional[str] = Query(None, description="'fruit' or 'vegetable'"),
    color:    Optional[str] = Query(None, description="e.g. 'red', 'green', 'yellow'")
):
    result = produce[:]

    if category == "fruit":
        result = filter_fruits(result)
    elif category == "vegetable":
        result = filter_vegetables(result)

    if color:
        result = filter_by_color(result, color)

    return {
        "status": "success",
        "filters": {"category": category or "all", "color": color or "all"},
        "count": len(result),
        "data": result
    }


@app.get("/produce/{produce_id}", summary="Get a single item by ID")
def get_by_id(produce_id: int):
    item = next((p for p in produce if p["id"] == produce_id), None)
    if item is None:
        raise HTTPException(status_code=404, detail="Item not found")
    return {"status": "success", "data": item}
