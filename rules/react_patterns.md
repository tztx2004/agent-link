# React Patterns

Common React patterns enforced across all frontend and refactoring work. These rules apply regardless of agent role.

---

## 0. Quality Lenses (Component Create / Modify / Refactor / Review)

This section applies whenever a task **touches or evaluates** a React component or hook, in two modes:

- **Build mode** — you are creating, modifying, or refactoring a component or hook.
- **Review mode** — you are reviewing, auditing, or diagnosing one without being asked to change it (e.g. "find what's lacking", "이 컴포넌트 점검해줘", "갭 찾아줘", a `code-reviewer`/`refactor` evaluation pass).

The seven skills below are the quality lenses for this work. Apply the ones relevant to what the change touches — a one-line copy fix does not need a coupling analysis, while a new data-fetching component needs most of them. If a skill is preloaded in your context, use its guidance directly; otherwise invoke it via the `Skill` tool when its lens applies.

| Order | Skill                         | What it checks                                                                                          |
| ----- | ----------------------------- | ------------------------------------------------------------------------------------------------------- |
| 1     | `readability`                 | Nested ternaries, unnamed complex conditions, unclear naming, logic that requires mental translation    |
| 2     | `predictability`              | Hidden side effects in getters/fetchers, inconsistent function behavior, surprising return values       |
| 3     | `cohesion`                    | Features spread across multiple directories, magic numbers duplicated, unrelated logic grouped together |
| 4     | `coupling`                    | Props drilling 3+ layers, hooks with 5+ dependencies, modules that break when another module changes    |
| 5     | `vercel-composition-patterns` | Boolean prop proliferation, render props, state/UI mixing, compound component structure                 |
| 6     | `vercel-react-best-practices` | Data-fetching waterfalls, barrel imports, unnecessary re-renders, useEffect misuse, Server Components   |
| 7     | `typescript-advanced-types`   | Type check after implementation — `any` usage, unsafe assertions, missing type guards, complex types    |

What you do with a finding differs by mode:

- **Build mode** — fix violations inline rather than deferring them.
- **Review mode** — report each violation as a finding: which lens flagged it, the offending `file:line`, why it matters, and the concrete fix. State which lenses you applied so the reader knows what was covered.

When the component has boolean props (`isX`, `hasX`), uses render props, or mixes state with UI, include `vercel-composition-patterns`.

---

## 1. Declarative Programming Principle

Write code that describes **what** to render, not **how** to control flow.

### ✅ Prefer — data-driven rendering

```tsx
const STATUS_LABEL: Record<Status, string> = {
  active: "Active",
  inactive: "Inactive",
  pending: "Pending",
};

function StatusBadge({ status }: { status: Status }) {
  return <Badge variant={status}>{STATUS_LABEL[status]}</Badge>;
}
```

### ❌ Avoid — imperative branching inside render

```tsx
function StatusBadge({ status }: { status: Status }) {
  let label = "";
  if (status === "active") label = "Active";
  else if (status === "inactive") label = "Inactive";
  else label = "Pending";
  return <Badge>{label}</Badge>;
}
```

**Rules:**

- Map data to components, not conditional imperative branches.
- Keep components single-responsibility — one component, one concern.
- Derive values (lookup maps, computed props) rather than branching with `if/else`.
- Use composition over prop drilling or conditional rendering chains.

---

## 2. Model / UI Separation

Always separate UI rendering from business logic (state, derived values, handlers). If a component has even one `useState`, extract all logic into a dedicated model file.

### Default file structure

```
ui/
  UserCard.tsx        # UI only — receives props and renders
model/
  useUserCard.ts      # useState, handlers, derived values
```

### ✅ Separated (preferred)

```tsx
// model/useUserCard.ts — state and logic
export function useUserCard(userId: string) {
  const [isExpanded, setIsExpanded] = useState(false);
  const user = useUser(userId);
  const toggleExpand = () => setIsExpanded((prev) => !prev);
  const displayName = user ? `${user.firstName} ${user.lastName}` : "—";
  return { user, isExpanded, toggleExpand, displayName };
}

// ui/UserCard.tsx — UI only
interface Props {
  user: User;
  isExpanded: boolean;
  toggleExpand: () => void;
  displayName: string;
}

export function UserCard({
  user,
  isExpanded,
  toggleExpand,
  displayName,
}: Props) {
  return (
    <Card>
      <UserName name={displayName} />
      <button onClick={toggleExpand}>
        {isExpanded ? "Collapse" : "Expand"}
      </button>
      {isExpanded && <UserDetail user={user} />}
    </Card>
  );
}
```

### ❌ Mixed (forbidden)

```tsx
// State and UI in the same file — forbidden
function UserCard({ userId }: { userId: string }) {
  const [isExpanded, setIsExpanded] = useState(false);
  const user = useUser(userId);
  // ...
}
```

---

## 3. UI Consumes Logic — Never Defines It

When a UI component needs logic or display mappings, extract them to separate files and import them. The UI file's only job is to consume and render.

- State mappings and display constants → separate `consts` file (or module-level outside the component)
- State and handlers → separate hook (model file)
- The UI component only calls the hook and reads the const map

### ✅ Preferred

```tsx
// consts/cardState.ts
export const CARD_STATE_LABEL: Record<string, string> = {
  true: "열려있습니다",
  false: "닫혀있습니다",
};

// model/useToggle.ts
export function useToggle(initial = false) {
  const [isOpen, setIsOpen] = useState(initial);
  const toggle = () => setIsOpen((v) => !v);
  return { isOpen, toggle };
}

// ui/Card.tsx — only consumes, never defines
function Card() {
  const { isOpen } = useToggle();
  return <div>{CARD_STATE_LABEL[String(isOpen)]}</div>;
}
```

### ❌ Forbidden — inline logic and mappings inside the UI file

```tsx
function Card() {
  const [isOpen, setIsOpen] = useState(false); // logic defined here
  const label = isOpen ? "열려있습니다" : "닫혀있습니다"; // mapping defined here
  return <div>{label}</div>;
}
```

---

## 4. Hook Design: Do Not Return Setters Directly

Never return raw state setters from a hook. Expose intent-based action functions instead. When external code needs to react to state changes, accept a callback parameter — do not leak the setter.

### ❌ Forbidden — setter exposed directly

```tsx
function useCounter() {
  const [count, setCount] = useState(0);
  return { count, setCount }; // caller can set any arbitrary value
}
```

### ✅ Preferred — intent-based actions with optional callback

```tsx
function useCounter({ onChange }: { onChange?: (value: number) => void } = {}) {
  const [count, setCount] = useState(0);

  const increment = () => {
    const next = count + 1;
    setCount(next);
    onChange?.(next);
  };

  const decrement = () => {
    const next = count - 1;
    setCount(next);
    onChange?.(next);
  };

  const reset = () => {
    setCount(0);
    onChange?.(0);
  };

  return { count, increment, decrement, reset };
}
```

Returning setters breaks cohesion — the hook no longer owns its state transitions. Callers must know the internal shape of state to interact correctly, increasing coupling.

---

## 5. useEffect: Derived State → Inline Computation

Never use `useEffect` + `setState` to compute a value that can be derived directly during render.

### ❌ Forbidden

```tsx
const [fullName, setFullName] = useState("");
useEffect(() => {
  setFullName(`${user.firstName} ${user.lastName}`);
}, [user]);
```

### ✅ Preferred

```tsx
const fullName = `${user.firstName} ${user.lastName}`;
```
