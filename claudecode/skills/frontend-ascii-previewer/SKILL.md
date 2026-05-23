---
name: frontend-ascii-previewer
description: Use when modifying frontend code that affects UI layout, visual appearance, or user interface elements. Apply before making CSS (including CSS preprocessors like SCSS/Sass/Less/Stylus), Tailwind CSS classes, HTML, or component structure changes to ensure visual requirements are met through ASCII mockups first.
---

# Frontend ASCII Preview Skill

You are an AI coding assistant with expertise in frontend development and ASCII UI visualization. When working on frontend UI changes, you **MUST** follow this workflow:

## Core Principle

Always visualize UI changes through ASCII art + parameter documentation **BEFORE** writing any implementation code.

This prevents 5+ iteration cycles and saves ~75% of development time by ensuring visual alignment BEFORE implementation.

## When to Use This Skill

Apply this skill **WHEN**:

- Modifying CSS that affects layout (width, height, padding, margin, display, grid, flex)
- Modifying CSS preprocessors: SCSS/Sass, Less, Stylus (any file with `.scss`, `.sass`, `.less`, `.styl` extension)
- Changing Tailwind CSS classes or Tailwind configuration
- Changing HTML structure or component hierarchy
- Creating new UI components or pages
- Adjusting responsive breakpoints
- Modifying spacing, alignment, or positioning
- Working on interactive states (hover, focus, disabled)
- Designing animations or transitions
- Any file change that affects visual appearance (including styled-components, emotion, CSS-in-JS)

Skip this skill **ONLY** for:

- Non-UI code (backend, logic, data processing)
- Trivial 1-2 line CSS fixes (typos, obvious bugs)
- Pure JavaScript/TypeScript logic changes
- Test code or configuration files

## Workflow

### Step 1: Draw ASCII Layout

Create a clear ASCII diagram showing:

- Component structure and hierarchy
- Relative dimensions (percentages, "200px", "flex: 1")
- Spacing between elements
- Layout relationships (grid columns, flex items)
- Alignment patterns

**ASCII Drawing Guidelines:**

- Use box-drawing characters: `┌ ─ ┐ │ ├ └ ┴ ┬ ┤ ┘`
- Label each region with its purpose
- Show dimensions inline or below
- Indicate spacing with gaps or annotations
- Keep it simple - focus on relationships, not pixel perfection

**Example:**

```
┌─────────────┬─────────────────────┐
│ Sidebar     │ Main Content        │
│ (200px)     │ (flex: 1)           │
│             │                     │
│ Nav Items   │ Page content with   │
│             │ multiple paragraphs │
└─────────────┴─────────────────────┘

Grid: 200px 1fr
Gap: 0 (border separates)
Sidebar padding: 16px
Main padding: 24px
```

### Step 2: Document Parameters

When ASCII alone isn't sufficient, add parameter documentation:

**Layout Parameters:**

- Width, height (px, %, fr, auto)
- Padding, margin, gap
- Border-radius
- Grid/flex properties

**Visual Parameters:**

- Colors (background, text, borders)
- Typography (font-size, font-weight, line-height)
- Shadows (box-shadow)
- Opacity, transparency

**Interactive Parameters:**

- Hover states
- Focus states
- Disabled states
- Active/selected states

**Animation Parameters:**

- Duration, timing-function
- Transformations
- Transitions

### Step 3: Present to User

Show your ASCII visualization and ask:

> "Does this layout look right to you?"

Or for parameter documentation: "Are these dimensions and spacing correct?"

### Step 4: Implement Only After Confirmation

**WAIT** for user approval **BEFORE** writing any code.

If user suggests changes:

1. Update ASCII diagram
2. Revise parameters
3. Ask again for confirmation

Only when user confirms:

1. Write the implementation code
2. Follow the exact dimensions/specs from ASCII
3. Use the documented parameters

## Multiple Solutions

When multiple valid approaches exist, present 2-3 options with trade-offs:

**Example:**

**Option 1: Fixed sidebar (200px) + flexible main**

```
┌───────┬───────────────┐
│ 200px │ flex: 1       │
└───────┴───────────────┘
```

- Predictable layout
- Wastes space on large screens

**Option 2: Percentage-based (25% / 75%)**

```
┌─────────┬─────────────────┐
│ 25%     │ 75%             │
└─────────┴─────────────────┘
```

- Uses all available space
- May become too narrow/wide

**Option 3: Responsive (200px min, 25% max)**

```
┌─────────┬─────────────────┐
│ 200-25% │ remainder       │
└─────────┴─────────────────┘
```

- Best of both worlds
- More complex CSS

Ask: "Which approach do you prefer?"

## Responsive Design

For responsive layouts, show breakpoints:

**Desktop (> 768px):**

```
┌──────────────────────────────────────────────┐
│ Logo │ Home    About    Products    Login    │
└──────────────────────────────────────────────┘
```

**Tablet (481px - 768px):**

```
┌─────────────────────────────────┐
│ Logo │ Home    About    Login    │
└─────────────────────────────────┘
```

**Mobile (< 481px):**

```
┌──────────────────────┐
│ [☰]      Logo        │
└──────────────────────┘
↓ When tapped
┌──────────────────────┐
│ ☐ Home               │
│ ☐ About              │
│ ☐ Products           │
│ ☐ Login              │
└──────────────────────┘
```

Document: "Breakpoints at 481px and 768px. Hamburger menu below 481px."

## Interactive States

Show different states with labels:

**Default state:**

```
┌─────────────┐
│ [Button]    │
└─────────────┘
```

**Hover state:**

```
┌─────────────┐
│ [Button]    │ ← Darker background
└─────────────┘
```

**Focus state:**

```
┌─────────────┐
│ ╔[Button]╗  │ ← Blue outline
└─────────────┘
```

**Disabled state:**

```
┌─────────────┐
│ [Button]    │ ← Grayed out, no cursor
└─────────────┘
```

- Background: `#3b82f6` (default), `#2563eb` (hover), `#9ca3af` (disabled)
- Focus: `2px solid #60a5fa`

## Animation Notation

Use arrows and annotations for animations:

**Initial:**

```
┌──────────┐
│ Box      │
└──────────┘
```

**After click (→ 0.3s ease-out):**

```
      ┌──────────┐
      │ Box      │  ← Moves 200px right
      └──────────┘
```

- Transform: `translateX(200px)`
- Duration: `0.3s`
- Easing: `ease-out`

## Component Composition

For nested components, show hierarchy:

```
Page
┌─────────────────────────────────┐
│ Header (fixed, 60px)            │
├─────────────────────────────────┤
│                                 │
│  Main Content                   │
│  ┌───────────┬───────────────┐  │
│  │ Sidebar   │ Article       │  │
│  │ (200px)   │ (flex: 1)     │  │
│  └───────────┴───────────────┘  │
│                                 │
├─────────────────────────────────┤
│ Footer (auto, 40px)             │
└─────────────────────────────────┘
```

- Header: Fixed position, z-index: 1000
- Sidebar: Sticky, top: 60px
- Footer: Bottom of page

## Common Mistakes to Avoid

**DON'T:**

- Skip ASCII for "simple" changes - even 5-minute tweaks benefit from visualization
- Write code before user confirmation - this defeats the purpose
- Make ASCII too complex - focus on key relationships, not every pixel
- Forget parameter docs when ASCII is ambiguous
- Ignore responsive design - always consider mobile
- Assume framework specifics - keep ASCII framework-agnostic

**DO:**

- Ask "Does this look right?" for EVERY UI change
- Iterate on ASCII based on feedback
- Document colors, spacing, typography explicitly
- Show multiple options when trade-offs exist
- Consider edge cases (empty states, long content, errors)
- Follow the exact specs from ASCII when implementing

## Example Conversation

**User:** "Add a sidebar to the dashboard page"

**AI (Step 1 - Draw ASCII):**

Here's the layout I'm planning:

```
Dashboard
┌─────────────┬─────────────────────┐
│ Sidebar     │ Main Content        │
│ (200px)     │ (flex: 1)           │
│             │                     │
│ ☐ Dashboard │ Welcome back!       │
│ ☐ Analytics │ Stats cards...      │
│ ☐ Settings  │                     │
│ ☐ Logout    │ Chart...            │
└─────────────┴─────────────────────┘

Grid: 200px 1fr
Gap: 0 with 1px border separator
Sidebar bg: #f9fafb
Sidebar padding: 16px
Main padding: 24px
```

Does this layout look right?

**User:** "Make the sidebar 250px and add a user profile section at top"

**AI (Revise ASCII):**

Updated layout:

```
Dashboard
┌───────────────┬─────────────────────┐
│ Sidebar       │ Main Content        │
│ (250px)       │ (flex: 1)           │
│               │                     │
│ ┌───────────┐ │ Welcome back!       │
│ │ John Doe  │ │ Stats cards...      │
│ │ avatar@ex │ │                     │
│ └───────────┘ │ Chart...            │
│               │                     │
│ ☐ Dashboard   │                     │
│ ☐ Analytics   │                     │
│ ☐ Settings    │                     │
│ ☐ Logout      │                     │
└───────────────┴─────────────────────┘

Grid: 250px 1fr
Profile section: 80px tall, centered
Avatar: 40px circle
```

Is this better?

**User:** "Perfect!"

**AI (Step 4 - Implement):** [Now writes the HTML/CSS/React code following the exact specifications above]

## Measuring Success

After implementation, the user should say:

- "Perfect!"
- "Exactly what I wanted"
- "Looks great"
- "That's right"

**NOT:**

- "Can you make it wider?"
- "The spacing is off"
- "Not quite what I had in mind"
- "Can we try something else?"

If you hear the latter, the ASCII preview didn't do its job - always iterate on the visualization before implementing.

## Framework-Specific Notes

While ASCII diagrams are framework-agnostic, implementation should follow framework conventions:

**React:**

- Use styled-components, emotion, CSS modules, or Tailwind CSS
- Component structure should match ASCII hierarchy
- Props for dynamic dimensions
- CSS-in-JS objects should match parameter documentation

**Vue:**

- Use scoped styles, CSS modules, or Tailwind CSS
- Component composition mirrors ASCII
- Reactive classes for states

**Angular:**

- Use component-scoped styles
- Follow component hierarchy from ASCII
- Directives for conditional states

**Plain HTML/CSS:**

- Semantic HTML matches ASCII structure
- CSS classes reflect logical groupings
- BEM or utility-class naming

**CSS Preprocessors (SCSS/Sass/Less/Stylus):**

- Use variables for documented colors, spacing, typography
- Nesting matches ASCII component hierarchy
- Mixins/functions for reusable patterns

**Tailwind CSS:**

- Utility classes match documented dimensions/spacing
- Config values (theme.extend) for custom parameters
- Arbitrary values `[]` for one-off specs from ASCII

## Quick Reference

**Always:**

- Draw ASCII first
- Document parameters
- Ask "Does this look right?"
- Wait for confirmation
- Implement exactly as shown

**Never:**

- Write code before ASCII
- Skip user confirmation
- Guess at dimensions
- Ignore feedback
- Implement without approval
