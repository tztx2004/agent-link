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

Currently **Tailwind v3**, with a **v4 migration planned** — avoid v3-only escape hatches that would block the move.

- **Utility-first**: Compose styles from Tailwind utility classes in JSX. Reach for custom CSS only when utilities genuinely cannot express the rule.
- **No inline styles**: Never use `style={{}}`. Dynamic values that cannot be a utility should use a CSS variable or a `tv()` variant, not inline style.
- **Conditional classes via `cn()`**: Merge/conditionalize classes through `cn()` (clsx + tailwind-merge) — never raw string concatenation or template literals (they break `tailwind-merge` conflict resolution).
- **Variants with `tv()` / `cva`**: Use `tailwind-variants` (`tv()`) or `cva` for variant-based components. Keep `base` separate from `variants`; expose variants as explicit props, not boolean soup.
- **Theme tokens over arbitrary values**: Prefer configured theme tokens (`text-primary`, `p-4`) over arbitrary values (`text-[#123]`, `p-[13px]`) whenever a token exists.
- **Class ordering**: Follow a consistent order (layout → box model → typography → visuals → states/transitions). Use the Prettier Tailwind plugin to enforce it automatically rather than ordering by hand.
- **v4 readiness**: Favor the CSS-first `@theme` token mindset; avoid utilities deprecated in v4.

## 4. Maintenance & Quality

- **Self-Documenting Code**: Write code that explains "what" it does. Use comments to explain "why" it does it.
- **Small Functions**: Keep functions focused on a single task (SRP).
- **Error Handling**: Implement proper `Error Boundaries` and `loading.tsx` states in Next.js.
