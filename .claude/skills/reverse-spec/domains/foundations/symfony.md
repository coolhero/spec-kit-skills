# Foundation: Symfony

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `symfony/framework-bundle` in `composer.json`
- `config/bundles.php` present
- `config/services.yaml` present
- `bin/console` entrypoint

## Architecture Notes (for SBI extraction)
- **DI**: Service Container, autowiring, `services.yaml` configuration
- **ORM**: Doctrine ORM (entities, repositories, migrations)
- **Routing**: `#[Route]` PHP attributes, `config/routes.yaml`
- **Templates**: Twig (`.html.twig` files)
- **Events**: EventDispatcher, event subscribers/listeners
- **Security**: Security bundle, firewalls, voters, authenticators
- **CLI**: `bin/console` commands, Symfony Flex recipes
- **Testing**: PHPUnit, Symfony WebTestCase, Panther (browser testing)
