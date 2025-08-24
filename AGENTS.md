# Build/Lint/Test Commands

- Flutter (Root directory: `.`): `flutter test` (all tests), `flutter test test/filename_test.dart` (single test), `flutter analyze`, `flutter pub get`
- Server (Root directory: `./server`): `cd server && pnpm build`, `cd server && pnpm start`

# Code Style Guidelines

- Flutter: Follow official Dart style, use flutter_lints, prefer const constructors, camelCase naming. Use Riverpod & Hive for state/data.
- TypeScript: Use ES modules (.mts), async/await, zod validation.
- Types: Use strong typing everywhere, prefer interfaces over inline types. See API schema at `server/src/types/schema.ts`
- Database: PocketBase. See raw type definition at `server/src/types/pocketbase-types.d.ts`.
