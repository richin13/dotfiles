# Response Schemas

All API responses are wrapped in a standard envelope so the OpenAPI schema surfaces the nesting. These are defined in `hub-platform-tools` and imported from there.

## Single-Item Response

```python
class APIResponse[T](CustomBaseModel):
    """Single-item API response envelope."""

    data: T
    meta: t.Mapping[str, t.Any] | None = Field(
        default=None,
        serialization_alias="_meta",
    )
```

Usage in routers:

```python
@router.get("/{item_id}", response_model=APIResponse[ItemRead])
def get_item(...) -> APIResponse[ItemRead]:
    item = get_item_op(ctx, item_id=item_id)
    return APIResponse(data=item)
```

## List Response

```python
class APIListResponse[T](CustomBaseModel):
    """List API response envelope."""

    data: list[T]
    meta: t.Mapping[str, t.Any] | None = Field(
        default=None,
        serialization_alias="_meta",
    )
```

Usage in routers:

```python
@router.get("/", response_model=APIListResponse[ItemRead])
def list_items(...) -> APIListResponse[ItemRead]:
    items = list_items_op(ctx)
    return APIListResponse(data=items)
```

`_meta` carries pagination, counts, or other envelope metadata when needed.

## Error Response

```python
class Error(BaseModel):
    """Single error entry."""

    status: int
    message: str
    description: str | None = None
    stack_trace: t.Sequence[str] | None = None
    extra: t.Mapping[str, t.Any] | None = None

    @classmethod
    def from_pydantic_error(cls, error: t.Any) -> t.Self:
        """Create from a single Pydantic validation error dict."""
        field = (
            ".".join(map(str, error["loc"][1:]))
            if len(error["loc"]) > 1
            else error["loc"][0]
        )
        return cls(
            status=status.HTTP_422_UNPROCESSABLE_ENTITY,
            message="Validation error",
            description=str(error.get("msg", "")),
            extra={
                "field": str(field),
                "value": error["type"],
                "loc": error["loc"][0],
            },
        )


class APIErrorResponse(BaseModel):
    """Error API response envelope."""

    errors: t.Sequence[Error]
```

## Exception Handlers

Register handlers in the app factory so `RequestValidationError` and app-level errors return `APIErrorResponse`:

```python
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    request: Request,
    exc: RequestValidationError,
) -> JSONResponse:
    errors = [Error.from_pydantic_error(e) for e in exc.errors()]
    return JSONResponse(
        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
        content=APIErrorResponse(errors=errors).model_dump(
            by_alias=True,
        ),
    )
```

## Conventions

- Operations return domain objects or Pydantic read schemas. The router wraps them in `APIResponse` / `APIListResponse`.
- Always set `response_model` on the endpoint so OpenAPI shows the envelope.
- Use `by_alias=True` when serializing error responses so `_meta` renders correctly.
