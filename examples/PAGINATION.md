Pagination URL rules and examples

Base behavior
- Parent permalink with placeholders: If a paginated page’s permalink includes `{{page}}` or `{{pageNumber}}`, page 1 uses the canonical base (placeholders removed) and pages 2+ replace the placeholders with the page number.
- Parent permalink without placeholders: Page 1 uses the parent permalink; pages 2+ default to `page/<n>/` under the same base path.
- No parent permalink: Uses `/<fileSlug>/` as the base. Pages 2+ default to `/<fileSlug>/page/<n>/`.
- Trailing slash → file: If a permalink ends with `/`, it maps to `index.html` under that path. If it includes a filename with an extension, that file is written directly.

Navigation
- `first` and page 1 hrefs point to the canonical first URL (base permalink without placeholders, with a trailing slash when using directory-style permalinks).
- `previous` from page 2 points to the canonical first URL.

Size-specific notes
- Multi-item pages (`size > 1`): follow the rules above for base and numbered pages.
- Single-item pages (`size == 1` with alias): the alias placeholder (e.g., `{{tag}}`) is replaced with each item; page numbering isn’t used.

Examples
1) Placeholder style (multi-item)

   Front matter:
   
   permalink: /blog/page/{{page}}/
   pagination:
     data: collections.post
     size: 5
   
   Output:
   - Page 1: `/blog/index.html` (href `/blog/`)
   - Page 2: `/blog/page/2/index.html` (href `/blog/page/2/`)

2) No placeholder (multi-item)

   Front matter:
   
   permalink: /articles/
   pagination:
     data: collections.post
     size: 5
   
   Output:
   - Page 1: `/articles/index.html` (href `/articles/`)
   - Page 2: `/articles/page/2/index.html` (href `/articles/page/2/`)

3) No permalink provided (multi-item)

   Front matter:
   
   pagination:
     data: collections.post
     size: 5
   
   Output base path is `/<fileSlug>/`.
   - Page 1: `/<fileSlug>/index.html`
   - Page 2: `/<fileSlug>/page/2/index.html`

4) Single-item with alias

   Front matter:
   
   permalink: /tag/{{tag}}.html
   pagination:
     data: collections.tags
     alias: tag
     size: 1
   
   Output: One file per tag such as `/tag/cfml.html`, `/tag/boxlang.html`, etc.

