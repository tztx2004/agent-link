# Code Style Guidelines

## 1. TypeScript Standards
- **No `any`**: Always use explicit types or `interface`. Use `unknown` if the type is truly dynamic.
- **Strict Typing**: Enable strict null checks and avoid non-null assertions (`!`).
- **Interfaces vs. Types**: Use `interface` for public APIs and object structures. Use `type` for unions, intersections, and primitives.

## 2. React & Next.js Best Practices
- **Component Declaration**: Use functional components. Avoid `React.FC`; prefer explicit props destructuring with types.
- **Naming Convention**: Components use `PascalCase`. Functions and variables use `camelCase`.
- **Server Components**: Keep them thin. Move complex logic to dedicated utility functions or Server Actions.
- **Client Components**: Use the `'use client'` directive sparingly at the leaf nodes of the component tree.
- **Server Actions**: Group related actions in a `actions.ts` file or define them with clear async boundaries.

## 3. Styling (Tailwind CSS)
- **Consistency**: Use utility classes directly. Avoid `@apply` in CSS files unless necessary for third-party overrides.
- **Class Ordering**: 
  1. Layout (position, z-index, display, flex, grid)
  2. Box Model (width, height, margin, padding, border)
  3. Typography (font, text, leading, tracking)
  4. Visuals (color, background, opacity, shadow)
  5. Transitions & Misc.

## 4. Maintenance & Quality
- **Self-Documenting Code**: Write code that explains "what" it does. Use comments to explain "why" it does it.
- **Small Functions**: Keep functions focused on a single task (SRP).
- **Error Handling**: Implement proper `Error Boundaries` and `loading.tsx` states in Next.js.
