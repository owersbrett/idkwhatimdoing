# idkwhatimdoing

This repo has two jobs at once:

1. **A teaching artifact.** The on-camera working surface for a video demonstrating fundamentals of working effectively with Claude. The video is shown, not told.
2. **A personal learning engine.** A date-indexed Q&A archive. Every question Brett asks becomes a record on today's page. Over time, the archive grows into a personal vocab + concepts lexicon, with an "eval" mode that generates worksheets to circle back and confirm what stuck.

The two jobs reinforce each other: the engine is what gets demonstrated in the video, and the video drives questions that fill the engine.

## Who this is for

Self-taught developers, bootcamp grads, career-switchers, and **potatofolk** trying to get up to speed with Claude as a real collaborator. The author (Brett) is a 3x college dropout turned full-stack dev via bootcamp — the audience is people on a similar path who don't have a CS degree shielding them from feeling like they don't know what they're doing.

The repo name is the point. Nobody fully knows what they're doing. The skill is having a protocol for working through it anyway.

## Cyummu — the first fundamental

**Before writing any code, ask `cyummu`.**

`cyummu` = "confirm your understanding matches my understanding." Restate the requirement in your own words, then end with the literal token `cyummu` as the ask.

Brett replies with exactly one of:

- **`yes`** — Close, but not locked. Usually includes extra context that should become your north star. Keep discussing. **Do not start building.**
- **`no`** — Materially wrong. Drop your current model. Re-read the correction (usually in the same message), restate, ask `cyummu` again.
- **`yumutsu`** — *Your understanding, my understanding; the same understanding.* Green light. Build immediately and confidently.

The loop exists so the expensive part (building the wrong thing) never starts until alignment is real. It is cheap to restate. It is cheap to be told no. It is very expensive to ship a misread.

Skip cyummu only for trivial, unambiguous requests (one-line fixes, obvious lookups). When in doubt, ask.

## The engine — date-indexed Q&A archive

The directory **is** the database. No external DB, no service. Files on disk are the source of truth; the website reads from them.

### Mental model

- **Today is the active page.** Today's date (e.g. `2026-06-04`) opens a record. Every question asked that day appends an entry.
- **One page per day.** Tomorrow's first question opens a new page for tomorrow. The archive grows one page per day, forever.
- **Each entry captures:** the question, the answer, and any key vocabulary or concepts surfaced while answering. Concepts accumulate into a personal lexicon, indexed by the day they first appeared.
- **Navigation = a dropdown** of every dated page, today as default.
- **Eval mode** = pick a day, generate a multiple-choice worksheet from that day's questions. The circle-back. Confirms the concept actually stuck.

### What is intentionally undecided

These are open and should not be invented by future sessions without a cyummu:

- **Web stack.** Next.js, Vite, plain HTML — TBD.
- **Record format.** One MD file per day, JSON, or both — TBD.
- **Capture mechanism.** Default for now is **manual**: when Brett asks a question, Claude writes the entry to today's page as part of answering. Cleaner to demo on camera. A hook-based automatic capture is a possible later upgrade, not the starting state.
- **Worksheet generation.** Inline at view time, or pre-generated and stored — TBD.

When any of these get decided, update this section.

## Video fundamentals (working list)

Candidates the video may cover. Not committed yet — picked from on-camera sessions as they prove useful:

- The cyummu/yumutsu loop (this file is exhibit A)
- The archive engine itself — note-taking as a side effect of asking
- Working with Claude's memory and skills
- Plan mode vs. just-do-it mode
- Subagents and when to delegate
- Reading what Claude actually did vs. what it claims it did

Don't pre-build structure for fundamentals that haven't been chosen yet.

## How to behave in this repo

- **Cyummu before code.** Always, unless the request is trivially unambiguous.
- **Log questions to today's page.** When Brett asks a substantive question (not a quick clarification, not a meta instruction), record it on today's archive page as part of answering. Use today's date as shown in context. If the storage format hasn't been decided yet, propose one and confirm via cyummu before inventing files.
- **Surface vocabulary.** When an answer leans on a term that a self-taught dev might not have, name it explicitly and add it to the day's concept list. The lexicon is a deliverable, not a side effect.
- **Teach by example.** Anything written here may end up on camera. Favor clarity over cleverness. Real code over toy code.
- **No filler.** No throat-clearing comments, no "this is a placeholder" scaffolding, no preemptive abstractions. The audience is learning to spot exactly that kind of noise.
- **Frame the audience.** When explaining something, assume a smart self-taught dev who has shipped real software but has gaps. Don't condescend; don't assume CS vocabulary either.
