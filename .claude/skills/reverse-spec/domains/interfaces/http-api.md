# Interface: http-api (reverse-spec)

> API endpoint analysis axes. Loaded when project exposes HTTP-based interfaces.
> Module type: interface (reverse-spec analysis)

---

## R3. Analysis Axes — API Endpoint Extraction (Phase 2-2)

Extract APIs from appropriate sources depending on the tech stack:

| Technology | Search Targets |
|------------|----------------|
| Express/Fastify | Router files, `app.use()`, `router.get()`, etc. |
| Django/DRF | `urls.py`, ViewSet, APIView |
| FastAPI | `@app.get()`, `@router.post()`, etc. decorators |
| Spring | `@RequestMapping`, `@GetMapping`, etc. |
| Rails | `config/routes.rb`, controllers |
| Next.js/Nuxt | `pages/api/`, `app/api/` directories |
| Go (net/http, Gin, Echo) | Router registration, handler functions |

Information to extract from each endpoint:
- HTTP method, path
- Request parameters, body schema
- Response schema (per status code)
- Authentication/authorization requirements
- Middleware/interceptors
