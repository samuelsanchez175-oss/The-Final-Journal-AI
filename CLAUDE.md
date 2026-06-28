# Claude Code — Project Instructions

## Data Presentation — Living HTML Dashboard (per project)

**Never create a one-off HTML file. Always write to the project's persistent dashboard file and deliver it to Downloads.**

### File paths (one per project)
| Project | File |
|---|---|
| The Final Journal AI / XJournal AI | `~/Downloads/the-final-journal-ai.html` |
| Penwork Studios | `~/Downloads/penwork-studios.html` |
| Any other project | `~/Downloads/{project-slug}.html` |

### Workflow on every data presentation

1. **Read** the existing file at the project path (or detect it doesn't exist yet).
2. **Append** a new `<section>` with:
   - A timestamped `<h2>` heading describing the topic (e.g. "Artist Scoring — June 28 2026")
   - The chart/table/diagram for this session's data
   - A "Back to top ↑" link
3. **Update the Table of Contents** `<nav>` at the top — add a new `<li>` entry that links to the new section.
4. **Write** the full updated file back to `~/Downloads/{project-slug}.html`.
5. **SendUserFile** pointing at that Downloads path so it surfaces immediately.

### File structure (when creating fresh)
```html
<!DOCTYPE html>
<html>
<head>
  <!-- dark theme, Chart.js CDN, Inter font -->
  <title>{Project Name} — Insights</title>
</head>
<body>
  <header>
    <h1>{Project Name} — Insights</h1>
    <p class="subtitle">Living document · updated each session</p>
  </header>
  <nav id="toc">
    <h3>Sessions</h3>
    <ul>
      <!-- entries appended here -->
      <li><a href="#section-1">Topic — Date</a></li>
    </ul>
  </nav>
  <!-- sections appended below -->
  <section id="section-1">...</section>
</body>
</html>
```

### Chart / visual standards
- Dark theme: `#0f0f0f` background, `#1a1a1a` cards, accent `#a78bfa`
- Chart.js (CDN), Inter font (Google Fonts CDN)
- Bubble chart for multi-axis scoring; bar/radar for comparisons; sortable tables for rankings
- All charts: tooltips with full data on hover, legend, axis labels
- Include architecture/flow diagram whenever data involves a model or pipeline

### Applies to
Ablation results, artist scoring, grader outputs, corpus analysis, feature comparisons,
A/B test results, eval runs, and any other structured numerical data.

**No plain-text tables, no ASCII charts, no standalone one-time HTML files — always the project dashboard.**
