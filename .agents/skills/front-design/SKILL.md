---
name: frontend-design
description: Create distinctive, production-grade frontend interfaces with high design quality. Use this skill when the user asks to build web components, pages, or applications. Generates creative, polished code that avoids generic AI aesthetics.
license: Complete terms in LICENSE.txt
---

This skill guides creation of distinctive, production-grade frontend interfaces that avoid generic "AI slop" aesthetics. Implement real working code with exceptional attention to aesthetic details and creative choices.

The user provides frontend requirements: a component, page, application, or interface to build. They may include context about the purpose, audience, or technical constraints.

## Design Thinking

Before coding, understand the context and commit to a BOLD aesthetic direction:

- **Purpose**: What problem does this interface solve? Who uses it?
- **Tone**: Pick an extreme: brutally minimal, maximalist chaos, retro-futuristic, organic/natural, luxury/refined, playful/toy-like, editorial/magazine, brutalist/raw, art deco/geometric, soft/pastel, industrial/utilitarian, etc. There are so many flavors to choose from. Use these for inspiration but design one that is true to the aesthetic direction.
- **Constraints**: Technical requirements (framework, performance, accessibility).
- **Differentiation**: What makes this UNFORGETTABLE? What's the one thing someone will remember?

**CRITICAL**: Choose a clear conceptual direction and execute it with precision. Bold maximalism and refined minimalism both work - the key is intentionality, not intensity.

Then implement working code (HTML/CSS/JS, React, Vue, etc.) that is:

- Production-grade and functional
- Visually striking and memorable
- Cohesive with a clear aesthetic point-of-view
- Meticulously refined in every detail

## Frontend Aesthetics Guidelines

Focus on:

- **Typography**: Choose fonts that are beautiful, unique, and interesting. In greenfield work, prefer distinctive, characterful type choices instead of defaulting to generic fonts. If the product already has approved brand fonts, platform-native typography, or accessibility/performance constraints, follow those constraints first. In iterative work, consistency with the existing typographic system is usually more important than introducing novelty.
- **Color & Theme**: Commit to a cohesive aesthetic. Use CSS variables for consistency. Dominant colors with sharp accents outperform timid, evenly-distributed palettes.
- **Motion**: Use animation intentionally, not by default. Prioritize CSS-only solutions for HTML. Use Motion library for React when available. Focus on high-impact moments that improve clarity, hierarchy, or delight. Honor `prefers-reduced-motion`, prefer low-cost properties like `transform` and `opacity`, and keep concurrent effects limited so performance and usability stay intact. Use scroll-triggered and hover motion only when they support the experience instead of distracting from it.
- **Spatial Composition**: Unexpected layouts. Asymmetry. Overlap. Diagonal flow. Grid-breaking elements. Generous negative space OR controlled density.
- **Backgrounds & Visual Details**: Create atmosphere and depth rather than defaulting to solid colors. Add contextual effects and textures that match the overall aesthetic. Apply creative forms like gradient meshes, noise textures, geometric patterns, layered transparencies, dramatic shadows, decorative borders, custom cursors, and grain overlays.

Avoid generic AI-generated aesthetics by default: overused font choices when they are not required, cliched color schemes (particularly purple gradients on white backgrounds), predictable layouts and component patterns, and cookie-cutter design that lacks context-specific character. When working inside an existing product or design system, preserve the approved visual language and extend it intentionally instead of forcing novelty.

Interpret creatively and make unexpected choices that feel genuinely designed for the context. In greenfield work, avoid repeating the same aesthetic direction across generations. When working within an existing product, design system, or approved visual language, prioritize consistency with the established patterns over novelty and extend the system intentionally instead of re-inventing it.

**IMPORTANT**: Match implementation complexity to the aesthetic vision. Maximalist designs can justify elaborate code and richer motion only when accessibility, reduced-motion behavior, and performance remain well-controlled. Minimalist or refined designs need restraint, precision, and careful attention to spacing, typography, and subtle details. Elegance comes from executing the vision well.

Remember: Claude is capable of extraordinary creative work. Don't hold back, show what can truly be created when thinking outside the box and committing fully to a distinctive vision.
