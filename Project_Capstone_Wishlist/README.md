# WISHLIST APPLICATION

this application contain 2 parts.
1. Frontend - user interface where user can view/create/delete/update wishlist build using ReactJS and semantic ui
2. Backend - API collection build using FastAPI (Python)


## Features

- Backend APIs deployed to aws using serverless
- To store the data I used Dynamodb.
- For authentication used Auth0 API.

## Getting Started

- added postman collection for backend Api. (please update auth token in headers for all APIs)

Here is the available APIs:
```
  POST - https://l5kr10d17c.execute-api.us-east-1.amazonaws.com/prod/wishlist/{wishlist_id}/attachment
  POST - https://l5kr10d17c.execute-api.us-east-1.amazonaws.com/prod/wishlist/{wishlist_id}/remove
  POST - https://l5kr10d17c.execute-api.us-east-1.amazonaws.com/prod/wishlist/create
  GET - https://l5kr10d17c.execute-api.us-east-1.amazonaws.com/prod/wishlist/get
  POST - https://l5kr10d17c.execute-api.us-east-1.amazonaws.com/prod/wishlist/update
```