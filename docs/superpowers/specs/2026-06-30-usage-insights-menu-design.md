# Usage Insights Menu Design

## Goal

Make Coco Usage Bar feel more like a classic macOS menu while adding detailed, shareable usage insights behind compact hover submenus.

## Approved Direction

- Use a compact native-shell menu, not a large dashboard popover.
- Keep progress bars for every `5h` and `Weekly` limit row.
- Bars stay full width, but become thinner.
- Keep the pace tick on each bar.
- Make `30d raw tokens` a submenu trigger for full details.
- Add `Copy summary`.
- Add `Create image snapshot`.
- Use the Coco mascot/logo on the share snapshot.
- Use the label `Estimated cost`, matching CodexBar-style wording.

## Main Menu Layout

The first-level menu should be dense and native-feeling:

- Provider section label: `Codex` / `Claude Code`, with plan detail on the right.
- `5h` row: percent used, reset time, thin full-width progress bar, pace tick.
- `Weekly` row: percent used, reset date, thin full-width progress bar, pace tick.
- `30d raw tokens` row: compact summary such as `1.3B, 92% cached`, with submenu chevron.
- Footer/action rows: `Refresh`, `Check for Updates...`, `Send Feedback`, `Quit Coco Usage Bar`.

The menu should use standard macOS menu cues where possible: separators, disabled section labels, compact row heights, hover highlight behavior, submenu chevrons, and keyboard shortcuts.

## Detail Submenu

Each provider's `30d raw tokens` row opens a submenu with full available data:

- Raw token total.
- Estimated cost.
- Pricing basis.
- Input tokens.
- Cached input/cache read/cache write tokens as applicable.
- Output tokens.
- Reasoning tokens when available.
- Cache share.
- Event count.
- Session count where available.
- Average tokens per session where available.
- Heaviest day where available.
- Source split where available, including Desktop/App vs CLI/exec/subagent.

The submenu must avoid local filenames, local paths, account identifiers, prompt text, or transcript content.

## Pricing Behavior

Pricing should be model-aware where the logs allow it.

Claude:

- Claude usage events include model names.
- Estimate cost per event using the model-specific public Anthropic API pricing catalog.
- Include cache write, cache read, input, and output rates.
- Treat unknown/synthetic model rows as unpriced or priced with an explicit fallback label.

Codex:

- Codex token-count events do not directly include a model.
- Use the best session-level model hint when available.
- If no reliable model can be attached, use a default fallback and mark the pricing basis as estimated.
- Prefer public OpenAI API pricing catalog entries by model and pricing mode.

All copy and UI should say `Estimated cost`, not `spend`, and should include a small note where space allows:

`Estimated from local token logs · public API pricing · not an invoice`

## Copy Summary

`Copy summary` copies a concise text/Markdown summary to the clipboard. It should include:

- Date/window.
- Provider token totals.
- Estimated cost by provider.
- Cache share.
- Session/source highlights when available.
- The pricing caveat.

It should not include private paths, file names, prompts, or account identifiers.

## Image Snapshot

`Create image snapshot` generates a PNG share card and copies or reveals it for sharing.

The image should:

- Be branded with the Coco mascot/logo.
- Show headline token totals and estimated cost.
- Include Codex and Claude Code cards when both are available.
- Include interesting compact stats such as cache share, sessions, heaviest day, and source split.
- Include a small privacy/pricing caveat.
- Exclude prompts, filenames, paths, and account identifiers.

## Implementation Notes

- Add structured detail aggregation rather than overloading `TokenWindow`.
- Preserve existing local-only data model.
- Keep the status bar title unchanged unless needed for consistency.
- Keep the app dependency-light; prefer AppKit rendering for menus and share image generation.
- Treat share snapshot generation as local-only.

## Verification

- Build succeeds with `swift build -c release`.
- Existing `--print-snapshot` still works.
- The running app refreshes successfully.
- Detail submenus render for Codex and Claude Code.
- Copy summary writes expected text to the clipboard.
- Image snapshot creates a valid PNG.
- Pricing output identifies its pricing basis and fallback status.
