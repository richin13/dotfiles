---
name: fastapi-dev
description: FastAPI engineering choices. To be used when asked to "create router", "create crud router", "add new endpoint" or similar in a fastapi codebase.
---

# FastAPI development

- Always define an application factory (`create_app`) in `<module>/__init__.py` or `<module>/main.py` (prefer the former).
- Import routers in app factory and register them via `app.include_router`. Define a helper `_register_routers` function colocated with `create_app`.
- Define a custom exceptions module at `<module>/exceptions.py` with a base application error. Then register an exception handler via `@app.exception_handler(BaseAppError)` to return proper JSON responses.
- Ensure pydantic's `RequestValidationError` and `ValidationError` are handled too and transformed to a consistent error response format.
- All responses use generic envelope schemas (`APIResponse[T]`, `APIListResponse[T]`, `APIErrorResponse`) so the OpenAPI spec surfaces the wrapping. See `references/response-schemas.md`.

## Routers

Routers are thin HTTP boundaries. They handle authentication, authorization, query parameter parsing, and response shaping, nothing else. Business logic lives in plain functions called "operations".

- Common dependencies are declared as annotated aliases, e.g:
  - `UseDBSession = t.Annotated[Session, Depends(get_db_session)]` — SQLAlchemy session
  - `UseSettings = t.Annotated[Settings, Depends(get_settings)]` — Pydantic settings object
- Cross-cutting request context is bundled into a single `AppContext` dataclass injected via `Depends`. Adding new cross-cutting concerns (e.g. request ID) means updating the dataclass and its factory, not every operation signature.
- Follow the naming pattern `UseX`. If routers start to have many different dependencies, refactor the most common ones to a `UseAppContext`.

## Operations

Operations are plain functions (or coroutines) that receive:

1. `ctx: AppContext` as the first argument (or `session` and `settings`)
2. Input data (validated Pydantic schemas) as keyword arguments

They handle business logic and external service calls.

### Testing

- Override individual dependencies via `app.dependency_overrides`
- Operations are tested by calling them directly with a constructed `AppContext`
