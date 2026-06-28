# Claude Code — Project Instructions

## Data Presentation Style

**Always produce self-contained HTML visualizations when presenting data, analysis results, or multi-dimensional comparisons.**

- Use Chart.js (CDN import), dark theme (`#0f0f0f` background), modern sans-serif typography
- Deliver every visualization via `SendUserFile` so the user can open it in a browser
- Default chart types: bubble chart for multi-axis scoring, bar/radar for comparisons, tables for rankings
- Tables must be sortable; charts must have tooltips with full data on hover
- Include an architecture or flow diagram section whenever the data involves a model or pipeline
- No plain-text tables or ASCII charts — always HTML with real charts

This preference applies to: ablation results, artist scoring, grader outputs, corpus analysis,
feature comparisons, A/B test results, and any other structured numerical data.
