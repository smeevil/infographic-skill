# Style prompt templates

Fill every bracketed section with content-specific detail. Prompts should land
in the **400–800 word** range for layout/icon description. Never send a vague
one-liner.

## On-image text budgets (critical)

Image models garble long paragraphs. Keep canvas text short; put prose in
`companion.md`.

| Style | Budget |
|-------|--------|
| infographic | Section titles + ≤3 bullets of ≤8 words; big numbers OK |
| whiteboard | Short marker phrases; doodle-friendly |
| presentation | Title + ≤5 bullets of ≤8 words |
| diagram | Node ≤4 words; edge ≤3 words |
| mindmap | Labels ≤5 words |
| mindmap-structured | Labels ≤5 words; badges OK |
| mockup | UI chrome labels only |

## Anti-slop

Forbidden: Inter+violet gradient clichés, cyan–magenta neon, emoji section
headers, glow spam, mesh gradient blobs, walls of paragraph text on canvas.

---

## INFOGRAPHIC (default)

```
Create a professional, publication-quality infographic. This should look like it was designed by a professional graphic designer for a premium educational publication — clean, structured, and visually sophisticated.

CANVAS: [Portrait/landscape] format with a [color] background. [If polished: subtle gradient or textured background. If sketch: slightly more organic/craft feel with paper texture.]

HEADER: "[Title]" in large, bold [sans-serif / modern] typography at the top. [Subtitle if applicable] in lighter weight below. Use [color scheme] for the header area with [a decorative banner, geometric shape, or colored background block].

COLOR PALETTE: Use a sophisticated, cohesive palette — [specify exact scheme, e.g., "slate blue (#4A6FA5), warm taupe (#B8A898), olive green (#6B7F3B), charcoal (#3D3D3D), and cream (#F5F0E8) — inspired by modern editorial design"]. Use color consistently to group related concepts.

LAYOUT: [Describe the grid/flow structure — e.g., "Two-column layout with numbered sections flowing top-to-bottom. Left column covers theory, right column covers application. A central dividing line with decorative elements separates them."]

NUMBERED SECTIONS:
[For each section, describe:]
- Section number in a [colored circle / hexagon / badge] with [icon inside or beside it]
- "[Section Title]" in bold [font style], [color]
- [Icon/illustration: use flat-design style icons, e.g., "a flat-design gear icon in slate blue with a small dollar sign overlay" — NOT hand-drawn]
- Content: [at most 3 short bullets OR one big stat — no paragraph prose]
- [Simple chart only if 1–2 numbers; otherwise skip charts]
- [Visual container: rounded rectangle card with subtle shadow, colored sidebar, etc.]
- TEXT BUDGET: short labels only — long explanations live off-image

ICONS AND ILLUSTRATIONS:
- Style: [flat design / line art / isometric / duotone] — consistent throughout
- [List specific icons for each concept with exact descriptions]
- Each icon should be [size] and use [color approach — monochrome with accent, full color, etc.]

FLOW AND CONNECTIONS:
- [Describe how sections connect visually — numbered progression, timeline, flowchart arrows]
- [Use consistent connector styles — thin lines, dotted paths, thick arrows with labels]

DATA CALLOUTS:
- [Any statistics, key numbers, or highlight boxes]
- [e.g., "A large '6' in a teal circle with 'Key Determinants' written below in small caps"]

FOOTER: [Attribution, source notes, or summary bar at the bottom]

TYPOGRAPHY:
- Headers: Bold modern sans-serif
- Body: Clean sans-serif, good readability
- Callouts: Slightly larger, accent color
- All text must be crisp and legible

OVERALL FEEL: Clean, authoritative, and visually balanced. Like a premium educational poster. Information hierarchy is immediately clear. White space used intentionally. Nothing cramped or cluttered.
```

---

## WHITEBOARD

```
Create a stunning hand-drawn whiteboard visual explanation. The image should look like an expert educator spent hours crafting an engaging whiteboard illustration — vibrant, energetic, and visually rich.

CANVAS: A large whiteboard with [slight off-white texture / clean white surface based on draw-level]. [If sketch: visible whiteboard frame edges, slight marker smudges, eraser marks. If polished: pristine surface with subtle shadow at edges.]

TITLE: "[Title text]" written in large, bold [hand-lettered / marker-style] text across the top [center/left]. Use [color] for the title with [decorative underline / banner / box around it]. [If sketch: slightly uneven lettering with personality. If polished: confident, clean hand-lettering.]

LAYOUT: [Describe the spatial arrangement — e.g., "Radial layout with the central concept in the middle and 5 sub-topics arranged around it like spokes of a wheel" or "Left-to-right flow with 4 stages connected by large curved arrows"]

SECTIONS:
[For each sub-topic, describe:]
- "[Section Title]" in [color] bold marker text [position]
- [Icon/illustration description — be VERY specific, e.g., "a hand-drawn brain with visible folds and small lightning bolts coming from it" not just "a brain icon"]
- Key points written in smaller [handwriting/print] text: "[exact text]"
- [Border style: colored rounded rectangle, cloud bubble, banner, torn paper effect, etc.]
- [Any annotations: stars, exclamation marks, arrows pointing to important parts]

CONNECTIONS:
[Describe every arrow, line, and visual connection between sections]
- [e.g., "A thick curved arrow in blue flows from Section 1 to Section 2 with the word 'triggers' written along it"]

DECORATIVE ELEMENTS:
- Small doodles: [stars, lightbulbs, question marks, checkmarks, sparkles, gears]
- Color splashes: [small colored dots, underline accents, highlighted keywords]
- Margin notes: [small speech bubbles with "Key!", "Remember this!", etc.]
- [If sketch: more scattered doodles. If polished: fewer carefully placed decorations]

COLORS: Vibrant palette — [specify 4–6 exact colors] for markers on white.

TYPOGRAPHY: All text [hand-written with markers / carefully hand-lettered]. Headers in thick marker strokes. Body in thinner pen-style writing. [sketch / normal / polished handwriting quality per draw-level]

OVERALL FEEL: Energetic, educational, like walking into a classroom where the best teacher just finished an amazing visual lecture. FULL but not cluttered — every element has purpose and the eye naturally flows through the content.
```

---

## PRESENTATION

```
Create a single, visually striking presentation slide that explains [topic]. This should look like a keynote slide from a world-class conference talk — bold, minimal, and impactful.

CANVAS: Widescreen (16:9) format. [Dark background with light text / Light background with dark text / Gradient background]. [Specify exact colors.]

TITLE: "[Title]" in [large/extra-large] bold modern sans-serif text. Positioned [top-left / center-top]. [Color and styling details.]

VISUAL HIERARCHY: ONE dominant visual element that immediately captures attention, supported by [2–4] secondary elements.

PRIMARY VISUAL:
[Describe the main illustration, diagram, or graphic]

SUPPORTING ELEMENTS:
[For each:]
- [Position on slide]
- [Visual description]
- [Text labels]

KEY POINTS:
[2–5 key takeaways as clean bullet points or visual callouts]
- [Exact text and position for each]

DESIGN DETAILS:
- [Subtle grid lines, geometric decorations, or accent shapes]
- [Icon style and placement]
- [Color accent usage]

TYPOGRAPHY: Conference-quality — bold headers, clean body text, consistent sizing.

OVERALL FEEL: TED-talk quality. Bold, confident, focused. High contrast and strong visual hierarchy. The key message is understood within 3 seconds.
```

---

## DIAGRAM

```
Create a clear, precise technical diagram explaining [topic]. Professionally created technical illustration — accurate, well-labeled, and easy to follow.

CANVAS: Clean [white / light gray] background.

TITLE: "[Title]" in [position] using clean, professional sans-serif text in [color].

DIAGRAM TYPE: [Flowchart / Architecture / Sequence / Process flow / Comparison matrix / Hierarchy tree / Network topology]

NODES/ELEMENTS:
[For each node:]
- Shape: [rectangle / rounded rectangle / circle / diamond / hexagon / cylinder / cloud]
- Color: [specific color]
- Label: "[exact text]"
- Position: [where in the diagram]
- [Any internal details or sub-elements]

CONNECTIONS:
[For each connection:]
- From [node] to [node]
- Line style: [solid / dashed / dotted / thick / thin]
- Arrow: [one-way / bidirectional / none]
- Label: "[text on the connection]"
- Color: [specific color]

LEGEND/KEY: [If applicable]

ANNOTATIONS:
- [Numbered callouts, notes, or labels outside the main diagram]

GROUPING:
- [Visual containers/boundaries — dashed rectangles, shaded regions, swim lanes]

TYPOGRAPHY: Clean, technical, highly legible. Larger for main nodes, smaller for connection labels.

OVERALL FEEL: Engineering-quality documentation. Precise, unambiguous, professionally typeset. Belongs in official technical docs or an architecture review deck.
```

---

## MINDMAP

```
Create a vibrant, colorful mind map illustration — organic, radial, bursting with color and personality.

CANVAS: [White / cream / light gray] background, landscape orientation. Subtle paper texture.

CENTER NODE: Large central element dead-center:
- Shape: [rounded rectangle / circle / cloud / organic blob] with bold fill (rich coral / deep teal / vibrant purple)
- Text: "[Central Topic]" in large bold white or dark text
- [Optional icon beside/inside representing the topic]
- The center is the "sun" — everything radiates outward

MAIN BRANCHES: [4–8] thick organic curved branches (NOT straight lines):
- Each a DIFFERENT bold color (cherry red, ocean blue, emerald green, golden amber, deep purple, tangerine…)
- Curve gracefully; taper thick→thin outward
- End at a rounded rectangle / pill node with the sub-topic title

BRANCH NODES (Level 1):
- Rounded rectangle / pill, same color family as branch (lighter tint)
- "[Sub-Topic Title]" in bold
- [Specific small icon per node]

SUB-BRANCHES (Level 2): 2–4 thinner branches per Level 1:
- Same color family, thinner lines
- Short labels (2–5 words)
- [Optional tiny icons / checkmarks]

SUB-BRANCHES (Level 3, if complexity=detailed): finest lines, simple text labels

DECORATIVE ELEMENTS:
- Topic-relevant icons near branches
- Colorful dots at connection points
- Subtle glow behind center
- Optional dotted gray cross-links between related branches with small labels

COLORS: Vibrant saturated palette — [list 4–8 colors]. Rainbow of organized knowledge.

TYPOGRAPHY: All text horizontal and readable (not rotated along branches). Size hierarchy: center > L1 > L2 > L3.

OVERALL FEEL: Organic, radiant, visually stunning. Eye drawn to center, follows branches outward. Balanced composition, no crowding.
```

---

## MINDMAP-STRUCTURED

```
Create a clean, professional, data-oriented mind map in the style of XMind / MindMeister — organized, precise, information-dense, minimal decoration.

CANVAS: Clean white or very light gray (#F8F9FA), landscape. No texture.

CENTER NODE:
- Rounded rectangle with subtle shadow or thin border
- Fill: muted professional (dark slate blue #2C3E50 / charcoal #34495E / dark teal #1A5276)
- Text: "[Central Topic]" clean white bold sans-serif
- Optional small monochrome icon left of text

MAIN BRANCHES: [4–8] clean straight or gently curved lines:
- MUTED professional palette: steel blue (#5B7B9A), sage green (#6B8E6B), warm gray (#8E8E7A), muted coral (#C27B6B), slate purple (#7B6B8E), dusty teal (#5B8E8E)
- Consistent 2–3px width — NOT organic/hand-drawn
- Balanced tree: top branches up-left/up-right, bottom down-left/down-right

LEVEL 1 NODES:
- Rounded rectangles, thin colored border matching branch, white/light fill
- "[Sub-Topic Title]" dark bold sans-serif
- Consistent sizing; optional monochrome line-art icon

LEVEL 2:
- Thinner lines (1–2px), same parent color
- Smaller pills / bordered nodes
- Regular weight dark gray text
- Vertically stacked or neatly fanned — not random

LEVEL 3 (if detailed):
- Finest lines, lighter parent shade
- Simple labels with bullet dots
- May use compact list/table container

DATA ELEMENTS:
- Priority badges: [HIGH] [LOW] colored pills
- Small progress-bar style percentages
- Status markers (green check / yellow circle / red X)
- Count badges ("3 items")
- Category labels: [Core] [Advanced] [Optional]

CROSS-CONNECTIONS:
- Thin dashed gray lines across branches
- Small relationship labels; directional arrows where needed

LAYOUT RULES:
- Hierarchy via size/weight, not color intensity
- Equal sibling spacing; no overlapping branches
- Generous white space

TYPOGRAPHY: Clean sans-serif only. No hand-drawn/script fonts. All text horizontal.

OVERALL FEEL: Corporate-ready knowledge map. Could drop into a board deck unmodified. Focus on DATA and RELATIONSHIPS, not visual flair.
```

---

## MOCKUP

Controlled by `--device` (`mobile` default, `desktop`, `tablet`) and `--draw-level`.

```
Create a [draw-level-description] wireframe mockup of [content description].

BACKGROUND: Pure clean white (#FFFFFF). [If sketch: subtle dot grid paper. If polished: completely clean white.]

DEVICE FRAME:
[If mobile]: Modern smartphone outline (iPhone proportions, thin bezels) centered. [sketch: hand-drawn dark gray marker | normal: clean medium-gray + subtle shadow | polished: precise #999 lines + refined drop shadow]. Notch/dynamic island + home indicator.
[If desktop]: Browser window frame with top bar [sketch: hand-drawn window controls + rough URL bar | normal: clean controls + URL | polished: pixel-perfect Chrome/Safari chrome with tabs]. Rounded corners + shadow per draw-level.
[If tablet]: iPad-style frame (orientation from content). Thin bezels, rounded corners, home indicator.

All UI elements render INSIDE the device frame.

SCREEN CONTENTS (top to bottom, generous vertical spacing):
- Navigation/Header: [nav, logo, menu, back arrow…]
- Input Fields: label above, rounded rect, left icon, placeholder "[…]"
- Buttons: primary [filled] / secondary [outlined or light fill] with exact labels
- Text Elements: headlines, body, links with size hierarchy
- Lists/Tables, Cards/Containers, Image placeholders (box with X + "[Image]"), Toggles, Tabs — as applicable

SPACING AND LAYOUT:
- Mobile: single column. Desktop/tablet: multi-column using full width
- Consistent padding (16px mobile feel / 24px desktop)
- Clear hierarchy — primary actions larger

ANNOTATIONS (outside frame, thin gray arrows):
[sketch/normal: 3–5 callouts for UX decisions / component names / specs like "48px height"]
[polished: minimal or none]

COLORS:
[sketch]: Grayscale; light blue only for interactive/links
[normal]: Grayscale + blue (#4A90D9) interactive + light blue (#E8F0FE) active
[polished]: Charcoal (#333) primary, medium gray (#888) secondary, light gray (#DDD) borders, blue (#4A90D9) interactive

TYPOGRAPHY:
[sketch]: Hand-drawn fine-tip markers
[normal]: Clean sans-serif (Helvetica/SF Pro style)
[polished]: Crisp sans-serif, precise sizing, Figma-export quality

OVERALL FEEL:
[sketch]: UX sketchbook during a design sprint
[normal]: Mid-fidelity Balsamiq/Whimsical wireframe
[polished]: Premium Figma/Sketch wireframe for design review
```

---

## Draw-level modifiers

Apply across styles that support them:

| Level | Feel |
|-------|------|
| `sketch` | Rough, playful, visible imperfections, more doodles, marker texture |
| `normal` | Balanced educator / designer quality (default) |
| `polished` | Clean, consistent spacing, professional publication / Figma quality |

`draw-level` has the strongest effect on **whiteboard**, **presentation**, and **mockup**. Infographic and mindmap-structured stay relatively polished regardless.
