# Build/Lint/Test Commands

- Flutter (Root directory: `.`): `flutter test` (all tests), `flutter test test/filename_test.dart` (single test), `flutter analyze`, `flutter pub get`, `dart run build_runner build`
- Server (Root directory: `./server`): `cd server && pnpm build`, `cd server && pnpm start`

# Code Style Guidelines

- Flutter: Follow official Dart style, use flutter_lints, prefer const constructors, camelCase naming. Use Riverpod for state management, Hive for local storage. Use Material 3 design system.
- TypeScript: Use ES modules (.mts), async/await, zod validation. Target ESNext with NodeNext modules. Strict TypeScript enabled.
- Types: Use strong typing everywhere, prefer interfaces over inline types. See API schema at `server/src/types/schema.ts`
- Database: PocketBase. See raw type definition at `server/src/types/pocketbase-types.d.ts`.
- Error handling: Use express-async-errors for server, proper try-catch in Flutter with custom error types.
- Imports: Use relative imports for local files, follow Dart/TS import conventions.
