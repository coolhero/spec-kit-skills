# Foundation: WordPress

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `wp-config.php` in root
- `wp-content/` directory structure
- `wp-includes/` or `wp-admin/` directories
- `functions.php` with `add_action()`/`add_filter()` calls

## Architecture Notes (for SBI extraction)
- **Hook system**: Actions (`add_action`/`do_action`) and Filters (`add_filter`/`apply_filters`)
- **Theme system**: Template hierarchy, `functions.php`, `style.css` with theme headers
- **Plugin architecture**: Plugin header comments, activation/deactivation hooks
- **Database**: `$wpdb` global, WP_Query, custom post types, meta tables
- **REST API**: `register_rest_route()`, WP REST API v2
- **Admin**: wp-admin screens, Settings API, Options API
- **Philosophy**: Backward Compatibility, Hook-Based Extension, Template Hierarchy, The Loop
