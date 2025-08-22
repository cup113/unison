# Build/Lint/Test Commands

- Flutter: `flutter test` (all tests), `flutter test test/filename_test.dart` (single test), `flutter analyze`, `flutter pub get`
- Server: `cd server && pnpm build`, `cd server && pnpm start`

**IMPORTANT**: Currently, the test part is no longer maintained as it's a personal project.

# Code Style Guidelines

- Flutter: Follow official Dart style, use flutter_lints, prefer const constructors, camelCase naming
- TypeScript: Use ES modules (.mts), async/await, zod validation, Winston logging
- Imports: Use relative imports for local files, organize with dart/flutter imports first
- Types: Use strong typing everywhere, prefer interfaces over inline types.
- Database: PocketBase. See raw type definition at `server/src/types/pocketbase-types.d.ts`.
