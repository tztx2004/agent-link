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

## 3. Styling (Panda CSS)

- **Patterns first**: Use Panda's built-in patterns (`flex`, `grid`, `stack`, `container`) before writing raw `css()` calls.
- **No inline styles**: All styles go through `css()`, `cva()`, or pattern utilities — never `style={{}}`.
- **Semantic tokens**: Reference design tokens (`colors.primary`, `spacing.4`) instead of raw values.
- **Recipes with `cva`**: Use `cva()` for variant-based components. Keep `base` styles separate from `variants`.
- **Property ordering inside `css()`**:
  1. Layout (position, zIndex, display, flex, grid)
  2. Box Model (w, h, m, p, border)
  3. Typography (fontSize, fontWeight, lineHeight, letterSpacing)
  4. Visuals (color, bg, opacity, shadow)
  5. Transitions & Misc.

## 4. Maintenance & Quality

- **Self-Documenting Code**: Write code that explains "what" it does. Use comments to explain "why" it does it.
- **Small Functions**: Keep functions focused on a single task (SRP).
- **Error Handling**: Implement proper `Error Boundaries` and `loading.tsx` states in Next.js.
