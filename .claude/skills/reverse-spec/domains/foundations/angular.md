# Foundation: Angular

> **Status**: Detection stub. Full F1-F8 sections TODO.

## F0: Detection Signals
- `@angular/core` in package.json dependencies
- `angular.json` in root
- `.component.ts` files present

## Architecture Notes (for SBI extraction)
- **Module system**: NgModule (legacy) vs Standalone Components (modern)
- **Change detection**: Zone.js (default) vs Zoneless (Angular 18+), Signals
- **DI**: Angular dependency injection (`@Injectable`, `inject()` function)
- **Routing**: `RouterModule`, lazy-loaded routes, route guards
- **SSR**: Angular Universal / `@angular/ssr`
- **State**: RxJS observables, NgRx, Angular Signals
- **CLI**: `ng build`, `ng test`, `ng serve`
- **Testing**: Jasmine + Karma (default), Jest (alternative), TestBed
