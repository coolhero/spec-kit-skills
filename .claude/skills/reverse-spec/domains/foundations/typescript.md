# Foundation: TypeScript (Standalone)

> **Status**: Detection stub. Full F1-F8 sections TODO.
> For TypeScript projects using specific frameworks (Next.js, NestJS, Express), see the respective framework files.
> This file covers standalone TypeScript projects: libraries, SDKs, CLI tools, and utilities without a web framework.

## F0: Detection Signals
- `tsconfig.json` present in root
- `package.json` → `devDependencies` contains `typescript`
- No framework-specific files (`next.config.*`, `nest-cli.json`, `angular.json`)
- `.ts` or `.tsx` source files present

## Architecture Notes (for SBI extraction)
- **Module system**: ESM (`import/export`) vs CJS (`require/module.exports`) — check `type` field in package.json and `module`/`moduleResolution` in tsconfig.json
- **Dual publishing**: Many SDKs publish both ESM and CJS — check `exports` field in package.json, `tsup`/`rollup`/`esbuild` build config
- **Declaration files**: `.d.ts` generation — check `declaration: true` in tsconfig.json, `types`/`typings` field in package.json
- **Strict mode**: `strict: true` in tsconfig.json — critical for SDK quality (affects `noImplicitAny`, `strictNullChecks`, etc.)
- **Testing**: vitest, jest, mocha — detect from devDependencies
- **Linting**: eslint + `@typescript-eslint/*` — check `.eslintrc.*` or `eslint.config.*`
- **Formatting**: prettier — check `.prettierrc` or package.json `prettier` field
- **Build tools**: tsc (direct), tsup, esbuild, rollup, vite (library mode) — detect from `scripts.build` in package.json
- **Monorepo**: turborepo (`turbo.json`), nx (`nx.json`), pnpm workspaces (`pnpm-workspace.yaml`)
- **Type checking**: `tsc --noEmit` for type-only checking, `skipLibCheck` for faster builds
