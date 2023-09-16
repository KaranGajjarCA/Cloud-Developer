# TODO APPLICATION

this application contain 2 parts.
1. Frontend - user interface where user can view/create/delete todos build using ReactJS
2. Backend - API collection build using FastAPI (Python)


## Features

- Backend APIs deployed to aws using terraform
- To store the data used Dynamodb.
- For authentication used Auth0 API.

## Getting Started

- added postman collection for backend Api. (please update auth token in headers for all APIs)

Here's an example APIs:
#### Endpoint 1: `/todo/get_todo`
- **Description:** List all todo for specific user.
- **HTTP Method:** GET
- **Parameters:**
  - `Authorization` (Type: String, Required: Yes, Header: True) 
- **Request Example:**
```
curl --location 'https://919puul7td.execute-api.us-east-1.amazonaws.com/prod/todo/get_todo' \
--header 'Authorization: <token>'
```

#### Endpoint 2: `/todo/create`
- **Description:** Create new Todo.
- **HTTP Method:** POST
- **Parameters:**
  - `Authorization` (Type: String, Required: Yes, Header: True) 
- **Request Example:**
```
curl --location 'https://919puul7td.execute-api.us-east-1.amazonaws.com/prod/todo/create' \
--header 'Authorization: <token>' \
--header 'Content-Type: application/json' \
--data '{
    "todo_text": "this is demo111"
}'
```

#### Endpoint 3: `/todo/update`
- **Description:** Update todo to mark as done.
- **HTTP Method:** POST
- **Parameters:**
  - `Authorization` (Type: String, Required: Yes, Header: True) 
- **Request Example:**
```
curl --location 'https://919puul7td.execute-api.us-east-1.amazonaws.com/prod/todo/update' \
--header 'Authorization: <token>' \
--header 'Content-Type: application/json' \
--data '{
    "todo_id": "20230916032402223189",
    "todo_text": "this is demo",
    "done": true
}'
```

#### Endpoint 4: `/todo/delete`
- **Description:** List all todo for specific user.
- **HTTP Method:** POST
- **Parameters:**
  - `Authorization` (Type: String, Required: Yes, Header: True) 
  - `todo_id` (Type: String, Required: Yes)
- **Request Example:**
```
curl --location 'https://919puul7td.execute-api.us-east-1.amazonaws.com/prod/todo/delete?todo_id=20230916043053082603' \
--header 'Authorization: <token>>' \
--header 'Content-Type: application/json' 
```
