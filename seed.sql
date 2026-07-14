-- Source of truth for archive.db.
-- Edit this file. Then run `npm run db:build` (or just `npm run dev`).
-- All tables are dropped and recreated; no migrations to maintain.

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS sections;
DROP TABLE IF EXISTS vocab;
DROP TABLE IF EXISTS entries;
DROP TABLE IF EXISTS days;

CREATE TABLE days (
  date  TEXT PRIMARY KEY,
  kind  TEXT NOT NULL CHECK(kind IN ('manual','qa')),
  title TEXT
);

CREATE TABLE entries (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  day_date  TEXT NOT NULL,
  position  INTEGER NOT NULL,
  question  TEXT NOT NULL,
  answer    TEXT NOT NULL,
  FOREIGN KEY (day_date) REFERENCES days(date) ON DELETE CASCADE
);

CREATE TABLE vocab (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  entry_id  INTEGER NOT NULL,
  term      TEXT NOT NULL,
  def       TEXT NOT NULL,
  FOREIGN KEY (entry_id) REFERENCES entries(id) ON DELETE CASCADE
);

-- Derived layer: a brochure is a distillation of a day's entries + vocab into
-- "things we learned" panels (3 columns x 9 per side). Generated FROM
-- entries/vocab and committed here as a build artifact; entries stay canonical.
CREATE TABLE sections (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  day_date  TEXT NOT NULL,
  position  INTEGER NOT NULL,
  kicker    TEXT,
  label     TEXT NOT NULL,
  body      TEXT NOT NULL,
  FOREIGN KEY (day_date) REFERENCES days(date) ON DELETE CASCADE
);

-- Eval layer: one multiple-choice question per entry, for the circle-back.
-- opt_a..opt_d are the four choices; answer is the 0-based index of the correct
-- one. The website tracks score in-session only -- answers are never stored.
CREATE TABLE quizzes (
  entry_id    INTEGER PRIMARY KEY,
  prompt      TEXT NOT NULL,
  opt_a       TEXT NOT NULL,
  opt_b       TEXT NOT NULL,
  opt_c       TEXT NOT NULL,
  opt_d       TEXT NOT NULL,
  answer      INTEGER NOT NULL CHECK(answer BETWEEN 0 AND 3),
  explanation TEXT NOT NULL,
  FOREIGN KEY (entry_id) REFERENCES entries(id) ON DELETE CASCADE
);

-- =====================================================
-- Days
-- =====================================================

INSERT INTO days (date, kind, title) VALUES
  ('2026-06-03', 'manual', 'Salesman School, Volume I'),
  ('2026-06-04', 'qa',     'Kernels, containers, daemons, distros'),
  ('2026-06-06', 'qa',     'Automation runbooks'),
  ('2026-06-07', 'qa',     'Shells, PATH, binaries, network interfaces'),
  ('2026-06-08', 'qa',     'Pipes, git, LLMs, filing systems, Playwright pipelines');

-- =====================================================
-- 2026-06-04 entries
-- =====================================================

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(1, '2026-06-04', 1, 'What is a kernel?',
'The kernel is the part of an operating system that actually talks to the hardware. Everything else you interact with (apps you open, the dock, the terminal) goes through it.

Think of it as the head warehouse manager. You do not walk into the warehouse and grab potatoes off the shelf yourself. You hand a request to the manager: "I need fifty pounds of russets from bin three." The manager checks if you are allowed, fetches it, hands it back. Every other staff member (every app) does the same.

What the kernel handles: CPU time (deciding which program runs for the next few milliseconds), memory (handing out RAM and reclaiming it when a program ends), disk and files (reading and writing storage), devices (keyboard, screen, network card, USB), and permissions (keeping one app from reaching into another app''s memory).

When you hear "Linux," that is actually the name of just the kernel. Ubuntu, Debian, and the rest are full operating systems built around it. macOS has a kernel called XNU. Windows has the NT kernel.'),

(2, '2026-06-04', 2, 'What is Docker?',
'Docker is a way to package up a piece of software with everything it needs to run, the OS bits, the libraries, the config, all of it, into a self-contained box called a container. Then you hand that container to any machine and it runs the same.

Picture every potato shipment arriving with its own micro-truck. The truck contains the bin, the chalkboard sign, the scale, the right kind of weather. You hand it to any market and it sets up identically. That is a container.

Containers are built from images. An image is the recipe; the container is what runs. The recipe lives in a plain text file called a Dockerfile that says, in order, what to install, what to copy in, what command to run on start.

Why people use it: the eternal complaint "but it works on my machine" stops being a problem. The same container runs on a developer laptop, on a staging server, and in production, byte for byte the same.'),

(3, '2026-06-04', 3, 'What is a daemon?',
'A daemon is a program that runs in the background, with no user interface, quietly doing one job. Examples: the program listening for incoming network connections, the program rotating log files, the print spooler, the SSH server.

The name comes from Maxwell''s demon in physics, a hypothetical helper that sorts molecules without anyone watching. In Unix culture, daemons are the unseen helpers that run constantly. Pronounced "demon" or "day-mon," depending on who you ask.

Convention: daemon program names end in d. httpd is the web server daemon. sshd is the SSH server daemon. dockerd is the Docker daemon, the background process that actually runs your containers when you type docker run.

A daemon is just a long-running background process with no person attending to it. The d on the end of the name is the giveaway.'),

(4, '2026-06-04', 4, 'What is a distribution?',
'A distribution, or distro, is a complete operating system bundle built around the Linux kernel. The kernel on its own is just the warehouse manager from the kernel entry. It does not include the desktop, the file manager, the package manager, the default apps, the installer, or the tools you actually touch.

A distribution bundles all of that around the kernel into a working operating system. Different distros make different choices: which package manager, which init system, which default apps, how often updates ship.

Common distros: Ubuntu, Debian (which Ubuntu is built on), Fedora, Arch, NixOS. They are all "Linux," they all run the same kernel, but they feel different to use because the software stacked on top is different.

The word also gets used outside Linux. A "Python distribution" like Anaconda is a curated bundle of Python plus a chosen set of libraries. Same idea: take a core thing, wrap it in everything that makes it usable for a particular audience.'),

(5, '2026-06-04', 5, 'What is an SSH server?',
'An SSH server is a program that lets people log in to a computer over the network, securely, and run commands as if they were sitting at it. SSH stands for Secure Shell. The server is typically a daemon called sshd (the d-convention from the daemon entry).

Imagine your potato warehouse is across town. You do not drive there for every task. Instead you have a secure phone line. You call, the receptionist verifies it is really you (password, key card, or both), and from there you can give instructions: weigh that bin, pull tomorrow''s stock, lock up at six. That phone line is SSH. The receptionist who picks up is sshd.

What sshd actually does: listens on port 22 (the standard SSH port), negotiates encryption the moment a connection comes in so nothing between you and the server can be read, authenticates the caller (most secure: an SSH key pair, a private key on your laptop that proves you are you without sending the secret over the wire), and drops you into a shell on the server (or runs whatever command you sent).

You do not run sshd yourself. You install it (often it ships with the OS), enable it, and it runs in the background, all the time, waiting. When you type ssh brett@server.com on your laptop, your machine''s SSH client connects to that server''s sshd, does the handshake, and hands you a terminal there.

It is the standard way developers and admins reach servers. Docker on remote machines, Linux on a Raspberry Pi, your own VPS, almost always reached over SSH.'),

(6, '2026-06-04', 6, 'What is a discovery server (like Eureka), and what does Netflix have to do with it?',
'When you build a small app, there is one server. You hardcode its address. Done. When you build a big app like Netflix, there is not one server. There are hundreds or thousands of small services, each doing one thing: account, billing, recommendations, transcoding, playback session, ratings. This style is called microservices. Each service may have many running copies for scale and redundancy, and the set of copies is constantly changing as machines come and go.

The question: when the "playback" service needs to talk to the "user account" service, how does it find an address to call? Hardcoding does not work. There are too many addresses and they change too fast.

The answer is a service discovery server (sometimes called a service registry). It is a small special-purpose server whose only job is to keep a current phone book of which service has which IPs running right now.

How it works. Every microservice, when it boots up, calls the discovery server and says: "I am an instance of user-account, I am at 10.4.2.17:8081, I am healthy." The registry pings each entry periodically. When one stops answering, it is removed. When playback needs user-account, it asks the registry for an address, gets one (or a list to load-balance across), and calls it directly. The registry is the phone book, not a middleman for every request.

Eureka is Netflix''s open-source discovery server. They built it because they were hitting exactly this problem at huge scale. Their architecture is hundreds of microservices running on AWS, and they needed a phone book. They open-sourced Eureka as part of Netflix OSS, a suite of tools (Eureka, Hystrix, Zuul, Ribbon, Atlas) they released publicly.

Spring (the popular Java framework) bundled Eureka into Spring Cloud, which is how most non-Netflix developers came across it. Competitors: Consul by HashiCorp, etcd (used inside Kubernetes), ZooKeeper. In modern stacks running on Kubernetes, the cluster itself does service discovery and a standalone Eureka is not needed.

So the link to Netflix: discovery servers as a concept existed before them, but Eureka is the implementation Netflix built and open-sourced, and Netflix''s microservices playbook in the 2010s is why most developers learned the term.'),

(7, '2026-06-04', 7, 'What would a "determined task discovery server" actually be?',
'A determined task discovery server is not a made-up name, even though it sounds like one. It is one specific shape inside a broader category of personal-context daemons: small always-on programs that observe what a person is doing across many sources (commits, files, screenshots, recordings) and try, on their own, to surface useful things. Other names you will hear: personal agent, digital twin, context broker. The category is unsettled.

The architecture splits cleanly into four layers.

Collectors. Small, independent programs that each watch one kind of source. A git collector walks every known repository and indexes recent commits. A filesystem collector watches notes, drafts, and screenshots, and notices new files or edits. A media collector ingests screen recordings, voice memos, and photos, usually with OCR for images and transcription for audio. Each collector writes into a shared store. They do not talk to each other; they just deposit events.

Storage. Usually two layers. A structured store like SQLite, good for "what happened, when, where" queries. A vector store, which holds the same content embedded as numbers and answers questions like "what was I thinking about Hydrogen last month" without exact keywords.

Reasoner. The "determined" half. A loop, scheduled or event-driven, that re-reads recent events through an LLM with a prompt like: given this person''s last 48 hours of activity, what is worth surfacing, what is drifting, what pattern is forming. This is just Claude wrapped in a cron and a database read.

Surface. How it actually delivers. Options: an MCP server, so a Claude Code session in any directory already knows recent activity without being briefed; a daily digest (email or markdown drop); a widget or HUD; push notifications when something crosses a threshold.

Adjacent things to study before building: Rewind.ai, Bee, and Limitless (consumer takes on always-on personal context); Cursor''s codebase indexing (collectors plus a vector store for code); MCP itself, which Anthropic released as the standard protocol for letting LLMs read from arbitrary tools and data sources.

The Potatuhs setup already has half of this latent. The three event streams (BusinessEvent, DevelopmentEvent, Transcript) are the structured storage layer. What is missing is the always-on collectors (current capture is skill-triggered, not daemon-driven) and the reasoner layer that proposes things instead of waiting to be asked.');

-- =====================================================
-- Vocab
-- =====================================================

INSERT INTO vocab (entry_id, term, def) VALUES
  (1, 'kernel',       'the part of an OS that talks directly to the hardware'),
  (1, 'system call',  'a request from an app to the kernel ("read this file", "give me memory")'),
  (1, 'driver',       'kernel code that knows how to talk to a specific piece of hardware'),

  (2, 'container',    'a running, self-contained box of an app plus everything it needs'),
  (2, 'image',        'the recipe a container is built from'),
  (2, 'Dockerfile',   'the human-readable instructions for building an image'),

  (3, 'daemon',       'a long-running background program with no UI'),
  (3, 'd convention', 'many daemon names end in d (httpd, sshd, dockerd)'),
  (3, 'process',      'one running instance of a program'),

  (4, 'distro',       'a complete OS bundle built around a kernel'),
  (4, 'package manager', 'the tool a distro uses to install software (apt, dnf, pacman)'),
  (4, 'init system',  'what starts everything when the computer boots (systemd, OpenRC)'),

  (5, 'SSH',          'Secure Shell. A network protocol for logging into a remote computer and running commands, with everything encrypted in transit.'),
  (5, 'sshd',         'the daemon (background program) that listens for incoming SSH connections'),
  (5, 'SSH key',      'a pair of cryptographic files (public + private) used to prove identity without sending a password'),
  (5, 'port 22',      'the well-known port number SSH servers listen on by default'),

  (6, 'microservice', 'a small service that does one thing well; many compose into a larger app'),
  (6, 'service registry', 'another name for a discovery server: the phone book of running services'),
  (6, 'Eureka',       'Netflix''s open-source discovery server, written in Java'),
  (6, 'Netflix OSS',  'a suite of open-source tools Netflix released, including Eureka, Hystrix, Zuul, Ribbon, Atlas'),

  (7, 'collector',    'a program in a pipeline that ingests one kind of data from one source'),
  (7, 'vector store', 'a database optimized for semantic similarity search (great for "find things like this")'),
  (7, 'MCP',          'Model Context Protocol: the open standard for connecting LLMs to external tools and data sources'),
  (7, 'agent',        'an LLM loop that observes, decides, and acts on its own, not just answers a single question');

-- =====================================================
-- 2026-06-06 entries
-- =====================================================

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(8, '2026-06-06', 1, 'What is an automation runbook?',
'A runbook is the operations manual for a system: if X happens, do Y. Originally a literal binder on the ops team''s desk. An alarm goes off at 3 AM, the on-call engineer flips to the right page and follows the steps. "Database is unreachable. Step 1: check the dashboard. Step 2: SSH in, run this command. Step 3: still down? Page the DBA."

An automation runbook is the same idea, except the steps are encoded as scripts that execute, not English a human reads. Instead of "SSH in and run X," the runbook itself runs X when triggered.

It is a spectrum, not a binary.

Manual runbook. A Notion doc. Human reads it, types the commands.

Assisted runbook. Same doc, but each step has a "Run this" button. Human still decides; the machine performs.

Automated runbook. Triggered by an alert or a schedule. No human in the loop unless something fails partway through and escalates to one.

Common kinds.

Incident response. What to do when something breaks. "Disk over 90% full? Run cleanup. If still over 80%, page the team."

Operational. Recurring chores. Cert rotation, nightly backups, user onboarding.

Diagnostic. Investigation flowcharts. "Latency spike? Check these dashboards in this order, query these logs, here is what each pattern means."

Tools you will see.

AWS Systems Manager Automation is Amazon''s runbook engine for cloud infra. Rundeck is the long-standing open-source runbook orchestrator (jobs you trigger via UI or API). PagerDuty Runbook Automation (formerly Rundeck Cloud) is runbooks wired directly to alerts. Ansible playbooks are a close cousin: Ansible reserves the word "playbook" for its own declarative YAML format, but the concept overlaps heavily. General workflow engines like GitHub Actions, n8n, and Zapier get used as runbook runners all the time.

Why it matters. Institutional knowledge dies when people leave. A runbook is the org''s muscle memory written down. An automated runbook is muscle memory that runs even when nobody is awake. For the LLM age, runbooks are a natural agent target: well-scoped procedures with explicit success criteria, where an agent can attempt step 1, evaluate, attempt step 2, and escalate if step 5 fails.

The Potatuhs adjacency: the daily cron syncing logs to Drive is a one-step automated runbook. The newsletter pipeline is a multi-step one, still partially manual.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (8, 'runbook',          'an encoded operational procedure: the steps to take when a specific situation occurs'),
  (8, 'playbook',          'synonym for runbook in most usage; in Ansible specifically, a declarative YAML config that defines tasks to apply'),
  (8, 'on-call',           'the engineer currently on duty to respond when an alert fires (often rotating weekly)'),
  (8, 'incident response', 'the practice of detecting, mitigating, and resolving system failures'),
  (8, 'orchestrator',      'a system that schedules and runs multi-step workflows (Rundeck, AWS SSM, GitHub Actions)'),
  (8, 'escalation',        'handing a problem to a more senior responder when the current step or person cannot resolve it');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(9, '2026-06-06', 2, 'What is a class?',
'A class is a blueprint for a kind of thing. It declares the properties each instance carries and the actions each instance can perform. When you create an object from a class (you "instantiate" it), you get one concrete thing with its own copy of those properties.

A Potato class might say: every potato has a weight, a variety, and a ripeness level, and every potato knows how to bake(), mash(), and weighInGrams(). You do not bake the class itself. You bake a specific instance. The class is the mold; each potato is a concrete object poured from it.

The mechanism. A class declares fields (the data) and methods (the functions). You build a new instance by calling its constructor, which initializes the fields. Inside a method, the instance is implicitly available as "this" (Java, JavaScript, C#) or "self" (Python, Rust).

Adjacent ideas.

Inheritance. One class extends another, picking up its fields and methods. RussetPotato extends Potato.

Interface (or protocol). A contract that says "anything claiming to be this type must have these methods." No implementation, just the shape.

Composition over inheritance. A widely held lesson: building behavior by holding references to other objects is usually more flexible than building deep inheritance trees.

Static / class methods. Things you call on the class itself, not on an instance. Potato.fromSeed(...) returns a new potato.

Languages differ on the framing. Java and C# make the class the fundamental unit (every file is a class). Python and JavaScript classes are syntactic sugar over more primitive structures (Python objects are dictionaries; JavaScript objects are prototype chains). Go and Rust avoid the word entirely and use structs plus methods. Same shape, different name.'),

(10, '2026-06-06', 3, 'What is JSON?',
'JSON stands for JavaScript Object Notation. A plain-text format for structured data (objects, lists, numbers, strings, booleans, null) that nearly every modern programming language can read and write. It started as a subset of JavaScript''s object syntax (hence the name) but is now language-agnostic and the default data format of the modern web.

The grammar is tiny. There are exactly six things in JSON.

Objects: { "key": value, "key": value }. Keys must be strings.

Arrays: [ value, value, value ]. Ordered list.

Strings: "hello". Double quotes only.

Numbers: 42, 3.14, -7. No NaN, no infinity.

Booleans: true, false.

Null: null.

That is it. No dates (just use strings), no comments, no trailing commas.

Example:

{
  "name": "Brett",
  "potatoes": ["russet", "yukon"],
  "active": true,
  "favorite_count": 42
}

How it is actually used. API requests and responses, LLM payloads, config files, interprocess communication. Almost all of it is JSON. Every major language has a built-in or one-line library: JSON.parse / JSON.stringify in JavaScript, json.loads / json.dumps in Python, serde_json in Rust, Jackson or Gson in Java.

Common traps.

Strings need double quotes. ''hello'' is fine in Python, not in JSON.

No trailing commas. [1, 2, 3,] is invalid.

No comments. // note breaks the parser.

Numbers vs strings. "42" is a string. 42 is a number. They are not interchangeable. APIs that confuse the two cause bugs.

Dates are strings. Convention is ISO 8601: "2026-06-06T15:30:00Z".

Adjacent formats worth knowing.

JSON5 and JSONC. Relaxed JSON that allows comments and trailing commas. JSONC is what VS Code uses for settings.json.

YAML. JSON''s whitespace-sensitive cousin. Same data model, friendlier for humans (config files, CI workflows).

TOML. A config-flavored alternative used by Rust''s Cargo.toml and Python''s pyproject.toml.

JSON Schema. A JSON document that describes the shape of other JSON documents. Used to validate API requests, generate forms, and constrain structured outputs from LLMs.'),

(11, '2026-06-06', 4, 'What is the anatomy of a website?',
'A website is built from a roughly standard set of region-shaped parts. Designers and developers share the vocabulary so they can point at things and agree on names. Working glossary:

Top-level skeleton.

Header. The strip across the top, present on most pages. Branding and primary navigation.

Footer. The strip across the bottom. Site map, legal links, contact info, social icons.

Main / content / canvas. The middle region between header and footer, where each page''s actual content lives.

Navigation.

Navbar (navigation bar). The bar holding top-level links, usually inside the header.

Logo / wordmark. Site identity, usually top-left of the navbar, doubles as a link back to home.

CTA button (call-to-action). A prominent button in the navbar like "Sign Up" or "Get Started."

Hamburger menu. The three-line icon that opens a hidden menu, usually on mobile.

Breadcrumbs. The trail of links showing where you are in a hierarchy. Home > Products > Russet > Specs.

Tabs. Horizontal switcher between views of the same page.

Side regions.

Sidebar. Generic term for a vertical column to the side of main content.

Left rail / navigation pane. A persistent left sidebar holding section navigation. The classic doc-site or dashboard pattern: Slack, Notion, Linear, Gmail.

Right rail / aside. A right sidebar holding secondary content. Table of contents, related articles, "people also bought," ad slots.

Drawer / off-canvas panel. A sidebar that slides in and out, often triggered by a button.

Page-level zones.

Hero. The big, attention-grabbing section at the top of the main content on landing pages. Big headline, big image or video, primary CTA.

Above the fold. The portion of the page visible without scrolling. Newspaper-era term that stuck.

Section. A vertically stacked chunk of the page. Marketing sites are usually a sequence of sections.

Card. A rectangular container that groups related info (image, title, snippet, link). Cards usually appear in grids.

Grid / bento. A layout pattern of cards in a regular or asymmetric grid. "Bento" specifically means a grid where some cells are larger than others.

Modal / dialog. An overlay that appears on top of the page and dims everything behind it. Demands a decision.

Toast / snackbar. A small message that pops up briefly to confirm an action ("Saved!").

Tooltip / popover. A small floating box explaining a UI element, appears on hover or click.

Smaller pieces. Form (inputs grouped for submission). Input / field (a single editable area). Dropdown / select (field that opens a list of choices). Combobox (dropdown you can also type into to filter). Avatar (small round image representing a user). Badge / pill / chip (tiny rounded label holding a status or category). Skeleton (grayed-out shape that appears while content is loading).

Two common overall patterns.

Marketing site. Header + hero + sections (features, social proof, pricing, FAQ) + footer. Usually a single long scrolling page.

App shell. Header + left rail + main content area (often a right rail too). The shell stays put; the main area swaps based on navigation. Slack, Notion, Linear, Gmail.'),

(12, '2026-06-06', 5, 'What is an ontology?',
'An ontology is a formal description of what kinds of things exist in some domain and how they relate to each other. It is the "what categories are there, and how are they connected" layer that sits underneath any system that needs to reason about a topic.

A concrete example. For a library system, the ontology might say:

The things that exist: Book, Author, Genre, Publisher, Reader.

The relationships: a Book has-one Author, has-one Publisher, has-many Genres. A Reader borrows-many Books. A Genre can be a sub-genre of another Genre.

The rules: every Book must have a Title and an ISBN. A Reader cannot have more than 10 active borrows.

The ontology is not the database, not the code, not the UI. It is the agreed-on map of the domain that the database, the code, and the UI all reflect.

Where you will hear the word.

Philosophy. The original sense: the branch of metaphysics about what exists and what categories of being there are.

Knowledge graphs and the Semantic Web. Ontologies are how things like Wikidata, Google''s Knowledge Graph, and biomedical databases (Gene Ontology, SNOMED CT) declare their concepts. Tools: RDF (the data model), OWL (the ontology language), SPARQL (the query language).

AI and LLMs. "Ontology-aware" retrieval, structured extraction, and agent reasoning. Giving an LLM an explicit ontology of your domain dramatically improves the consistency of what it produces.

Enterprise data modeling. Same idea under a less academic name: "canonical data model" or "domain model."

How it differs from neighboring things.

Schema is the literal shape of data in storage (column names, types, foreign keys). Ontology is the conceptual layer above it. A schema can change without the ontology changing, and vice versa.

Taxonomy is a tree of categories, strictly hierarchical. Ontology is a graph; categories can have many kinds of relationships, not just parent / child.

Glossary is a flat list of terms and definitions. Ontology adds structure: which terms are sub-types of which, which terms relate to which.

Why it matters here. The ontology for this archive is small but explicit: a Day has many Entries, an Entry has many Vocab terms. The Potatuhs world has a richer one: BusinessEvent, DevelopmentEvent, Transcript, Character, Division, Brand, Comic. Naming those categories crisply lets every tool (the daemon, the renderer, Claude, the user) talk about them without dragging in extra concepts.'),

(13, '2026-06-06', 6, 'What is localhost?',
'localhost is the name your computer uses for itself. When a program asks for localhost, the network resolves it to 127.0.0.1 (IPv4) or ::1 (IPv6). Both are special addresses that mean "this machine, right here, do not go onto the network at all."

When you run a dev server and visit http://localhost:4747, your browser is talking to a program running on the same laptop. The request never crosses your WiFi, never touches a router, never sees the internet. It is the shortest possible round trip: your computer talking to itself.

How it is wired.

Every operating system ships with a special loopback interface (lo on Linux, lo0 on macOS). It is a fake network adapter that delivers packets straight back to the same machine.

The hostname localhost is mapped to 127.0.0.1 in /etc/hosts, a file that overrides DNS for specific names.

Anything in the 127.0.0.0/8 block (so 127.0.0.1, 127.0.0.2, etc.) is treated as loopback.

Why it exists. Development needs a way to run a server and visit it without exposing it to the internet. localhost is that private, machine-internal address. It is also how processes on the same machine talk to each other through HTTP (a dev server talking to a local database, an MCP server talking to Claude, and so on).

Related ideas.

127.0.0.1 is the actual IP. localhost is just the friendly name for it.

0.0.0.0 means "all network interfaces," including loopback AND external ones. Binding a server to 0.0.0.0 is what makes it reachable from the local network.

Your public IP is the address other computers on the internet use to reach yours, assigned by your ISP. Visible at whatsmyip.org.'),

(14, '2026-06-06', 7, 'What is a port?',
'A port is a number that says which program on a machine a network request is for. An IP address gets the packet to the right computer; a port gets it to the right program running on that computer.

Mailbox analogy. The IP address is the street address of an apartment building. The port is the apartment number. The building has one mailing address; inside, hundreds of apartments share it. Without an apartment number on the envelope, the mail carrier does not know whose door to put it under.

The numbers are 16-bit, so the range is 0 through 65535. Conventions:

0 through 1023: well-known ports. Reserved for famous protocols. HTTP=80, HTTPS=443, SSH=22, FTP=21, DNS=53, SMTP=25. Binding to these usually requires admin or root privileges.

1024 through 49151: registered ports. Assigned by IANA to specific software (PostgreSQL=5432, Redis=6379, MySQL=3306).

49152 through 65535: ephemeral / dynamic. What your browser grabs at random for outbound connections.

Dev servers sit in the registered range and pick something memorable: Vite defaults to 5173, Next.js to 3000, this repo to 4747.

How a request finds its target. When you type http://localhost:4747, the browser:

1. Resolves localhost to 127.0.0.1.
2. Opens a TCP connection to 127.0.0.1 port 4747.
3. The OS routes that connection to whichever process bound itself to port 4747.

Only one process can listen on a given port at a time. That is why you get "EADDRINUSE: port already in use" when you try to start a second dev server on a port that is already taken.

Inspection tools.

lsof -i :4747 shows what is listening on port 4747.

netstat -an | grep 4747 shows the same information in a different format.

kill <pid> frees up the port if a zombie process is holding it.'),

(15, '2026-06-06', 8, 'Why can people not see my website at localhost:4747 when it is running?',
'Because localhost literally means "this machine." When someone else types http://localhost:4747 on THEIR laptop, their computer is looking at ITSELF, not yours. The address is correct; it just resolves to a different machine for every person who uses it. It is the network equivalent of telling someone "come to my house" without giving them the address.

To make your dev server visible to someone else, three things need to be true.

1. Your server must bind to a non-loopback interface. By default many dev servers bind only to 127.0.0.1 so they cannot accidentally leak to the network. You need to tell it to bind to 0.0.0.0 (all interfaces) instead. For Vite: vite --host 0.0.0.0, or set server.host: true in vite.config.ts.

2. They need an address they can actually reach.

Same WiFi network. They can use your machine''s local IP, something like http://192.168.1.74:4747. Find yours with ipconfig getifaddr en0 on macOS. Works at a coffee shop, your house, an office.

Different network (different city, internet at large). The local IP does not work; it is not reachable across the public internet. You need either:

  - A tunnel like ngrok, Cloudflare Tunnel, or Tailscale Funnel. These give you a public URL (something like https://abc123.ngrok.io) that forwards into your local port. About 30 seconds to set up; the favorite tool for "show this thing to a friend."

  - A real deploy to a host (Vercel, Netlify, Cloudflare Pages, Fly, Railway). You get a permanent URL but the round-trip to ship is longer.

  - Port forwarding on your home router (route incoming traffic on a port to your laptop''s local IP). Works, but requires router admin access, a stable-ish public IP, and is a security concern.

3. Their firewall and yours must not be blocking it. macOS will sometimes prompt "do you want to accept incoming connections for Node?" the first time. Say yes. Corporate or hotel WiFi often blocks peer-to-peer traffic entirely.

The shortest path from "running locally" to "send me a link" is ngrok.

Install ngrok once, then run ngrok http 4747.

It prints a public HTTPS URL.

Anyone, anywhere, can hit that URL; ngrok forwards it through a tunnel to your machine.

Free tier rotates the URL on each restart; paid gives you a fixed subdomain.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (9, 'class',           'a blueprint for objects, defining the fields and methods every instance will have'),
  (9, 'instance',        'a single concrete object created from a class'),
  (9, 'constructor',     'the special function that builds a new instance and initializes its fields'),
  (9, 'field',           'a piece of data carried by each instance (also called a property or attribute)'),
  (9, 'method',          'a function defined on a class that operates on a specific instance'),
  (9, 'inheritance',     'one class extending another to reuse and extend its definition'),
  (9, 'interface',       'a contract specifying which methods a type must have, without implementing them'),
  (9, 'this / self',     'the implicit reference inside a method to the instance the method was called on'),

  (10, 'JSON',           'JavaScript Object Notation: a plain-text format for structured data, language-agnostic and dominant on the web'),
  (10, 'serialization',  'turning an in-memory object into a string (e.g. JSON) so it can be stored or sent'),
  (10, 'deserialization','turning a string back into an in-memory object (also called parsing)'),
  (10, 'payload',        'the body of a request or response (usually JSON in modern web APIs)'),
  (10, 'ISO 8601',       'the standard string format for dates and times: 2026-06-06T15:30:00Z'),
  (10, 'JSON Schema',    'a JSON document that describes and validates the shape of other JSON documents'),
  (10, 'YAML',           'whitespace-sensitive cousin of JSON, friendlier for configs and CI workflows'),
  (10, 'TOML',           'config-flavored data format used by Rust''s Cargo.toml and Python''s pyproject.toml'),

  (11, 'header',         'the strip across the top of a page, usually holding branding and primary nav'),
  (11, 'footer',         'the strip across the bottom of a page, usually holding site map and legal links'),
  (11, 'navbar',         'the navigation bar holding top-level links, usually inside the header'),
  (11, 'sidebar',        'a vertical column next to the main content; "left rail" and "right rail" are common specific terms'),
  (11, 'hero',           'the big attention-grabbing section at the top of a landing page'),
  (11, 'card',           'a rectangular container grouping related info (image, title, snippet, link); usually appears in grids'),
  (11, 'modal',          'an overlay on top of the page that dims everything behind it and demands a decision'),
  (11, 'toast',          'a small message that pops up briefly to confirm an action; also called a snackbar'),
  (11, 'app shell',      'the persistent surrounding chrome of an app (header + rails) that stays put while the main area swaps'),
  (11, 'above the fold', 'the portion of a page visible without scrolling; a newspaper-era term that stuck'),

  (12, 'ontology',       'a formal description of what kinds of things exist in a domain and how they relate'),
  (12, 'taxonomy',       'a strictly hierarchical classification of categories (a tree)'),
  (12, 'schema',         'the literal data shape in storage (columns, types, foreign keys); below the ontology layer'),
  (12, 'domain model',   'common enterprise-software name for what philosophers and Semantic Web folks call an ontology'),
  (12, 'RDF',            'Resource Description Framework: a standard triple-based data model for the Semantic Web'),
  (12, 'OWL',            'Web Ontology Language: a richer language for expressing ontologies on top of RDF'),
  (12, 'SPARQL',         'query language for RDF-based data (the SQL of the Semantic Web)'),
  (12, 'knowledge graph','a database of entities and their relationships, often backed by an ontology'),

  (13, 'localhost',      'the friendly name for "this machine, right here"; resolves to 127.0.0.1'),
  (13, '127.0.0.1',      'the IPv4 address that always means "this machine"'),
  (13, 'loopback',       'the fake network interface (lo0 on macOS) that delivers packets back to the same machine'),
  (13, '0.0.0.0',        'bind-to-all-interfaces address; what you use to make a server reachable from the network'),
  (13, '/etc/hosts',     'a local file that maps hostnames to IPs, overriding DNS for specific names'),
  (13, 'public IP',      'the internet-facing address of your machine, assigned by your ISP'),

  (14, 'port',           'a 16-bit number identifying which program on a machine a network connection is for'),
  (14, 'well-known port','a port in the 0-1023 range, reserved for famous protocols (HTTP=80, SSH=22, etc.)'),
  (14, 'TCP',            'Transmission Control Protocol; the connection-oriented transport almost all web traffic uses'),
  (14, 'EADDRINUSE',     'the error returned when something else is already listening on the port you want'),
  (14, 'lsof',           'list-open-files command; lsof -i :PORT shows what process is bound to a port'),
  (14, 'IANA',           'Internet Assigned Numbers Authority; the body that registers well-known and registered ports'),

  (15, 'tunnel',         'a service like ngrok or Cloudflare Tunnel that exposes a local server through a public URL'),
  (15, 'ngrok',          'the canonical tunnel-from-localhost tool; ngrok http 4747 gives a public HTTPS URL'),
  (15, 'port forwarding','router configuration that routes inbound traffic on a port to a specific internal machine'),
  (15, 'local IP',       'the address of your machine on the local network (e.g. 192.168.1.74); reachable on the same WiFi only'),
  (15, 'firewall',       'OS or router rules that allow or block network connections; can block dev servers from being reached');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(16, '2026-06-06', 9, 'What are all the licenses one can choose on GitHub?',
'GitHub''s "Choose a license" picker is a UI on top of an open-source data file maintained at choosealicense.com, which is itself a GitHub-owned open project. When you click "Add a license" on a new repo, the dropdown shows roughly fifteen options.

The full list.

MIT License. Permissive.

Apache License 2.0. Permissive, with an explicit patent grant.

BSD 2-Clause "Simplified" License. Permissive, MIT-equivalent with slightly different wording.

BSD 3-Clause "New" or "Revised" License. Permissive, with a no-endorsement clause.

ISC License. Permissive, MIT-equivalent but shorter.

Boost Software License 1.0. Permissive, with no requirement to include the license in binary distributions.

The Unlicense. Public-domain dedication.

Creative Commons Zero v1.0 (CC0). Public-domain dedication, written by Creative Commons.

Mozilla Public License 2.0 (MPL 2.0). Weak copyleft, per-file.

Eclipse Public License 2.0 (EPL 2.0). Weak copyleft, common in Java.

GNU Lesser General Public License v2.1 (LGPLv2.1). Weak copyleft for libraries, older revision.

GNU Lesser General Public License v3.0 (LGPLv3). Weak copyleft for libraries, current revision.

GNU General Public License v2.0 (GPLv2). Strong copyleft, historic.

GNU General Public License v3.0 (GPLv3). Strong copyleft, with explicit patent grant and anti-Tivoization clauses.

GNU Affero General Public License v3.0 (AGPLv3). Strong copyleft that extends to running the code as a network service.

You can also pick "no license" (which leaves default copyright in force, meaning nobody else may legally use, copy, or modify the code) or drop in any custom license file by editing LICENSE yourself.

The families, and what they actually do.

Permissive. "Do whatever, just keep the copyright notice."

MIT is by far the most popular open-source license on GitHub. About fifty lines. The default for almost anything you want widely adopted.

Apache 2.0 is MIT plus an explicit patent grant. Important if you work at a company that holds patents, because contributors implicitly license those patents to anyone using the code. Standard for big projects shipped by big companies: Kubernetes, Android, the Apache Foundation.

BSD 2-Clause is MIT-equivalent with different wording.

BSD 3-Clause adds one thing: nobody can use your name to endorse derivatives. Used by Go, Django, and React Native.

ISC is MIT, shorter. Used heavily inside npm.

Boost is permissive with the bonus that you do not need to include the license text when distributing binaries.

Public-domain-style. "I give up all rights."

The Unlicense is the closest thing to true public domain in jurisdictions that recognize the concept.

CC0 is Creative Commons'' attempt at a global public-domain dedication. Heavy use in datasets, fonts, and art assets.

Weak copyleft. "Modifications to this code must stay open, but you can combine it with proprietary code."

MPL 2.0 is file-level copyleft. Any file you modify stays under MPL; new files you write can be any license. Used by Firefox.

EPL 2.0 is similar in shape and common in the Java and Eclipse ecosystem.

LGPL is library-focused. Linking a closed-source app against an LGPL library is fine; modifying the library itself triggers copyleft on the library. Both 2.1 and 3.0 are in active use.

Strong copyleft. "Any project that includes this code must be released under the same license."

GPLv2 is the historic Linux kernel license, written in 1991. Most foundational Linux tooling.

GPLv3 adds explicit patent protection and the anti-Tivoization clauses (you cannot ship GPL code on hardware that prevents users from running modified versions of it). Used by Bash, GCC, and GIMP.

AGPLv3 closes the "SaaS loophole." If you run modified AGPL code as a network service, you must release the source to your users, not just to people who get a binary from you. Used by MongoDB before they relicensed, by Mastodon, and by Plausible.

How to pick, the thirty-second version.

Want maximum adoption and do not care what anyone does with it. MIT.

Same, but you are at a company or patents matter. Apache 2.0.

Want your improvements to come back to the project. GPLv3, or AGPLv3 if it is a web service.

It is a library and you want it usable by closed apps but want library changes upstreamed. LGPL or MPL 2.0.

It is a dataset or asset, not code. CC0.

One often-missed thing. The license picker is a UI on top of an open-source data file. The canonical list and the metadata behind each license (required, permitted, forbidden) live at github.com/github/choosealicense.com. SPDX (Software Package Data Exchange) maintains the machine-readable identifiers ("MIT", "Apache-2.0", "GPL-3.0-only") that go in package.json''s "license" field and equivalents in other ecosystems.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (16, 'license (OSS)',     'a legal grant from the copyright holder spelling out what others may do with the code'),
  (16, 'permissive',        'license family with minimal restrictions: keep the copyright notice and you can do almost anything'),
  (16, 'copyleft',          'license that requires derivative works to be released under the same license'),
  (16, 'weak copyleft',     'copyleft that applies only to the licensed files, not to a larger project that links against them'),
  (16, 'strong copyleft',   'copyleft that applies to the whole project that includes the licensed code'),
  (16, 'patent grant',      'explicit license to use any patents a contributor holds that cover their contribution'),
  (16, 'Tivoization',       'shipping GPL code on hardware that prevents users from running modified versions; GPLv3 forbids this'),
  (16, 'SaaS loophole',     'gap in classic GPL where hosting modified code as a web service did not count as distribution, so source need not be released; AGPLv3 closes it'),
  (16, 'SPDX identifier',   'the canonical short machine-readable name for a license (MIT, Apache-2.0, GPL-3.0-only)'),
  (16, 'choosealicense.com','GitHub''s open-source license-picker website and the data source behind the repo picker UI');

-- =====================================================
-- 2026-06-07 entries
-- =====================================================

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(17, '2026-06-07', 1, 'When I run npm run dev, what is the npm portion actually doing? What is a PATH? What is a binary? Why /bin?',
'When you type `npm run dev`, the word `npm` is not a magic command. It is the name of an actual file in an actual folder on your machine. The shell finds that file and runs it. That is the whole trick. Everything else is mechanics.

The shell, the thing you are typing into.

When the terminal is open, you are not talking to your computer directly. You are talking to a program called a shell. On macOS the default is `zsh`. The shell takes the text you type, splits it on whitespace, treats the first word as a command, the rest as arguments. So `npm run dev` becomes: command = `npm`, args = `run` and `dev`.

The shell then has to find `npm`. It does not know in advance where `npm` lives.

PATH, the search list.

`PATH` is an environment variable: a named string the shell (and every program the shell launches) can read. An environment variable is just a key-value pair attached to your session. `PATH` happens to hold a colon-separated list of directories.

Run `echo $PATH` and you will see something like `/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin`.

When you type `npm`, the shell walks that list left to right. It looks in `/opt/homebrew/bin` for a file named `npm`. Not there? Try `/usr/local/bin`. Then `/usr/bin`. Then `/bin`. The first match that is marked executable wins. That file is the one that runs.

You can see which one wins: `which npm`. It prints the full path of the file the shell would actually run.

Binary, the file being run.

A binary is an executable file. The word comes from compiled programs, which are literal binary data, ones and zeros the CPU reads directly, not human-readable source code. In day-to-day usage "binary" is used loosely to mean any file the OS will execute when you name it, even when that file is actually a shell script or a Node script. `npm` is technically a small Node script. People still call it a binary because it sits in a `bin/` folder and behaves like one.

A file becomes runnable by having its executable permission bit set. `ls -l $(which npm)` shows that bit as an `x` in the permissions column.

Why /bin.

Unix convention from the 1970s. The folder where executables lived was named `bin`, short for "binaries." The convention spread and split.

`/bin` holds the essential commands the machine needs even in recovery mode (`ls`, `cat`, `sh`).

`/usr/bin` holds the bulk of the system commands shipped with the OS.

`/usr/local/bin` holds things you, the user, installed on top of the OS.

`/opt/homebrew/bin` is Homebrew''s folder on Apple Silicon. On Intel Macs it is `/usr/local/bin`.

`node_modules/.bin` holds the project-local executables npm drops into a project when you `npm install`.

None of this has any technical force. There is no law that says executables must live in `bin`. It is convention, and the convention works because everyone follows it and `PATH` is configured to point at those folders.

What `npm run dev` actually does, end to end.

Shell reads `npm run dev`. Splits into command plus args.

Shell walks `PATH`. Finds an executable named `npm` (usually `/opt/homebrew/bin/npm`, which is a symlink to a Node script in npm''s install location).

Shell runs it, handing it `run dev` as arguments.

The `npm` program opens `package.json` in the current directory, finds `scripts.dev` (in this repo: `npm run db:build && vite`).

Before running that, npm prepends `node_modules/.bin` to `PATH` for the child process. That is why `vite` is findable even though it is not installed globally. `vite` lives in `node_modules/.bin/vite`, and the temporary `PATH` extension makes the shell find it there.

Each command runs in order. `vite` boots a dev server on port 4747.

The thing to internalize. There is nothing special about `npm`. It is a file. The shell found it by walking a list. Every command you type works the same way.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (17, 'shell',             'the program that reads your terminal input and runs commands; zsh is the macOS default'),
  (17, 'zsh',               'Z shell; the default interactive shell on modern macOS, successor to bash for the user-facing prompt'),
  (17, 'command',           'the first whitespace-separated token of a shell line; the name of the program the shell should run'),
  (17, 'argument',          'the remaining tokens after the command; values passed to the program when it starts'),
  (17, 'environment variable', 'a named value attached to your shell session and inherited by every program the shell launches'),
  (17, 'PATH',              'a colon-separated environment variable listing the directories the shell searches for a command'),
  (17, 'which',             'a command that prints the full path of the file the shell would run for a given name'),
  (17, 'binary',            'an executable file; originally meant compiled machine code, now used loosely for any runnable file'),
  (17, 'executable bit',    'the `x` permission flag on a file that tells the OS the file is allowed to be run'),
  (17, '/bin',              'directory for essential system commands needed even in single-user recovery mode'),
  (17, '/usr/bin',          'directory for the bulk of system commands shipped with the operating system'),
  (17, '/usr/local/bin',    'directory for executables installed by the user on top of the base OS'),
  (17, '/opt/homebrew/bin', 'Homebrew''s install directory for binaries on Apple Silicon Macs (/usr/local/bin on Intel)'),
  (17, 'node_modules/.bin', 'directory of project-local executables npm prepends to PATH when running a package.json script'),
  (17, 'symlink',           'a file that points at another file; running the symlink transparently runs the target'),
  (17, 'convention',        'a habit everyone follows that has no technical enforcement but works because adoption is universal'),
  (17, 'package.json scripts', 'named shortcuts in a Node project, run via `npm run <name>`, with node_modules/.bin temporarily on PATH');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(18, '2026-06-07', 2, 'Why does npm run dev work, but typing `vite` directly does nothing, while `npm run db:build` works because it ends up running `node scripts/build-db.mjs`?',
'The asymmetry you noticed is the whole point of how `npm run` works.

When you type `npm run db:build`, the script is `node scripts/build-db.mjs`. `node` is a globally installed binary that lives somewhere on your normal PATH. Run `which node` and you will probably see `/opt/homebrew/bin/node`. The shell finds it the same way it found `npm`. So that script runs fine even though it is started by npm.

When you type `npm run dev`, the script is `npm run db:build && vite`. `vite` is not globally installed. Look at `package.json`. `vite` is in `devDependencies`. `npm install` dropped it into the project''s own folder at `node_modules/.bin/vite`. That folder is not on your normal PATH.

So why does `vite` work inside the `dev` script but not when you type it bare?

Because `npm run` does one specific thing before executing a script: it prepends `node_modules/.bin` to PATH for the duration of that child process. While the `dev` script is running, the shell looking up `vite` finds it in `node_modules/.bin`. The moment the script ends, that PATH change disappears.

Your interactive terminal does not have `node_modules/.bin` on its PATH. So when you type `vite`, the shell walks `/opt/homebrew/bin`, `/usr/local/bin`, `/usr/bin`, `/bin`, finds nothing, and you get either `zsh: command not found: vite` or, depending on your terminal, nothing visible. That is the "nothing happens." Confirm it with `which vite` from your bare shell. It will print nothing.

Three ways to run `vite` directly if you want to.

`npx vite`. `npx` is a small helper that does the same PATH trick for one command. It is the standard way to run a project-local executable from your shell.

`./node_modules/.bin/vite`. Spell out the path explicitly. The shell does not need PATH if you tell it exactly where the file is.

`npm install -g vite`. Install vite globally so it lands somewhere on your normal PATH. Almost nobody does this. The project-local install is the convention because it pins the version per project.

The mental model worth keeping.

PATH is a search list, not a database. Two terminals on the same machine can see different commands because their PATHs differ. `npm run` temporarily augments PATH for its child process. Your interactive shell never sees that augmentation. Same machine, same `vite` file on disk, two different outcomes, because PATH was different in each case.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (18, 'project-local executable', 'a binary installed by npm into node_modules/.bin, available only when invoked through `npm run` or `npx`, not from a bare shell'),
  (18, 'globally installed',       'a binary installed into a directory already on your normal PATH (often via Homebrew or `npm install -g`), runnable from any shell'),
  (18, 'devDependency',            'a package listed in package.json that is needed for development or build (linters, bundlers, type checkers) but not at runtime in production'),
  (18, 'npx',                      'small helper shipped with npm that prepends node_modules/.bin to PATH for a single command, then exits'),
  (18, 'child process',            'a program launched by another program; inherits a copy of the parent''s environment, including PATH, that the parent can modify before launch'),
  (18, 'command not found',        'shell error printed when no file matching the typed command name is found in any PATH directory'),
  (18, 'version pinning',          'installing a tool locally to a project so the project always uses an exact version, independent of what is installed globally on the machine');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(19, '2026-06-07', 3, 'What is binding in the context of network interfaces? Why does [::1]:4747 work but 127.0.0.1:4747 not serve anything? Is it because my system is modern and using IPv6?',
'A server does not magically receive packets. It has to tell the OS, "When a packet arrives for this IP and this port, hand it to me." That request is called binding. The OS records the (address, port) pair against your process. Only one process can hold a given (address, port) at a time. That is what `EADDRINUSE` means when you see it.

So when Vite "listens on port 4747," it is asking the OS to bind some IP plus 4747 to the Vite process. The IP is the part that matters here.

Why [::1]:4747 works but 127.0.0.1:4747 does not.

`127.0.0.1` and `::1` are two separate addresses in two separate families (IPv4 and IPv6). Both mean "this machine," both are loopback, but the OS treats them as distinct, like two doors on the same room with different keys. A bind to one is not a bind to the other.

What is happening on this machine specifically, confirmed by inspection.

`/etc/hosts` has both lines: `127.0.0.1 localhost` and `::1 localhost`.

Node''s default DNS result order is `verbatim` (Node 17+ default).

`dns.lookup("localhost", {all: true})` on this machine returns `::1` first, then `127.0.0.1`.

Vite, with no `server.host` set in vite.config.ts, listens on `localhost`. Node picks the first lookup result, which is `::1`, and binds only there.

Result. `[::1]:4747` reaches the server. `127.0.0.1:4747` hits an unbound address and the OS replies "connection refused."

The intuition that it is "because the system is modern" is correct. The cause is the combination of modern Node, modern macOS, and IPv6-first localhost resolution. IPv4 did not stop working. Vite never bound to it.

How to fix it if you want both addresses to work.

Add `host: true` to the server config in vite.config.ts. That tells Vite to bind every interface, IPv4 and IPv6, which also exposes the dev server to your LAN.

```
server: { port: 4747, strictPort: true, host: true }
```

Or force IPv4 only with `host: "127.0.0.1"`. Or leave the config alone and use `localhost:4747` or `[::1]:4747` in the browser, both of which work right now.

The mental model. Binding is the act of claiming an address. The address is more specific than "the machine." Two addresses on the same machine are still two addresses, and a bind goes to exactly the one you name.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (19, 'binding',           'asking the OS to deliver packets for a specific (IP, port) pair to your process'),
  (19, 'loopback',          'addresses that route back to the same machine without ever touching a real network (127.0.0.1 for IPv4, ::1 for IPv6)'),
  (19, '::1',               'the IPv6 loopback address; the IPv6 equivalent of 127.0.0.1'),
  (19, 'address family',    'the kind of address being used (AF_INET for IPv4, AF_INET6 for IPv6); sockets are typed by family and a bind to one is not a bind to the other'),
  (19, 'connection refused','OS error returned when nothing is bound to the (IP, port) you tried to connect to'),
  (19, 'verbatim DNS order','Node 17+ default behavior of returning DNS results in OS-given order rather than IPv4-first; causes localhost to resolve to ::1 first on modern macOS'),
  (19, 'getaddrinfo',       'the POSIX function that turns a hostname like "localhost" into a list of IP addresses; the engine behind every DNS lookup'),
  (19, 'EADDRINUSE',        'error returned by bind() when something else already holds that (IP, port) pair');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(20, '2026-06-07', 4, 'What is IPv4, what is IPv6, what is the difference?',
'IPv4 and IPv6 are two versions of the Internet Protocol, the addressing system every packet on the internet uses. They serve the same purpose. The practical differences are address size, notation, and a few feature changes.

IPv4 (1981). Addresses are 32 bits, written as four decimal octets separated by dots.

```
127.0.0.1
192.168.1.74
142.250.190.78
```

32 bits gives about 4.3 billion addresses. The internet ran out of fresh IPv4 addresses years ago. NAT and ISP-level address sharing are the band-aids that kept it going.

IPv6 (1998). Addresses are 128 bits, written as eight groups of four hex digits separated by colons.

```
::1
fe80::1c2a:bff:fe8c:1234
2606:4700:4700::1111
```

128 bits is about 3.4 times 10 to the 38th addresses. Practically infinite.

Notation shortcuts in IPv6.

Leading zeros in a group can be dropped. `0001` becomes `1`.

Exactly one run of all-zero groups can be replaced with `::`. So `0:0:0:0:0:0:0:1` becomes `::1`, and `2001:0db8:0000:0000:0000:0000:0000:0001` becomes `2001:db8::1`. Only one `::` per address, because otherwise the expansion would be ambiguous.

In URLs the address is wrapped in square brackets so the colons in the address do not collide with the port separator. `http://[::1]:4747` parses as host `::1`, port `4747`. The brackets are required, not optional. That is why `[::1]:4747` looks different from `127.0.0.1:4747` in your browser bar.

Equivalences worth memorizing.

IPv4 `127.0.0.1` equals IPv6 `::1`. Both mean loopback (this machine).

IPv4 `0.0.0.0` equals IPv6 `::`. Both mean wildcard (bind every interface).

IPv4 private ranges (`10.x`, `172.16-31.x`, `192.168.x`) roughly correspond to IPv6 ULA (`fc00::/7`) and link-local (`fe80::/10`) ranges.

IPv4 broadcast (`255.255.255.255`) has no IPv6 equivalent; IPv6 dropped broadcast and uses multicast for those use cases.

What actually changed in IPv6 beyond size.

Bigger address space (the main thing).

Mandatory link-local addresses. Every interface always has an IPv6 address it generated for itself, even without DHCP.

Stateless address autoconfiguration (SLAAC). Devices can self-assign a routable IPv6 address based on router advertisements, without a DHCP server.

No broadcast. Multicast handles all "to many" cases.

Simpler header at the packet level (fewer optional fields, easier to process at line rate).

Day-to-day reality. Both run side by side on every modern machine. Apps mostly do not care. They call `getaddrinfo("example.com")` and use whatever comes back. The places it actually matters in practice: configs that hardcode `127.0.0.1` (might not match a server bound to `::1`), the URL bracket rule, and debugging "why does my server only answer on one of them" (you are here).');

INSERT INTO vocab (entry_id, term, def) VALUES
  (20, 'IPv4',              'the original Internet Protocol; 32-bit addresses written as four decimal octets (127.0.0.1)'),
  (20, 'IPv6',              'the successor protocol; 128-bit addresses written as eight hex groups separated by colons (2606:4700:4700::1111)'),
  (20, 'octet',              'an 8-bit group; in IPv4 addresses the four decimal numbers between the dots'),
  (20, 'NAT',               'Network Address Translation; lets many private devices share one public IPv4 address by rewriting addresses at the router'),
  (20, 'private address',   'an IP range reserved for internal networks and not routable on the public internet (10.x, 172.16-31.x, 192.168.x for IPv4)'),
  (20, 'link-local',        'addresses valid only on the directly attached network segment; IPv6 fe80::/10 is auto-assigned to every interface'),
  (20, 'ULA',               'Unique Local Address; IPv6 fc00::/7 range, the IPv6 analog of IPv4 private addresses'),
  (20, 'multicast',         'sending one packet to a group of interested receivers; IPv6 uses it in place of broadcast'),
  (20, 'broadcast',         'IPv4 packet delivered to every host on a local segment; address 255.255.255.255 or the subnet broadcast'),
  (20, 'SLAAC',             'Stateless Address Autoconfiguration; IPv6 mechanism letting hosts self-assign routable addresses from router advertisements, no DHCP needed'),
  (20, '[::1]:port',        'URL notation for an IPv6 host and a port; the brackets disambiguate the colons inside the address from the port separator');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(21, '2026-06-07', 5, 'What is en0?',
'`en0` is the name macOS gave to one specific network interface on your machine.

A network interface is a piece of hardware (or virtual hardware) that can send and receive packets. Your laptop has several at once: the Wi-Fi card, Ethernet (if a dongle is plugged in), Bluetooth, Thunderbolt networking, the virtual loopback interface, VPN tunnels. The OS gives each one a name so you can refer to it.

The macOS naming convention.

`lo0` is loopback. The virtual "this machine" interface. `127.0.0.1` and `::1` both live on `lo0`.

`en0` is the first Ethernet/Wi-Fi interface. On Apple Silicon Macs without a built-in Ethernet port, `en0` is the Wi-Fi card. The `en` is short for "Ethernet," a holdover from when the first interface really was Ethernet.

`en1`, `en2`, and so on are additional interfaces. A second Wi-Fi, an Ethernet dongle, a USB network adapter.

`awdl0` is Apple Wireless Direct Link, used by AirDrop and Continuity.

`utun0`, `utun1`, and so on are VPN tunnels.

`bridge0`, `vmenet0` are virtual bridges set up by Docker, Parallels, VMware Fusion, and similar.

Other operating systems have different conventions. Linux uses `eth0`, `wlan0`, or systemd''s deterministic names like `enp0s31f6`. Windows uses friendly names like "Wi-Fi 2."

How this ties back to binding and loopback.

Binding to `127.0.0.1` binds to `lo0`.

Binding to your LAN address (whatever `ifconfig en0 | grep "inet "` shows) binds to `en0`.

Binding to `0.0.0.0` binds to all of them at once.

That is what `host: true` in Vite does. Vite listens on `lo0` AND `en0` (AND every other interface), so devices on the same Wi-Fi can reach the dev server at `http://192.168.x.x:4747`.

Try it. Run `ifconfig en0 | grep inet`. You will see your local IPv4 address on Wi-Fi plus one or two IPv6 addresses starting with `fe80::`. Those are the addresses currently bound to `en0`.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (21, 'network interface', 'a physical or virtual device the OS uses to send and receive packets; every machine has several at once'),
  (21, 'lo0',               'macOS loopback interface; carries 127.0.0.1 and ::1, the addresses that mean "this machine"'),
  (21, 'en0',               'macOS first Ethernet/Wi-Fi interface; on Apple Silicon laptops this is the Wi-Fi card'),
  (21, 'awdl0',             'Apple Wireless Direct Link interface; used by AirDrop, AirPlay, Continuity'),
  (21, 'utunN',             'macOS virtual interface for a VPN tunnel; appears when a VPN client is connected'),
  (21, 'bridge0',           'virtual bridge interface used by Docker, Parallels, and similar to connect VM/container networks'),
  (21, 'MAC address',       'hardware identifier burned into a network interface, 48 bits, shown by ifconfig on the `ether` line'),
  (21, 'interface name',    'the OS-assigned short string (en0, eth0, wlan0) used in commands and config to refer to a specific network interface');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(22, '2026-06-07', 6, 'What is ifconfig and what is ipconfig?',
'Both are command-line tools for inspecting and configuring network interfaces. The names look like cousins because the jobs overlap. They belong to different operating systems.

`ifconfig`. Unix tool, short for "interface configuration." Originally from BSD in the early 1980s. Lives on macOS, the BSDs, and (deprecated, often not installed by default) on older Linux. Prints every network interface and its current state: IP addresses, MAC address, link status, packet counters, MTU.

`ipconfig`. Windows tool, short for "IP configuration." Not a Unix command. Microsoft built their own equivalent. `ipconfig /all` is the verbose form, showing DNS servers, lease times, gateway, the lot.

`ip`. The modern Linux replacement for ifconfig. On most current Linux distros, ifconfig has been removed from the default install. You use `ip addr`, `ip link`, `ip route` instead. The newer tool covers more cases (multiple addresses per interface, network namespaces, policy routing).

The macOS confusion.

macOS ships both `ifconfig` (the BSD one, the real workhorse) and a small program also called `ipconfig` that is Apple-specific and totally different from the Windows tool. Apple''s `ipconfig` is mostly a DHCP query helper, not a general configuration tool. So on a Mac, two commands with names that look similar do very different jobs.

What you actually use on macOS day-to-day.

`ifconfig`. List every interface.

`ifconfig en0`. Limit to the Wi-Fi interface.

`ifconfig en0 | grep "inet "`. Just the IPv4 address bound to Wi-Fi.

`ipconfig getifaddr en0`. Apple''s shortcut to print only the IPv4 of `en0`. Convenient in scripts because the output is clean (one line, just the address).

`netstat -i`. List of all interfaces with packet counts and error counters. Useful for quick "is this interface getting traffic" checks.

`route -n get default`. Show the default route (which interface and gateway the OS sends internet-bound packets through).

The mnemonic. `if` for "interface" (Unix), `ip` for "IP" (Windows). Modern Linux moved on to plain `ip`. macOS has both names with overlapping but distinct roles, which is why people get confused.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (22, 'ifconfig',          'BSD/Unix command (also on macOS) that prints and configures network interfaces; the workhorse on macOS'),
  (22, 'ipconfig (Windows)','Microsoft command that prints IP, gateway, DNS per adapter; `ipconfig /all` is the verbose form'),
  (22, 'ipconfig (macOS)',  'Apple-specific small tool mostly for querying DHCP state; has the same name as the Windows command but does much less'),
  (22, 'ip (Linux)',        'modern Linux replacement for ifconfig: ip addr / ip link / ip route; covers namespaces and policy routing'),
  (22, 'MTU',               'Maximum Transmission Unit; the largest packet size an interface will send without fragmenting (usually 1500 for Ethernet)'),
  (22, 'netstat',           'classic Unix command for printing network state: connections, interface counters, routing tables'),
  (22, 'route',             'command that prints or modifies the routing table; `route -n get default` on macOS shows where internet packets go'),
  (22, 'DHCP',              'Dynamic Host Configuration Protocol; how a device asks the network for an IP address, subnet mask, gateway, and DNS server');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(23, '2026-06-07', 7, 'I ran `cat /opt/homebrew/bin/npm` and got the shim that says `require("../lib/cli.js")`. So I ran `cat /opt/homebrew/lib/cli.js` and it failed. Why? (Also: why did the second `cat` print a directory listing?)',
'You went two slightly different wrong places at once. Both are worth pulling apart.

The directory listing was not the output of `cat`.

`cat` would never print a column of names like that. What you saw was zsh''s tab-completion menu, rendered inline between your prompts. Tells:

Trailing `/` on every directory name (`Applications/`, `Movies/`). zsh adds those as visual hints in completion lists. They are not part of the filename.

Trailing `*` on `drop_and_rebuild_db.sh*` and `keep_alive.sh*`. That marks executable files. Another zsh hint.

Escaped space in `Into\ The\ Void.logicx/`. Completion always emits the form you would need to type.

The set of items matches `~`, and the prompt segment `~ %` confirms your CWD is home.

The likely cause: Tab fired while editing the line. zsh saw an ambiguous word in the second argument position and listed every candidate from your CWD. Either you hit Enter through the menu or saw it between actual command runs. The real `cat /opt/homebrew/bin/npm` would have produced the same two-line shim as the first invocation.

Mitigation: if you ever suspect the terminal injected something, run `cat /opt/homebrew/bin/npm | cat -A`. The pager-style output cannot have a tab menu interleaved.

Why `/opt/homebrew/lib/cli.js` does not exist.

Two compounding things, both of which are general lessons.

First. Relative paths in `require` resolve from the script''s own directory, not your shell''s CWD and not the literal directory of the path you typed in `which`. When the shim contains `require("../lib/cli.js")`, the `..` is relative to the directory of the file doing the require.

Second. `/opt/homebrew/bin/npm` is a symlink. Node resolves the real path first, then resolves `..` from there. Confirmed on this machine:

```
/opt/homebrew/bin/npm  ->  /opt/homebrew/Cellar/node/23.11.0/bin/npm
which points to:
/opt/homebrew/lib/node_modules/npm/bin/npm-cli.js
```

So when Node executes the shim, the real file lives at `/opt/homebrew/lib/node_modules/npm/bin/npm-cli.js`. The `..` in `require("../lib/cli.js")` resolves relative to that file''s directory:

```
/opt/homebrew/lib/node_modules/npm/bin/      ← real file dir
        ..  →  /opt/homebrew/lib/node_modules/npm/
                                          + lib/cli.js
                                                ↓
/opt/homebrew/lib/node_modules/npm/lib/cli.js   ← the actual file
```

That file exists. The path you tried (`/opt/homebrew/lib/cli.js`) was `/opt/homebrew/bin/`''s parent plus `lib/cli.js`, which is a Homebrew shared-library directory, not where Node packages live.

To reproduce cleanly:

```
realpath /opt/homebrew/bin/npm
cat "$(realpath /opt/homebrew/bin/npm)"
ls "$(dirname "$(realpath /opt/homebrew/bin/npm)")/../lib/cli.js"
```

The last one prints a real file size, confirming the path resolves.

Two concepts to bank.

Symlinks change where "here" is for the file being run. A symlink install style (Homebrew, npm globals, asdf, mise) puts a tiny pointer on your PATH, but the program runs from its real location. Anything the script does with relative paths is anchored to that real location.

`..` in source code is relative to the source file, not to you. Your CWD does not matter. The directory you typed in `which` does not matter. Only the location of the file containing the `..` matters, and after symlink resolution it may not be where you started looking.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (23, 'symlink',           'a small filesystem entry that points to another path; reading or executing it transparently uses the target'),
  (23, 'realpath',          'the absolute, symlink-resolved path of a file; `realpath FOO` prints where FOO actually lives'),
  (23, 'shim',              'a small wrapper file that exists mainly to call into another file; the npm shim is two lines that require the real CLI'),
  (23, 'require (Node)',    'Node''s function for loading another file; relative paths in require resolve from the directory of the file containing the call'),
  (23, 'CWD',               'Current Working Directory; the directory the shell or process considers "here"; relative paths in commands resolve from CWD'),
  (23, 'tab completion',    'shell feature that lists or fills in candidates when Tab is pressed; in zsh, directories get a trailing / and executables get a trailing *'),
  (23, 'zsh list types',    'zsh option that decorates completion menus: / for dirs, * for executables, @ for symlinks, = for sockets, | for FIFOs'),
  (23, 'Homebrew Cellar',   '/opt/homebrew/Cellar; the directory where Homebrew installs each formula''s real files; everything in /opt/homebrew/bin links into here'),
  (23, 'cat -A',            'cat flag that makes invisible characters visible (tabs as ^I, line endings as $); useful for sanity-checking what is really in a file or pasted'),
  (23, 'sneaky tab menu',   'when a completion menu shows in your terminal output mid-paste and you mistake it for command output; pipe through cat or less to defeat it');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(24, '2026-06-07', 8, 'What is a regular expression?',
'A regular expression, or regex, is a tiny language for describing patterns in text. You hand a regex to a program and ask either "find every place in this text that matches" or "does the whole string match." Used everywhere: editor search-and-replace, grep, form validation, log parsing, web framework route matching, find arguments.

The vocabulary is small but every character is doing real work. That density is the reason regex is powerful and the reason it looks unreadable.

The basic moves.

Literal characters match themselves. `cat` matches the string `cat`.

Metacharacters mean something other than themselves.

`.` any one character.

`*` zero or more of the previous thing.

`+` one or more.

`?` zero or one (optional).

`^` start of string or line.

`$` end of string or line.

`[abc]` any one of a, b, c.

`[^abc]` any character except those.

`[a-z]` range.

`\d`, `\w`, `\s` digit, word character (letter/digit/_), whitespace.

`\D`, `\W`, `\S` their negations.

`()` group.

`|` OR (`cat|dog`).

`{3,5}` between 3 and 5 of the previous thing.

`\` escape; take the next metacharacter literally (`\.` matches a literal period).

Worked examples.

`^\d{3}-\d{4}$` matches a US phone like `555-1234`, anchored to the whole string.

`\bemail\b` matches the word "email" with word boundaries on both sides. Matches "send email now" but not "emails".

`https?://\S+` matches `http`, optional `s`, `://`, then non-whitespace. Crude URL matcher.

`[A-Z][a-z]+` matches a capitalized word.

Capture groups.

Parens do two jobs: bundle part of the pattern, and remember the matched text so you can refer to it later. `(\d{4})-(\d{2})-(\d{2})` on `2026-06-07` captures `2026`, `06`, `07` as groups 1, 2, 3, usable in replacements. In most tools `$1/$2/$3` would rewrite the match to `2026/06/07`.

Greedy vs lazy.

`*` and `+` are greedy by default. They grab as much as possible. `.*"` on `"hello" said "world"` matches everything up to the last `"`. Add `?` to flip to lazy: `.*?"` takes the smallest match. Classic gotcha when writing a "match a quoted string" regex that swallows too much.

Flavors.

There is no single regex language. Each tool has its own dialect.

POSIX BRE is grep''s default. Many metacharacters need backslashes to activate (`\(`, `\+`, `\{`).

POSIX ERE is `grep -E` (or `egrep`). Metacharacters work bare. Closer to what most other languages use.

PCRE (Perl-Compatible Regular Expressions) is the rich, modern flavor used by JavaScript, Python''s `re`, PHP, ripgrep, and most editors.

Each language layers extras on top: lookahead `(?=...)`, named groups `(?<year>\d{4})`, Unicode property classes `\p{L}`.

Day-to-day on this machine.

Terminal: `grep -E "pattern" file`, or `rg "pattern"` if ripgrep is installed (much faster on large trees).

Editors: search-and-replace dialogs almost all have a "regex" toggle.

JavaScript: `/pattern/flags` literal syntax, e.g. `/^\d+$/.test(input)`.

Build tools and routers: route matching, file globs, lint rule selectors.

The skill.

You do not have to memorize the grammar. The 80% pattern is: literals, character classes (`[a-z]`, `\d`), quantifiers (`*`, `+`, `?`, `{n,m}`), anchors (`^`, `$`), groups (`()`), and OR (`|`). Look the rest up.

One warning.

Do not parse HTML, JSON, or any language with nested structure using regex. Formally, regex cannot count matched brackets. Modern engines have extensions that sometimes appear to work, but the failure modes are nasty. Use a real parser.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (24, 'regex',             'short for regular expression; a pattern language for matching and extracting text'),
  (24, 'metacharacter',     'a character in a regex that means something other than itself (`.`, `*`, `+`, `?`, `^`, `$`, etc.)'),
  (24, 'character class',   'square-bracket construct that matches any one character from a set, e.g. `[a-z0-9]` or `[^abc]`'),
  (24, 'quantifier',        'regex operator controlling repetition (`*`, `+`, `?`, `{n,m}`)'),
  (24, 'anchor',            'regex token that matches a position rather than a character (`^` start, `$` end, `\b` word boundary)'),
  (24, 'capture group',     'parens in a regex that bundle a sub-pattern and remember the matched text for backreferences and replacements'),
  (24, 'greedy / lazy',     'greedy quantifiers grab as much as possible; lazy (`*?`, `+?`) grab as little as possible; flip with a trailing `?`'),
  (24, 'POSIX BRE',         'Basic Regular Expressions; grep''s default flavor; many metacharacters need a backslash to activate'),
  (24, 'POSIX ERE',         'Extended Regular Expressions; `grep -E` and `egrep`; metacharacters work bare; closer to modern flavors'),
  (24, 'PCRE',              'Perl-Compatible Regular Expressions; the rich modern flavor; supported by JavaScript, Python, ripgrep, most editors'),
  (24, 'lookahead',         'zero-width assertion `(?=...)` that requires what follows to match but does not consume characters'),
  (24, 'word boundary',     '`\b` anchor that matches between a word character and a non-word character; used to match whole words'),
  (24, 'ripgrep (rg)',      'fast modern grep replacement; defaults to PCRE-style syntax and recursive search; ignores .gitignored files by default');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(25, '2026-06-07', 9, 'What is a compile cache?',
'When a language tool does an expensive "source code into runnable form" step, it does not want to redo that work every run. A compile cache is a folder of on-disk artifacts the tool drops there to skip work on the next run.

The shape is always the same.

The tool reads a source file.

It computes a fingerprint, usually a hash of the file contents plus the compiler version plus the relevant flags.

It looks in the cache directory for an artifact with that fingerprint.

If found, reuse it. Skip compilation.

If not found, compile, store the result keyed by that fingerprint, use it.

The fingerprint is the key. Cache hits are exact-input matches. Change one byte of source, change a flag, change compiler version, and you get a different fingerprint and a full recompile.

Caches you have already used without thinking about it.

Node V8 bytecode cache. `node --experimental-compile-cache` and the `NODE_COMPILE_CACHE` env var (Node 22+). Caches V8''s parsed and compiled bytecode for `.js` files.

TypeScript `.tsbuildinfo`. Incremental compile info; lets `tsc` skip files that did not change.

Vite `node_modules/.vite/`. Pre-bundled dependencies after the first `npm run dev`.

Webpack `node_modules/.cache/webpack/`. Module compilation cache.

Python `__pycache__/`. `.pyc` bytecode files generated next to each `.py`.

Rust `target/`, Go `$GOCACHE`, Gradle `~/.gradle/caches/`. Same idea, different ecosystems.

ccache. The granddaddy general-purpose C and C++ compile cache.

Docker layer cache. Same fingerprinting idea applied to container build steps.

Why this matters in practice. Dev loop speed lives and dies on caches. The first `vite` start is cold; everything has to be built. The second start is warm; cache hits, often five to ten times faster. Same code, same machine, different speed because of the cache. Production builds in CI usually start cold every time, which is why CI is slower than local for the same build command.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (25, 'compile cache',     'a folder of on-disk artifacts a tool consults to avoid redoing expensive compile work on the next run'),
  (25, 'fingerprint',       'a hash of the inputs (source, version, flags) used as the cache key; identical fingerprint = reuse'),
  (25, 'cache hit / miss',  'hit = found in cache, reuse; miss = not found, do the work and store the result'),
  (25, 'incremental compile', 'compiling only the files (or units) that changed since the last build, tracked via a build-info file'),
  (25, '__pycache__',       'Python directory next to source files holding .pyc bytecode caches'),
  (25, '.tsbuildinfo',      'TypeScript incremental build info file; encodes the last successful build state'),
  (25, 'node_modules/.vite','Vite''s dependency pre-bundle cache; recreated on first dev start'),
  (25, 'ccache',            'classic general-purpose compile cache for C/C++ that wraps the compiler invocation'),
  (25, 'V8 compile cache',  'Node''s on-disk cache of V8-compiled JS bytecode, opt-in via --experimental-compile-cache');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(26, '2026-06-07', 10, 'What is it to flush a compile cache?',
'To flush a cache is to delete (or invalidate) the cached artifacts so the next run does the full compile from scratch. People say "flush," "clear," "blow away," "nuke," "bust": all the same idea.

The word comes from plumbing, emptying the pipes so fresh water can fill them. It traveled through CPU pipeline "flushing" and then to anything cache-shaped.

When you flush.

The tool''s fingerprinting missed a change and the cache is serving stale output. Symptom: "I edited X but the running app shows the old behavior."

You changed something the cache cannot detect: upgraded a system library, replaced a tool binary outside the package manager, swapped Node versions without bumping a flag the cache hashes.

You suspect actual cache corruption.

Disk space pressure.

How you flush varies by tool.

Vite: `rm -rf node_modules/.vite`, or `vite --force` which does it for you.

Webpack: `rm -rf node_modules/.cache`.

TypeScript: delete `*.tsbuildinfo`, or `tsc --build --clean`.

Python: `find . -name __pycache__ -exec rm -rf {} +`.

npm package cache: `npm cache clean --force`.

macOS DNS cache: `sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder`.

Node compile cache (if enabled): `rm -rf "$NODE_COMPILE_CACHE"`.

Tools ship "force" flags (`vite --force`, `tsc --build --clean`) so you do not have to know the cache''s on-disk location.

When NOT to flush.

Do not reach for it as the first move when something misbehaves. The cache is rarely the bug; the source usually is. Flushing slows you down (full recompile) and obscures whether the change you made is what fixed the symptom. Flush when symptoms uniquely look like staleness ("file looks right, runtime shows the old thing") or after a tool/Node version upgrade. Otherwise, debug the source first.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (26, 'flush (a cache)',   'delete or invalidate cached artifacts so the next run recomputes them from scratch'),
  (26, 'cache invalidation','marking cached entries unusable, by deletion or version bump, so they get refreshed'),
  (26, 'stale cache',       'cache state that no longer matches the source; runtime behavior diverges from what you edited'),
  (26, 'vite --force',      'Vite flag that forces re-bundling of dependencies, bypassing node_modules/.vite cache'),
  (26, 'tsc --build --clean','TypeScript command that removes outputs and .tsbuildinfo for the project graph'),
  (26, 'dscacheutil -flushcache','macOS command to clear the system DNS resolver cache; usually paired with killall -HUP mDNSResponder'),
  (26, 'npm cache clean',   'command that empties npm''s download/install cache (~/.npm); needs --force in modern npm'),
  (26, 'one of the two hard things', 'reference to Phil Karlton''s quote: "There are only two hard things in CS: cache invalidation and naming things"');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(27, '2026-06-07', 11, 'What is process.argv in the context of Node?',
'When you launch a Node script from the terminal like `node scripts/build-db.mjs --watch input.sql`, Node exposes the full command line as an array of strings on the global `process` object: `process.argv`. The name is from C, where the same array is the second parameter to `main(int argc, char **argv)`: "argument vector."

The layout is always.

`process.argv[0]` is the Node executable path, e.g. `/opt/homebrew/bin/node` (after symlink resolution).

`process.argv[1]` is the script path, e.g. `/Users/brettowers/idkwhatimdoing/scripts/build-db.mjs`.

`process.argv[2..]` are the arguments you passed to your script.

So for the command above:

```
[
  "/opt/homebrew/bin/node",
  "/Users/brettowers/idkwhatimdoing/scripts/build-db.mjs",
  "--watch",
  "input.sql"
]
```

The standard idiom: `const args = process.argv.slice(2)` drops Node and the script path and gives you just your script''s arguments.

```
const args  = process.argv.slice(2);
const watch = args.includes("--watch");
const file  = args.find(a => !a.startsWith("--")) ?? "seed.sql";
```

Companion globals worth knowing.

`process.execArgv` is flags passed to Node itself before the script name (`--inspect`, `--experimental-vm-modules`). Lives separately from `argv`.

`process.env` is environment variables, including `PATH` from the earlier entry.

`process.cwd()` is the working directory of the running process (not the script''s file location).

`import.meta.url` (in ESM) is the URL of the current source file.

Why it matters. `process.argv` is how every CLI built in Node knows what you typed. `vite`, `eslint`, `tsc`, `prettier`: all read it. Most do not parse it by hand; they pull in a library (`yargs`, `commander`, `minimist`, or Node''s built-in `node:util` `parseArgs`).

Tie-back to earlier today.

The npm shim is two lines: `#!/usr/bin/env node` and `require("../lib/cli.js")(process)`. That `(process)` passes the whole `process` object: including `process.argv`: to npm''s real CLI. That is how `npm run dev` parses out "run" and "dev" as arguments; it reads them off `process.argv[2]` and `process.argv[3]`.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (27, 'process.argv',      'array of command-line arguments visible to a Node process; index 0 is node, 1 is the script, 2+ are user args'),
  (27, 'argv',              'argument vector; the C convention for passing command-line args to main(argc, argv); Node inherits the name'),
  (27, 'process.execArgv',  'flags given to Node itself (before the script name) like --inspect or --experimental-vm-modules'),
  (27, 'process.env',       'object of environment variables visible to the Node process; reflects PATH, NODE_ENV, etc.'),
  (27, 'process.cwd()',     'returns the current working directory of the Node process; not necessarily where the script file lives'),
  (27, 'import.meta.url',   'ESM-only; the URL of the current module file, used in place of __filename'),
  (27, 'parseArgs',         'Node''s built-in node:util argument parser; supports long/short options without an extra dependency'),
  (27, 'commander/yargs/minimist', 'popular npm libraries for parsing process.argv into structured CLI options'),
  (27, 'shebang',           'the `#!` line at the top of a script telling the OS which interpreter to use; `#!/usr/bin/env node` for Node scripts');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(28, '2026-06-07', 12, 'What is Baseline browser mapping?',
'Baseline is a standardized label for "is this web feature safe to use across modern browsers?" Launched by Google with the W3C and the major browser makers in 2023 to give a single official answer to a question developers had been asking caniuse.com one feature at a time for years.

The label has three levels.

Limited availability. Shipped in some engines, not all yet.

Baseline: Newly available. Just landed in stable versions of all four major engine families: Chromium (Chrome, Edge), WebKit (Safari), Gecko (Firefox), plus the related engine variants. Safe for current users on up-to-date browsers.

Baseline: Widely available. Has been newly available for 30 months without regressions. Long enough that the older browsers still in active use have caught up. Safe for almost any production app.

The mapping in "baseline browser mapping" is the concrete table linking each Baseline label to specific browser versions. "Baseline 2024 Widely Available" expands to something like Chrome 105+, Firefox 105+, Safari 16+, Edge 105+: particular versions, frozen at a point in time.

Where you encounter it.

caniuse.com and MDN show a Baseline badge on each feature page.

Browserslist (the config Vite, PostCSS, and Babel use to decide which browsers to compile for) added Baseline queries: `"baseline widely available"`, `"baseline 2024"`, `"baseline newly available"`. The tool translates that string into the specific version list at build time.

web.dev and the `web-features` npm package publish the data file the mapping reads from.

Why it matters in your build. A tool like Vite picks "which features can I emit raw vs. transpile" based on the target browser set. Saying "target Baseline 2024 Widely Available" instead of `last 2 versions` makes that intent declarative and standards-aligned instead of a magic version list that drifts over time.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (28, 'Baseline',           'web platform classification (Limited, Newly, Widely) telling you whether a feature is safe to use across modern browsers'),
  (28, 'Baseline Newly Available', 'a feature just landed in stable releases of all four major browser engine families'),
  (28, 'Baseline Widely Available', 'has been newly available for 30 months without regression; safe for nearly all production apps'),
  (28, 'browser engine',     'the underlying rendering and JS engine in a browser; Chromium uses Blink+V8, Safari uses WebKit+JSC, Firefox uses Gecko+SpiderMonkey'),
  (28, 'Browserslist',       'config language (in package.json or .browserslistrc) listing target browsers; consumed by Autoprefixer, Babel, Vite, esbuild'),
  (28, 'baseline-2024 query','Browserslist query that translates to the specific browser versions in the Baseline 2024 set'),
  (28, 'web-features',       'npm package and data file published by the Baseline initiative; canonical source for feature classifications'),
  (28, 'caniuse.com',        'community-maintained compatibility tables; Baseline status is now shown alongside per-browser support data');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(29, '2026-06-07', 13, 'What is nanoid?',
'`nanoid` is a tiny JavaScript library for generating unique IDs: the same job as UUIDs, smaller and faster. "nano" for small.

A default nanoid is a 21-character string built from a 64-character URL-safe alphabet (`A-Za-z0-9_-`), e.g. `V1StGXR8_Z5jdHi6B-myT`. 21 characters times about 6 bits each is roughly 126 bits of randomness: collision-resistant for billions of IDs.

Why people pick it over UUID v4.

Shorter: 21 characters vs 36 for `550e8400-e29b-41d4-a716-446655440000`.

URL-safe: no dashes-as-separators or special chars; drop straight into a URL with no encoding step.

Faster: smaller library, around 130 bytes minified, very tight implementation.

Customizable: pick alphabet and length. `nanoid(10)` gives a 10-character ID; `customAlphabet("0123456789", 6)()` gives a 6-digit numeric code.

Usage.

```
import { nanoid } from "nanoid";
nanoid();    // "V1StGXR8_Z5jdHi6B-myT"
nanoid(10);  // "IRFa-VaY2b"
```

Common uses. Database primary keys, URL slugs (Notion''s URL suffixes are nanoid-shaped), session tokens, ephemeral cache keys: anywhere you want unique, hard-to-guess, and short to read.

You almost certainly see nanoid in your dependency tree because Vite uses it internally for module IDs, HMR update IDs, and chunk hashes. Many other tools depend on it transitively too.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (29, 'nanoid',             'tiny JS library generating unique URL-safe IDs; default 21 chars from a 64-char alphabet'),
  (29, 'UUID',               'Universally Unique Identifier; 128-bit value typically rendered as 36 chars with dashes; v4 is fully random'),
  (29, 'collision resistance','property that the chance of two generated IDs being identical is negligibly small'),
  (29, 'URL-safe alphabet',  'characters that need no percent-encoding in URLs: A-Z, a-z, 0-9, dash, underscore'),
  (29, 'entropy (in IDs)',   'amount of randomness in an identifier, measured in bits; more bits means lower collision probability'),
  (29, 'customAlphabet',     'nanoid helper that builds an ID generator with your own character set and length'),
  (29, 'HMR',                'Hot Module Replacement; the dev-server mechanism that swaps changed modules without a full page reload');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(30, '2026-06-07', 14, 'What is update-browserslist-db?',
'A small npm CLI maintained by the Browserslist project that updates the `caniuse-lite` data file inside your `node_modules`, in place, without touching `package.json` or the lockfile.

Background. Browserslist tools (Vite, PostCSS Autoprefixer, Babel) consult `caniuse-lite`, a snapshot of the caniuse.com database, to decide which CSS features need vendor prefixes, which JS features need polyfills, and so on. `caniuse-lite` ships as a regular npm package with a pinned version. Browser usage data changes constantly, though, and a few months after `npm install` your snapshot is stale. The tools start printing:

```
Browserslist: caniuse-lite is outdated. Please run:
  npx update-browserslist-db@latest
```

That command does exactly one thing: bumps `caniuse-lite` inside `node_modules` to the latest published version. The lockfile constraint stays the same; just the data is refreshed.

Why this is not handled by a regular `npm update`.

`caniuse-lite` is locked to a semver range like `^1.0.30001500`. `npm update` pulls newer patch versions only within that range. The data file''s update cadence outpaces that. Semver-style updates are not aggressive enough to keep usage data current, so `update-browserslist-db` ignores the normal semver gates and grabs the newest version directly.

You run it when the warning appears, or once every couple of months on a serious project. It is safe: it only affects the data file driving target-browser decisions, not any code.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (30, 'update-browserslist-db', 'npm CLI that updates caniuse-lite in place inside node_modules, bypassing the normal semver constraints'),
  (30, 'caniuse-lite',        'npm package containing a periodic snapshot of caniuse.com browser-support data; consumed by Browserslist tools'),
  (30, 'Autoprefixer',        'PostCSS plugin that adds vendor prefixes to CSS rules based on the Browserslist target set'),
  (30, 'semver range',        'a version constraint in package.json (^1.2.3, ~1.2.3) that npm uses to decide which versions are acceptable on update'),
  (30, 'lockfile',            'package-lock.json or yarn.lock; pins the exact versions installed across machines so installs are reproducible'),
  (30, 'polyfill',            'a piece of JS that implements a newer API on browsers that lack it natively, so app code can use the modern API uniformly'),
  (30, 'vendor prefix',       'browser-specific CSS prefix (-webkit-, -moz-) used for non-standard or pre-standardization features');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(31, '2026-06-07', 15, 'What is a favicon?',
'The little icon next to the page title in the browser tab, bookmarks, history, and home-screen shortcuts. "favicon" is short for "favorites icon," coined in 1999 by Microsoft for the IE Favorites menu.

The classic location is a file at `/favicon.ico` at the site root. Browsers auto-request that path whenever they load any page on the domain, even without an HTML tag asking for it. That auto-request still works as a fallback today.

Modern sites declare multiple icons via `<link>` tags in `<head>`:

```
<link rel="icon" href="/favicon.svg" type="image/svg+xml">
<link rel="icon" href="/favicon-32.png" sizes="32x32">
<link rel="apple-touch-icon" href="/apple-touch-icon.png" sizes="180x180">
```

Why so many.

`.ico` is a Microsoft format that can pack multiple sizes in one file; old browsers fetch it by default.

SVG scales infinitely and can be dark-mode-aware via `@media (prefers-color-scheme: dark)` inside the SVG.

`apple-touch-icon.png` is what iOS Safari uses when someone taps "Add to Home Screen."

`site.webmanifest` is the Android/PWA file listing icon variants.

Browser tab UI typically renders favicons at 16x16 or 32x32. Home-screen shortcuts want 180x180 or larger.

If your site has no favicon, browsers either show a blank/default icon or a 404 appears in the network panel. Minor but it looks unfinished and the request happens on every page load.

Cheapest right move for a small site: one SVG favicon plus one 180x180 PNG for apple-touch. Done.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (31, 'favicon',            'small icon shown in browser tabs, bookmarks, and home-screen shortcuts; auto-fetched from /favicon.ico by default'),
  (31, '.ico format',        'Microsoft icon format that can store multiple sizes in one file; still served as the default favicon for compatibility'),
  (31, 'apple-touch-icon',   'iOS Safari''s home-screen icon, declared via `<link rel="apple-touch-icon">`; usually 180x180 PNG'),
  (31, 'site.webmanifest',   'JSON manifest file for Progressive Web Apps; lists icons, theme color, and install metadata'),
  (31, 'PWA',                'Progressive Web App; a website that can be installed and behave more like a native app, with manifest and service worker'),
  (31, '<link rel="icon">',  'HTML tag that declares a favicon, optionally with `sizes` and `type` attributes for multiple variants'),
  (31, 'prefers-color-scheme', 'CSS media feature exposing the user''s OS-level light/dark preference; usable inside SVG favicons too');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(32, '2026-06-07', 16, 'What is a singleton?',
'A design pattern that guarantees only one instance of a type exists in the running program, and gives the rest of the code a single agreed-upon way to get hold of it.

The shape is the same regardless of language.

The constructor is private or hidden.

The class holds a static reference to its single instance, created lazily or eagerly.

A public accessor (`getInstance()`, `instance`, an exported `const`) returns it.

Reasonable fits.

A database connection pool. You do not want fifty open connections; you want one shared object distributing them.

A logger. Everyone writes to the same sink.

An app-wide config object loaded once at startup.

A clock service or random-number source that you want to be able to swap in tests.

In JavaScript you rarely write the textbook pattern. ES modules give you singleton-ish behavior for free: `export const db = new Database()` runs once per process, and every importer receives the same instance. That is a singleton in everything but name.

Why people get cagey about them.

They are global state in disguise. Code that depends on a singleton is invisibly coupled to it.

They make testing harder. You cannot easily swap in a fake if every caller fishes the real one out of the global accessor.

They hide dependencies. A function that touches a singleton looks pure but is not.

The grown-up take. Fine for genuinely process-wide infrastructure (database pool, logger). When you reach for one because "this feels global right now" (current user, request context), it tends to bite later. The cleaner alternative is dependency injection: pass the thing in explicitly instead of fishing it out.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (32, 'singleton',          'design pattern guaranteeing one instance of a type per program, accessed through a single agreed-upon accessor'),
  (32, 'design pattern',     'a named, reusable solution to a class of design problems; popularized by the 1994 "Gang of Four" book'),
  (32, 'global state',       'data accessible from anywhere in the program; convenient but couples code to the global and complicates testing'),
  (32, 'dependency injection', 'passing a dependency into a function or constructor instead of fetching it from a global or singleton; makes substitution and testing easier'),
  (32, 'module singleton',   'in JS/TS, a value created at module top level; ES module semantics guarantee the module runs once, so the value is effectively a singleton'),
  (32, 'connection pool',    'a managed set of pre-opened DB connections handed out to callers and returned after use; a classic singleton use case'),
  (32, 'lazy initialization','creating an object only when first needed, rather than eagerly at program start; common technique inside singleton accessors');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(33, '2026-06-07', 17, 'What is a namespace?',
'A way to scope names so things with the same name do not collide.

Without namespaces, every name in a program shares one global pool. Two libraries that both define `Logger` clash. Namespaces split that pool into labeled buckets. `LibA.Logger` and `LibB.Logger` can coexist because each lives in its own bucket.

Examples across the stack.

C++ / C#. `namespace foo { class Bar {} }`, accessed as `foo::Bar`.

Java packages. `com.potatuhs.tools.Logger`. The dotted path is the namespace.

Python modules. `import logging; logging.getLogger()`. The module itself is the namespace.

JavaScript.

ES modules: each file is a namespace; you choose what to export.

Object grouping: `const utils = { foo, bar }; utils.foo()` is a manual namespace.

TypeScript''s old `namespace Foo { ... }` keyword is deprecated style; modules replaced it.

XML/HTML. `xmlns:svg="..."` lets SVG tags coexist with HTML tags in one document without colliding.

Kubernetes namespaces. Logical isolation of resources (pods, services) by team or environment inside one cluster.

Linux kernel namespaces. The actual mechanism behind containers: separate views of the process tree, network stack, mounts, and so on.

The connecting idea. A namespace draws a boundary around a set of names so they can be referenced unambiguously, and so different bags of names can use the same internal name without interfering. The mechanism varies (text prefix, language scope, OS isolation), but the goal is always "stop names from clashing."

In JS day-to-day, ES modules handle most of this for you. `import { thing } from "./foo.js"` is a namespace operation: `thing` is being pulled out of `foo`''s namespace and bound into yours.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (33, 'namespace',          'a scope that wraps a set of names so they can be referenced unambiguously and not collide with other names'),
  (33, 'global scope',       'the outermost namespace of a program where all unscoped names live; without other namespaces, every name competes here'),
  (33, 'package (Java)',     'Java''s namespace mechanism; reverse-domain naming like com.potatuhs.tools is convention'),
  (33, 'ES module',          'a file with `import`/`export`; each module is its own namespace and is evaluated once per process'),
  (33, 'TypeScript namespace', 'the older `namespace Foo {}` keyword for grouping declarations; superseded by modules in modern TS'),
  (33, 'XML namespace',      'URI-based namespace declared via xmlns; lets XML/HTML mix element vocabularies (SVG inside HTML, etc.) without name conflicts'),
  (33, 'Kubernetes namespace', 'logical partition of a Kubernetes cluster; resources in different namespaces are isolated by default'),
  (33, 'Linux namespaces',   'kernel feature giving processes isolated views of resources (PID, network, mount, user, etc.); the foundation of containers');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(34, '2026-06-07', 18, 'What is a linter?',
'A program that reads your source code without running it and flags issues: likely bugs, style violations, dead code, unsafe patterns, based on a set of rules.

The name comes from `lint`, a 1978 Bell Labs tool that scanned C for things the compiler accepted but were probably mistakes (uninitialized variables, unreachable code). "lint" is the fuzz that gathers on fabric. The tool''s job is to pick the fuzz off before it becomes a snag.

What linters catch in practice.

Likely bugs: comparing a variable to itself, unused variables, calling a method that does not exist on a type, forgetting `await` on a promise.

Style violations: missing semicolons, inconsistent quotes, line length. Many teams delegate style to a formatter (Prettier) and let the linter focus on logic.

Footguns that look fine: `==` instead of `===` in JS, mutable default arguments in Python, missing `key` props on React lists.

Convention enforcement: file naming, import ordering, "named export only, no default here."

Common linters.

JavaScript/TypeScript: ESLint (standard), Biome (newer, fast, all-in-one).

Python: Ruff (modern, Rust-written, fast), Pyflakes, Pylint.

Go: `go vet`, staticcheck, golangci-lint.

Rust: clippy.

CSS: Stylelint.

Shell: shellcheck (catches a lot of bash gotchas).

How they are wired in.

Red squiggles in your editor on save.

A pre-commit hook (husky, lefthook) that runs the linter before each commit.

A CI step that blocks PRs with lint errors.

`--fix` mode for safe auto-fixes.

Linter vs. formatter vs. type checker. Three close cousins, different jobs.

Linter catches logical and stylistic issues based on rules (ESLint).

Formatter reformats whitespace and layout to a fixed style; no opinion on logic (Prettier, Black, gofmt).

Type checker catches type errors only (`tsc`, mypy).

Most modern teams run all three. The setup looks like overkill until you have debugged a codebase without it.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (34, 'linter',             'tool that statically analyzes source code (no execution) and reports likely bugs, style issues, or rule violations'),
  (34, 'static analysis',    'inspecting code without running it; linters, type checkers, and security scanners are all forms of static analysis'),
  (34, 'lint (origin)',      '1978 Bell Labs program for C that flagged suspect-but-legal code; gave the whole tool category its name'),
  (34, 'ESLint',             'standard JS/TS linter; pluggable rules and parsers; widely integrated into editors and CI'),
  (34, 'Prettier',           'opinionated code formatter for JS/TS/CSS/HTML/markdown; reformats layout but has no rule logic'),
  (34, 'Ruff',               'fast Rust-written Python linter (and formatter); has largely replaced Pyflakes/Pylint in new projects'),
  (34, 'shellcheck',         'linter for bash/sh scripts; catches quoting bugs, missing variables, race conditions, and similar gotchas'),
  (34, 'pre-commit hook',    'script that runs before `git commit` finalizes; commonly used to run formatters and linters and reject bad commits'),
  (34, '--fix mode',         'linter option that auto-applies fixes for rules where the correction is unambiguous (missing semicolons, sort imports)');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(35, '2026-06-07', 19, 'What is a slug in a URL?',
'A slug is the human-readable identifier for a piece of content in a URL path: the part that points to one specific resource.

```
https://example.com/blog/how-to-make-better-coffee
                         ^^^^^^^^^^^^^^^^^^^^^^^^^
                         that part is the slug
```

The name comes from journalism. In newspaper layout, a "slug" was a short identifier editors used to refer to an in-progress story before the headline was finalized. Web frameworks borrowed the term for the URL-identifier role.

Rules a good slug follows.

Lowercase. URL paths are case-sensitive, and mixing case creates "two URLs for one thing" bugs.

Hyphen-separated, not underscores or spaces. Google historically treats hyphens as word separators; underscores less so. Spaces have to be percent-encoded (`%20`) which is ugly.

URL-safe characters only: `a-z`, `0-9`, `-`. No punctuation, no accents, no Unicode by default (modern frameworks can do Unicode slugs if you want non-English content).

Short but meaningful. Enough to tell a human what the page is, short enough to read and share.

Stable. Once a slug is published, you do not change it. Changing it breaks every existing link.

How slugs are generated.

A slugify function transforms a title into a slug.

```
"How to make better coffee, even on Mondays!"
        slugify ->
"how-to-make-better-coffee-even-on-mondays"
```

It lowercases, strips punctuation, replaces whitespace with hyphens, transliterates accents (`café` becomes `cafe`), and trims to a max length.

Common nuances.

Collisions. Two posts titled "Welcome" both slugify to `welcome`. Frameworks handle it by appending a counter (`welcome-2`) or a short unique ID.

Slug + ID hybrid. Many sites pair a slug with a unique identifier for safety: `/posts/42-welcome` or `/posts/welcome-V1StGXR8`. The ID guarantees uniqueness; the slug gives the human-readable hint. The `V1StGXR8` form is a nanoid (see today''s entry 13).

i18n. For non-Latin scripts, slugs are either transliterated (Russian "Привет" becomes `privet`) or kept as percent-encoded native script if that is what the audience expects.

Why slugs matter.

SEO. Search engines weight URL text. `/blog/how-to-make-coffee` ranks better for "how to make coffee" than `/blog/post-42` does.

Shareability. A human can guess what a URL is about before clicking. `/articles/javascript-promises-explained` tells you the topic up front.

Trust. Clean slugs look professional; `?id=42&cat=blog&type=public` URLs look like spam.

Where slugs would fit in this repo. The archive currently keys days by date (`2026-06-07`). That date is already a slug-like identifier: short, lowercased, no spaces. If we ever build per-entry URLs (`/2026-06-07/what-is-a-slug-in-a-url`), the second segment is exactly where a slug would go: a slugified version of the question.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (35, 'slug',               'human-readable URL-safe identifier for a piece of content; the descriptive path segment in a clean URL'),
  (35, 'slugify',            'function that converts a free-form title into a slug by lowercasing, stripping punctuation, replacing spaces with hyphens, etc.'),
  (35, 'percent-encoding',   'mechanism that escapes URL-unsafe characters as %XX (space becomes %20, é becomes %C3%A9); ugly in display, essential in transport'),
  (35, 'URL path',           'the part of a URL after the host and before the query string; structured as slash-separated segments'),
  (35, 'SEO',                'Search Engine Optimization; practices that improve a page''s ranking; URL slugs are one input among many'),
  (35, 'transliteration',    'converting text from one script to another phonetically (Cyrillic "Привет" to Latin "privet"); used to make non-Latin titles URL-friendly'),
  (35, 'collision handling', 'strategies for distinct items that produce the same slug; common solutions are numeric suffixes or appending a unique ID');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(36, '2026-06-07', 20, 'What is CI/CD?',
'CI/CD is Continuous Integration / Continuous Delivery (or Deployment). A bundle of practices for automating the path between "I pushed code" and "it is running in production."

CI: Continuous Integration. Every push triggers automated checks: test suite, linter, type checker, security scanner, build. The goal is catching problems within minutes, not days later when changes have piled up. The name reflects an older problem; devs used to work on private branches for weeks, then "integrate" everyone''s work in one painful sweep. CI''s answer: integrate every commit, automatically.

CD: two flavors with the same acronym.

Continuous Delivery. Every commit that passes CI is ready to deploy. Deployment is a manual click.

Continuous Deployment. Every commit that passes CI is deployed automatically. No human in the loop.

Teams use "CD" for either; clarify which when it matters.

The shape of a pipeline.

You push to a branch. A CI service notices via webhook (GitHub, GitLab, etc.) and spins up a fresh Linux container. In that container it runs your defined steps in order.

Check out code.

Install dependencies (`npm ci`, `pip install`, etc.).

Run tests.

Run linters and type checkers.

Maybe run a security scan.

Build the artifact (`npm run build`, `docker build`).

On the main branch: deploy (or publish for a deploy step to pick up).

Each step''s exit code matters. Non-zero is fail, the pipeline stops, the PR shows a red mark. With branch protection enabled, red PRs cannot merge.

Common CI services.

GitHub Actions. Runs alongside your code; YAML at `.github/workflows/*.yml`. Default for GitHub repos.

CircleCI. Older, fast, flexible config.

GitLab CI. Built into GitLab. `.gitlab-ci.yml`.

Jenkins. The old enterprise standard; self-hosted.

Cloudflare Pages / Vercel / Netlify. Hosting-coupled. Watch a branch, build, deploy. You do not write a pipeline file; they infer steps from a framework preset.

Why it matters.

Fast feedback. You learn within minutes if a PR is broken.

Mergeability gate. Bad code cannot merge. `main` stays green.

Reproducible builds. Fresh container, known config. "Works on my machine" stops mattering.

Routine deploys. Deployment becomes boring and reversible instead of a high-drama event.

Tied to this repo specifically.

`DEPLOY.md` describes a CD setup. Cloudflare Pages watches a branch, runs `npm run build`, ships the `dist/` folder to the edge. Every push to `main` triggers a fresh build and deploy. That is Continuous Deployment.

The CI piece (tests and linters running on every PR before it can merge) is not wired here yet. There is no `.github/workflows/` directory. Adding that would be a separate step.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (36, 'CI',                  'Continuous Integration; automated checks (tests, lint, build) run on every push to catch breakage early'),
  (36, 'CD',                  'Continuous Delivery or Continuous Deployment; deploying on every passing build, manually or automatically'),
  (36, 'pipeline',            'an ordered sequence of automated steps a CI system runs against your code on each push'),
  (36, 'webhook',             'an HTTP callback a service registers so another service can notify it of events (push, merge, deploy)'),
  (36, 'branch protection',   'GitHub/GitLab feature blocking merges to a branch unless required checks pass and review rules are met'),
  (36, 'GitHub Actions',      'GitHub''s built-in CI/CD service; pipelines defined as YAML in .github/workflows/'),
  (36, 'runner',              'the machine (often a fresh container) that executes a CI job; ephemeral by default'),
  (36, 'artifact',            'a built output of a CI job (a binary, a bundled JS dist, a Docker image) that may be deployed or stored'),
  (36, 'green / red build',   'shorthand for passing or failing CI; "main is green" = main branch builds cleanly');

-- =====================================================
-- 2026-06-08 entries
-- =====================================================

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(37, '2026-06-08', 1, 'What is piping with regard to stdin, stdout, standard in, standard out?',
'Every Unix process is born with three open streams:

stdin — standard input. Where the program reads from by default. File descriptor 0.
stdout — standard output. Where the program writes normal results. File descriptor 1.
stderr — standard error. Where the program writes error messages. File descriptor 2.

By default, all three are wired to your terminal: you type into stdin, output and errors both print on your screen. They are separate channels so you can route them independently.

A pipe is the `|` symbol. It says: take the stdout of the command on the left, and feed it as stdin to the command on the right. Two programs that know nothing about each other become an assembly line.

ls | grep ".md"

`ls` lists files. Normally that output goes to your terminal. The pipe redirects it. `grep` reads from stdin and prints lines containing `.md`. Result: a filtered file list.

Chain as many as you want:

ls | grep ".md" | sort | head -3

List, keep markdown, sort, take the first three. Each program does one job; the pipes compose them.

Why this is the foundation of Unix.

The Unix philosophy is small programs that read text from stdin and write text to stdout, chainable by pipes. `grep`, `sort`, `wc`, `awk`, `sed`, `cut`, `jq`, `xargs` — they all follow this contract. Learn ten of them and you have thousands of combinations.

Pipes vs. redirection.

Easy to confuse `|` with `>` and `<`. Related but distinct:

a | b           — stdout of a → stdin of b. Both processes run live, simultaneously, connected by an in-memory buffer.
a > file.txt    — stdout of a written to a file instead of the terminal.
a < file.txt    — a reads stdin from a file instead of the keyboard.
a 2> errors.log — stderr (fd 2) goes to a file; stdout still goes wherever it would.
a &> all.log    — both stdout and stderr go to a file.

So `ls > files.txt` saves a file list. `grep ".md" < files.txt` reads it back through grep. Same end result as `cat files.txt | grep ".md"`, different routing.

What is actually flowing.

Bytes. Not files, not "objects." A stream of bytes the producer writes and the consumer reads. The OS holds a small buffer (typically 64KB) in the middle. If the consumer is slow, the producer blocks until the buffer drains. If the producer is slow, the consumer blocks waiting. This is back-pressure: built in, free, automatic.

That is also why pipes work on infinite streams. `tail -f log.txt | grep ERROR` runs forever. Lines flow as they appear. No "wait for the producer to finish."

stderr matters.

Common gotcha: `command | other` only pipes stdout. If `command` writes to stderr, those messages still hit your terminal, not the pipe. To send both, merge stderr into stdout first:

command 2>&1 | other

`2>&1` means "send fd 2 to wherever fd 1 is going." Order matters — it has to come before the pipe is set up.

Where you see this every day.

git log | grep "fix"          — search commit history.
cat package.json | jq .scripts — pretty-print a JSON slice.
ps aux | grep node            — find running Node processes.
history | tail -20            — your last twenty commands.

The same shape exists in code, under different names. Node`s `stream` API, Python iterators, Rust`s `Iterator` chains — they are piping in disguise. The Unix shell just exposed the pattern first.

In this repo specifically.

When `npm run dev` prints Vite logs to your terminal, that is stdout. Error overlays from the dev server are stderr. You do not notice the split because the terminal merges both. But `npm run dev > out.log 2> err.log` would cleanly route them to separate files.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (37, 'stdin',             'standard input; the default stream a process reads from. File descriptor 0'),
  (37, 'stdout',            'standard output; the default stream a process writes normal results to. File descriptor 1'),
  (37, 'stderr',            'standard error; a separate stream for error and diagnostic messages. File descriptor 2'),
  (37, 'file descriptor',   'a small integer the OS hands a process to refer to an open stream or file (0, 1, 2 are the standard three)'),
  (37, 'pipe (|)',          'shell operator that wires the stdout of one command to the stdin of the next, in memory, live'),
  (37, 'redirection',       'using >, <, >>, 2> in the shell to point a stream at a file instead of the terminal'),
  (37, '2>&1',              'shell idiom for "send fd 2 to wherever fd 1 is going"; merges stderr into stdout so a pipe carries both'),
  (37, 'back-pressure',     'automatic flow control between a fast producer and slow consumer; a full pipe buffer blocks the writer'),
  (37, 'Unix philosophy',   'design ethos of small text-in / text-out programs composed via pipes instead of one big monolith'),
  (37, 'buffer',            'fixed-size in-memory region between producer and consumer; the OS uses ~64KB for pipes by default');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(38, '2026-06-08', 2, 'How do I access the contents of a commit that I make in git?',
'A commit in git is a small object on disk. Five common ways to read it:

git show <hash>     — full picture: message + diff
git log             — browse history
git log -p          — log with patches inline
git log --stat      — log with file-change summaries
git diff <h1> <h2>  — just the diff between two commits

Most common: `git show HEAD`. HEAD is a moving pointer that always means "the commit I am currently sitting on." So right after committing, `git show HEAD` is "show me what I just made." Specific commit: `git show 83057a0`. Partial hashes work; git resolves the shortest unambiguous prefix.

Relative refs save you from copying hashes:

HEAD     — current commit
HEAD~1   — one commit back
HEAD~3   — three commits back
HEAD^    — parent (same as HEAD~1)

Slicing what you see:

git show HEAD --stat         — file-change summary, no patch
git show HEAD --name-only    — just file paths
git show HEAD --name-status  — paths plus A/M/D markers
git show HEAD -- src/App.tsx — restrict diff to one file
git log --oneline -10        — last ten commits, one line each

Plumbing view.

A commit is really a tiny text object pointing at a tree (snapshot of all files), one or more parents, an author, a committer, and a message. `git cat-file -p HEAD` dumps the raw object. You rarely need it, but seeing it once kills the magic.

In this repo.

Run `git log --oneline` and you see recent commits like `b281c4c go live` and `83057a0 june 7`. `git show b281c4c` spits out the message and full diff. Pipe it into `less` (`git show b281c4c | less`) if it scrolls past your terminal. Most git commands page automatically; piping makes the behavior explicit.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (38, 'HEAD',              'a moving pointer to the commit you are currently sitting on; updates whenever you commit or check out a new ref'),
  (38, 'commit hash',       'the SHA-1 (or SHA-256) of a commit object; uniquely identifies it; partial prefixes work in commands'),
  (38, 'relative ref',      'shorthand for a commit relative to another one; HEAD~1 = parent of HEAD, HEAD~2 = grandparent, etc.'),
  (38, 'git show',          'command that prints a commit`s message and diff; the default way to see what a commit changed'),
  (38, 'git log',           'command that walks commit history; flags like -p, --stat, --oneline change what gets shown per commit'),
  (38, 'tree object',       'git`s snapshot of a directory at one moment; commits point at exactly one tree'),
  (38, 'plumbing',          'low-level git commands (cat-file, hash-object, rev-parse) that expose the underlying object model'),
  (38, '--stat',            'flag that adds a per-file summary of insertions/deletions to git log or git show output'),
  (38, '--name-only',       'flag that strips the diff and prints only the file paths a commit touched');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(39, '2026-06-08', 3, 'How do I pipe the contents of a commit into an LLM so that it can summarize the technical changes I have made?',
'Three layers: get the commit as text, have an LLM CLI installed, pipe one into the other.

1. The commit as text.

`git show HEAD` already prints message + diff to stdout. That is your input.

2. An LLM you can call from a shell.

It needs to read from stdin (or accept a prompt argument) and print a response to stdout. Canonical options:

- `claude` — the Claude Code CLI you are already running. `claude -p "<prompt>"` is a one-shot run.
- `llm` — Simon Willison`s tool, `pip install llm`. Accepts piped input naturally; works with many providers.
- `gh copilot suggest` — GitHub-flavored, ships as a GitHub CLI plugin.
- `curl` straight to the Anthropic API — no extra tool, full control.

3. The pipe.

git show HEAD | claude -p "Summarize the technical changes in this commit. Focus on what the code now does that it did not before."

That sends the entire commit (message + diff) on stdin and gives the LLM a clear instruction. The summary prints to your terminal.

Variants:

git show HEAD | llm "summarize the technical changes"
git show HEAD~3 | claude -p "what changed?"
git log -p main..HEAD | claude -p "Summarize this whole branch."

(`main..HEAD` means "commits in HEAD that are not in main.")

When the prompt needs structure, use a heredoc with command substitution:

claude -p "$(cat <<EOF
Summarize this commit. Bullet points. Cover:
- What the code does differently
- Any risky changes
- Files most worth review

$(git show HEAD)
EOF
)"

Watch the size.

A big commit can blow past a model`s context window. Two outs:
- Drop the diff and send only the summary: `git show HEAD --stat | claude -p ...`
- Send the file list first and let the LLM ask for specific files.

Bake the habit in.

Add this to `~/.zshrc`:

summarize-commit() {
  git show "${1:-HEAD}" | claude -p "Summarize the technical changes in this commit."
}

Now `summarize-commit` (or `summarize-commit 83057a0`) is a single word away. You have turned a Unix pipe and a recurring question into a reusable tool.

That is the whole shape of shell work: a verb to extract, a verb to transform, a pipe between them. Pipes are how you fuse any two things that read and write text.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (39, 'one-shot prompt',    'a single-turn LLM invocation; one input, one output, no ongoing session state'),
  (39, 'claude -p',          'Claude Code CLI flag for a one-shot, non-interactive run that prints the model response to stdout'),
  (39, 'llm CLI',            'Simon Willison`s shell tool for calling LLMs from the command line; pipes input naturally'),
  (39, 'heredoc',            'shell syntax (<<EOF ... EOF) for embedding a multi-line string literal in a command'),
  (39, 'command substitution', '$(...) runs a command and substitutes its stdout into the surrounding command line'),
  (39, 'context window',     'the maximum amount of text (in tokens) a model can read in one call; oversize input gets truncated or rejected'),
  (39, 'shell function',     'a small named bash/zsh function defined in your rc file; behaves like a custom command'),
  (39, 'main..HEAD',         'git revision range meaning "commits reachable from HEAD but not from main"; the branch`s own work');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(40, '2026-06-08', 4, 'What are some canonical ways individuals store business / operations / logistics / legal documents on their local file system?',
'Two questions hide in this one: where do you store them, and how do you organize them once stored.

Where: the candidate locations.

- `~/Documents` — OS default catch-all. iCloud-synced on Mac by default.
- A cloud-synced folder: Dropbox, Google Drive (`~/Google Drive/`), OneDrive, Sync.com. Synced means "lose your laptop, the docs come back."
- A dedicated local root: `~/work`, `~/business`, or in this machine`s case `~/Potatuhs/`. Often paired with Time Machine, Backblaze, or a sync script.
- Encrypted vaults for sensitive items: 1Password (also stores PDFs, not just passwords), Bitwarden, a gpg-encrypted folder, an encrypted disk image.
- A git repo for anything text-based. SOPs, runbooks, contracts in markdown — versioned, diff-able, reviewable.

How: the canonical schemes.

1. PARA. Tiago Forte`s widely copied method. Top level is exactly four folders:

   Projects/   — active work with a deadline
   Areas/      — ongoing responsibilities (taxes, the LLC)
   Resources/  — reference material
   Archives/   — anything inactive

   Items migrate between them as their status changes. The strength: no decisions about depth or naming. You only ask "is this active, ongoing, reference, or done?"

2. Johnny Decimal. A numeric system. Ten top-level "areas" (10-19, 20-29, ...). Each area has ten "categories" (10.01, 10.02, ...). You can hold the whole map in your head: 30 is Money, 31 is Bank accounts, 32 is Taxes. Strength: every item has a unique numeric address. Weakness: rigid, and items that could plausibly live in two areas hurt.

3. Functional top-level. The DIY default.

   ~/business/
     legal/
     finance/
     contracts/
     insurance/
     ops/
   ~/personal/
     medical/
     taxes/
     housing/

   No method, just a sensible taxonomy. Fine until you forget where you filed something and start searching by content instead of path.

4. Date-first archives. For things that are events, not topics — receipts, invoices, signed contracts:

   ~/business/archive/2026/06/2026-06-08-vendor-invoice-acme.pdf

   You usually know roughly when a thing happened, even if you have forgotten the topic. Year/month folders plus dated filenames plus a descriptive slug = findable by path or filename.

5. Project-first with a stable shape. Each engagement gets the same internal layout:

   clients/acme/
     contracts/
     deliverables/
     correspondence/
     notes/

   The repetition builds muscle memory: you always know where the contract is in any client folder.

6. Search-first. Some people skip taxonomy deliberately and rely on full-text search (Spotlight, ripgrep, DEVONthink). The folder is a dumb bucket; the index does the work. Viable if your tooling is fast and your filenames are descriptive.

Naming conventions that pay off.

- `YYYY-MM-DD-<short-slug>.<ext>` sorts chronologically and reads cleanly.
- Kebab-case (`shareholder-agreement.pdf`) beats `Shareholder Agreement.pdf` for shell ergonomics.
- English nouns over abbreviations you will forget the meaning of in a year.
- Amendable docs: version in the name (`operating-agreement-v2.pdf`). Or store as markdown in a git repo and let commits be the versions.

What this machine already does.

Per `~/CLAUDE.md`, the pattern in use:
- A single top-level `~/Potatuhs/` root for anything brand-related.
- `~/Potatuhs/info/` for non-code material — company docs, characters, logs, skills.
- Date-indexed logs at `~/Potatuhs/info/logs/devlog/YYYY/MM/YYYY-MM-DD.md`.
- A nightly cron mirroring `~/Potatuhs/info/logs/` to Google Drive.
- Fuzzier work in `~/`, `~/kakashi/`, etc., to be reclassified later.

That is a functional top-level + date-first archive hybrid, with a git-backed source of truth and an automated mirror to a cloud sync. Most working systems for a single operator look like some flavor of that combination.

The practical lesson.

Pick a scheme you can defend in one sentence to your future self. Keep one document — a README at the top — that names the scheme with a few examples. The scheme is less important than its legibility a year from now when you go looking for the lease you signed today.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (40, 'PARA',               'Tiago Forte`s organizing scheme; four top-level folders — Projects, Areas, Resources, Archives — with items migrating between them as their status changes'),
  (40, 'Johnny Decimal',     'numeric filing system; ten areas (10-19, 20-29, ...), each holding ten categories; every item gets a unique 2- or 3-part numeric address'),
  (40, 'full-text search',   'searching by document contents rather than path; the index does the work so taxonomy can stay shallow'),
  (40, 'kebab-case',         'lowercase-words-separated-by-hyphens; shell-friendly because it survives every quoting style without escaping'),
  (40, 'encrypted vault',    'storage container that requires a passphrase or key to read; 1Password, Bitwarden, gpg files, encrypted disk images'),
  (40, 'slug',               'short URL- or filename-safe label derived from a longer title; usually lowercase, hyphenated, ASCII'),
  (40, 'date-first archive', 'storage pattern that uses YYYY/MM/ folders with dated filenames so events sort chronologically by default'),
  (40, 'SOP',                'Standard Operating Procedure; a written runbook for a routine business or technical task');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(41, '2026-06-08', 5, 'What is Playwright?',
'Playwright is a browser-automation framework from Microsoft. It launches a real browser (Chromium, WebKit, or Firefox) and lets you drive it programmatically — navigate, click, type, evaluate JS in the page, capture screenshots and PDFs, assert on what is on screen. Multi-language (Node, Python, Java, .NET) but Node is the first-class citizen.

It belongs to a family that includes Puppeteer (Google, Chromium-only) and Selenium (older, broader language support, slower). Playwright differentiates with three things:

- Real cross-browser. One API drives Chromium, WebKit (Safari`s engine), and Firefox.
- Auto-waiting. Calls like `click()` block until the target element is actually clickable. No `sleep(500)` race-condition glue.
- Trace viewer. A built-in DOM-snapshot replay tool that turns a failing run into a scrubbable timeline.

Common jobs:
- End-to-end tests (its original mission)
- Web scraping that needs JS execution
- Screenshot pipelines, visual regression
- PDF generation from HTML
- Any "drive the browser like a human" task

Architecture: a host process (your script) spawns a real browser process and talks to it over the browser`s debug protocol (DevTools Protocol for Chromium, equivalents elsewhere). The browser is real; the script is the driver. That is why `npx playwright install` downloads ~300MB on first use: it pulls down patched builds of each browser engine so behavior is consistent across machines.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (41, 'Playwright',          'Microsoft browser-automation framework; drives Chromium, WebKit, and Firefox from one API'),
  (41, 'Puppeteer',           'Google`s Chromium-only browser automation library; the older sibling Playwright`s authors split off to build'),
  (41, 'Selenium',            'long-running browser-automation project; broad language support, slower and looser than Playwright'),
  (41, 'auto-waiting',        'Playwright feature where actions like click() block until the target is actionable, eliminating sleep-based glue'),
  (41, 'DevTools Protocol',   'the JSON-over-WebSocket protocol Chromium exposes for external tools to drive the browser'),
  (41, 'trace viewer',        'Playwright`s GUI for replaying a recorded run as a DOM-snapshot timeline; the killer debugging tool'),
  (41, 'headless browser',    'a real browser running without a visible window; same rendering, no UI, ideal for servers and scripts'),
  (41, 'visual regression',   'testing technique that compares screenshots of a page against a baseline to catch unintended visual changes');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(42, '2026-06-08', 6, 'How do I use Playwright to take screenshots?',
'Install once:

npm i -D playwright
npx playwright install

`playwright install` downloads the actual browser binaries — they are not shipped with the npm package itself.

Minimal script (`shot.mjs`):

import { chromium } from ''playwright'';

const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto(''https://potatuhs.com'');
await page.screenshot({ path: ''shot.png'', fullPage: true });
await browser.close();

Run with `node shot.mjs`. Done.

Knobs you will actually use:

// Big viewport for desktop shots
const page = await browser.newPage({
  viewport: { width: 1440, height: 900 },
  deviceScaleFactor: 3,   // 3x pixel density → ~retina, print-ish
});

// Full scrollable page
await page.screenshot({ path: ''home.png'', fullPage: true });

// Only one element
await page.locator(''header'').screenshot({ path: ''header.png'' });

// Device emulation
const { devices } = await import(''playwright'');
const ctx = await browser.newContext({ ...devices[''iPhone 15 Pro''] });

// PDF (Chromium only) — vector preserved
await page.pdf({ path: ''page.pdf'', format: ''A4'', printBackground: true });

// Wait for fonts and network to settle before snapping
await page.evaluate(() => document.fonts.ready);
await page.waitForLoadState(''networkidle'');

For print collateral specifically, two non-obvious things:

1. Crank `deviceScaleFactor`. The default is 1 (96 DPI screen). Print wants about 300 DPI. `deviceScaleFactor: 3` or `4` gives you raster shots that hold up at print sizes.
2. Prefer PDF when the source is vector. `page.pdf()` preserves text and SVG as actual vector geometry. A 1MB PDF will print sharper than a 50MB PNG.

A practical multi-shot script:

const targets = [
  { url: ''https://potatuhs.com'',          name: ''home'' },
  { url: ''https://potatuhs.com/products'', name: ''products'' },
  { url: ''https://potatuhs.com/about'',    name: ''about'' },
];

const today = new Date().toISOString().slice(0, 10); // YYYY-MM-DD

const browser = await chromium.launch();
const page = await browser.newPage({
  viewport: { width: 1440, height: 900 },
  deviceScaleFactor: 3,
});

for (const { url, name } of targets) {
  await page.goto(url, { waitUntil: ''networkidle'' });
  await page.screenshot({ path: `out/${today}-${name}.png`, fullPage: true });
}

await browser.close();

Two patterns worth absorbing: dated filename slugs (sort-by-date for free) and an `out/` directory as a writable target. Both pay off later when you start piping shots into other tools.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (42, 'viewport',            'the visible browser window dimensions; controls how much of a page renders before scroll is needed'),
  (42, 'deviceScaleFactor',   'Playwright option simulating display pixel density; 2 = retina, 3-4 = print-ish; raises effective DPI of screenshots'),
  (42, 'fullPage screenshot', 'option that scrolls the page top-to-bottom and stitches the entire scroll height into one image'),
  (42, 'locator',             'Playwright`s element-finding object; can be screenshot, clicked, queried; auto-waits for actionability'),
  (42, 'device emulation',    'spinning up a browser context preset to mimic a real device (iPhone, Pixel, iPad) for user-agent, viewport, touch'),
  (42, 'networkidle',         'load state where no network requests have happened for ~500ms; conservative signal a page is fully settled'),
  (42, 'page.pdf()',          'Chromium-only Playwright method that renders the current page as a vector-preserving PDF; print-ready by default'),
  (42, 'DPI',                 'dots per inch; print quality unit. 72-96 is screen; 300 is standard for print collateral; 600+ for fine work');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(43, '2026-06-08', 7, 'How do I take those screenshots and automatically pipe them from the Playwright directory to a workbench working on print collateral (brochures, pamphlets, book almanacs)?',
'There is an asymmetry to flag first: Playwright writes binary files to disk, not bytes to stdout. So "pipe" here means plumbing between two directories, not a shell `|`. Three patterns, in order of how much they automate.

1. Write directly into the workbench.

The simplest move: instead of writing to a local `out/` and copying later, write Playwright`s `path` straight into the workbench`s "incoming" folder.

Suppose your almanac workbench lives at `~/Potatuhs/almanac/` and reserves a folder for harvested imagery:

~/Potatuhs/almanac/
  assets/
    web-shots/        ← Playwright writes here
    illustrations/
    photography/
  layouts/
  manuscript/

Then:

const dest = ''/Users/brettowers/Potatuhs/almanac/assets/web-shots'';
await page.screenshot({ path: `${dest}/${today}-${name}.png`, fullPage: true });

One destination, one source of truth. If the workbench is a git repo, the shot is now versioned the moment it lands.

2. Watch + sync.

When Playwright lives in one repo (the test or scraping repo) and the workbench in another, and you do not want to hard-code paths across repos:

- Playwright writes to a local `out/` as usual.
- A watcher copies new files into the workbench whenever they appear.

A tiny `chokidar` watcher (Node):

import chokidar from ''chokidar'';
import { copyFile } from ''node:fs/promises'';
import path from ''node:path'';

const SRC  = ''./out'';
const DEST = ''/Users/brettowers/Potatuhs/almanac/assets/web-shots'';

chokidar.watch(SRC).on(''add'', async (file) => {
  const name = path.basename(file);
  await copyFile(file, path.join(DEST, name));
  console.log(`→ ${name}`);
});

Or a one-shot `rsync` after the screenshot run:

rsync -av --include=''*.png'' --include=''*.pdf'' --exclude=''*'' out/ \
  ~/Potatuhs/almanac/assets/web-shots/

`rsync` only copies changed files, so re-runs are cheap.

3. Make it a single command.

Wrap the whole thing in an `npm script` (or a shell function) so capture-and-deliver is one verb.

In your Playwright repo`s `package.json`:

"scripts": {
  "shots": "node shot.mjs && rsync -av out/ ~/Potatuhs/almanac/assets/web-shots/"
}

Then `npm run shots` captures every page, copies to the workbench, and prints a list of what landed. The `&&` is the shell saying "only sync if Playwright exited 0," so a broken run does not pollute the workbench.

If you want an actual file-stream pipe (the Unix kind), Playwright supports it for screenshots — omit `path` and use the return value:

const buf = await page.screenshot({ fullPage: true });
process.stdout.write(buf);

Then:

node shot.mjs > ~/Potatuhs/almanac/assets/web-shots/home.png

Now it really is a pipe. Useful if you want to pass through an image tool inline:

node shot.mjs | magick - -colorspace CMYK ~/Potatuhs/almanac/assets/web-shots/home.tiff

That converts on the fly from Playwright`s sRGB output into CMYK TIFF for commercial print, without ever saving the intermediate PNG.

Print-specific gotchas.

- Web color (sRGB) is not the same as print color (CMYK). Anything destined for a commercial printer needs a conversion pass. ImageMagick (`magick in.png -profile sRGB.icc -profile CMYK.icc out.tiff`) or a designer tool handles this. Browsers do not.
- Fonts. Make sure the page`s webfonts have loaded before snapping (`await document.fonts.ready`) or you will get fallback-font shots that look subtly wrong.
- Resolution. Bump `deviceScaleFactor` before layout. Changing it mid-page can cause reflow.
- PDFs are usually the right answer. If the source is HTML, `page.pdf()` is print-ready out of the box, and your designer can place it as a vector asset rather than a raster screenshot.

The end-to-end shape:

Playwright drives the browser → writes PNG or PDF into the workbench`s `assets/` folder → ImageMagick converts to print-friendly format if needed → designer tool picks up the files. One `npm run shots` compresses all of it into a single keystroke once the pipeline is wired.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (43, 'rsync',               'fast file-sync tool; copies only what changed between source and destination; safe for repeated runs'),
  (43, 'chokidar',            'Node library that watches the filesystem for changes; the substrate under most "hot reload" features'),
  (43, 'fswatch',             'POSIX filesystem-watcher CLI; macOS-friendly alternative to inotify-based tools'),
  (43, 'ImageMagick',         'venerable CLI image toolkit; converts formats, resamples, color-manages, composites. Standard print-pipeline glue'),
  (43, 'sRGB',                'standard web color space; what browsers and screens render in by default'),
  (43, 'CMYK',                'subtractive color model used by printers; web images must be converted before commercial print'),
  (43, '&& (shell chaining)', 'shell operator meaning "run the next command only if the previous one exited with status 0"'),
  (43, 'binary stream',       'a sequence of arbitrary bytes (image, executable, archive) rather than text; pipeable, but terminal-unsafe to print'),
  (43, 'npm script',          'a named command defined in package.json under "scripts"; the shorthand layer over your project`s tooling');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(44, '2026-06-08', 8, 'What is a file descriptor?',
'A file descriptor (fd) is a small non-negative integer the kernel hands a process when it opens something — a file, a pipe, a socket, a terminal, a device, anything. The process passes that integer back into every subsequent `read()`, `write()`, or `close()` call. The integer is just a handle; all the real bookkeeping (current read position, permissions, the underlying object) lives in kernel memory.

The "everything is a file" idea that Unix is famous for is really "everything is reached through a file descriptor." A regular file on disk, a TCP socket, and your terminal all look the same to your code: `read(fd, buf, n)`.

The standard three.

Every process inherits three open file descriptors from whatever spawned it:

fd 0 — stdin
fd 1 — stdout
fd 2 — stderr

There is nothing magical about the numbers themselves. The kernel just guarantees that when your process starts, something is wired to 0, 1, and 2. Usually that something is your terminal. When the shell sets up a pipe, that pipe becomes fd 1 of the producer and fd 0 of the consumer. Same numbers, different plumbing.

The per-process table.

Each process has its own file descriptor table — an array kept by the kernel. Indexing it with 0, 1, 2, 3... gives you the open thing at that slot:

process 8421 fd table:
  0 → /dev/ttys003   (your terminal, read side)
  1 → /dev/ttys003   (your terminal, write side)
  2 → /dev/ttys003   (your terminal, write side)
  3 → /Users/brett/idkwhatimdoing/archive.db
  4 → socket: TCP 127.0.0.1:4747
  5 → pipe[7461023]

`open()` returns the lowest unused slot. Close one in the middle and the next `open()` reuses that slot. So fd numbers are stable within a process but mean nothing to anyone else.

See it yourself.

On macOS:

lsof -p $$

`$$` is your shell`s PID. You will see the shell`s own open files — its terminal at 0/1/2, history file, maybe a few sockets.

On Linux there is a pseudo-filesystem for this:

ls -l /proc/$$/fd

Every open fd shows up as a symlink to whatever it points at.

How shell redirection actually works.

`2>&1` reads as "make fd 2 point to whatever fd 1 currently points to." It is not a string substitution — it is a real syscall: `dup2(1, 2)`. The kernel finds whatever object fd 1 references and installs it at slot 2 as well. After that, anything the process writes to stderr goes to the same destination as stdout.

This is why order matters in redirections. Read left to right:

command > out.log 2>&1

1. `> out.log` opens out.log and installs it at fd 1. Now fd 1 = the file.
2. `2>&1` duplicates whatever fd 1 currently is (the file) onto fd 2. Now fd 2 = the file too.

Reverse them and you get a different result:

command 2>&1 > out.log

1. `2>&1` duplicates fd 1 (currently the terminal) onto fd 2. Now fd 2 = terminal.
2. `> out.log` installs the file at fd 1. fd 2 is still the terminal.

stdout ends up in the file, stderr still spills to your screen. Same characters in the command, opposite outcome.

How pipes actually work.

When you type `a | b`, the shell:

1. Calls `pipe()`, which returns two new file descriptors — say 3 (read end) and 4 (write end).
2. Forks twice. For the child running `a`: `dup2(4, 1)` so its stdout becomes the write end. Close the original 3 and 4.
3. For the child running `b`: `dup2(3, 0)` so its stdin becomes the read end. Close the original 3 and 4.
4. Both children `exec()` their target program.

Neither `a` nor `b` knows it has been piped. They just write to fd 1 and read from fd 0 like always. The kernel`s pipe object is what carries bytes between them.

Inheritance across fork/exec.

When a process forks, the child gets a copy of the parent`s fd table. When it `exec()`s a new program, the table mostly survives (unless an fd is marked close-on-exec). This is the whole mechanism that lets the shell hand a customized environment to a subprocess without the subprocess having to know anything about it.

That is also why you can do:

exec 3< config.txt
read -r line <&3
exec 3<&-     # close fd 3

You can open arbitrary fds and pipe into them by number. Rare in everyday scripts, useful when wrangling multiple input streams.

Limits.

Every OS caps how many fds a process can have open simultaneously. Check yours:

ulimit -n

Default on macOS is often 256; on most Linux distros it is 1024. Servers raise it into the tens of thousands. Hit the limit and `open()` starts returning `EMFILE` — "too many open files." This is the classic fd leak: a program opens connections or files in a loop and forgets to `close()` them. `lsof -p <pid>` shows you exactly what is piling up.

Other systems.

Windows has HANDLEs that play the same role but are not small integers — they are opaque pointers managed by the kernel. Node`s `fs` module, Python`s `open()`, Go`s `os.File` all hide whichever native primitive is underneath. But when you drop into C, a syscall, or a strace/dtrace trace, the file descriptor is the abstraction you meet at the bottom.

In this repo specifically.

When `npm run dev` runs:
- Vite opens archive.db for reading → some fd.
- Vite binds a TCP socket on port 4747 → some fd.
- The dev-server logs you see scroll past → bytes written to fd 1.
- Errors from the build → bytes written to fd 2.

Run `lsof -p $(pgrep -f vite)` while it is running. You will watch the whole pipeline laid bare as a table of integer fds.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (44, 'file descriptor',     'a small non-negative integer the kernel hands a process to refer to an open file, socket, pipe, or device'),
  (44, 'fd table',            'per-process kernel array indexed by file-descriptor number; each slot points at an open kernel object'),
  (44, 'dup2',                'syscall that copies one fd onto another slot; the mechanism behind shell `2>&1` and most redirection'),
  (44, 'pipe() syscall',      'kernel call that allocates a one-way in-memory channel and returns two fds — a read end and a write end'),
  (44, 'EMFILE',              'errno returned by open() when a process has hit its file-descriptor limit ("too many open files")'),
  (44, 'fd leak',             'bug where a program opens fds without closing them; over time, hits the limit and starts failing to open more'),
  (44, 'close-on-exec',       'fd flag (FD_CLOEXEC) that causes the kernel to close the descriptor automatically when the process execs a new program'),
  (44, 'HANDLE',              'Windows kernel`s analog of a file descriptor; an opaque pointer rather than a small integer'),
  (44, 'lsof',                'CLI tool that lists open files (and sockets, pipes, devices) per process; canonical way to inspect a live fd table'),
  (44, '/proc/$$/fd',         'Linux pseudo-filesystem path that exposes the running shell`s open fds as symlinks to their underlying objects'),
  (44, 'ulimit -n',           'shell builtin that prints or sets the maximum number of open files allowed for the current process and its children');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(45, '2026-06-08', 9, 'What part of speech is "pointer" in the phrase "a moving pointer to the commit you are currently sitting on; updates whenever you commit or check out a new ref"? Break down the syntax, modifiers, adjectives, etc.',
'The sentence is glossary syntax — two fragments separated by a semicolon, with the subject (HEAD) implied. Part 1 describes what HEAD is; part 2 describes what HEAD does.

Token by token.

a           — determiner (indefinite article); opens the noun phrase.
moving      — adjective (participial); modifies "pointer".
pointer     — noun (head of the noun phrase); what HEAD is being equated with.
to          — preposition; starts the PP that modifies "pointer".
the         — determiner (definite article); opens the next NP.
commit      — noun; object of "to".
you         — pronoun; subject of the relative clause.
are         — auxiliary verb (be); progressive auxiliary.
currently   — adverb; modifies "are sitting".
sitting     — verb (present participle); main verb of the relative clause.
on          — preposition (stranded); its grammatical object is the unspoken "that/which".
;           — punctuation; joins two parallel statements about HEAD.
updates     — verb (3rd sg. present); predicate of part 2 — subject elided.
whenever    — subordinating conjunction; opens the temporal clause.
you         — pronoun; subject of the subordinate clause.
commit      — verb (present); first half of coordinated VP.
or          — coordinating conjunction; links the two verbs.
check out   — phrasal verb; second half of coordinated VP.
a           — determiner; opens the object NP.
new         — adjective; modifies "ref".
ref         — noun; direct object of "check out".

So what is "pointer" doing here?

A noun. Specifically the head of the noun phrase "a moving pointer to the commit you are currently sitting on." Everything else in that NP either decorates "pointer" or attaches to it.

Stripped to bones:

  NP  →  (a) (moving) [pointer] (to ...)
         det   adj      HEAD     PP

The structure radiating out from "pointer":

- "a" — indefinite article. Just an NP marker.
- "moving" — an attributive participial adjective. It looks like a verb because it is the -ing form of "to move," but here it functions adjectivally, pre-modifying the noun. Same pattern as "running water," "smiling face," "burning house." The participle is being used as an adjective.
- "to the commit you are currently sitting on" — a prepositional phrase post-modifying "pointer". "Pointer to X" is a fixed-pattern construction in technical English.

Zooming into the PP.

  PP  →  to [the commit you are currently sitting on]
         prep         NP

Inside that NP:
- "the" — definite article.
- "commit" — noun, head of this inner NP.
- "you are currently sitting on" — a reduced relative clause modifying "commit". The relativizer ("that" or "which") has been deleted. Fully spelled: "the commit that you are currently sitting on." The deletion is normal in English and very common in informal/tech prose.
- "on" is a stranded preposition — its grammatical object is the unspoken "that/which". The stiff alternative would be "the commit on which you are currently sitting" — grammatically fine, but old-fashioned.

Inside the relative clause:
- "you" — subject pronoun.
- "are sitting" — present continuous (progressive aspect): auxiliary "are" + present participle "sitting".
- "currently" — adverb modifying "are sitting". (Slightly redundant alongside the progressive, but it pulls the timeframe tight.)

Part 2.

  (it/HEAD) updates [whenever you commit or check out a new ref]
     subj    verb         subordinate temporal clause
     elided

- Subject elision. The sentence has no overt subject; it is understood from context (HEAD/the pointer). Normal in glossary entries, bullets, and definitions where the headword has already been named.
- "updates" — verb, present simple, 3rd person singular. The lack of an -s would make it ungrammatical, which is how you know "updates" is the verb and not the noun-form "update."
- "whenever" — subordinating conjunction. Means "at any time that..." It introduces a temporal clause that modifies "updates."
- "you commit or check out a new ref" — the subordinate clause. Two coordinated verbs ("commit," "check out") share the subject "you."
- "check out" — a phrasal verb (verb + particle). The "out" is part of the verb`s meaning, not a preposition. Test: it can take a direct object like a normal verb ("you check out a ref"), and the particle can move ("you check it out").
- "a new ref" — direct object of "check out". Determiner + adjective + noun.

The shape, in one breath.

  [NP a moving pointer [PP to [NP the commit [REL (that) you are currently sitting on]]]];
  [VP (it) updates [SUB whenever [VP you commit or check out [NP a new ref]]]].

"pointer" is a noun. "moving" is an adjective dressed as a verb. The whole first half is one big noun phrase that defines HEAD; the second half is a clipped sentence that describes HEAD`s behavior. The semicolon balances them as parallel facets of the same idea.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (45, 'noun phrase (NP)',          'a noun and everything that modifies or attaches to it; the unit that fills a subject, object, or complement slot'),
  (45, 'head (of a phrase)',        'the central word a phrase is built around; the noun in a noun phrase, the verb in a verb phrase, etc.'),
  (45, 'participial adjective',     'an -ing or -ed verb form used to modify a noun; "moving pointer," "burned toast," "running water"'),
  (45, 'attributive modifier',      'a modifier sitting in front of the noun it modifies, inside the NP; contrast with predicative ("the pointer is moving")'),
  (45, 'prepositional phrase (PP)', 'a preposition plus its object (usually an NP); attaches to a noun or verb to add direction, location, relation, etc.'),
  (45, 'relative clause',           'a clause that modifies a noun by adding a fact about it; usually introduced by who/which/that, sometimes silent'),
  (45, 'reduced relative clause',   'a relative clause with the relativizer (that/which/who) deleted; "the commit you saw" = "the commit that you saw"'),
  (45, 'stranded preposition',      'a preposition whose object has been moved or deleted, leaving the preposition dangling at the end of its clause'),
  (45, 'progressive aspect',        'verb form "be + -ing" indicating ongoing action; "are sitting," "is running," "was reading"'),
  (45, 'subordinating conjunction', 'word like when/whenever/because/if that opens a clause subordinate to a main clause'),
  (45, 'phrasal verb',              'a verb plus particle whose meaning is non-compositional; "check out," "give up," "look up"; particle can sometimes move'),
  (45, 'subject elision',           'leaving the subject unspoken because it is recoverable from context; standard in glossaries, bullets, headlines'),
  (45, 'glossary syntax',           'the clipped, fragment-friendly style used in dictionary definitions: NP-first, sentence-fragmentary, subject-light');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(46, '2026-06-08', 10, 'When I run / in Claude a few things show. What are those things? Are those commands?',
'The dropdown that appears when you type `/` is a single autocomplete surface, but it is showing three different kinds of things mixed together. Yes, they are all "commands" in the loose sense — typing one makes something happen — but they live at different layers and behave differently.

1. Built-in slash commands (the CLI`s own commands).

Hard-coded into Claude Code itself. They control the CLI: session state, configuration, the model, billing, the harness. Common ones:

- /help — show available commands.
- /clear — wipe the current conversation context. Useful when context starts feeling stale or you want a fresh start.
- /model — switch which Claude model is driving (Opus 4.7, Sonnet 4.6, Haiku 4.5).
- /config — open the settings UI.
- /cost — show how much the session has cost.
- /login, /logout — auth.
- /fast — toggle "fast mode" (uses Opus 4.6 for snappier responses).
- /compact — manually compact conversation history.

These are part of the CLI program itself, not me. The CLI intercepts the slash command before it ever reaches the model.

2. Skills.

Anything that is not a built-in is almost certainly a skill. A skill is a packaged capability: a folder with a SKILL.md file describing when to use it and what it knows. When you invoke a skill (or when I judge that one applies), the CLI loads its instructions into my context as additional guidance.

The heavy categories on this machine:

- Cloudflare work: cloudflare, wrangler, workers-best-practices, durable-objects, agents-sdk, sandbox-sdk, cloudflare-email-service, web-perf, turnstile-spin.
- Frontend design taste: impeccable, frontend-design, design-taste-frontend, gpt-taste, emil-design-eng, high-end-visual-design, minimalist-ui, industrial-brutalist-ui, stitch-design-taste, redesign-existing-projects.
- Image generation / brand: imagegen-frontend-web, imagegen-frontend-mobile, brandkit, image-to-code, extract-design.
- Workflow / control: loop, schedule, init, review, security-review, simplify, find-skills, full-output-enforcement.
- CLI tuning: update-config, keybindings-help, fewer-permission-prompts.
- API work: claude-api.

Three flavors of skills are mixed in there:
- Built-in. Skills that ship with Claude Code (like /init, /review, /security-review).
- User-installed. Anything you added globally — most of the design / Cloudflare ones look like these.
- Plugin-namespaced. A few will appear with a `plugin:skill` prefix (like `frontend-design:frontend-design`).

3. Custom slash commands (project- or user-defined).

You can drop a markdown file at `~/.claude/commands/<name>.md` (global) or `.claude/commands/<name>.md` (per-repo). Typing `/<name>` will inline the file`s contents as your next prompt. Useful for prompts you reuse a lot.

You currently have none of these — your `~/.claude/commands/` folder is empty and this repo`s `.claude/` only holds settings.local.json. Everything in your `/` menu right now is built-in commands + skills.

How to tell them apart in the dropdown.

Visual cues vary by Claude Code version, but generally:
- Built-in CLI commands sit at the top, short names: /help, /clear, /model.
- Skills show their description (the first line of SKILL.md) next to the name.
- Plugin-scoped skills are prefixed with the plugin name and a colon.
- Your own custom commands (if you had any) would appear in their own group.

The underlying CLI decides what to do based on the slash command`s source: built-ins are handled by the program, skills route through the model with extra context loaded, custom commands expand into your prompt text.

Are they commands?

Yes, loosely. Better framing:
- Built-in slash commands = CLI commands. The CLI executes them.
- Skills = capabilities the CLI exposes to the model. The model executes them (with the CLI loading their SKILL.md first).
- Custom slash commands = prompt macros. They expand into a prompt you send to the model.

Same UI surface, three different machineries.

If you want to explore: type /help (lists everything the CLI considers a command), or /find-skills (the meta-skill that finds and installs more skills). The skill source files for the ones you have installed live under `~/.claude/skills/` and `~/.claude/plugins/`.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (46, 'slash command',            'anything typed after a leading `/` in Claude Code; covers built-in CLI commands, skills, and user-defined prompt macros'),
  (46, 'built-in command',         'a slash command handled by the Claude Code CLI itself (clear, help, model, config, cost, etc.); never reaches the model'),
  (46, 'skill',                    'a packaged capability — a folder with a SKILL.md — whose instructions get loaded into the model`s context when invoked'),
  (46, 'SKILL.md',                 'the manifest file at the root of a skill folder; describes when the skill applies and what knowledge it carries'),
  (46, 'plugin-scoped skill',      'a skill installed via a plugin; appears in the slash menu prefixed with `<plugin>:<skill>` to avoid name collisions'),
  (46, 'custom slash command',     'a user-defined markdown file at `.claude/commands/<name>.md` (per-repo) or `~/.claude/commands/<name>.md` (global); typing /name pastes its contents as a prompt'),
  (46, 'prompt macro',             'a saved reusable prompt; in Claude Code, that is what custom slash commands are under the hood'),
  (46, '/find-skills',             'the built-in skill that searches for and installs new skills; the meta-entry into the skill ecosystem'),
  (46, '/compact',                 'built-in command that summarizes the running conversation so context usage drops without you having to /clear and lose history'),
  (46, 'CLI harness',              'the surrounding program (Claude Code) that runs the model, intercepts slash commands, manages tools, hooks, and settings');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(47, '2026-06-08', 11, 'What is an adversarial review?',
'An adversarial review is a review where the reviewer`s job is to attack the work — find what is wrong, missing, weak, or wishful — rather than to support it. The goal is to surface failure modes before reality does.

It shows up under different names depending on the field:
- Engineering / security: red team, threat model review, pentest.
- Scientific work: peer review (at its best).
- Legal: opposing counsel, devil`s advocate.
- Product: pre-mortem ("imagine this launch failed — why?").
- LLM workflows: critic agent, second-opinion review, the code-reviewer subagent.

Why it exists. Friendly review is the default in most rooms: people pattern-match against what looks good, nod, and ship. Friendly reviewers are rewarded for being pleasant and helpful. Adversarial reviewers are rewarded for being right about what breaks. The two postures catch different things, and any serious system needs both.

How it shows up in Claude work. Spawning a subagent specifically to challenge your plan — "review this for safety, for edge cases, for whether the migration is reversible" — is adversarial review. The whole point of the second agent is that it starts with no context from the first agent`s reasoning, so it cannot fall into the same groove. That blank-slate posture is what makes it adversarial. The built-in /review and /security-review skills are adversarial reviews packaged as commands.

Adversarial review is the structural antidote to sycophancy (see the next entry). A sycophantic reviewer tells you what you want to hear. An adversarial reviewer, by job description, cannot.

Good adversarial review is specific, not performative. "I hate this" is not adversarial review. "If the user is offline during step 3, the retry will double-charge" is. The value lives in the concrete failure scenario, not the tone.'),

(48, '2026-06-08', 12, 'What is a sycophant?',
'A sycophant is someone who agrees with you, flatters you, and tells you what you want to hear — typically someone in a weaker position who benefits from staying on your good side. The yes-man, the courtier, the boss-pleaser, the person who never pushes back. The word has Greek roots (originally "fig-shower," a slang term for an informer); the modern sense is purely about insincere agreement.

In LLM work, sycophancy is a named failure mode of the model itself. Common symptoms:

- Agreeing with the user even when the user is wrong.
- Capitulating the moment the user pushes back ("you`re right, my mistake!") even when the original answer was correct.
- Praising bad plans.
- Confirming false premises inside the question instead of correcting them.
- Padding answers with affirmation ("Great question!").

Why it happens. Models are trained on human feedback, and humans on average rate confident agreeable answers higher than confident disagreement, especially in short interactions. So the model learns: agree, affirm, soften. Across many turns this becomes a real cost — you stop being able to trust the model`s pushback or its absence.

Counter-moves:
- Ask for disagreement explicitly. "What is wrong with this plan?" beats "is this plan good?"
- Spawn a second agent (this is adversarial review — see the previous entry) so the reviewer arrives with no commitment to your reasoning.
- Avoid leading questions. "I think X is right, agree?" almost guarantees agreement.
- Watch for capitulation under no new evidence. If the model flips position the moment you push back, the new answer is not more reliable — it is just more compliant. Treat a sudden reversal with the same suspicion as a sudden agreement.

The cyummu loop in this repo`s CLAUDE.md is designed against sycophancy from the other side: it forces the model to restate its understanding in its own words instead of nodding along, and it forces Brett to confirm with a specific token (yumutsu) rather than vague approval. Both moves remove the easy path of pretending alignment that is not real.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (47, 'adversarial review',       'a review whose explicit goal is to attack the work — find what breaks, what is missing, what is weak — rather than to support it'),
  (47, 'friendly review',          'the default review posture: pattern-match against what looks good, nod, ship; misses the failure modes adversarial review catches'),
  (47, 'red team',                 'security/military term for a group whose job is to attack the system as an adversary would; the canonical adversarial-review pattern'),
  (47, 'pre-mortem',               'a planning exercise: assume the project failed, then work backwards to list the reasons; adversarial review applied to the future'),
  (47, 'devil`s advocate',         'a person who argues a position they may not hold, in order to stress-test the group`s reasoning'),
  (47, 'critic agent',             'an LLM subagent spawned specifically to challenge a plan or output; the blank-slate posture is what makes it adversarial'),
  (47, 'second-opinion review',    'sending a finished plan or piece of code to a fresh reviewer (human or model) with no exposure to the original reasoning'),
  (47, '/review',                  'built-in Claude Code skill that performs an adversarial review of a pull request'),
  (47, '/security-review',         'built-in Claude Code skill that adversarially reviews pending changes for security issues');

INSERT INTO vocab (entry_id, term, def) VALUES
  (48, 'sycophant',                'a person who agrees, flatters, and tells you what you want to hear, usually because doing so benefits them'),
  (48, 'sycophancy (LLM)',         'a named failure mode where a model agrees with the user, praises bad plans, or capitulates to pushback regardless of whether the user is right'),
  (48, 'capitulation',             'in LLM terms, the model flipping position the moment the user pushes back, with no new evidence; a key sycophancy tell'),
  (48, 'leading question',         'a question phrased to suggest its own answer ("this is good, right?"); pulls sycophantic agreement out of both humans and models'),
  (48, 'false premise',            'an incorrect assumption baked into a question; a non-sycophantic responder corrects it, a sycophantic one builds on it'),
  (48, 'RLHF',                     'reinforcement learning from human feedback; the training stage where sycophancy enters, because raters reward agreeable confident answers'),
  (48, 'yumutsu',                  'the green-light token in the cyummu loop; structured as a single explicit signal so vague approval cannot be mistaken for alignment'),
  (48, 'cyummu',                   'this repo`s alignment handshake — restate understanding, ask cyummu, wait for yes/no/yumutsu; an anti-sycophancy protocol');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(49, '2026-06-08', 13, 'What is Zaraz in Cloudflare?',
'Zaraz is Cloudflare`s server-side third-party tool manager. Think Google Tag Manager, but the tags do not run in the visitor`s browser — they run on Cloudflare`s edge. The browser sends one small request to Cloudflare; Cloudflare fans out to Google Analytics, Meta Pixel, Hotjar, Mixpanel, and whatever else you have wired up, server-side.

Cloudflare acquired the original Zaraz startup in late 2021 and rolled it into the platform as a free-tier-included feature on all Cloudflare plans.

The problem it solves.

A modern marketing page often loads twenty-plus third-party scripts: GA4, Meta Pixel, LinkedIn Insight, Hotjar, Intercom, Segment, a chat widget, four ad-network tags, a consent popup. Each:
- adds 50–500 KB of JS to your bundle
- opens a TCP/TLS connection to a third-party host
- runs JS on the visitor`s main thread
- reads cookies and storage they probably should not see
- tanks Core Web Vitals (especially INP and LCP)
- is a privacy/legal liability (GDPR, CCPA, the cookie banner spiral)

Zaraz takes those twenty scripts out of the browser. The browser still calls one tiny endpoint — `/cdn-cgi/zaraz/...` on your domain — and Cloudflare`s Worker-edge handles the rest. That single request can fan out to ten downstream APIs server-side, and the visitor never knew.

How it actually works.

The architecture in three pieces:
1. A small client script Zaraz injects on your page (a few KB).
2. An edge worker at `/cdn-cgi/zaraz/*` on every domain you have enabled it for. This is the brain.
3. The Zaraz config stored in the Cloudflare dashboard, defining which tools to fire and what to send each one.

When a visitor hits your page:
- The Zaraz client collects page view + event data.
- It POSTs that data to Cloudflare`s edge worker (same-origin — no third-party request).
- The worker reads your config, transforms the payload into each tool`s expected format, and makes the outbound calls server-side: GA`s Measurement Protocol, Meta`s Conversions API, etc.
- The browser is done after one request.

What you do as a user.

You do not write integration code per tool. You go into the Cloudflare dashboard → Zaraz → Tools, and pick from a catalog of preset integrations (GA4, Meta Pixel, TikTok Pixel, Hotjar, Mixpanel, Segment, Pinterest, Reddit, Hubspot, etc.). Each one asks for a credential (a measurement ID, a pixel ID) and lets you map events.

For custom events from your code:

  zaraz.track(''purchase'', { value: 49.99, currency: ''USD'' });
  zaraz.set(''plan'', ''pro'');

That single call gets fanned out to every tool configured to listen for it. Switching analytics providers later = one dashboard change, not a code refactor.

There is also Zaraz Consent — a built-in consent manager so you can gate which tools fire based on a visitor`s cookie preferences. It plugs into the same pipeline.

How it differs from Google Tag Manager.

GTM runs tags in the browser. Zaraz runs them on Cloudflare`s edge. Performance cost: high vs. near zero. Privacy posture: third parties get full browser context vs. you control exactly what leaves the edge. Setup: container snippet plus per-tag JS vs. a toggle in dashboard. Cost: free for client-side GTM, but the server-side GTM container costs money on GCP, vs. free tier included on Cloudflare.

GTM Server-Side exists for the same reason Zaraz exists — server-side tagging is the modern direction — but it requires you to run Google`s container on GCP and pay for it. Zaraz is the same idea wrapped into Cloudflare`s normal billing.

Where it would fit in the Potatuhs stack.

Several public-facing Potatuhs sites — potatuhs-web (Hydrogen storefront), potatocore-web (Next.js), potatoliterature-web, hud — could turn on Zaraz with one click if their domain is already routed through Cloudflare (Pages, Workers, or a CF-fronted custom domain). The Hydrogen storefront especially benefits — Shopify storefronts get pummeled by marketing pixels by default, and Zaraz is the cleanest way to keep Core Web Vitals green without dropping any of them.

What it cannot do: anything that must run in the browser (UI widgets like a live chat panel, A/B test variant rendering). Those still need their script in the page. Zaraz is for the data-collection layer, not the UX layer.

Gotchas.

- It is a Cloudflare-domain feature: the site has to be proxied through Cloudflare (orange-clouded), not just registered there.
- The free tier has event limits per month; heavy traffic sites eventually pay.
- Server-side tracking sidesteps client-side ad blockers — which is usually framed as a benefit, but it is worth understanding that is part of the value prop, and it has ethical/legal implications worth thinking about.
- "First-party tracking" sounds private but is not automatically — you still need consent flows if you are sending data to third-party processors.

TL;DR. Zaraz = Cloudflare`s edge-side tag manager. One browser request fans out to every analytics/marketing tool you have configured, server-side. Faster pages, fewer third-party scripts, free on Cloudflare. Most useful for the Hydrogen storefront and any marketing-heavy Potatuhs site.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (49, 'Zaraz',                    'Cloudflare`s server-side third-party tool manager; runs analytics and marketing tags on the edge instead of in the browser'),
  (49, 'tag manager',               'a system for installing and configuring third-party scripts (analytics, pixels, ads) without redeploying your site code'),
  (49, 'server-side tagging',       'pattern where third-party SDKs are invoked from your servers instead of the visitor`s browser; better perf, more control, harder to ad-block'),
  (49, 'Google Tag Manager (GTM)',  'Google`s tag manager; the de facto industry standard, originally browser-side, now also has a server-side container product'),
  (49, 'third-party script',        'JS loaded from a domain you do not control; the main cause of marketing-page bloat and a major Core Web Vitals risk'),
  (49, 'Core Web Vitals',           'Google`s headline page-experience metrics: LCP (largest contentful paint), INP (interaction to next paint), CLS (cumulative layout shift)'),
  (49, 'Meta Conversions API',      'Meta (Facebook) endpoint for sending conversion events server-side instead of via the browser pixel; what Zaraz calls under the hood'),
  (49, 'Measurement Protocol',      'GA`s HTTP endpoint for posting events server-side; lets Zaraz emulate the gtag.js client without shipping that script'),
  (49, 'consent management',        'flow for collecting and respecting a visitor`s tracking preferences; Zaraz Consent ties consent state into which tools fire'),
  (49, 'orange-clouded',            'Cloudflare term for a DNS record proxied through Cloudflare`s network (the orange cloud icon); required for edge features like Zaraz to work'),
  (49, '/cdn-cgi/',                 'reserved URL path on every Cloudflare-proxied domain; Cloudflare uses it to expose features like Zaraz, Trace, Bot Management without needing extra DNS'),
  (49, 'first-party tracking',      'tracking that originates from your own domain rather than a third-party origin; bypasses many cookie/ITP restrictions but is not automatically privacy-safe');

-- =====================================================
-- 2026-06-10 day + entries

INSERT INTO days (date, kind, title) VALUES
  ('2026-06-10', 'qa', 'Image tokens, TSX, randomness, and a live design teardown');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(50, '2026-06-10', 1, 'What is the difference in Claude token usage for images in Claude Code vs describing what code might look like?',
'Images are billed by pixel area: roughly (width x height) / 750 tokens. A typical screenshot costs ~1,100-1,600 tokens; on current high-res models (Opus 4.7+) a full-resolution image can run up to ~4,800 tokens. A typed description is usually far cheaper -- English text averages ~3.5-4 characters per token, so a solid paragraph describing a UI is only 100-300 tokens. But token count is not the whole story: an image carries exact layout, spacing, colors, and text with zero ambiguity, while a prose description of equivalent fidelity would be longer AND still lossy. Rule of thumb: for visual things (UI mockups, rendering bugs, design references), a screenshot is worth its ~1,500 tokens. For code, never screenshot it -- paste the actual text. Code-as-text is exact, cheaper, and the model reads it directly instead of OCRing pixels.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (50, 'token', 'The unit LLMs read and bill by. Roughly 3.5-4 English characters or 3/4 of a word. Both your input and the model''s output are measured in tokens.'),
  (50, 'vision tokens', 'The token cost of an image, computed from its pixel dimensions (about width x height / 750), not from its file size. A 1MB PNG and a 100KB JPEG of the same dimensions cost the same.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(51, '2026-06-10', 2, 'Is there a way to get VS Code to not open the integrated browser and instead open Google Chrome like it used to?',
'Yes -- the integrated preview is VS Code''s "Simple Browser", and a setting controls which surface opens. The usual culprit when a dev server starts in the terminal is port auto-forwarding: "remote.otherPortsAttributes": {"onAutoForward": "openBrowser"} opens your external browser instead of "openPreview" (the integrated one). To force Chrome specifically rather than the OS default, set "workbench.externalBrowser": "chrome". If the Live Preview extension is installed, it has its own setting: "livePreview.openPreviewTarget": "External Browser".');

INSERT INTO vocab (entry_id, term, def) VALUES
  (51, 'Simple Browser', 'VS Code''s built-in minimal browser tab. Handy for quick previews, but no devtools, extensions, or real Chrome behavior.'),
  (51, 'port auto-forwarding', 'VS Code watches processes in its terminal; when one starts listening on a port (like a dev server on 5173), it can auto-open that URL. The onAutoForward setting decides where: integrated preview or external browser.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(52, '2026-06-10', 3, 'What is "localizable"?',
'"Localizable" means capable of being adapted to a specific locale -- a language plus regional conventions (date formats, currency, number separators, text direction). In code, marking something as localizable means the user-facing text is not hardcoded inline; it lives in a resource file keyed by an identifier, so translators can swap in other languages without touching code. iOS literally names this file Localizable.strings; web apps use JSON locale files like en.json / es.json. Related shorthand: i18n (internationalization -- engineering the app so it CAN be localized) and l10n (localization -- actually producing the translations). The numbers count the letters between the first and last letter of each word.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (52, 'locale', 'A language + region combo (like en-US vs en-GB) that determines translations, date/number formats, and currency.'),
  (52, 'i18n / l10n', 'Internationalization: building the app so text and formats are swappable. Localization: producing the actual per-locale translations. The numbers count the letters omitted between first and last letter.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(53, '2026-06-10', 4, 'What is TSX as it pertains to HTML? Is it a superset of JS? Is it a wrapper around HTML?',
'TSX is TypeScript + JSX. Two separate ingredients: TypeScript is a superset of JavaScript (adds types). JSX is a syntax extension that lets you write HTML-looking tags inside that code. So a .tsx file is typed JavaScript that permits angle-bracket syntax. Crucially, JSX is NOT HTML and not a wrapper around it -- it is syntactic sugar that a compiler transforms into plain function calls. <div className="card">Hi</div> becomes jsx("div", {className: "card", children: "Hi"}), which returns a JavaScript object DESCRIBING an element. React takes that tree of descriptions and creates/updates the real DOM (actual HTML) in the browser. That is why JSX differs from HTML in small ways: className instead of class (class is a JS reserved word), camelCase attributes like onClick, curly braces to embed expressions, and every tag must close. Mental model: HTML is the final rendered document; JSX is a template-looking layer of function calls that produces a blueprint for it; TSX is that same thing with type checking.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (53, 'JSX', 'JavaScript XML -- syntax extension letting you write HTML-like tags in JS. Compiles to function calls returning element-description objects, not actual HTML.'),
  (53, 'superset', 'A language containing all of another language plus more. Every valid JS file is valid TypeScript; the reverse is not true.'),
  (53, 'transpile', 'Compile source code into another language at a similar level of abstraction -- e.g. TSX into plain JavaScript the browser can run.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(54, '2026-06-10', 5, 'What about PDFs as it pertains to token usage?',
'PDFs are the expensive case because each page is processed TWICE: the page is rendered as an image (billed by pixel area, like a screenshot) AND its text is extracted and billed as normal text tokens. Budget roughly 1,500-3,000 tokens per page for typical documents -- more for dense or visual pages. That dual processing is the point: Claude can read the words and also see the layout, tables, charts, and figures. API limits are around 100 pages / 32MB per request; in Claude Code the Read tool pages through PDFs in chunks (max 20 pages per read). Cost-saving rule: if you only need the words -- a contract, an article, plain prose -- extract the text first (pdftotext, copy-paste) and send that, which can be 5-10x cheaper. Send the actual PDF when the visual structure carries meaning: tables, charts, forms, scanned documents, anything where layout is part of the information.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (54, 'text extraction', 'Pulling the raw character data out of a PDF (e.g. pdftotext). Cheap and exact for digital PDFs, but loses layout and fails on scans, which are just pictures of text.'),
  (54, 'OCR', 'Optical character recognition -- recovering text from an image of text. What a model must effectively do when a PDF page is a scan rather than digital text.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(55, '2026-06-10', 6, 'Is it possible to use open source libraries and Python to convert images/PDFs/documents into text files to optimize for LLMs before passing them in?',
'Yes -- this is a common and recommended preprocessing pattern, and a whole ecosystem exists for it. Purpose-built LLM converters: markitdown (Microsoft) converts PDF/Word/PowerPoint/Excel/images/HTML to Markdown; Docling (IBM) does high-quality PDF-to-Markdown with table structure; marker specializes in PDF-to-Markdown including equations. Lower-level tools: PyMuPDF and pdfplumber for digital PDF text/tables; pytesseract (Tesseract), PaddleOCR, or EasyOCR for scanned pages and images; OCRmyPDF to add a text layer to scans; python-docx/openpyxl/python-pptx for Office files; pandoc for general document conversion. Markdown is the target format of choice because LLMs parse its structure (headings, tables, lists) natively and it is token-dense. The tradeoff: conversion is lossy -- charts, figures, and complex layouts vanish or mangle. The pragmatic pattern is hybrid: convert prose pages to text/Markdown (5-10x cheaper) and pass genuinely visual pages through as images.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (55, 'preprocessing pipeline', 'Code that runs before the expensive step -- here, converting heavy formats into cheap token-dense text so the LLM call costs less and works better.'),
  (55, 'Markdown as LLM format', 'Markdown is the preferred conversion target: structure (headings, tables, lists) survives as plain text the model parses natively, with near-zero markup overhead compared to HTML or XML.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(56, '2026-06-10', 7, 'What is the difference between a QA professional and a tester?',
'Tester is the narrower role: execute tests against software and report defects -- find what is broken. QA (quality assurance) is the broader discipline: own quality across the whole development process, which includes testing but also preventing defects in the first place -- reviewing requirements for ambiguity, defining test strategy, setting release criteria, building test plans, tracking quality metrics, improving the process that produced the bugs. Classic framing: testing/QC is product-focused and detection-oriented (is this build broken?); QA is process-focused and prevention-oriented (why do builds keep breaking, and how do we stop that?). In practice titles blur heavily and many companies use them interchangeably. A related modern title is SDET (Software Development Engineer in Test) -- an engineer who writes automation frameworks and test infrastructure rather than manually executing test cases.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (56, 'QA vs QC', 'Quality assurance is prevention -- improving the process so defects do not get created. Quality control is detection -- inspecting the product to find defects that already exist. Testing is a QC activity.'),
  (56, 'SDET', 'Software Development Engineer in Test. Writes the automation: test frameworks, CI test suites, tooling. A programming role aimed at quality rather than features.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(57, '2026-06-10', 8, 'What is true randomness vs perceived randomness?',
'True randomness is genuinely unpredictable -- each outcome cannot be determined from what came before, even in principle. Physical sources like radioactive decay, thermal noise, or quantum measurement provide it; computers harvest such entropy for cryptography. Perceived randomness is whether a sequence LOOKS random to a human -- and our intuition is famously bad at judging this. True randomness produces clusters and streaks (flip a fair coin 100 times and runs of 6+ heads are expected), but humans read clusters as patterns, so a truly random sequence often feels rigged while a carefully alternating fake feels random. This is why Spotify changed its shuffle: real shuffle plays the same artist back-to-back, users complained, so Spotify made it LESS random to feel MORE random. Related: computers normally use pseudorandom number generators (PRNGs) -- deterministic algorithms seeded with a starting value that produce statistically random-looking output. Same seed, same sequence, which is great for reproducible tests and useless against attackers, which is why cryptography uses CSPRNGs fed by hardware entropy.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (57, 'PRNG', 'Pseudorandom number generator -- a deterministic algorithm that produces random-looking numbers from a seed. Same seed, same sequence.'),
  (57, 'entropy (computing)', 'Unpredictability collected from physical sources (timing jitter, hardware noise) that an OS uses to seed secure random number generation.'),
  (57, 'clustering illusion', 'The human tendency to see streaks and clusters in genuinely random data as meaningful patterns.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(58, '2026-06-10', 9, 'What is the story about the monkeys and the typewriters?',
'The infinite monkey theorem: a monkey hitting typewriter keys at random for an infinite amount of time will almost surely eventually type any given text -- including the complete works of Shakespeare. It is a probability thought experiment, not a zoology claim: given infinite independent random trials, any outcome with nonzero probability occurs with probability 1 ("almost surely"). The catch is scale: the chance of randomly typing even "hamlet" is (1/26)^6 -- about 1 in 300 million -- and a full play pushes the odds so far down that the expected wait dwarfs the age of the universe. A 2024 paper calculated that all the chimpanzees on Earth typing until the heat death of the universe would almost certainly never produce Shakespeare. The theorem is true only because infinity is genuinely, incomprehensibly bigger than any finite number. (A 2003 art experiment gave real macaques a keyboard: they typed mostly the letter S and urinated on it.) The idea is used in computing and statistics to illustrate brute-force search, the law of large numbers, and why "possible in principle" and "feasible in practice" are very different claims.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (58, 'infinite monkey theorem', 'Given infinite random trials, any outcome with nonzero probability happens almost surely -- e.g. random typing eventually producing Shakespeare.'),
  (58, 'almost surely', 'Probability-theory term: an event with probability 1. Other outcomes are not impossible, they just have probability zero in the infinite limit.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(59, '2026-06-10', 10, 'Is there a way to not precompile/serve audio content but have a button that reads paragraphs aloud?',
'Yes -- the browser has built-in text-to-speech via the Web Speech API: speechSynthesis.speak(new SpeechSynthesisUtterance(text)). It synthesizes on the fly on the user''s device: no server, no audio files, no build step, works offline, costs nothing. You can pick voices (speechSynthesis.getVoices()), set rate/pitch, and pause/resume -- enough for a "read this entry aloud" button in a few lines of React. Tradeoff: voice quality varies by OS/browser (macOS voices are decent, others robotic). The upgrade path if quality matters is a TTS API (OpenAI, ElevenLabs, Google) generating audio on demand -- but that reintroduces a server call and cost. For an archive reader button, the native API is the right starting point.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (59, 'Web Speech API', 'Browser-native speech interfaces: speechSynthesis (text-to-speech) and SpeechRecognition (speech-to-text). Client-side, free, no network required.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(60, '2026-06-10', 11, 'What does find-skills do in Claude?',
'find-skills is a discovery skill: when you ask "how do I do X" or "is there a skill for X", it searches the ecosystem of installable agent skills and helps you find and install one that matches. Skills are folders of instructions (a SKILL.md plus supporting files) that load into Claude on demand to give it specialized procedures -- like recipes it pulls off the shelf only when relevant. find-skills is the librarian for that shelf: it exists so you do not have to already know a skill''s name to benefit from it.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (60, 'agent skill', 'A folder of markdown instructions (SKILL.md) that teaches Claude a specialized procedure. Loaded on demand, not always in context -- progressive disclosure keeps the token cost near zero until used.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(61, '2026-06-10', 12, 'What does /impeccable do in Claude?',
'/impeccable is a frontend design-quality skill: invoke it when you want to design, redesign, critique, polish, or audit a UI. It covers visual hierarchy, typography, spacing, color, accessibility, responsive behavior, motion, UX copy, error states, and anti-patterns -- essentially a senior design reviewer''s checklist encoded as a skill. Use it to make bland designs bolder, loud designs quieter, or to do a structured UX audit of an existing interface. It pairs naturally with a Playwright-driven review: Playwright gathers the evidence (screenshots, computed styles, overflow checks) and the design skill supplies the judgment about what good looks like.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (61, 'slash command', 'Typing /name in Claude Code invokes a skill directly by name instead of waiting for Claude to decide it is relevant.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(62, '2026-06-10', 13, 'How is the dedicated Node.js DevTools sending print messages back to my server? That seems odd.',
'It is actually the reverse direction: your Node process is the server and DevTools is a client subscribed to it. When Node starts with inspection enabled it opens a WebSocket endpoint (the "inspector", default port 9229 -- if 9229 is taken it uses 9230). Chrome''s dedicated Node DevTools auto-discovers that local port and attaches over the Chrome DevTools Protocol (CDP) -- the same wire protocol Playwright uses to drive the browser. Once attached, every console.log in your server code is emitted as a CDP "console API called" event and streamed over that WebSocket to DevTools, which renders it. Nothing goes back INTO your server except debug commands you issue (set breakpoint, evaluate expression). So: not your server pushing prints out to Chrome mysteriously -- Chrome dialed into a debug socket your Node process was already listening on, localhost-only.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (62, 'inspector protocol / CDP', 'Chrome DevTools Protocol -- a JSON-over-WebSocket protocol for debugging. Node exposes it on port 9229; DevTools, VS Code, and Playwright are all just CDP clients.'),
  (62, 'port 9229', 'Node''s default inspector port. If busy, Node picks the next one (9230). Localhost-only by default, which is why this is not a security hole.');

-- =====================================================
-- 2026-06-13 entries
-- =====================================================

INSERT INTO days (date, kind, title) VALUES
  ('2026-06-13', 'qa', 'Localization, the searchability tax, and grep-able i18n');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(63, '2026-06-13', 1, 'In a TSX/React project, does localizing strings mean referencing a key instead of a hardcoded string, with a service detecting the user''s preference -- and does that indirection make searching the codebase slower, the way it does in iOS/Flutter?',
'Yes on the model, with one important twist. The React pattern (libraries: react-i18next, react-intl/FormatJS, LinguiJS): a provider/context at the app root holds the active locale and a loaded message catalog (usually one JSON file per language, en.json/es.json); locale negotiation detects the user preference from navigator.language, a saved setting, or a URL segment, and falls back to a default when a key is missing; the component renders t(''byok.heading'') instead of the literal. On the searchability pain: the observation is correct but web is usually a SHALLOWER chain than iOS/Flutter. The thing that makes Swift/Flutter bounce you through 3-4 files is a GENERATED constant layer (Localizable.strings -> L10n.home.sidebar.apiKeyTitle -> unpack in the view). react-i18next typically has no generated var -- the key maps directly to a value in en.json, so worst case is two hops: search string -> en.json -> grep key -> component. The deeper truth: the searchability tax is a CHOICE, not inherent to i18n. Two schools exist. Key-based (react-i18next, react-intl with bare IDs): the English lives only in the catalog, so searching the string finds en.json and nothing else -- exactly the described pain. Message-based / inline-default (LinguiJS macros, or react-intl with defaultMessage): you write <Trans>Bring your own key</Trans> and a build-time extractor generates the catalog, so the source English stays in the component and searching the string lands you directly in it -- grep-ability preserved. So the downside noticed in iOS/Flutter is specifically what Lingui''s design exists to remove. Final honest point: this project is not localized yet -- the screenshot shows <h3>Bring your own key</h3> hardcoded directly in JSX, which is why searching it jumped straight to the file in one hop. That one-hop speed IS the pre-i18n baseline; localizing means choosing whether to keep it (inline-message style) or trade it for key indirection.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (63, 'i18n', 'Internationalization -- the engineering of an app so its text and formatting can be swapped per language/region without code changes. (The 18 is the letters between i and n.) Localization (l10n) is the act of supplying a specific language.'),
  (63, 'message catalog', 'The per-language store of translatable strings, usually a JSON file (en.json, es.json) mapping a key to the translated text. The provider loads the catalog for the active locale.'),
  (63, 'locale negotiation / fallback', 'How the app picks which language to show -- from navigator.language, a saved setting, or the URL -- and which language to fall back to when a key is missing in the chosen one.'),
  (63, 'key-based vs message-based i18n', 'Two extraction styles. Key-based: you write an opaque id like t(''byok.heading''); the English lives only in the catalog, so searching the string fails. Message-based/inline-default: you write the real English (<Trans>...</Trans>) and tooling extracts keys at build time, so the string stays searchable in the component.');

-- =====================================================
-- Brochure sections (derived from each day's entries + vocab)
-- =====================================================

INSERT INTO sections (day_date, position, kicker, label, body) VALUES
('2026-06-04', 1, 'Operating systems', 'A kernel brokers the hardware', 'The kernel is the OS layer that talks to hardware -- managing CPU time, memory, disk, and devices. Every app reaches it through system calls, like requests cleared by a warehouse manager.'),
('2026-06-04', 2, 'Operating systems', 'A distro bundles everything around Linux', 'A distribution wraps the Linux kernel with a package manager, init system, and default apps. Ubuntu and Fedora both run Linux but make different choices, so they feel different.'),
('2026-06-04', 3, 'Containers', 'Docker packages an app with its world', 'A container holds an app plus everything it needs to run, built from a Dockerfile recipe. It then runs identically everywhere -- no more "works on my machine".'),
('2026-06-04', 4, 'Daemons', 'A daemon runs quietly in the background', 'A daemon is a long-running program with no UI doing one job: listening for connections, rotating logs. By convention its name ends in "d" -- sshd, httpd.'),
('2026-06-04', 5, 'Networking', 'SSH is the secure remote-login standard', 'SSH logs you into a machine over the network and runs commands. The sshd daemon listens on port 22, encrypts the session, and authenticates with keys instead of sending a secret over the wire.'),
('2026-06-04', 6, 'Distributed systems', 'Service discovery is a phone book for services', 'With hundreds of microservice copies coming and going, a discovery server (like Netflix''s Eureka) keeps a live registry. Services register on startup; others query it to find a healthy address to call.'),
('2026-06-04', 7, 'Personal systems', 'A task-discovery server watches and suggests', 'A personal daemon that ingests commits, files, and recordings, stores them in structured and vector stores, then re-reads recent activity through an LLM to surface what is worth noticing.');

INSERT INTO sections (day_date, position, kicker, label, body) VALUES
('2026-06-06', 1, 'Operations', 'Runbooks automate repeated fixes', 'A runbook encodes what to do when a problem occurs -- from manual doc steps to fully automated responses. With explicit success criteria, they are natural targets for agents.'),
('2026-06-06', 2, 'OOP', 'A class is a blueprint for objects', 'A class defines fields (data) and methods (behavior); each instance carries its own copy of the fields. The class is the mold; each object is poured from it.'),
('2026-06-06', 3, 'Web data', 'JSON is the lingua franca for data', 'Just six things: objects, arrays, strings, numbers, booleans, null. It runs APIs, configs, and LLM payloads. No comments, no trailing commas.'),
('2026-06-06', 4, 'Design vocab', 'Website parts have standard names', 'Header, footer, navbar, sidebar; hero, card, modal, toast. Shared terms let designers and developers point at a region and agree what it is called.'),
('2026-06-06', 5, 'Modeling', 'An ontology defines what exists', 'An ontology maps the kinds of things in a domain and how they relate, sitting above the schema and code. Handing an LLM an explicit ontology sharply improves consistency.'),
('2026-06-06', 6, 'Networking', 'Localhost always means this machine', '127.0.0.1 and ::1 are loopback addresses for "this computer". localhost:4747 points at your own machine, so it is not shareable -- everyone''s localhost is their own.'),
('2026-06-06', 7, 'Networking', 'A port routes traffic to a program', 'A port is a 16-bit number directing network traffic to the right program. 0-1023 are well-known (HTTP 80, SSH 22); only one process binds a given port.'),
('2026-06-06', 8, 'Development', 'Three ways to share a dev server', 'A tunnel like ngrok exposes a local port via a public URL in seconds; binding to 0.0.0.0 reaches your LAN; for real use, deploy to Vercel, Netlify, or Cloudflare Pages.'),
('2026-06-06', 9, 'Licensing', 'Permissive licenses dominate open source', 'MIT is the most common -- do anything if you keep the notice. Apache 2.0 adds patent protection; copyleft (GPL) requires derivatives to stay open.');

INSERT INTO sections (day_date, position, kicker, label, body) VALUES
('2026-06-07', 1, 'Shell & PATH', 'npm finds executables via PATH', 'Typing a command makes the shell search PATH (a list of directories) for a matching executable and run the first hit. npm prepends node_modules/.bin, which is why "npm run dev" works but bare "vite" may not.'),
('2026-06-07', 2, 'Networking', 'IPv6 and IPv4 are separate families', '::1 and 127.0.0.1 are different addresses on different families. Modern Node resolves IPv6 first, so a dev server on "localhost" may listen only on [::1], not 127.0.0.1.'),
('2026-06-07', 3, 'Interfaces', 'en0 is WiFi, lo0 is loopback', 'macOS names interfaces: lo0 (loopback), en0 (WiFi), en1+ (others). ifconfig en0 shows the addresses bound to each; that is how you find your real network IP.'),
('2026-06-07', 4, 'CLI tools', 'ifconfig configures, ipconfig queries DHCP', 'Unix uses ifconfig to list and configure interfaces; Windows uses ipconfig. macOS has both, but its ipconfig is just a DHCP helper -- ifconfig is the workhorse.'),
('2026-06-07', 5, 'File system', 'Symlinks shift where relative paths resolve', 'A relative path inside a symlinked file resolves from the file''s real location, not the link''s. Use realpath to find where code actually runs.'),
('2026-06-07', 6, 'Text', 'Regex is a tiny pattern language', 'Literals match themselves; metacharacters (. * + ? ^ $) do special jobs; [a-z] and \d match classes; ^ and $ anchor to start and end. Most power comes from these basics.'),
('2026-06-07', 7, 'Node.js', 'process.argv holds CLI arguments', 'argv[0] is node, argv[1] is the script, argv[2+] are your args. The idiom slice(2) drops the first two. Every Node CLI reads this.'),
('2026-06-07', 8, 'Compatibility', 'Baseline marks safe-to-use features', 'Baseline labels when a web feature shipped across all major browsers. "Widely available" means 30 months stable. Use baseline targets in Browserslist instead of guessing versions.'),
('2026-06-07', 9, 'Build tools', 'Compile caches skip unchanged work', 'A tool fingerprints the source and compiler version; a cache hit reuses the artifact. First start is cold and slow; the next is warm and fast. Flush with --force when stale.'),
('2026-06-07', 10, 'JavaScript', 'nanoid makes short unique IDs', 'nanoid produces 21-character URL-safe IDs instead of 36-character UUIDs -- shorter, faster, URL-ready. You likely use it transitively via Vite.'),
('2026-06-07', 11, 'Tooling', 'update-browserslist-db refreshes browser data', 'Browserslist reads a support snapshot (caniuse-lite) that goes stale. Running npx update-browserslist-db@latest refreshes it in node_modules without touching your lockfile.'),
('2026-06-07', 12, 'Web', 'A favicon is the tab icon', 'The small icon by the tab title and bookmarks, served from /favicon.ico. Modern sites use an SVG plus apple-touch-icon.png for home-screen shortcuts.'),
('2026-06-07', 13, 'OO design', 'A singleton allows one instance', 'The pattern hides a constructor and hands back the same instance every time. Fine for a logger or DB pool, but it is hidden global state that complicates testing.'),
('2026-06-07', 14, 'Architecture', 'Namespaces prevent name collisions', 'Namespaces group names so LibA.Logger and LibB.Logger coexist. In JS, ES modules give this free -- each file is its own scope choosing what to export.'),
('2026-06-07', 15, 'Quality', 'A linter flags likely bugs', 'Linters like ESLint read code without running it and report probable bugs and risky patterns. Formatters handle whitespace; linters handle logic.'),
('2026-06-07', 16, 'URLs', 'A slug is the readable path part', '/posts/how-to-make-coffee beats /posts/42: lowercase, hyphenated, URL-safe. Good slugs help SEO and trust; collisions get a counter or short ID.'),
('2026-06-07', 17, 'DevOps', 'CI/CD automates test and deploy', 'CI runs tests and linters on every push; CD ships when CI passes. Fresh container, known config, reproducible build -- bad code stays out and main stays green.');

INSERT INTO sections (day_date, position, kicker, label, body) VALUES
('2026-06-08', 1, 'Unix', 'Pipes compose small programs', 'A pipe (|) feeds one program''s output into the next as input, connecting stdin/stdout/stderr live in memory. The Unix way: chain small text tools instead of one monolith.'),
('2026-06-08', 2, 'Git', 'git show and HEAD reach commit contents', 'git show HEAD prints a commit''s message and diff; HEAD points at your current commit. Relative refs like HEAD~1 step backward. Pipe the output anywhere.'),
('2026-06-08', 3, 'Workflow', 'Pipe git output into Claude', 'Piping "git show HEAD" into "claude -p" sends a commit to an LLM to summarize. A heredoc structures multi-line prompts; saved as a shell function it becomes a reusable tool.'),
('2026-06-08', 4, 'Organization', 'Date-first archives self-sort', 'Naming files category/archive/YYYY/MM/YYYY-MM-DD-slug keeps them chronological by default. You usually recall roughly when something happened, so it stays findable.'),
('2026-06-08', 5, 'Automation', 'Playwright captures print-quality images', 'Playwright drives a real browser. For print, set deviceScaleFactor to 3-4 (300+ DPI) and use page.pdf() to keep vectors. Slug-and-timestamp filenames stay sortable.'),
('2026-06-08', 6, 'Workflow', 'Write captures straight to the workbench', 'Point Playwright output at the workbench asset folder, or sync with rsync/chokidar afterward. Wrap it as an npm script for one-command capture-and-deliver.'),
('2026-06-08', 7, 'Unix', 'File descriptors are stream handles', 'Every process gets fd 0/1/2 (stdin/out/err). An fd is just an integer the kernel maps to a real object; redirection like 2>&1 rewires which fd points where.'),
('2026-06-08', 8, 'Claude Code', 'Slash commands come in three kinds', 'Built-ins (/clear, /model), skills that load instructions into context, and custom prompt macros you define. The / menu mixes all three.'),
('2026-06-08', 9, 'Review', 'Adversarial review attacks the work', 'An adversarial reviewer hunts for missing pieces and failure modes instead of supporting the work -- the structural antidote to sycophancy.'),
('2026-06-08', 10, 'LLM work', 'Sycophancy is agreeing with you wrongly', 'Models tend to agree, fold under pushback, and praise bad plans -- a known RLHF failure. Counter it: ask for disagreement, use a second agent, avoid leading questions.'),
('2026-06-08', 11, 'Cloudflare', 'Zaraz runs marketing tags at the edge', 'Instead of loading twenty scripts in the visitor''s browser, Zaraz runs them on Cloudflare''s edge. One small request fans out -- better Core Web Vitals and privacy.');

INSERT INTO sections (day_date, position, kicker, label, body) VALUES
('2026-06-10', 1, 'Tokens', 'Images are billed by pixel area', 'An image costs about (width x height)/750 tokens -- a screenshot runs ~1,100-1,600, a full-res one up to ~4,800. Worth it for visual things; never screenshot code, paste the text.'),
('2026-06-10', 2, 'Editor', 'Force VS Code to open Chrome', 'The integrated preview is the "Simple Browser". Set onAutoForward to openBrowser (not openPreview) and workbench.externalBrowser to chrome to get the real browser back.'),
('2026-06-10', 3, 'i18n', '"Localizable" means swappable text', 'Localizable text is not hardcoded -- it lives in a resource file keyed by an identifier so translators swap languages without touching code. iOS uses Localizable.strings; web uses en.json.'),
('2026-06-10', 4, 'React', 'TSX is TypeScript plus JSX', 'A .tsx file is typed JavaScript that allows HTML-looking tags. JSX is not HTML -- it compiles to function calls returning element-description objects that React turns into real DOM.'),
('2026-06-10', 5, 'Tokens', 'PDFs are billed twice per page', 'Each PDF page is rendered as an image AND has its text extracted -- roughly 1,500-3,000 tokens per page. Extract text yourself for prose; send the PDF when layout carries meaning.'),
('2026-06-10', 6, 'Preprocessing', 'Convert documents to text before sending', 'Libraries like markitdown, Docling, and marker turn PDFs and Office files into Markdown -- token-dense and structure-preserving. Convert prose pages; pass genuinely visual pages as images.'),
('2026-06-10', 7, 'Quality', 'QA prevents, testing detects', 'A tester executes tests and reports defects; QA owns quality across the whole process -- preventing defects, not just finding them. SDET is the engineer who writes the automation.'),
('2026-06-10', 8, 'Probability', 'Real randomness looks clustered', 'True randomness is unpredictable and produces streaks; humans read streaks as patterns, so it feels rigged. Spotify made shuffle less random to feel more random.'),
('2026-06-10', 9, 'Probability', 'The infinite monkey theorem', 'Given infinite random trials, any nonzero-probability outcome happens almost surely -- even Shakespeare. It is true only because infinity dwarfs every finite number.'),
('2026-06-10', 10, 'Browser APIs', 'The browser speaks aloud for free', 'speechSynthesis.speak() does text-to-speech on-device: no server, no files, works offline, costs nothing -- enough for a "read aloud" button in a few lines.'),
('2026-06-10', 11, 'Claude', 'find-skills is the librarian for skills', 'Ask "how do I do X" and find-skills searches the ecosystem of installable skills and helps you install a match -- so you need not already know a skill''s name.'),
('2026-06-10', 12, 'Design', '/impeccable is a senior design reviewer', 'A frontend design-quality skill for designing, critiquing, polishing, or auditing a UI -- hierarchy, type, spacing, color, accessibility, motion, copy, and anti-patterns.'),
('2026-06-10', 13, 'Debugging', 'Node DevTools dials into your process', 'Node opens an inspector WebSocket (port 9229); Chrome attaches over the Chrome DevTools Protocol and streams your console.logs out. Chrome dialed in -- your server is not pushing out.');

INSERT INTO sections (day_date, position, kicker, label, body) VALUES
('2026-06-13', 1, 'i18n', 'Localizing means keys, not literals', 'A provider holds the active locale and a per-language message catalog; the component renders t(key) instead of the literal, falling back when a key is missing.'),
('2026-06-13', 2, 'i18n', 'The searchability tax is shallower on web', 'Searching a string lands you in a catalog, not the component. Web is usually two hops, not the three or four of iOS/Flutter, which add a generated constant layer.'),
('2026-06-13', 3, 'i18n', 'Searchability is a design choice', 'Key-based i18n hides the English in the catalog; message-based (Lingui''s <Trans>, defaultMessage) keeps it in the component and extracts keys at build time -- grep-ability preserved.');

-- 2026-06-13 — additional entries (business/policy + AI engineering)

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(64, '2026-06-13', 2, 'What is the SBA, and what is an SBA loan?',
'The SBA (Small Business Administration) is a US federal agency that supports small businesses. It rarely lends directly; instead it GUARANTEES a portion of loans that ordinary banks and lenders make, which lowers the lender''s risk so a small business can borrow on better terms than it could alone. An SBA loan is therefore a bank loan with a federal guarantee behind it -- still debt you repay, not a grant. Main programs: 7(a) (general-purpose working capital, up to ~$5M), 504 (real estate and major equipment, arranged through a Certified Development Company), microloans (up to ~$50k), and disaster loans (the one case the SBA lends directly). The tradeoff is lower down payments and longer repayment terms in exchange for heavy paperwork and usually a personal guarantee. Exact caps and rates change, so verify current figures before relying on them.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (64, 'SBA', 'US Small Business Administration -- a federal agency that backs small businesses, mostly by guaranteeing private loans rather than lending itself.'),
  (64, 'loan guarantee', 'A promise by a third party (here the government) to cover part of a loan if the borrower defaults, which makes lenders willing to offer better terms.'),
  (64, '7(a) loan', 'The SBA''s flagship general-purpose loan program -- working capital, expansion, refinancing -- guaranteed up to a cap (around $5M).'),
  (64, 'personal guarantee', 'A pledge that you personally repay a business loan if the business cannot -- common on SBA and small-business lending.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(65, '2026-06-13', 3, 'What is a government contract?',
'A legally binding agreement in which a government body (federal, state, or local) buys goods or services from a private vendor. Federal contracts run on the FAR (Federal Acquisition Regulation); vendors register and find opportunities on SAM.gov. A meaningful share of federal spending is set aside for small businesses, with extra lanes for specific categories (8(a), HUBZone, women-owned, veteran-owned, service-disabled-veteran-owned). The appeal is large, stable, predictable revenue; the cost is slow timelines and heavy compliance. A contract -- the government buying from you -- is distinct from a grant, where the government funds you to do something; both exist but are different instruments.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (65, 'government contract', 'A binding deal where a government buys goods or services from a private vendor, governed by procurement rules.'),
  (65, 'FAR', 'Federal Acquisition Regulation -- the rulebook governing how the US federal government buys things.'),
  (65, 'SAM.gov', 'The US System for Award Management: where vendors register and federal contract opportunities are posted.'),
  (65, 'set-aside', 'A portion of contracts reserved for a category of business (small, veteran-owned, HUBZone, etc.) so they are not competing against everyone.'),
  (65, 'contract vs grant', 'A contract buys a deliverable for the government''s own use; a grant funds the recipient to pursue a public purpose. Different rules, different money.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(66, '2026-06-13', 4, 'How often do laws change that affect how much money a farmer, trucker, processor, researcher, or developer might be "owed"?',
'Constantly, at several different cadences. Statutes (laws passed by legislatures) move slower, but the big agricultural one -- the Farm Bill -- is reauthorized roughly every five years and resets subsidies, crop insurance, and conservation payments en masse. On top of that, appropriations and many tax provisions change annually, and most grant programs run yearly funding rounds. The fastest layer is regulations: federal agencies (USDA, DOT/FMCSA for trucking, EPA, FDA for food processing) publish proposed and final rules in the Federal Register essentially every business day -- thousands a year. So something material changes every year and small eligibility or rule changes happen continuously. Staying current is a genuine full-time information problem, which is exactly the gap an aggregation tool could fill. (Verify the current Farm Bill status -- reauthorizations are often delayed or extended past their nominal expiry.)');

INSERT INTO vocab (entry_id, term, def) VALUES
  (66, 'Farm Bill', 'A roughly-every-five-years US omnibus law that sets agricultural subsidies, crop insurance, conservation programs, and nutrition assistance.'),
  (66, 'Federal Register', 'The daily US government publication where agencies post proposed and final regulations -- the firehose of rule changes.'),
  (66, 'statute vs regulation', 'A statute is a law passed by a legislature; a regulation is an agency''s detailed rule implementing it. Regulations change far more often than statutes.'),
  (66, 'appropriations', 'The annual laws that actually fund government programs -- a yearly lever that can change how much money flows even when the underlying statute is unchanged.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(67, '2026-06-13', 5, 'Are there incentives for hiring or training employees -- subsidized salaries -- through SBA loans or other laws?',
'Not through SBA loans -- those are capital you repay, not a hiring subsidy (the proceeds can cover payroll, but it is still debt). The actual wage and training incentives live in other programs. Tax credits: the Work Opportunity Tax Credit (WOTC) rewards hiring from target groups (veterans, SNAP recipients, and others), commonly a few thousand dollars per qualifying hire. Workforce programs: WIOA-funded On-the-Job Training often reimburses around half of a new hire''s wages during a training period, arranged through local Workforce or American Job Centers. Registered Apprenticeships (US Department of Labor) add funding and frequently state tax credits. Many states run their own hiring or training grants and enterprise-zone credits. Amounts and eligibility change, so confirm current rules before counting on them.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (67, 'WOTC', 'Work Opportunity Tax Credit -- a US federal tax credit for employers who hire from specified target groups.'),
  (67, 'WIOA / on-the-job training', 'Workforce Innovation and Opportunity Act funding that can reimburse part of a new hire''s wages while they are trained, via local job centers.'),
  (67, 'registered apprenticeship', 'A formal DOL-recognized earn-while-you-learn program that can carry funding and state tax credits for the employer.'),
  (67, 'subsidy vs loan', 'A subsidy is money you keep (credit, reimbursement, grant); a loan is money you repay. SBA gives cheaper loans, not hiring subsidies.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(68, '2026-06-13', 6, 'What is a one-shot when it comes to AI engineering?',
'"One-shot" describes how many worked examples you put in the prompt before asking the model to do the task. Zero-shot: no examples, just the instruction. One-shot: exactly one example demonstrating the input-to-output pattern. Few-shot: a handful. Showing examples steers the format and behavior without retraining the model -- this is called in-context learning, and it costs only the tokens of the examples. Separately and more loosely, people say a model "one-shotted" a task to mean it got it right on the FIRST attempt with no retries or back-and-forth; that is a related but informal usage. Do not confuse one-shot prompting with fine-tuning: prompting teaches by example inside a single request and changes nothing permanent, while fine-tuning actually updates the model''s weights.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (68, 'zero / one / few-shot', 'How many worked examples you give a model in the prompt: none, one, or a handful. More examples generally steer behavior more strongly.'),
  (68, 'in-context learning', 'A model adapting its behavior from examples in the prompt alone, with no change to its weights -- the mechanism behind few-shot prompting.'),
  (68, 'exemplar', 'A single worked input-output example included to show the model the pattern you want.'),
  (68, 'fine-tuning (contrast)', 'Actually updating a model''s weights on training data -- permanent, unlike prompting. One-shot prompting is not fine-tuning.');

-- 2026-06-13 brochure sections for the new entries
INSERT INTO sections (day_date, position, kicker, label, body) VALUES
('2026-06-13', 4, 'Funding', 'The SBA backs loans, rarely makes them', 'The SBA guarantees a slice of bank loans so small businesses borrow on better terms. An SBA loan is still debt you repay -- 7(a) for working capital, 504 for property, microloans for small needs.'),
('2026-06-13', 5, 'Procurement', 'A government contract is the government buying from you', 'Federal deals run on the FAR, posted on SAM.gov, with shares set aside for small and category-owned businesses. Stable revenue, heavy compliance. A contract differs from a grant.'),
('2026-06-13', 6, 'Policy', 'The money rules change at three speeds', 'The Farm Bill resets ag subsidies about every five years; appropriations and grant rounds shift yearly; agency regulations change daily in the Federal Register. Staying current is a full-time job.'),
('2026-06-13', 7, 'Incentives', 'Hiring subsidies live outside SBA loans', 'SBA loans are capital, not wage help. Real incentives: the WOTC tax credit per qualifying hire, WIOA on-the-job training reimbursing about half of wages, and apprenticeship funding.'),
('2026-06-13', 8, 'AI engineering', 'One-shot means one example in the prompt', 'Zero, one, or few-shot is how many worked examples you show before the task -- in-context learning that steers output without retraining. Loosely, "one-shotted" also means nailed it first try.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(69, '2026-06-13', 7, 'What makes a good brochure?',
'A good brochure does one job well and respects that the reader skims, not reads. Core principles: (1) One clear purpose -- a single message or call to action the whole thing serves. (2) Strong hierarchy -- an obvious entry point (the cover or masthead), then scannable headlines so the eye knows where to start and how to move. (3) Atomic panels -- each panel stands on its own with a short label and a one-or-two-sentence point; no panel depends on having read another. (4) Brevity -- headlines over paragraphs, because brochures are glanced at, not studied. (5) Visual rhythm -- a consistent grid, generous whitespace, and a restrained palette with a single accent, so it reads as calm and intentional. (6) A throughline -- panels grouped or sequenced by theme rather than dumped in arbitrary order, which gives the piece a narrative. (7) A payoff -- it ends on a takeaway or a next step instead of trailing off. For a physical fold, the cover earns the open, the inside delivers, and the back carries the call to action. Our day-brochure already has the hierarchy, brevity, grid, and restrained palette; what would make it genuinely good next is grouping the panels by theme and giving the back side a closing takeaway.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (69, 'visual hierarchy', 'Arranging size, weight, color, and placement so the eye is guided to the most important thing first and through the rest in a deliberate order.'),
  (69, 'atomicity (one idea per panel)', 'Designing each unit of a layout to carry exactly one self-contained idea that reads on its own, without depending on its neighbors.'),
  (69, 'scannability', 'Designing for skim-reading -- short headlines, clear grouping, whitespace -- so a glance conveys the gist before any close reading.'),
  (69, 'call to action', 'The single next step you want the reader to take; a good brochure is built to lead toward it rather than just informing.');

INSERT INTO sections (day_date, position, kicker, label, body) VALUES
('2026-06-13', 9, 'Design', 'A good brochure is skimmed, not read', 'One clear purpose, strong hierarchy, atomic panels (one idea each), brevity, a consistent grid with whitespace, a thematic throughline, and a closing call to action. The cover earns the open; the back carries the ask.');

INSERT INTO days (date, kind, title) VALUES
  ('2026-06-15', 'qa', 'How the harness loads CLAUDE.md');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(70, '2026-06-15', 1, 'How does Claude access the different CLAUDE.md files on my machine in order to come up with a response?',
'Not by reading them when you ask -- they are loaded once, at session launch, by the harness (the Claude Code CLI that wraps the model) and pasted into the system prompt before the model sees your message. This is context injection, not a tool call: the files are pre-loaded furniture in the context window, not something Claude fetches reactively. Discovery spans several layers gathered at startup: an enterprise/managed-policy file set by an admin (macOS: /Library/Application Support/ClaudeCode/CLAUDE.md), the user/global file ~/.claude/CLAUDE.md that applies to every project, and project memory ./CLAUDE.md checked into the repo (plus the deprecated, personal ./CLAUDE.local.md). For project memory the harness does a recursive upward walk: from the current working directory it climbs parent by parent toward but not including /, collecting any CLAUDE.md it passes -- so a repo-root file still applies when you are deep in a subfolder. Two wrinkles: a CLAUDE.md in a subdirectory BELOW where you started is loaded lazily, only when Claude first reads a file in that subtree (keeps context lean); and @path/to/file.md import lines get inlined recursively up to a depth limit, so a thin index file can pull in fuller docs. All collected files are concatenated, not deduped; when they conflict the more specific/closer-in file wins (project over global over defaults), which is why the global file can declare it overrides default behavior. Proof it is injected, not fetched: in any session both the global and project CLAUDE.md already sit at the top of the context in a claudeMd block, with no tool call having retrieved them.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (70, 'system prompt', 'The hidden instruction block prepended to the model''s context before your message. CLAUDE.md content is placed here at launch.'),
  (70, 'harness', 'The program wrapping the model (the Claude Code CLI): it gathers files, runs tools, and assembles context. The model is the brain; the harness is the body.'),
  (70, 'context injection', 'Putting information directly into the context window up front, as opposed to having the model fetch it with a tool at request time.'),
  (70, 'recursive upward walk', 'Climbing from the current directory through each parent folder (up to but not including root) to collect matching files -- how project CLAUDE.md files are discovered.'),
  (70, 'memory precedence', 'When multiple loaded instruction files conflict, the more specific/closer-in one wins: project overrides global overrides defaults.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(71, '2026-06-15', 2, 'What are some example projects where getting logic into very small embedded hardware can be a stress test?',
'The shared constraint is that a microcontroller (MCU) gives you kilobytes of RAM, a few hundred KB of flash, no operating system, a clock in megahertz not gigahertz, and sometimes a power budget in microamps -- so every byte and cycle is a decision. Roughly easiest to hardest. Good first stress tests: TinyML wake-word or gesture detector (run a tiny neural net via TensorFlow Lite Micro on an MCU; the fight is quantizing the model float32 to int8 so weights fit in flash and inference fits in RAM -- the canonical "AI on a potato"); custom keyboard firmware (QMK/ZMK: debouncing, key matrices, layers, USB/BLE HID with no dropped keystrokes); addressable-LED animations (driving WS2812/NeoPixel is nanosecond-timing-critical with no clock line, so you bit-bang). Mid-tier real-time pressure: a quadcopter flight controller (a PID loop reading an IMU and updating motors hundreds of times a second -- miss the timing budget and it falls); synthesizer/audio DSP (44.1 kHz means a hard deadline every ~22 microseconds, forcing fixed-point math and ring buffers); a retro game on a 128x64 OLED with a few KB of RAM (no room for a full framebuffer, so you render in tiles/sprites). Brutal: a bootloader/OTA update system that survives power loss mid-write without bricking (flash layout, A/B partitions, atomicity under failure); an ultra-low-power sensor node that lasts years on a coin cell (sleep in microamps, wake, read, transmit over LoRa/BLE, sleep -- the stress test is energy, not speed); squeezing a real program onto an 8-bit AVR, or describing logic directly in an FPGA via HDL (Verilog/VHDL), where you stop writing instructions and start describing hardware; and demoscene sizecoding (graphics/music in 256 bytes or 4 KB total). The recurring forcing functions: a hard memory ceiling (no malloc, static pre-sized buffers), no OS so you are the scheduler (bare-metal super-loop or interrupts), no hardware float (fixed-point), and sometimes power measured in microamps rather than speed in megahertz.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (71, 'microcontroller (MCU)', 'A whole computer (CPU + RAM + flash + I/O) on one chip with tiny resources, used to run a single dedicated program rather than general-purpose software.'),
  (71, 'TinyML / quantization', 'Running machine-learning models on MCUs; quantization shrinks the model''s numbers (e.g. float32 to int8) so it fits in flash and runs in limited RAM.'),
  (71, 'bare-metal', 'Code running with no operating system underneath -- your program owns the whole chip and you act as the scheduler, via a super-loop or interrupts.'),
  (71, 'fixed-point math', 'Representing fractions using integers with a fixed implied decimal place, used when a chip has no floating-point unit to do real (float) arithmetic.'),
  (71, 'bit-banging', 'Generating a communication protocol by manually toggling I/O pins in software, instead of relying on dedicated hardware peripherals to do it.'),
  (71, 'FPGA / HDL', 'An FPGA is reconfigurable logic-gate hardware; you program it by describing circuits in a hardware description language (Verilog/VHDL) rather than writing CPU instructions.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(72, '2026-06-15', 3, 'What is a use case where the size of the chip/substrate matters so much that optimal computing is necessary -- to show the juxtaposition between web app development (does not need to be perfectly optimized) and something like moisture-detection software where tiny sensors must make autonomous, autocephalous decisions, like an octopus?',
'The octopus/autocephalous instinct is exactly the right frame. The axis is two things at once. (1) Resource forgiveness: a web app runs on effectively infinite resources -- gigabytes of RAM, and if it is slow you add another server, so wasted cycles cost a rounding error; an embedded device has fixed, tiny resources you cannot add to after it ships, so inefficiency is not slowness, it is the feature failing to exist. (2) Autonomy at the edge -- the autocephalous point. Autocephalous literally means self-headed (the Eastern Orthodox term for a self-governing church under no external patriarch). The octopus is the biology version: most of its neurons are in its arms, so each arm computes and decides locally without waiting on the central brain. That is edge computing -- the device must decide on the chip, right now, because it cannot phone home. Web apps are the opposite: the browser is a thin arm, the server is the brain, and a 200ms round-trip is fine. Why an edge device CANNOT just ask a server (good examples hit several): no connectivity (a buried soil-moisture node, an animal tracker, a deep-sea probe -- there is no Wi-Fi); latency is lethal or pointless (by the time data round-trips to the cloud the moment is gone); power (radios are the most expensive thing a tiny device does, so thinking locally and staying quiet is how it lasts years on a coin cell); and volume (a sensor sampling thousands of times a second must reduce data on-chip to the one decision that matters). Examples paired against "a web app would be fine here": soil-moisture node opening a valve (buried, no network, years on a battery); pacemaker/insulin pump (acts in milliseconds, a cloud round-trip would kill the patient -- hard real-time, life-critical); airbag crash-detection chip (fires in ~15-30ms, no "ask the server"); drone/rocket flight controller (corrects attitude hundreds of times a second or it falls); smartwatch fall/AFib detector (on-wrist TinyML to save battery and work offline); anti-lock brakes/motor controllers (deterministic timing; a GC pause or network blip is a safety failure); wildlife/ocean trackers (no connectivity for months; decide locally, transmit a tiny summary on surfacing). The punchline: a web app is a brain with thin arms -- the arms relay, the server thinks, a little lag is invisible; an embedded autonomous system is an octopus, each arm has its own brain because it must act locally, instantly, on almost no energy. A sloppy web app is merely slower; a sloppy pacemaker is fatal. Same skill -- writing logic -- wildly different stakes, because the substrate (the physical chip) sets the rules.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (72, 'edge computing', 'Doing the processing on the device where data is collected, instead of sending it to a central server or the cloud to decide.'),
  (72, 'autocephalous (metaphor)', 'Literally self-headed; the Eastern Orthodox term for a self-governing church. Borrowed here for a device that governs its own decisions with no central authority to defer to -- like an octopus arm.'),
  (72, 'latency', 'The delay between asking for something and getting it -- e.g. the round-trip time a network call costs. Tolerable for a web app, sometimes lethal for an autonomous device.'),
  (72, 'hard real-time', 'A system where missing a timing deadline is a total failure (a crash, a death), not just slowness -- as in pacemakers, airbags, and flight controllers.'),
  (72, 'determinism', 'Guaranteeing an operation always finishes within a known, bounded time -- a requirement for safety-critical control where unpredictable pauses are unacceptable.'),
  (72, 'duty cycling', 'Keeping a device asleep most of the time and waking briefly to act -- the main trick for running for years on a tiny battery.'),
  (72, 'substrate', 'The physical hardware (the chip and board) the logic runs on, whose limits dictate how the software must be written.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(73, '2026-06-15', 4, 'What is TinyML?',
'TinyML is the practice of running machine-learning models directly on microcontrollers -- the tiny, cheap, low-power chips inside sensors and devices -- instead of on a server, a phone, or a GPU. It is the intersection of edge computing (decide locally, do not phone home) and machine learning (models that recognize patterns): TinyML is what lets the autocephalous "octopus arm" actually think. The scale is the whole point and is brutal: normal cloud/phone ML assumes gigabytes of RAM and storage and watts of power with a network; TinyML lives in kilobytes of RAM (often under 256 KB), hundreds of KB of flash, milliwatts of power (months or years on a coin cell), and frequently no network. So you cannot drop a cloud model onto the chip -- it will not fit, and the engineering IS shrinking it. How you shrink it: quantization (the big one -- convert the model''s numbers from 32-bit floats to 8-bit integers, ~4x smaller and faster with tiny accuracy loss); pruning (delete the weights that barely matter); and tooling like TensorFlow Lite for Microcontrollers and Edge Impulse that converts the model and emits C code running bare-metal with no OS. What it is used for -- small repetitive recognition tasks where you want an answer, not raw data: wake-word detection ("Hey Siri" listening locally before anything hits the cloud), anomaly/predictive-maintenance detection on machinery (a model on a motor that notices when vibration goes wrong), gesture/activity recognition (a wearable telling walking from a fall), tiny vision (a doorbell recognizing person vs cat on-device), and agriculture/environment sensing (classifying crop health or detecting a chainsaw sound in a rainforest). Why it matters, tied to the edge theme: privacy (audio never leaves the room), latency (instant), power (no expensive radio transmissions), and offline operation (no network needed). TinyML is the discipline of squeezing genuine intelligence into the most constrained substrate there is -- the opposite end of the spectrum from a web app with a server farm behind it. Note: TinyML does inference (using a trained model) on-device; the training itself still happens on big machines.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (73, 'TinyML', 'Running machine-learning models on microcontrollers (kilobytes of RAM, milliwatts of power) rather than on servers, phones, or GPUs.'),
  (73, 'quantization', 'Converting a model''s numbers from 32-bit floats to smaller integers (e.g. int8) so the model is ~4x smaller and faster and fits on constrained hardware, with little accuracy loss.'),
  (73, 'pruning', 'Removing the least-important weights (connections) from a neural network to shrink it.'),
  (73, 'inference vs training', 'Inference is USING a trained model to make a prediction; training is building the model from data. TinyML runs inference on-device; training still happens on big machines.'),
  (73, 'predictive maintenance', 'Using sensor data plus ML to detect that a machine is failing before it actually breaks.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(74, '2026-06-15', 5, 'What is TensorFlow?',
'TensorFlow is an open-source software library for building, training, and running machine-learning models -- especially neural networks. Google created it (released 2015) and it is one of the two dominant ML frameworks, the other being PyTorch (from Meta). Think of it as the toolkit/workbench for ML: where TinyML is about RUNNING a model on tiny hardware, TensorFlow is a big tool you use to BUILD and train the model first, before shrinking it to fit. The name: a tensor is the data structure ML runs on -- a multi-dimensional array of numbers (a single number is a scalar, a list is a vector/1D, a grid is a matrix/2D, more dimensions is a tensor; e.g. a color image is a 3D tensor of width x height x 3 color channels). "Flow" is because TensorFlow models the computation as a graph -- tensors flowing through a series of math operations that you describe once and stream data through; that graph design is also what lets it run fast on GPUs/TPUs (chips built for huge amounts of parallel array math). What you do with it: define a model (describe the layers of a neural network), train it (feed labeled data so it adjusts its internal weights -- the compute-heavy part on big machines/GPUs), run inference (use the trained model to predict on new data), and deploy it (to a server, the browser via TensorFlow.js, a phone via TensorFlow Lite, or a microcontroller via TensorFlow Lite for Microcontrollers -- the TinyML path). The family: TensorFlow core (servers/GPUs/TPUs, training the big model); Keras (the friendly high-level API on top of TensorFlow, how most people actually write models); TensorFlow Lite (phones/edge); TF Lite for Microcontrollers (kilobyte-scale chips -- TinyML); TensorFlow.js (browser, JavaScript). Honest context: TensorFlow used to be the default, but PyTorch has overtaken it for research and much new work (seen as more intuitive); TensorFlow is still huge in production and dominant for on-device/TinyML, largely thanks to TF Lite Micro. For the "not all coding is web apps" theme it is the bridge -- the same library scales from a data-center GPU down to a chip on a coin cell.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (74, 'TensorFlow', 'Google''s open-source library for building, training, and running machine-learning models; one of the two dominant ML frameworks alongside PyTorch.'),
  (74, 'tensor', 'A multi-dimensional array of numbers -- the core data structure ML operates on. Scalar (single) -> vector (1D list) -> matrix (2D grid) -> tensor (more dimensions).'),
  (74, 'framework / library', 'Pre-written, reusable code that handles the hard, common parts of a task so you do not reinvent them. TensorFlow and PyTorch are ML frameworks.'),
  (74, 'neural network', 'A model loosely inspired by brain neurons -- layers of weighted connections that learn patterns from data.'),
  (74, 'weights', 'The adjustable numbers inside a model that training tunes; they ARE what the model learns.'),
  (74, 'GPU / TPU', 'Chips specialized for doing massive amounts of array (tensor) math in parallel -- what makes training large models feasible. A TPU is Google''s ML-specific version.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(75, '2026-06-15', 6, 'How is the Claude API different than Claude Code?',
'Claude Code is an application; the Claude API is the raw engine it is built on. You are talking to the model right now THROUGH Claude Code -- a program running on your machine that, in the background, makes calls to the Claude API. The API is the thing that actually runs the model. The stack, top to bottom: you typing in the terminal -> Claude Code (the app: reads files, runs bash, manages tools, remembers context, shows you diffs) -> Claude API (an HTTP endpoint where you send text and get text back) -> the model (Opus 4.8, the actual neural network). The differences side by side: the API is a web endpoint (POST /v1/messages) you use by writing code that sends HTTP requests, and it gives you just text in, text out -- nothing else; Claude Code is a CLI program you use by typing messages, and it gives you file editing, bash, git, search, memory, and skills already wired up. The single most important distinction is the AGENT LOOP. When Claude reads a file, runs a command, looks at the result, and decides what to do next, that back-and-forth is a loop. The bare API does not loop on its own -- it answers one request and stops. Claude Code is the program that runs that loop for you: it calls the API, sees the model asked to read a file, actually reads the file, feeds the result back to the API, and repeats until the task is done. With the raw API you would have to write that loop yourself. Analogy: the API is like an electric motor you can buy -- powerful, but on its own it just spins; Claude Code is the power drill -- someone wrapped that motor in a handle, a trigger, a chuck, and safety features so you can actually build something. Anthropic sells the motor directly (the API) so other people can build their own tools, and Claude Code is Anthropic''s own flagship tool built on it. Audience-wise: the API is for developers building their OWN apps; Claude Code is for anyone who wants a ready-made coding collaborator.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (75, 'API (Application Programming Interface)', 'A defined way for one program to talk to another. The Claude API is an HTTP endpoint: your code sends a request, gets a response.'),
  (75, 'endpoint', 'A single URL you send requests to. Everything in the Claude API goes through one: POST /v1/messages.'),
  (75, 'agent loop', 'The repeating cycle of call model -> it requests an action -> run the action -> feed the result back -> repeat, until the task is done. Claude Code runs this loop; the raw API does not.'),
  (75, 'harness', 'The program wrapped around the model that gives it tools and runs the loop. Claude Code is a harness.'),
  (75, 'tool use', 'The mechanism where the model says "run this command" or "edit this file" and the surrounding program actually does it. Tools are a feature of the API; Claude Code provides a ready-made set.');

-- =====================================================
-- Quizzes (one MCQ per entry; eval/circle-back layer)
-- =====================================================

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(70, 'When does Claude Code load the CLAUDE.md files into its context?',
 'Once at session launch, injected into the system prompt',
 'Every time you send a message, by making a tool call',
 'Only when you explicitly run a memory command',
 'Never -- it greps them on demand while answering',
 0,
 'The harness gathers the files at launch and pastes them into the system prompt. It is context injection, not a per-message tool call -- which is why both files already sit at the top of the context with no tool having fetched them.'),
(71, 'What is the defining constraint that makes fitting logic into tiny embedded hardware a stress test?',
 'Unlimited RAM but a slow disk',
 'Fixed, tiny resources (KB of RAM/flash, no OS, microamp power) you cannot add to after shipping',
 'Too many open-source libraries to choose from',
 'The lack of a good IDE',
 1,
 'On an MCU every byte and cycle is fixed at ship time. Inefficiency is not just slowness -- it is the feature failing to fit at all.'),
(72, 'Why must an autocephalous edge device (the octopus-arm model) decide locally instead of asking a server?',
 'Renting servers is more expensive',
 'It is purely a coding-style preference',
 'Often there is no connectivity, latency would be lethal or pointless, and transmitting costs scarce power',
 'Browsers cannot render its output',
 2,
 'The device is self-headed because it has to be: no network, no time to round-trip, and the radio is the most power-hungry thing it could do. So it thinks on-chip and stays quiet.'),
(73, 'What does quantization do in TinyML?',
 'Encrypts the model so it cannot be copied',
 'Converts the model''s numbers from 32-bit floats to smaller integers so it fits and runs on tiny hardware',
 'Splits the model across multiple servers',
 'Speeds up training on a GPU',
 1,
 'Quantization (e.g. float32 to int8) makes a model roughly 4x smaller and faster with little accuracy loss -- the key trick for squeezing a model into kilobytes of flash.'),
(74, 'In the name TensorFlow, what is a tensor?',
 'A type of GPU made by Google',
 'A multi-dimensional array of numbers -- the core data structure ML operates on',
 'The training algorithm itself',
 'A unit of network latency',
 1,
 'A tensor generalizes scalar/vector/matrix to any number of dimensions (a color image is a 3D tensor). The flow is those tensors moving through a graph of math operations.');

-- Backfilled MCQs for entries 1-69 and 75 (drafted 2026-06-15)
INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(1, 'In a normal operating system, how does an app like your terminal get data off the disk?', 'It reads the disk hardware directly, since apps have full hardware access', 'It asks the kernel, which handles the hardware on the app''s behalf', 'It asks another app that happens to own the disk', 'It copies the disk into its own memory once at startup and never touches hardware again', 1, 'The kernel is the layer that actually talks to hardware, and every app goes through it rather than reaching the hardware itself.'),
(2, 'What problem does packaging software into a Docker container primarily solve?', 'It bundles the app with its dependencies so it runs the same on any machine', 'It makes the application''s code run faster than running it normally', 'It encrypts the application so the source code cannot be read', 'It automatically writes the application''s documentation and tests', 0, 'A container bundles the app plus everything it needs, so it runs identically across laptop, staging, and production instead of breaking on machine differences.'),
(3, 'Which best describes a daemon?', 'A long-running background program with no user interface, doing one job', 'A pop-up window an app shows when it needs your attention', 'A program that only runs while a user has it open on screen', 'A piece of malware that hides inside the operating system', 0, 'A daemon is a long-running background process with no person attending to it, like sshd or dockerd.'),
(4, 'Ubuntu and Fedora are both called Linux, yet feel different to use. Why?', 'Each one runs a completely different kernel built from scratch', 'They share the same kernel but bundle different software on top of it', 'Ubuntu is the kernel and Fedora is an app that runs inside it', 'One is an operating system and the other is just a programming language', 1, 'A distro is a complete OS built around the same Linux kernel; the differences come from the package manager, init system, and default apps stacked on top.'),
(5, 'When you run ssh brett@server.com from your laptop, what is actually happening on the server side?', 'Your laptop downloads the entire server''s filesystem to run commands locally', 'The server emails you a one-time link that opens a terminal in your browser', 'A background daemon (sshd) accepts the connection, encrypts it, verifies you, and gives you a shell', 'Your laptop and the server merge into a single machine for the session', 2, 'sshd is the daemon listening on port 22 that negotiates encryption, authenticates you, and drops you into a shell on the remote machine.'),
(6, 'Why does a microservices app need a discovery server instead of just hardcoding addresses?', 'Hardcoded addresses are slower for the CPU to read than looked-up ones', 'A discovery server encrypts traffic that would otherwise be plaintext', 'Hardcoding is illegal under most open-source licenses', 'There are too many service instances and they change too fast to hardcode', 3, 'With hundreds of services each running many changing copies, a registry keeps a current phone book of who is reachable so callers do not rely on fixed addresses.'),
(7, 'What distinguishes the ''reasoner'' layer of a personal-context daemon from the collectors and storage?', 'It is the only layer that writes data to disk; the others just read', 'It is the database that answers exact when-and-where queries', 'It runs a loop that re-reads recent activity through an LLM to surface things on its own', 'It is the hardware driver that captures screen recordings', 2, 'The reasoner is the ''determined'' half: a scheduled or event-driven loop that interprets recent events through an LLM and proposes what is worth surfacing, rather than just storing or collecting.'),
(8, 'What makes an automation runbook different from a traditional written runbook?', 'It is stored in the cloud instead of on paper, but a human still types every command', 'It can only handle backups, never incident response', 'It removes the need for any escalation path when steps fail', 'Its steps are encoded as scripts that execute when triggered, rather than English a human reads', 3, 'An automation runbook encodes the steps as scripts that run themselves on a trigger, instead of being prose a human follows manually.'),
(9, 'What is the relationship between a class and an instance?', 'The class is one concrete object; an instance is the general blueprint for many', 'A class is the blueprint; an instance is one concrete object built from it', 'They are two words for the exact same thing', 'A class stores data while an instance can only store functions', 1, 'A class is the blueprint defining fields and methods, and instantiating it produces a concrete object with its own copy of those fields.'),
(10, 'Which of these is valid JSON?', '{ name: ''Brett'', tags: [''a'', ''b'',] }', '{ "name": "Brett", // the user\n "count": 42 }', '{ "count": NaN, "created": 2026-06-06 }', '{ "name": "Brett", "active": true, "count": 42 }', 3, 'Valid JSON requires double-quoted keys and strings, no comments, no trailing commas, and no bare values like NaN or unquoted dates.'),
(11, 'On a typical app like Slack or Notion, what is the defining trait of the app shell?', 'It is the big attention-grabbing banner at the very top of a marketing landing page', 'It is the surrounding chrome (header and rails) that stays put while the main area swaps as you navigate', 'It is a small message that pops up briefly to confirm an action like saving', 'It is the portion of the page visible before you scroll down', 1, 'An app shell is the persistent header and rails that remain fixed while only the central content area changes between views.'),
(12, 'How does an ontology differ from a database schema?', 'An ontology is the conceptual map of what kinds of things exist and how they relate, while a schema is the literal storage shape like columns and types', 'An ontology is the actual table layout in storage, while a schema is the abstract idea behind it', 'They are the same thing described with two different words', 'An ontology is a flat list of term definitions, while a schema adds the relationships between them', 0, 'An ontology is the conceptual domain layer of categories and relationships, sitting above the schema, which is the concrete storage shape of the data.'),
(13, 'Why does visiting http://localhost:4747 reach a dev server running on your own laptop?', 'localhost is a public address your ISP assigns, so the request goes out and comes back to you', 'localhost resolves to your machine itself (127.0.0.1), so the request never leaves the computer or touches the network', 'localhost forwards the request through your router to whichever device is serving on that port', 'localhost is a shared address every computer on your WiFi can see', 1, 'localhost resolves to the loopback address 127.0.0.1, meaning this machine, so the request stays entirely on your own computer.'),
(14, 'An IP address gets a packet to the right computer. What does the port number add?', 'It encrypts the packet so nothing in between can read it', 'It tells the network which physical machine on the WiFi to deliver to', 'It identifies which specific program running on that computer the packet is for', 'It guarantees the packet arrives in order with no data lost', 2, 'The IP routes to the machine and the port routes to the specific program on it, like an apartment number inside a building''s street address.'),
(15, 'A friend in another city tries your link http://localhost:4747 and sees nothing. Why?', 'Your dev server crashed the moment a second person connected to it', 'On their laptop localhost means their own machine, not yours, so the address points somewhere entirely different', 'Their browser blocks any address that uses a port number above 1023', 'localhost only works over HTTPS, and your server is running plain HTTP', 1, 'localhost always means the machine typing it, so on your friend''s computer the address resolves to their machine rather than yours.'),
(16, 'What is the practical effect of releasing code under a strong copyleft license like the GPL?', 'Anyone may use the code however they like as long as they keep your copyright notice', 'Any project that includes your code must itself be released under the same license', 'You give up all rights and place the code in the public domain', 'Only files you personally modify must stay open, while the rest of the project can be proprietary', 1, 'Strong copyleft requires that the whole project incorporating the licensed code also be released under that same license.'),
(17, 'When you type npm run dev, how does the shell figure out where the npm program actually is?', 'It walks the directories listed in the PATH variable, left to right, and runs the first executable file named npm it finds', 'It searches your entire hard drive for any file named npm and runs the newest one', 'npm is built into the shell itself, so there is no file to find', 'It always runs the npm located in the current project''s node_modules folder', 0, 'The shell searches each directory in PATH in order and runs the first executable matching the command name, so npm is just a file found via that list.'),
(18, 'Why does vite run fine inside the npm run dev script but typing vite alone in your terminal does nothing?', 'vite is installed globally, but the dev script overrides it with a different version', 'npm run temporarily adds node_modules/.bin to PATH while the script runs, and your bare terminal never has that directory on PATH', 'Typing vite alone runs it, but it silently exits because no package.json argument was passed', 'vite can only be started by another program, never directly from a shell', 1, 'npm run prepends node_modules/.bin to PATH for the child process, so vite is findable there, but your interactive shell lacks that directory and cannot find it.'),
(19, 'Why does [::1]:4747 reach your Vite server while 127.0.0.1:4747 returns connection refused?', 'IPv4 has been disabled on modern macOS, so 127.0.0.1 no longer functions at all', '127.0.0.1 and ::1 are distinct addresses, and Vite bound only to ::1 because modern Node resolves localhost to the IPv6 address first', 'Port 4747 is reserved for IPv6 traffic only and cannot accept IPv4 connections', '127.0.0.1 is a public address that requires a router, while ::1 is the only true local address', 1, '127.0.0.1 and ::1 are separate addresses, and Vite bound only to ::1 because Node''s verbatim DNS order resolves localhost to the IPv6 address first.'),
(20, 'What is the core difference between IPv4 and IPv6?', 'IPv4 is for local networks only, while IPv6 is exclusively for the public internet', 'IPv4 is encrypted by default, while IPv6 sends everything in plain text', 'IPv6 uses much larger 128-bit addresses to provide a vastly bigger address space than IPv4''s 32-bit addresses', 'IPv6 is faster because it removed the need for port numbers entirely', 2, 'The main change is address size: IPv6''s 128-bit addresses give an enormous address space compared to IPv4''s exhausted 32-bit space.'),
(21, 'On an Apple Silicon Mac with no built-in Ethernet port, what does the interface named en0 actually refer to?', 'The loopback interface that handles 127.0.0.1', 'The Wi-Fi card (en is a historical holdover from Ethernet)', 'The VPN tunnel interface', 'A virtual bridge created by Docker', 1, 'On Apple Silicon Macs without a built-in Ethernet port, en0 is the Wi-Fi card, with the en name kept from when the first interface really was Ethernet.'),
(22, 'On macOS, why do ifconfig and ipconfig cause confusion even though both ship with the system?', 'They are two names for the exact same Windows-derived tool', 'ipconfig is the modern replacement that Apple wants you to use instead of ifconfig', 'ifconfig is the BSD workhorse, while Apples ipconfig is a small, different DHCP query helper, not the Windows tool', 'Neither one works on macOS without installing them via Homebrew first', 2, 'macOS ships the real BSD ifconfig plus a small Apple-specific ipconfig that is mainly a DHCP helper, so the similar names hide very different jobs.'),
(23, 'The npm shim contains require(''../lib/cli.js''). When Node runs it, what is the .. resolved relative to?', 'The directory of the real file after symlink resolution, not the symlink path or your shell CWD', 'Your current working directory in the terminal', 'The literal /opt/homebrew/bin directory where the symlink lives', 'The root of the filesystem', 0, 'Relative paths in require resolve from the requiring files own directory, and Node resolves the symlink to its real location first, so .. is anchored there.'),
(24, 'Why does the entry warn against using regex to parse HTML, JSON, or other nested-structure formats?', 'Regex engines are too slow to handle large documents', 'Regex cannot match any special characters like angle brackets', 'Formally, regex cannot count matched brackets, so nested structure breaks it with nasty failure modes', 'Most regex flavors do not support capture groups, which nested data requires', 2, 'Regex formally cannot count matched/nested brackets, so it is the wrong tool for structured formats and a real parser should be used instead.'),
(25, 'What is the key that a compile cache uses to decide whether it can reuse a stored artifact instead of recompiling?', 'The timestamp of when the file was last opened', 'A fingerprint, typically a hash of the source contents plus compiler version plus relevant flags', 'The name of the source file', 'Whether the previous build succeeded or failed', 1, 'A compile cache keys reuse on an exact-input fingerprint (source contents, compiler version, flags), so any change to those triggers a full recompile.'),
(26, 'According to the entry, when is flushing a compile cache actually the right move?', 'As the first thing to try whenever any build or app misbehaves', 'Every time before starting the dev server, to guarantee a clean build', 'When symptoms uniquely look like staleness (file looks right but runtime shows old behavior) or after a tool/Node version upgrade', 'Only when you are completely out of disk space', 2, 'Flushing is warranted when symptoms specifically point to stale output or after an undetectable change like a version upgrade, not as a default debugging reflex.'),
(27, 'For the command node scripts/build-db.mjs --watch input.sql, what does process.argv.slice(2) give you?', 'The Node executable path and the script path only', 'Just the script path', 'Every environment variable available to the process', 'Just your scripts own arguments: [''--watch'', ''input.sql'']', 3, 'process.argv[0] is the Node path and [1] is the script path, so slicing from index 2 drops both and leaves only the arguments you passed to your script.'),
(28, 'What does the Baseline label ''Widely available'' specifically mean?', 'The feature has been newly available across all major engines for 30 months without regressions', 'The feature just shipped in the stable version of every major browser engine', 'The feature is available in at least one browser engine', 'The feature is available only in Chromium-based browsers', 0, 'Widely available means a feature has been Baseline newly available in all major engines for 30 months without regressions, long enough for lingering older browsers to catch up.'),
(29, 'What is the main thing nanoid is designed to do, compared to a UUID?', 'Generate sequential IDs that always increase over time', 'Generate unique IDs that are shorter, URL-safe, and faster than a UUID', 'Encrypt data so IDs cannot be reversed', 'Guarantee globally coordinated IDs across multiple servers', 1, 'nanoid does the same unique-ID job as a UUID but produces shorter, URL-safe strings from a tiny, fast implementation.'),
(30, 'Why is updating caniuse-lite handled by update-browserslist-db instead of a normal npm update?', 'npm update cannot modify anything inside node_modules', 'update-browserslist-db rewrites package.json and the lockfile, which npm update refuses to do', 'The data files update cadence outpaces its semver range, so the tool bypasses semver gates and grabs the newest version directly', 'caniuse-lite is not actually an npm package, so npm has no way to reach it', 2, 'caniuse-lite is pinned to a semver range that npm update respects, but its data changes faster than that, so update-browserslist-db ignores the semver gates to fetch the latest data in place.'),
(31, 'Why do browsers still request /favicon.ico from a site even when the page has no link tag pointing to a favicon?', 'Browsers automatically probe that root path as a built-in fallback, regardless of any HTML tag', 'The web server is required to inject a favicon link tag into every page it serves', 'The .ico file is the only image format a browser tab is technically able to render', 'JavaScript on the page silently triggers the request after the page finishes loading', 0, 'Browsers auto-request /favicon.ico at the site root by default, so the fallback works even with no link tag declared.'),
(32, 'What core guarantee defines the singleton pattern?', 'The object is recreated fresh every time any code asks for it', 'Only one instance of the type exists in the running program, reached through one shared accessor', 'The object can never be modified after it is first created', 'Each module that imports it gets its own private copy', 1, 'A singleton guarantees exactly one instance per program and gives all code a single agreed-upon way to reach it.'),
(33, 'Two libraries each define a type called Logger. How does a namespace let both coexist?', 'It renames one of the types automatically so neither keeps the name Logger', 'It deletes the second definition and forces both libraries to share one Logger', 'It puts each name in its own labeled bucket, so LibA.Logger and LibB.Logger refer to different things', 'It merges the two definitions into a single combined Logger type', 2, 'A namespace scopes names into separate buckets, so identical internal names in different namespaces do not collide.'),
(34, 'What fundamentally distinguishes a linter from a tool that runs your tests?', 'A linter only works on compiled languages, while test runners work on any language', 'A linter analyzes the source code without executing it, flagging likely bugs and rule violations', 'A linter rewrites your code into a fixed visual style and has no opinion on logic', 'A linter executes your program and reports which lines threw runtime errors', 1, 'A linter performs static analysis: it reads code without running it and flags likely bugs, style issues, and rule violations.'),
(35, 'Why is it considered bad practice to change a slug once it has been published?', 'Changing it forces search engines to permanently delist the page', 'Slugs are stored in a read-only system that physically cannot be edited', 'Changing it breaks every existing link that pointed to the old slug', 'A changed slug stops the page from rendering until the server restarts', 2, 'A slug is the URL identifier for the content, so changing it breaks every link that already points to the old one.'),
(36, 'What is the difference between Continuous Delivery and Continuous Deployment?', 'Delivery runs the tests; Deployment runs the linters', 'With Delivery a human clicks to ship a passing build; with Deployment passing builds ship automatically', 'Delivery only works on the main branch; Deployment works on any branch', 'Delivery skips the build step, while Deployment always rebuilds from scratch', 1, 'Both ship builds that pass CI, but Continuous Delivery keeps a manual deploy step while Continuous Deployment is fully automatic.'),
(37, 'In the command ls | grep .md, what does the pipe actually do?', 'It saves the output of ls into a file that grep later reads', 'It runs grep first and then passes its result to ls', 'It feeds the stdout of ls directly into the stdin of grep, with both running live', 'It merges the error messages of both commands onto the screen', 2, 'A pipe wires the left command''s stdout into the right command''s stdin, with both processes running simultaneously.'),
(38, 'Right after making a commit, why is git show HEAD a reliable way to see exactly what you just committed?', 'HEAD is a pointer that always refers to the commit you are currently sitting on', 'HEAD is a special command that only displays the most recent commit on any branch', 'git show caches the last commit you typed and replays it', 'HEAD permanently locks onto the first commit you ever made in the repo', 0, 'HEAD points at the commit you are currently on, so just after committing it refers to the commit you just made.'),
(39, 'What problem can arise when you pipe a very large commit''s full diff into an LLM, and what fixes it?', 'The pipe corrupts binary files; switching to redirection with > avoids it', 'The diff exceeds the model''s context window; sending only --stat or a file list instead avoids it', 'git refuses to output diffs over a size limit; running git gc first avoids it', 'The LLM cannot read from stdin at all; saving the diff to a file first avoids it', 1, 'A big diff can blow past the model''s context window, so sending a summary like git show --stat or a file list keeps the input small enough.'),
(40, 'What is the defining principle of the PARA filing scheme?', 'Every item gets a unique numeric address built from areas and categories', 'Files are stored in year and month folders with dated filenames', 'Four top-level folders sorted by status (Projects, Areas, Resources, Archives) with items migrating between them', 'There is no folder structure; a full-text index does all the work', 2, 'PARA uses exactly four status-based top-level folders and items move between them as their status changes, so filing only asks whether something is active, ongoing, reference, or done.'),
(41, 'What primarily sets Playwright apart from older tools like Selenium and from Puppeteer?', 'It runs entirely without launching any real browser, simulating the DOM in pure JavaScript', 'It drives Chromium, WebKit, and Firefox from one API and auto-waits for elements to be actionable', 'It is the only browser tool that can take screenshots and generate PDFs', 'It only works in Python, making it faster than the Node-based alternatives', 1, 'Playwright''s distinguishing features are real cross-browser support from a single API plus auto-waiting that removes sleep-based race-condition glue.'),
(42, 'You are capturing web pages for high-quality print collateral. Which adjustment most directly improves the result?', 'Raise deviceScaleFactor (to 3 or 4) so the raster output holds up at print DPI', 'Set fullPage to false so only the visible viewport is captured', 'Lower the viewport width so the page renders its mobile layout', 'Save as a larger PNG file, since bigger file size means higher print quality', 0, 'Print needs roughly 300 DPI versus a screen''s 96, and deviceScaleFactor multiplies the pixel density of the screenshot to reach print-grade resolution.'),
(43, 'Why does moving Playwright screenshots to a print workbench mean plumbing between directories rather than a literal shell pipe by default?', 'Because shell pipes cannot carry image data of any kind', 'Because Playwright requires every output to be committed to git before it can move', 'Because Playwright writes binary files to disk via its path option rather than emitting bytes to stdout', 'Because the workbench can only read files that already exist in the same repo', 2, 'By default Playwright''s screenshot writes a file to the path you give it, so delivery means copying/syncing files between folders, not a stdout-to-stdin shell pipe.'),
(44, 'What does the redirection 2>&1 actually instruct the kernel to do?', 'Swap the contents of stdout and stderr with each other', 'Make fd 2 point at whatever object fd 1 currently points at, via a dup2-style call', 'Merge stderr into a new file literally named 1', 'Always send stderr to the terminal regardless of where stdout goes', 1, '2>&1 is a real syscall (dup2) that installs whatever fd 1 references into slot 2, which is why redirection order changes the outcome.'),
(45, 'In the phrase ''a moving pointer to the commit you are currently sitting on'', what part of speech is ''moving'' and what is it doing?', 'A verb acting as the main predicate of the clause', 'An adverb modifying the verb ''sitting''', 'A participial adjective attributively modifying the noun ''pointer''', 'A noun forming a compound with ''pointer''', 2, 'Despite being the -ing form of a verb, ''moving'' here pre-modifies the noun ''pointer'' adjectivally, like ''running water'' or ''burning house''.'),
(46, 'How does the Claude Code CLI handle a built-in slash command like /clear differently from invoking a skill?', 'Built-ins are intercepted and executed by the CLI itself, while skills route through the model with their SKILL.md loaded as context', 'Built-ins are sent to the model as prompts, while skills are run silently by the CLI', 'Both are handled identically; the only difference is the icon shown in the dropdown', 'Built-ins expand into your next prompt, while skills are hard-coded into the model''s training', 0, 'Built-in slash commands are handled by the CLI program before reaching the model, whereas a skill loads its SKILL.md instructions into the model''s context so the model acts on them.'),
(47, 'What makes a second Claude subagent spawned to challenge a plan count as adversarial review?', 'It uses a larger model than the first agent so it can find more issues', 'It is instructed to be harsh and use a critical tone', 'It starts with no context from the first agent''s reasoning, so it cannot fall into the same groove', 'It reviews the work only after the plan has already shipped', 2, 'The blank-slate posture is the key: arriving with no commitment to the original reasoning lets the reviewer surface failure modes the first agent grooved past.'),
(48, 'An LLM gives a correct answer, you push back with no new evidence, and it immediately reverses to agree with you. How should you read the new answer?', 'As more reliable, since the model reconsidered and corrected itself', 'With the same suspicion as sudden agreement, because capitulation signals compliance rather than correctness', 'As proof the original answer was wrong', 'As neutral; reversals carry no signal either way', 1, 'Flipping position under no new evidence is a classic sycophancy tell, so the reversal indicates compliance, not a more trustworthy answer.'),
(49, 'What is the core mechanism that makes Cloudflare Zaraz different from browser-side Google Tag Manager?', 'It bundles all third-party scripts into one smaller file that still runs in the visitor''s browser', 'It blocks third-party tags entirely so no analytics data is collected', 'It moves the third-party tags off the browser and runs them server-side on Cloudflare''s edge, with the browser making one same-origin request', 'It caches the third-party scripts on a CDN so they load faster in the browser', 2, 'Zaraz takes the tags out of the browser and fires them server-side at the edge, so the visitor''s browser makes a single same-origin request that fans out to many tools.'),
(50, 'What determines the token cost of an image you send to Claude?', 'Its pixel area (roughly width times height divided by 750)', 'Its file size in kilobytes', 'The number of distinct colors it contains', 'Whether it is a PNG or a JPEG', 0, 'Vision tokens are computed from pixel dimensions, so a 1MB PNG and a 100KB JPEG of the same dimensions cost the same.'),
(51, 'A dev server starts and VS Code keeps popping the URL into its own built-in Simple Browser instead of Chrome. What is the most direct cause to address?', 'The port auto-forward action is set to openPreview, so changing it to openBrowser sends the URL to an external browser', 'Chrome is not installed, so VS Code falls back to its Simple Browser', 'The dev server is binding to the wrong port, which VS Code cannot forward externally', 'The integrated terminal must be closed before any external browser can open', 0, 'VS Code''s port auto-forwarding decides where a detected dev-server URL opens, and switching onAutoForward from openPreview to openBrowser routes it to the external browser.'),
(52, 'What does it mean for an app''s user-facing text to be localizable?', 'The text is automatically translated at runtime by the operating system', 'The text lives in resource files keyed by identifier instead of being hardcoded inline, so translations can be swapped without changing code', 'The app detects the user''s location via GPS and adjusts content accordingly', 'Every string is written in multiple languages within the same source line', 1, 'Localizable means the user-facing strings are externalized into keyed resource files so translators can supply other languages without touching the code.'),
(53, 'What does JSX actually become after compilation, and how does it relate to HTML?', 'It is a special dialect of HTML that browsers parse directly', 'It is a wrapper that injects raw HTML strings into the page', 'It compiles to JavaScript function calls returning objects that describe elements, which React then uses to build the real DOM', 'It is HTML stored as a template that the server renders before sending it', 2, 'JSX is syntactic sugar that compiles into function calls producing element-description objects, and React turns that tree into the real DOM, so JSX is not HTML itself.'),
(54, 'Why are PDFs an especially token-expensive input to send to Claude?', 'PDFs are compressed, so they must be decompressed into many extra tokens before reading', 'Each page is processed twice: rendered as a billed image and also extracted as billed text tokens', 'PDF text is encrypted, forcing the model to decrypt it character by character', 'PDFs always require OCR even when they contain digital text', 1, 'Every PDF page is billed both as an image (by pixel area) and as extracted text tokens, so the dual processing roughly doubles the cost.'),
(55, 'When converting documents to text for an LLM, why is Markdown the preferred target format?', 'Markdown files are encrypted, making them safer to send than plain text', 'Markdown preserves visual elements like charts and figures perfectly', 'Markdown keeps structure such as headings, tables, and lists as plain text the model parses natively, with very little markup overhead', 'Markdown is the only format LLMs are technically able to read', 2, 'Markdown retains document structure as token-dense plain text that models parse natively, which is why it is the conversion target of choice.'),
(56, 'What best captures the difference between QA and a tester?', 'A tester prevents defects by improving the process, while QA only executes test cases', 'QA is the broader process-focused, prevention-oriented discipline, while testing is the narrower detection-oriented activity of finding what is broken', 'QA and tester are the same role with no conceptual distinction at all', 'A tester writes automation frameworks while QA only does manual checks', 1, 'QA owns quality across the whole process and aims to prevent defects, whereas testing is the narrower activity of detecting existing defects.'),
(57, 'Why did Spotify deliberately make its shuffle less random?', 'Truly random shuffle produces clusters and repeats that humans misread as not random, so a less-random algorithm feels more random', 'Truly random shuffle was too computationally expensive to run at scale', 'Random number generators on phones cannot produce genuine randomness', 'Users wanted songs grouped by the same artist on purpose', 0, 'Genuine randomness produces streaks that people perceive as rigged, so Spotify reduced randomness to better match human intuition of what random feels like.'),
(58, 'What is the actual point the infinite monkey theorem illustrates?', 'Monkeys can be trained to type coherent text given enough practice', 'Random processes naturally tend toward producing meaningful output over time', 'Given infinite random trials, any outcome with nonzero probability happens almost surely, even though it is wildly infeasible in any finite time', 'Any finite amount of random typing will eventually produce Shakespeare', 2, 'The theorem holds only in the infinite limit, showing that something possible in principle can be utterly infeasible in practice over any finite span.'),
(59, 'Why can a read-aloud button work with no server, no audio files, and no build step?', 'The audio is pre-generated at build time and cached in the browser', 'The browser''s built-in Web Speech API synthesizes speech on the fly on the user''s own device', 'A free public TTS API streams the audio over the network', 'The text is converted to audio files the first time and reused forever', 1, 'The native Web Speech API (speechSynthesis) generates speech client-side on the user''s device, so no server, files, or build step are needed.'),
(60, 'What is the core purpose of the find-skills skill?', 'It writes new skills automatically based on your project', 'It permanently loads every available skill into context so they are always ready', 'It searches the ecosystem of installable skills and helps you find and install a matching one without already knowing its name', 'It runs whichever skill you name by its exact identifier', 2, 'find-skills is the discovery layer that searches for and helps install matching skills so you benefit without already knowing a skill''s name.'),
(61, 'When would you reach for the /impeccable skill?', 'You want a structured design review of a UI: hierarchy, typography, spacing, accessibility, and polish', 'You need to scaffold a new backend API with database models', 'You want Claude to write unit tests for a server-side module', 'You need to deploy your site to a hosting provider', 0, '/impeccable is a frontend design-quality skill for designing, critiquing, polishing, or auditing a UI, not for backend, testing, or deployment work.'),
(62, 'When Node DevTools shows your server''s console.log output, what is actually happening at the connection level?', 'Your server pushes log messages out to Chrome over the public internet', 'Chrome connects into a debug socket your Node process is already listening on locally, and logs stream to it', 'Node writes logs to a file that Chrome polls every second', 'DevTools injects code into your server that forwards each print', 1, 'Node opens a localhost inspector WebSocket; DevTools is a client that dials in over CDP, and console output is streamed to it as events.'),
(63, 'Why does key-based i18n (like t(''byok.heading'')) make a string harder to find in the codebase, while message-based i18n (like <Trans>Bring your own key</Trans>) does not?', 'Key-based runs faster at runtime, so the build strips the English text', 'Message-based stores all text in a database instead of files', 'In key-based the English lives only in the catalog, so searching the literal text finds nothing in the component; message-based keeps the real English in the source', 'Key-based requires a separate file per component, multiplying the hops', 2, 'Key-based i18n moves the English into the catalog so the literal string is absent from the component, whereas message-based keeps the real text inline and grep-able.'),
(64, 'What does an SBA loan actually mean for the borrower?', 'Free money from the government that does not need to be repaid', 'A bank loan with a federal guarantee behind it, which you still repay', 'A direct loan made by the SBA itself in every case', 'An equity investment where the government takes ownership of the business', 1, 'The SBA mostly guarantees a portion of loans made by private lenders; it is still debt the borrower repays, not a grant or equity.'),
(65, 'What is the difference between a government contract and a government grant?', 'A contract is always smaller in dollar value than a grant', 'A contract has the government buy a deliverable for its own use; a grant funds the recipient to pursue a public purpose', 'A grant must be repaid while a contract does not', 'A contract is only for federal agencies; grants are only state and local', 1, 'A contract is the government purchasing goods or services for its own use, while a grant funds the recipient to do something for a public purpose.'),
(66, 'Which layer of rules affecting what someone might be owed changes the most frequently?', 'Statutes passed by legislatures', 'The Farm Bill reauthorization', 'Agency regulations published in the Federal Register', 'Constitutional amendments', 2, 'Regulations are the fastest layer: agencies publish proposed and final rules in the Federal Register essentially every business day, far more often than statutes change.'),
(67, 'If a business wants a subsidy for hiring or training employees, where should it look?', 'SBA loans, since their proceeds can cover payroll', 'Programs like WOTC tax credits and WIOA on-the-job training reimbursements', 'Any standard bank business loan', 'The Farm Bill''s crop insurance provisions', 1, 'SBA loans are repayable debt, not subsidies; actual wage and training incentives come from programs like the WOTC tax credit and WIOA-funded training reimbursements.'),
(68, 'In prompting terms, what does one-shot mean?', 'Permanently updating the model''s weights using one training example', 'Including exactly one worked input-to-output example in the prompt to steer behavior', 'Giving the model unlimited attempts until it succeeds', 'Sending a prompt with no examples at all, just the instruction', 1, 'One-shot prompting means putting exactly one worked example in the prompt to demonstrate the pattern, which is in-context learning and does not change the model''s weights.'),
(69, 'What is the design principle behind making each panel of a brochure self-contained?', 'Atomicity: each panel carries one idea that reads on its own without depending on neighbors', 'Maximizing word count so every panel is thorough', 'Repeating the same message identically on every panel', 'Filling all whitespace so no space is wasted', 0, 'A good brochure uses atomic panels, each standing on its own with one self-contained point, because readers skim rather than read in order.'),
(75, 'What is the single most important distinction between the raw Claude API and Claude Code?', 'The API uses a faster model than Claude Code does', 'Claude Code runs the agent loop (call, act, feed result back, repeat) while the bare API answers one request and stops', 'The API can edit files and run bash, but Claude Code cannot', 'Claude Code talks to the model directly without going through the API', 1, 'The bare API answers one request and stops; Claude Code is the harness that runs the agent loop, executing tool actions and feeding results back until the task is done.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(76, '2026-06-15', 7, 'In the field of AI, what is signal vs noise?',
'Signal is the real, repeatable relationship in your data -- the part that actually connects the inputs to what you are predicting and will hold up on data you have not seen. Noise is the random, irrelevant variation: measurement error, coincidence, one-off quirks of this particular sample that will not recur. A model''s whole job is to learn the signal and ignore the noise; when it instead memorizes the noise, that is overfitting. Example: predicting house prices, square footage is signal, while the fact that one house happened to sell high because the buyer was in a rush is noise. The term is borrowed from engineering as the signal-to-noise ratio -- the higher it is, the easier learning gets.'),
(77, '2026-06-15', 8, 'What is the difference between a pattern and an outlier?',
'A pattern is a regularity that recurs across many data points -- the rule a model can generalize from. An outlier is a single point that sits far from that pattern -- the exception. The subtlety: an outlier is sometimes just noise (a typo, a broken sensor) you would clean out, but sometimes it is the most valuable signal there is. Anomaly detection -- fraud, intrusions, equipment failure -- flips the goal entirely: the outlier IS the thing you are hunting. So "pattern vs outlier" does not always line up with "signal vs noise"; context decides which an outlier is. Relation to the bigger picture: a pattern is generally signal; an outlier may be noise to discard OR the rare event you most want to catch.'),
(78, '2026-06-15', 9, 'Can you compare and contrast bias and variance?',
'They are the two halves of the bias-variance tradeoff, and they map onto signal vs noise. Bias is error from a model being too simple: it makes strong wrong assumptions and misses the signal -- that is underfitting, like forcing a straight line through clearly curved data. High bias means being consistently wrong in the same way. Variance is error from a model being too sensitive to the exact training data: it chases the noise -- that is overfitting. High variance means that retraining on a slightly different sample makes the predictions swing wildly. Dartboard picture: bias is arrows tightly grouped but off the bullseye; variance is arrows scattered all around it. Lowering one often raises the other, so the goal is the sweet spot that minimizes total error rather than either one alone.'),
(79, '2026-06-15', 10, 'How does precision play into recall?',
'Both judge a classifier on the positive class, and they trade off against each other. Take a spam filter. Precision asks: of everything the model FLAGGED as positive, how much was actually positive? -- TP / (TP + FP). It punishes false alarms (did we wrongly trash real email?). Recall asks: of all the ACTUAL positives out there, how many did the model catch? -- TP / (TP + FN). It punishes misses (did spam slip into the inbox?). The interplay: make the model trigger-happy and flag everything, and recall rises but precision falls (many false alarms); make it cautious and flag only when certain, and precision rises but recall falls (you miss real cases). Which you favor depends on stakes: cancer screening wants high recall (never miss a case, tolerate false alarms), while a spam filter wants high precision (never trash a real email, tolerate some spam getting through). The F1 score, the harmonic mean of the two, is the single number people use when they want balance.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (76, 'signal', 'The real, generalizable relationship in data that genuinely connects inputs to the thing being predicted -- what a model should learn.'),
  (76, 'noise', 'Random, irrelevant variation in data (measurement error, coincidence, sample quirks) that will not recur and should not be learned.'),
  (76, 'signal-to-noise ratio', 'How much of the data is meaningful signal versus random noise; the higher it is, the easier a pattern is to learn.'),
  (76, 'overfitting', 'When a model memorizes the noise/quirks of its training data instead of the underlying signal, so it performs worse on new data.'),
  (77, 'pattern', 'A regularity that recurs across many data points -- the rule a model generalizes from.'),
  (77, 'outlier', 'A single data point far from the established pattern; may be an error to discard or a rare event worth special attention.'),
  (77, 'anomaly detection', 'A task whose goal is to find the outliers themselves (fraud, intrusions, failures) rather than treat them as noise.'),
  (78, 'bias (ML)', 'Error from a model being too simple -- strong wrong assumptions that miss the signal; the cause of underfitting.'),
  (78, 'variance (ML)', 'Error from a model being too sensitive to its exact training data -- chasing noise; the cause of overfitting.'),
  (78, 'bias-variance tradeoff', 'The tension where reducing bias (more complex model) tends to raise variance and vice versa; the aim is to minimize total error.'),
  (78, 'underfitting', 'When a model is too simple to capture the real pattern, so it is wrong in a consistent way on both training and new data.'),
  (79, 'precision', 'Of the items a model flagged as positive, the share that truly were positive: TP / (TP + FP). Measures false alarms.'),
  (79, 'recall', 'Of all the actual positives, the share the model caught: TP / (TP + FN). Measures misses.'),
  (79, 'false positive / false negative', 'A false positive is a wrong alarm (flagged but not really positive); a false negative is a missed real case.'),
  (79, 'F1 score', 'The harmonic mean of precision and recall -- one number balancing false alarms against misses.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(76, 'A model that memorizes one-off quirks of its training data instead of the real underlying relationship is said to be doing what?',
 'Learning the signal',
 'Overfitting -- it has fit the noise',
 'Improving its signal-to-noise ratio',
 'Generalizing well to new data',
 1,
 'Fitting the random, non-recurring variation (the noise) rather than the generalizable relationship (the signal) is exactly overfitting.'),
(77, 'In fraud detection, how should you usually treat a strong outlier?',
 'As noise to be deleted before training',
 'As the target you are actually trying to find',
 'As proof the model has high bias',
 'As irrelevant, since only patterns matter',
 1,
 'Anomaly detection flips the usual logic: the outlier is the signal you want to catch, not noise to discard.'),
(78, 'A model predicts wildly different things when retrained on slightly different samples of the same data. This is a symptom of what?',
 'High bias (underfitting)',
 'High variance (overfitting)',
 'A perfect bias-variance balance',
 'Low signal-to-noise ratio in the labels',
 1,
 'Sensitivity to the exact training sample -- predictions swinging with small data changes -- is high variance, the hallmark of overfitting.'),
(79, 'A cancer screening test is tuned so it almost never misses a real case, even though it raises some false alarms. Which metric is being prioritized?',
 'Precision, at the expense of recall',
 'Recall, at the expense of precision',
 'F1 score, balancing both equally',
 'Accuracy, ignoring both',
 1,
 'Catching nearly all true cases (few false negatives) maximizes recall; tolerating extra false alarms means precision is being traded away.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(80, '2026-06-15', 11, 'What is training and how does it affect inference?',
'Training is how a model is built: feed it data, let it predict, measure how wrong it is with a loss function, then nudge its internal weights (via gradient descent and backpropagation) to reduce that error -- repeated over many passes called epochs. It is expensive and done up front on big hardware. Inference is using the finished, frozen model on new inputs -- cheap and fast. The link between them: at inference the weights are frozen, so everything the model knows was baked in during training -- the patterns it learned, its biases, its knowledge cutoff, and the ceiling on its quality are all set at training time. Inference applies what was learned; it does not learn. Garbage training data yields garbage inference, permanently. The mental model: training is writing the book, inference is reading from it.'),
(81, '2026-06-15', 12, 'What is one way a model becomes overfit, and a way that a model becomes underfit?',
'Overfit: train a high-capacity model (too many parameters) on too little data, for too many epochs with no regularization -- it memorizes the training examples, noise and all, and then does worse on new data. Fixes include more data, regularization or dropout, early stopping, and a simpler model. Underfit: use a model too simple for the relationship -- for example a straight-line (linear) model on clearly curved data, or stopping training too early -- so it cannot even capture the signal. Fixes include more capacity, more features, and training longer. These are the two failure modes of the bias-variance tradeoff: underfitting is high bias, overfitting is high variance.'),
(82, '2026-06-15', 13, 'What is hallucination and grounding in the AI world?',
'Hallucination is when an AI produces confident, plausible-sounding output that is factually wrong or fabricated -- invented facts, fake citations. It happens because an LLM predicts likely text, not verified truth; it has no built-in fact-checker. Grounding is the fix: tying the model''s output to real, verifiable sources -- feeding it actual documents (retrieval-augmented generation, or RAG), letting it use tools to look things up, and having it cite what it used. Grounding shrinks hallucination by making the model answer from provided evidence instead of from its parametric memory alone. Ungrounded means answering from memory; grounded means answering from retrieved or supplied context.'),
(83, '2026-06-15', 14, 'What is the difference between memory and stateless? Why are REST APIs so common, what makes them stateless, and what would be a stateful alternative?',
'Stateless means each request is self-contained and the server keeps no memory of previous requests -- every request must carry everything needed to process it (auth token, parameters). Stateful means the server remembers context across requests (a session). REST APIs are typically stateless, and that is why they are everywhere: statelessness makes them trivially scalable (any server can handle any request -- easy load balancing, no session affinity), reliable (no session to lose if a server dies), and cacheable. The client resends what it needs each time. Important nuance: stateless is about the connection/session, not about storing nothing -- the data still lives in a database; the server just does not remember YOU between calls. Stateful alternatives: WebSockets (a persistent open connection holding live session state -- chat, games), gRPC streaming, or classic server-side sessions. This maps onto AI: a raw LLM API call is stateless (you resend the whole conversation every time), whereas a stateful agent (such as a Cloudflare Durable Object) holds the session for you.'),
(84, '2026-06-15', 15, 'What is convergence?',
'In training, convergence is when the loss settles and stops improving -- gradient descent has approached a stable minimum, the weights barely change anymore, and the loss curve flattens. It is the signal that the model has learned about as much as this setup allows, so you stop training around there. Convergence does not guarantee the model is good (it can converge to a poor local minimum, or converge while overfit); it just means the optimization has stopped making progress.'),
(85, '2026-06-15', 16, 'What is divergence?',
'Divergence is the opposite of convergence: training goes unstable -- the loss increases or oscillates wildly instead of decreasing, often blowing up toward infinity or NaN. The model is getting worse, not better. The classic cause is a learning rate that is too high, so each weight update overshoots the minimum and the steps grow instead of shrinking; other causes include bad or unscaled input data and numerical instability. In short: convergence is settling toward the target, divergence is flying away from it.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (80, 'training', 'Building a model by feeding it data, measuring error with a loss function, and adjusting its weights to reduce that error over many passes (epochs).'),
  (80, 'inference', 'Using a finished, frozen model to make predictions on new inputs. The weights do not change -- it applies what training learned.'),
  (80, 'loss function', 'A measure of how wrong a model''s predictions are; training works by minimizing it.'),
  (80, 'epoch', 'One full pass through the training dataset. Training usually runs for many epochs.'),
  (81, 'regularization', 'Techniques (e.g. dropout, weight penalties) that discourage a model from memorizing noise, used to combat overfitting.'),
  (81, 'early stopping', 'Halting training once validation performance stops improving, to avoid overfitting from training too long.'),
  (82, 'hallucination', 'When an AI generates confident but factually wrong or fabricated output, because it predicts likely text rather than verified truth.'),
  (82, 'grounding', 'Tying a model''s output to real, verifiable sources (retrieved documents, tools, citations) to reduce hallucination.'),
  (82, 'RAG (retrieval-augmented generation)', 'Fetching relevant documents and feeding them to the model so it answers from real evidence instead of memory alone.'),
  (83, 'stateless', 'A design where the server keeps no memory between requests; each request carries everything needed. The basis of REST''s scalability.'),
  (83, 'stateful', 'A design where the server remembers context across requests (a session), as with WebSockets or server-side sessions.'),
  (83, 'REST API', 'A common style of web API built on self-contained HTTP requests; typically stateless, which makes it easy to scale and cache.'),
  (83, 'WebSocket', 'A persistent, two-way open connection between client and server that holds live session state -- a stateful alternative to REST.'),
  (84, 'convergence', 'The point in training where the loss flattens and weights stop changing much -- the optimization has reached a stable minimum.'),
  (85, 'divergence', 'When training becomes unstable and the loss grows or oscillates instead of shrinking, often from too high a learning rate.'),
  (85, 'learning rate', 'How big a step each training update takes; too high causes divergence (overshooting), too low makes training painfully slow.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(80, 'What happens to a model''s weights during inference, compared with training?',
 'They keep updating as each new input arrives',
 'They are frozen -- inference applies what training baked in and does not learn',
 'They are randomly reinitialized for every request',
 'They exist only during training and are discarded afterward',
 1,
 'Training sets the weights; at inference they are frozen, so the model applies learned patterns but cannot learn anything new.'),
(81, 'Using a simple straight-line (linear) model to fit a clearly curved relationship will most likely cause what?',
 'Overfitting, because it memorizes noise',
 'Underfitting, because the model is too simple to capture the pattern',
 'Perfect generalization',
 'Divergence during inference',
 1,
 'A model too simple for the underlying relationship cannot capture the signal -- that is underfitting (high bias).'),
(82, 'What is the main purpose of grounding an LLM, for example with retrieval-augmented generation?',
 'To make it generate text faster',
 'To tie its output to verifiable external sources and reduce hallucination',
 'To increase its number of parameters',
 'To let it update its weights in real time',
 1,
 'Grounding feeds the model real, citable evidence so it answers from sources rather than fabricating -- directly reducing hallucination.'),
(83, 'What makes a REST API stateless?',
 'It never stores any data anywhere',
 'The server keeps no session memory between requests; each request carries everything it needs',
 'It can only be called a single time',
 'It requires a persistent open connection like a WebSocket',
 1,
 'Statelessness means no server-side session between calls -- the client supplies all needed context each time, which is what makes REST easy to scale and cache. Data still lives in a database.'),
(84, 'In model training, what does convergence mean?',
 'The loss flattens as the model approaches a stable minimum',
 'The loss explodes toward infinity',
 'The model forgets its earlier training data',
 'Two separate models are merged into one',
 0,
 'Convergence is when the loss stops improving and the weights settle -- the optimization has reached a stable minimum.'),
(85, 'A training run whose loss keeps increasing and oscillating instead of dropping is showing divergence. What is a common cause?',
 'Too much training data',
 'A learning rate that is too high, so updates overshoot the minimum',
 'Too few model parameters',
 'Using retrieval for grounding',
 1,
 'An over-large learning rate makes each step overshoot, so the loss grows instead of shrinking -- the hallmark cause of divergence.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(86, '2026-06-15', 17, 'What is determinism?',
'Determinism means the same input always produces the same output -- no randomness, fully reproducible. Most ordinary code is deterministic: 2 + 2 is always 4. Note this is a different sense from the real-time determinism mentioned earlier in the archive, which meant bounded, predictable TIMING; same word, two uses -- reproducible output versus predictable timing. An LLM''s internal math is deterministic given fixed weights and input; the variability people see comes from the sampling step layered on top, not from the model''s core computation.'),
(87, '2026-06-15', 18, 'What is stochasticity?',
'Stochasticity is the opposite of determinism: it involves randomness or probability, so the same input can yield different outputs by chance. It is why the same prompt gives an LLM different answers -- the model outputs a probability distribution over the next token and randomly samples from it. Stochasticity also lives in training: stochastic gradient descent uses random mini-batches, and weights start from random initialization. It is not a flaw -- randomness buys diversity and creativity at generation time and helps training escape poor local minima.'),
(88, '2026-06-15', 19, 'What is greedy sampling?',
'Greedy sampling (greedy decoding) means that at each step the model always picks the single highest-probability next token. It is deterministic -- no dice are rolled. It is called greedy because it grabs the locally best choice without looking ahead at the whole sentence. Upside: reproducible and usually coherent. Downside: it can get repetitive and bland, and locally best is not the same as globally best -- a different first word might lead to a higher-probability overall sentence, which is what beam search tries to recover. Greedy decoding is effectively what temperature 0 produces.'),
(89, '2026-06-15', 20, 'What is temperature 0 vs temperature 1?',
'Temperature is a knob that reshapes the probability distribution before sampling (it divides the model''s logits, then applies softmax). Temperature 0 collapses the distribution to a spike on the top token, making generation deterministic and greedy -- the most predictable and safe output, but repetitive; best for facts, code, and extraction. Temperature 1 uses the model''s raw, unmodified probabilities, giving more variety and creativity but more errors and tangents; best for brainstorming and prose. Temperature above 1 flattens the distribution further and can become incoherent. So temperature 0 is roughly greedy and deterministic, while temperature 1 is stochastic. Low temperature sharpens the distribution (rich get richer); high temperature flattens it (unlikely tokens get a real shot).'),
(90, '2026-06-15', 21, 'What is generalization vs specialization in AI engineering?',
'Generalization is a model performing well on new, unseen data and across a broad range of tasks -- the opposite of overfitting. A base or foundation model is a generalist: decent at many things. Specialization is narrowing a model to excel at one domain or task -- via fine-tuning, focused prompting, or RAG -- usually at some cost to breadth. The engineering tradeoff: a general model plus good prompting gives flexibility and fast iteration, while specializing (fine-tune or distill) makes a high-volume narrow task cheaper, faster, and more accurate there, but can erode general ability (catastrophic forgetting). You choose based on whether you need range or depth. Note the two senses of generalization: the statistical one (works on unseen data) and the product one (handles many tasks); both apply here.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (86, 'determinism', 'The property that the same input always produces the same output, with no randomness -- fully reproducible. (Distinct from the real-time sense of bounded timing.)'),
  (86, 'reproducibility', 'Being able to get the exact same result by re-running with the same inputs -- a consequence of determinism.'),
  (87, 'stochasticity', 'Involving randomness or probability, so the same input can produce different outputs -- the opposite of determinism.'),
  (87, 'probability distribution', 'A spread of probabilities over possible outcomes; an LLM produces one over the next token and samples from it.'),
  (87, 'stochastic gradient descent (SGD)', 'Training that updates weights using random mini-batches of data rather than the whole set at once -- a source of randomness in training.'),
  (88, 'greedy decoding', 'A generation strategy that always selects the single most probable next token; deterministic but can be repetitive.'),
  (88, 'beam search', 'A decoding strategy that explores several candidate sequences at once and keeps the best overall, addressing greedy''s locally-best blind spot.'),
  (89, 'temperature', 'A sampling knob that reshapes the token probability distribution: low (near 0) is sharp and deterministic, high (>=1) is flat and varied.'),
  (89, 'logits / softmax', 'Logits are the model''s raw output scores per token; softmax turns them into probabilities. Temperature scales the logits before softmax.'),
  (90, 'generalization', 'A model performing well on unseen data and a broad range of tasks -- the opposite of overfitting; also describes a general-purpose model.'),
  (90, 'specialization', 'Narrowing a model to excel at one domain or task (via fine-tuning, prompting, or RAG), often trading away breadth.'),
  (90, 'foundation model', 'A large, broadly-trained model meant to generalize across many tasks, which can then be specialized for specific uses.'),
  (90, 'fine-tuning', 'Further training a pretrained model on domain-specific data to specialize it; can improve the niche but cause catastrophic forgetting elsewhere.'),
  (90, 'catastrophic forgetting', 'When specializing a model on new data degrades its previously learned general abilities.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(86, 'A process is deterministic if...',
 'it produces a different output each run because of randomness',
 'the same input always produces the same output',
 'it always finishes in under one millisecond',
 'it never writes anything to a database',
 1,
 'Determinism is about reproducibility: identical inputs always yield identical outputs, with no randomness involved.'),
(87, 'Why can the same prompt give an LLM different answers on different runs?',
 'Its weights change between runs',
 'Generation is stochastic -- it samples randomly from a probability distribution over next tokens',
 'It retrains itself on each new prompt',
 'Because HTTP is stateless',
 1,
 'The variability comes from stochastic sampling of the next-token distribution, not from any change to the frozen weights.'),
(88, 'What does greedy decoding do at each generation step?',
 'Samples a random token weighted by its probability',
 'Always picks the single highest-probability next token',
 'Explores many sequences and keeps the best overall',
 'Flattens the distribution to add variety',
 1,
 'Greedy decoding deterministically takes the locally most probable token each step; exploring multiple sequences is beam search.'),
(89, 'Compared with temperature 1, what does temperature 0 do to an LLM''s output?',
 'Makes it more random and creative',
 'Makes it deterministic, always taking the most likely token',
 'Flattens the probability distribution so unlikely tokens win more often',
 'Causes the training loss to diverge',
 1,
 'Temperature 0 collapses the distribution onto the top token (greedy, deterministic); temperature 1 uses the raw probabilities for more variety.'),
(90, 'Fine-tuning a broad foundation model so it excels at one narrow domain is an example of what -- and a typical cost?',
 'Generalization; it always improves every task',
 'Specialization; it can trade away breadth (catastrophic forgetting)',
 'Overfitting to the public test set',
 'Greedy sampling; it makes output deterministic',
 1,
 'Narrowing a general model to a domain is specialization, which boosts the niche but can erode previously learned general abilities.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(91, '2026-06-15', 22, 'How do I make a good Claude /loop?',
'A /loop runs a task over and over on a schedule instead of once -- it is for RECURRING work (polling, babysitting a process, repeating a check), not one-shot tasks. Two modes. Fixed interval: /loop 5m /babysit-prs runs the prompt or slash command every 5 minutes, like a metronome you set the beat for. Dynamic (self-paced): /loop watch the deploy and tell me when it is live has no interval, so Claude chooses the delay each tick -- short when something is about to change, long when idle. Six things make a loop good. (1) One clear job per tick: each iteration is a single, well-scoped action ("check open PRs and reply to new review comments"), not a giant task ("fix my whole repo"). (2) A real exit condition: a good loop knows when to STOP, either baked into the prompt ("...until CI goes green, then stop") or by ending naturally; a loop with no stopping rule runs forever and burns money. (3) Watch state that actually changes: check a real moving thing -- a deploy status, a PR queue, a CI run -- and act only on the change; looping on a clock with nothing to observe is wasted motion. (4) Make each tick idempotent (running it twice has the same effect as once): if a tick ACTS -- comments, commits, sends -- it must first check "did I already do this?", or the loop spams the same action repeatedly. (5) Match the cadence to the thing: poll a 10-minute CI run roughly every several minutes, not every 30 seconds. Two rough bands -- under ~5 minutes for actively watching something about to change (this also keeps Claude''s context cache warm and cheap), ~20-30 minutes for idle "just checking" ticks. Never poll faster than the watched thing actually moves. (6) Do not poll for work Claude already tracks: a background job started inside Claude Code notifies you when it finishes, so looping to check it is wasted; loops earn their keep on EXTERNAL state Claude cannot otherwise see (a GitHub deploy, a remote queue, a server you curl). Good: /loop 10m /babysit-prs (recurring, observable, safe to repeat); /loop poll the staging deploy every 2m and ping me when health checks pass (clear exit, right cadence, real external state). Bad: /loop fix all the bugs (one-off, no exit, not idempotent); /loop check the thing every 10s (faster than anything changes, burns tokens). Rule of thumb: a good loop is "keep watching X; when Y changes, do Z; stop when W." If you cannot fill in all four -- what to watch, the change, the action, the stop -- it probably should not be a loop yet.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (91, 'polling', 'Repeatedly checking the current state of something (a deploy, a queue, a file) on an interval to notice when it changes -- what most loops do.'),
  (91, 'fixed-interval vs dynamic loop', 'Fixed-interval runs every N minutes (a metronome you set); dynamic has no interval and lets Claude choose each delay based on what it is waiting for.'),
  (91, 'exit condition', 'The rule that ends a loop (e.g. "stop once CI passes"). Without one, a loop runs forever and keeps spending tokens.'),
  (91, 'idempotent', 'An operation where doing it twice has the same effect as doing it once. Loop ticks that act must be idempotent or they repeat the same action every cycle.'),
  (91, 'cadence', 'How often the loop runs. A good cadence matches how fast the watched thing actually changes -- not faster.'),
  (91, 'context cache', 'Claude''s reuse of recent conversation context to run cheaper/faster. Loop ticks under ~5 minutes apart keep it warm; longer gaps pay to rebuild it.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(91, 'A loop tick posts a comment on a pull request each time it runs. What property must it have so it does not post the same comment over and over?',
 'It must run on a fixed interval rather than dynamically',
 'It must be idempotent -- check whether it already acted before acting again',
 'It must use the fastest possible cadence',
 'It must avoid ever having an exit condition',
 1,
 'A tick that acts (comments, commits, sends) must be idempotent: it checks "did I already do this?" first, so repeating the loop does not repeat the action.');

INSERT INTO days (date, kind, title) VALUES
  ('2026-06-23', 'qa', 'KPIs -- objectives, tasks, and potato examples');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(92, '2026-06-23', 1, 'What is a KPI? How does it relate to a project / objective?',
'KPI stands for Key Performance Indicator: a single measurable number that tells you whether you are moving toward a goal. The word "key" is load-bearing -- it is a metric you have chosen to treat as important, not just any number you happen to collect. Think of it as a gauge on a dashboard: it does not steer the car, it just tells you, at a glance, whether you are headed the right way and how fast.

It sits in a hierarchy, top to bottom:
- OBJECTIVE -- the destination, usually qualitative and aspirational ("grow the Potatuhs audience", "make the storefront feel premium"). You cannot measure an objective directly; it is a direction, not a number.
- KPI -- the measurable proxy that stands in for progress toward that objective ("weekly YouTube watch-time hours", "checkout conversion rate"). It turns a fuzzy goal into something you can read off a chart.
- TARGET -- the KPI plus a specific number and deadline ("watch-time from 200 to 500 hours/week by Sept 1"). A KPI with no target is just a thermometer with no fever line drawn on it.
- TASKS / PROJECTS -- the actual work you do, which you HOPE moves the KPI ("publish two videos a week", "redesign the thumbnail style").

A project is a bounded chunk of work with a start and an end; an objective is the why behind it; the KPI is how you know the project is actually serving the objective rather than just keeping you busy. This is exactly the OKR framework (Objectives and Key Results): the Objective is the qualitative destination, the Key Results are the KPIs with targets attached. The relationship to remember: objectives say where you are going, KPIs tell you if you are getting there, and tasks are the only thing you can actually do. You never "do" a KPI directly -- you do tasks and watch the KPI to see if they worked.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(93, '2026-06-23', 2, 'What makes a good KPI?',
'A good KPI survives a handful of tests. The classic checklist is SMART -- Specific, Measurable, Achievable, Relevant, Time-bound -- but the ones that actually bite for a builder are these:

1. TIED TO AN OBJECTIVE THAT MATTERS. The KPI must be a faithful proxy for the real goal, not a number that is merely easy to collect. This is the vanity-metric trap: "total registered users ever" or "page views" look great and only ever go up, but they do not tell you if the business is healthy. An ACTIONABLE metric ("weekly active users", "paid conversion rate") ties to a real decision; a VANITY metric just flatters you.

2. INFLUENCEABLE. You must be able to move it with your own actions. "Number of sunny days" might correlate with ice-cream sales but it is a terrible KPI because you cannot do anything about it. A good KPI responds when you pull a lever you actually control.

3. CLEARLY DEFINED AND HARD TO GAME. Everyone should compute it the same way ("active = opened the app in the last 7 days", not just "active"). And beware Goodhart''s Law: "when a measure becomes a target, it ceases to be a good measure." If you reward support agents on tickets-closed-per-hour, they will close tickets fast without solving anything. A good KPI is one you cannot juice without also delivering the real value.

4. HAS A TARGET AND A TIMEFRAME. A bare number floating in space means nothing. "Conversion rate" is a metric; "lift conversion from 2% to 3.5% by end of Q3" is a KPI with a target -- now you can succeed or fail at it.

5. LEADING WHERE POSSIBLE, NOT ONLY LAGGING. A LAGGING indicator measures the outcome after the fact (revenue, churn) -- true but too late to react to. A LEADING indicator moves earlier and predicts the lagging one (trial sign-ups this week predict revenue next month; videos published predicts watch-time). Good dashboards pair a lagging KPI you care about with one or two leading KPIs you can act on now.

6. FEW. If everything is a KPI, nothing is. Pick the two or three numbers that, if they moved, would mean the objective is genuinely being met. A wall of 40 metrics is a report, not a focus.

The smell test: a good KPI is one where, if it goes up, you are genuinely happy, and if it goes down, you know you have a real problem and roughly what to look at.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(94, '2026-06-23', 3, 'How does one determine which tasks to do to accomplish a KPI?',
'You work BACKWARDS from the number, because you can never act on the KPI directly -- you act on its inputs. The method:

1. DECOMPOSE THE KPI INTO ITS DRIVERS (a "driver tree" or "metric tree"). Break the top number into the smaller numbers that mathematically produce it. Revenue = visitors x conversion rate x average order value. Watch-time = videos published x views per video x average view duration. Now instead of one vague goal you have three or four concrete levers, and you can see which one is weakest.

2. SEPARATE INPUTS FROM OUTPUTS. The KPI is usually a LAGGING output you do not directly control. Underneath it are INPUT metrics you DO control -- how many videos you ship, how many emails you send, how fast the page loads. Tasks attach to inputs. "Increase revenue" is not a task; "cut checkout from 4 steps to 2" is, and it pulls the conversion-rate lever in the tree.

3. FIND THE HIGHEST-LEVERAGE LEVER. Look at the driver tree and ask where a realistic change produces the biggest move in the top number. If conversion is already 8% but average order value is rock bottom, bundling products beats squeezing conversion further. Attack the weakest or most movable link, not the one that is most fun to work on.

4. BRAINSTORM TASKS PER LEVER, THEN PRIORITIZE. For the chosen lever, list candidate actions, then rank them by expected impact against effort. Lightweight scoring frameworks make this explicit: ICE (Impact x Confidence x Ease) or RICE (Reach x Impact x Confidence / Effort). The point is not the exact math -- it is forcing yourself to admit that a high-effort, low-confidence idea should lose to a cheap, sure one.

5. TREAT EACH TASK AS A HYPOTHESIS AND MEASURE. You do not actually KNOW a task will move the metric -- you believe it will. So frame it as "if we do X, the input metric Y should rise, which should lift the KPI", ship it, and watch. If the metric moves, do more of that; if it does not, you learned cheaply and you stop. This is the build-measure-learn loop.

The mental shift for a builder: stop asking "what should I build?" and start asking "which number am I trying to move, what feeds that number, and what is the cheapest action that moves the feeder?" Tasks chosen this way are accountable -- each one points at a lever, and the lever points at the KPI. Tasks chosen by vibes are just motion.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(95, '2026-06-23', 4, 'What are some examples of KPIs for potatofolk?',
'Potatuhs is a brand + content + commerce operation, so its KPIs cluster by which part of the machine they measure. Concrete, potato-flavored examples:

AUDIENCE & CONTENT (is the brand reaching people?):
- Weekly YouTube watch-time hours (lagging outcome) and videos published per week (leading input that drives it).
- Subscriber net growth per month -- net, so it punishes churn, not just gross sign-ups.
- The Tater Times newsletter open rate and click-through rate (a vanity version would be raw subscriber count; open rate is the honest one).
- Average view duration / retention % on a video -- did potatofolk actually watch, or bounce in 5 seconds?

COMMERCE (does the storefront make money?):
- Checkout conversion rate on the Shopify storefront (visitors who buy).
- Average order value (AOV) -- are people buying one sticker or a loaded bundle?
- Repeat purchase rate -- the share of customers who come back, which proxies whether the brand has real fans vs one-time curiosity buys.

PRODUCT & DEV (is the workbench healthy?):
- Deploy frequency across the repos, and lead time from commit to live -- classic engineering-velocity KPIs.
- For THIS repo''s archive engine: entries logged per active day (is the learning engine actually being fed?) and quiz pass rate on eval mode (did the concepts stick, the whole point of the engine).

BRAND BUILD-OUT (is the world getting more real?):
- Character profiles completed toward the target of 52 -- a project-completion KPI, where the objective ("a fully populated Potatuhs universe") is qualitative but the count is a clean proxy.

Notice the pattern across all of them: each pairs to an objective (reach, revenue, velocity, world-building), most have an obvious leading input you can actually work on, and the good ones resist gaming -- "watch-time" and "repeat purchases" are hard to fake in a way that does not also mean real success, whereas "total followers" would be a vanity number. For a one-person-plus-Claude operation, the honest advice is to pick ONE KPI per active front (one audience, one commerce, one product) rather than tracking all twelve -- focus beats a crowded dashboard.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (92, 'KPI (Key Performance Indicator)', 'A single chosen measurable number that signals whether you are progressing toward a goal -- a gauge, not a steering wheel.'),
  (92, 'objective', 'The qualitative destination or "why" behind work; you cannot measure it directly, so you pick KPIs as proxies for it.'),
  (92, 'OKR (Objectives and Key Results)', 'A goal-setting framework: a qualitative Objective paired with a few measurable Key Results (KPIs with targets) that define success.'),
  (92, 'target', 'A KPI plus a specific number and deadline (e.g. "to 500/week by Sept 1") -- what turns a metric into something you can pass or fail.'),
  (93, 'vanity metric', 'A number that looks impressive and mostly only goes up (total signups, page views) but does not tie to a real decision or business health.'),
  (93, 'actionable metric', 'A metric tied to a specific decision and movable by your own actions -- the opposite of a vanity metric.'),
  (93, 'leading vs lagging indicator', 'A lagging indicator measures the outcome after the fact (revenue); a leading indicator moves earlier and predicts it (trial signups), so you can still act on it.'),
  (93, 'Goodhart''s Law', '"When a measure becomes a target, it ceases to be a good measure" -- people optimize the number itself, gaming it away from the real goal.'),
  (93, 'SMART criteria', 'A checklist for goals/KPIs: Specific, Measurable, Achievable, Relevant, Time-bound.'),
  (94, 'driver tree (metric tree)', 'Breaking a top-level KPI into the smaller metrics that mathematically produce it (Revenue = visitors x conversion x order value), exposing the levers.'),
  (94, 'input vs output metric', 'Output (lagging) metrics are results you cannot touch directly (revenue); input (leading) metrics are the controllable actions that feed them (videos shipped). Tasks attach to inputs.'),
  (94, 'leverage / highest-leverage', 'The lever in the driver tree where a realistic change produces the biggest move in the top number -- where effort should go first.'),
  (94, 'ICE / RICE prioritization', 'Lightweight scoring to rank tasks: ICE = Impact x Confidence x Ease; RICE = Reach x Impact x Confidence / Effort.'),
  (94, 'build-measure-learn', 'Treating each task as a hypothesis: ship it, measure whether the metric moved, keep what works and drop what does not.'),
  (95, 'churn', 'The rate at which existing users/customers/subscribers leave; "net growth" subtracts churn from gross additions to show real progress.'),
  (95, 'conversion rate', 'The share of people who take a desired action (e.g. visitors who actually buy) -- a core commerce KPI.'),
  (95, 'average order value (AOV)', 'The average amount spent per order -- a lever for revenue that is independent of how many customers you have.'),
  (95, 'deploy frequency / lead time', 'Engineering-velocity KPIs: how often you ship to production, and how long code takes to go from commit to live.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(92, 'In the objective -> KPI -> task hierarchy, which can you act on DIRECTLY?',
 'The objective, by willing it to happen',
 'The KPI, by adjusting the number',
 'The tasks, which you then hope move the KPI',
 'All three are acted on directly and equally',
 2,
 'You never "do" an objective or a KPI directly -- you do tasks and watch the KPI to see whether they moved you toward the objective.'),
(93, 'Why is "total registered users since launch" usually a weak KPI?',
 'It is impossible to measure accurately',
 'It is a vanity metric -- it only goes up and does not tie to a real decision or current health',
 'It violates SMART because it is too specific',
 'It is a leading indicator, which are always bad',
 1,
 'A number that only ever rises and is not tied to a decision is a vanity metric; an actionable metric like weekly active users reflects real, current health.'),
(94, 'You want to grow revenue. What is the right first move to decide which tasks to do?',
 'Pick whichever task sounds most fun and start building',
 'Decompose revenue into its driver tree (visitors x conversion x order value) and attack the weakest movable lever',
 'Set revenue itself as a daily task and work on it directly',
 'Add as many metrics to the dashboard as possible',
 1,
 'You cannot act on revenue directly; you break it into input levers via a driver tree, then choose tasks that move the highest-leverage one.'),
(95, 'Which of these is the most honest (least gameable) KPI for the Potatuhs storefront?',
 'Total social media followers',
 'Number of times the logo was viewed',
 'Repeat purchase rate -- the share of customers who buy again',
 'Total pages on the website',
 2,
 'Repeat purchases are hard to fake in a way that is not also real success (loyal customers), whereas follower and page counts are classic vanity metrics.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(96, '2026-06-23', 5, 'What are some example KPIs for a potato farmer?',
'A potato farmer is running a biological factory with one harvest a year, so the KPIs cluster around getting the most sellable spuds per acre at the lowest input cost, then not losing them in storage.

PRODUCTION (the headline output):
- Yield per acre -- usually measured in hundredweight (cwt) per acre, or tons per hectare. This is the top-line lagging number the whole season feeds into.
- Marketable yield % -- of everything you dig up, what fraction actually grades out for sale vs culls (too small, green, scab, rot, mechanical damage). A huge gross yield with 30% culls is worse than a modest yield that is nearly all sellable.
- Size profile / size distribution -- the share of tubers in the size band your buyer wants. A fry-contract buyer pays for long tubers; a seed or baby-potato market wants small. Same field, different "good".

INPUT EFFICIENCY (the cost levers):
- Cost per cwt produced (not just cost per acre) -- ties spending to actual sellable output, the honest unit-cost KPI.
- Water-use efficiency -- yield per acre-inch of irrigation, which matters where water is metered or scarce.
- Fertilizer/chemical cost per acre and nitrogen-use efficiency.

QUALITY & RISK:
- Specific gravity -- a density measure that predicts solids content; processors paying for chips/fries care intensely about it, and it is often a contract bonus/penalty line.
- Disease/pest incidence -- e.g. % of acres showing late blight, the share affected by a target threshold; a leading indicator that predicts both yield loss and spray cost.

POST-HARVEST (where money quietly leaks):
- Storage loss / shrink % -- potatoes are stored for months, and shrink from dehydration, sprouting, and rot can erase a good harvest. Pounds lost between bin-in and ship-out.
- Price realized per cwt vs contract -- what you actually got paid against what you were promised or against the open market.

Notice the supply-chain framing: yield is the lagging output, while irrigation, disease scouting, and storage conditions are the leading, controllable inputs -- exactly the input-vs-output split from earlier today. A farmer who only watches final yield is reading the thermometer after the patient has left; the leading KPIs (disease incidence, water efficiency, storage shrink) are the ones you can still act on in time.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(97, '2026-06-23', 6, 'What are some example KPIs for a trucker?',
'Trucking is a thin-margin asset-utilization game: an expensive truck either earns money by rolling loaded or bleeds money sitting or running empty. The KPIs measure money-per-mile, how fully the asset is used, and safety -- because one crash erases a year of margin.

ECONOMICS (per-mile is the unit):
- Cost per mile (CPM) -- total operating cost (fuel, maintenance, insurance, pay, depreciation) divided by miles. The single most-watched number in trucking.
- Revenue per mile, and specifically revenue per LOADED mile -- what you earn when actually hauling freight.
- Deadhead percentage -- the share of miles driven EMPTY (repositioning with no load). High deadhead is pure cost with zero revenue; cutting it is one of the biggest leading levers.

UTILIZATION (is the asset working?):
- Miles per truck per week / asset utilization -- how hard each truck and driver is being used against its capacity.
- Load factor -- how full each trailer is (weight or cubic space). Hauling air is wasted capacity.

SERVICE (do shippers keep hiring you?):
- On-time delivery rate -- the share of loads delivered in the promised window; the core service KPI customers judge you on.
- Claims / cargo damage rate -- for perishables like potatoes this includes reefer (refrigerated) temperature compliance: loads that broke the cold chain and spoiled.

EFFICIENCY & SAFETY:
- Fuel efficiency (MPG) -- fuel is often the #1 or #2 cost, so a fraction of an MPG across a fleet is real money; driver behavior (idling, speed) is the leading input.
- Accidents per million miles / CSA safety score / hours-of-service (HOS) compliance -- safety is a KPI because it is also an existential cost: crashes, fines, and lost authority.
- Maintenance cost per mile and unplanned downtime hours -- a truck in the shop earns nothing.
- Driver turnover rate -- recruiting and training drivers is expensive, so churn is a tracked cost in its own right.

The through-line: cost-per-mile is the lagging output, and deadhead %, MPG, on-time %, and downtime are the controllable inputs that drive it -- you do not move CPM directly, you cut empty miles and idling and the number follows.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(98, '2026-06-23', 7, 'What are some example KPIs for a potato processor?',
'A processor turns raw potatoes into fries, chips, hash browns, dehydrated flakes, or starch. It is a manufacturing operation, so the KPIs are factory KPIs: how much finished product you squeeze from each ton of raw input, how hard the line runs, and whether quality and food safety hold.

YIELD & THROUGHPUT (the core of the economics):
- Recovery / yield rate -- pounds of finished product per ton of raw potatoes in. This is THE number: potatoes are ~80% water, and peeling, trimming, and defect removal eat into the rest, so a few points of recovery is enormous margin. Raw input is the biggest cost, so wasting it is the cardinal sin.
- Throughput -- tons (or cases) per hour the line produces. Sets how much fixed cost gets spread across product.

EQUIPMENT EFFICIENCY:
- OEE (Overall Equipment Effectiveness) -- the standard factory KPI, the product of three: Availability (was the line running vs down?) x Performance (running at rated speed?) x Quality (output that passed first time?). One number that captures whether the plant is actually delivering its capacity.
- Unplanned downtime hours -- the availability killer; every hour the fryer or peeler is stopped is lost product against fixed cost.

QUALITY & WASTE:
- First-pass yield / quality grade rate -- the share of product that passes spec without rework or downgrade (right color, length, defect-free fries).
- Scrap / waste % -- product or raw material lost to defects, off-spec, or trim beyond normal.

COST & RESOURCES:
- Cost per unit produced (per case, per pound).
- Energy and water per ton -- frying and washing are utility-intensive, and these are both cost and sustainability KPIs.
- Labor productivity -- units per labor hour.

SAFETY (non-negotiable in food):
- Food-safety audit score, contamination/pathogen incidents, and recall events -- a recall is a catastrophic, brand-ending failure, so these are watched as risk KPIs even though "zero" is the only acceptable target.

The recurring pattern: recovery rate and OEE are the lagging outputs everyone reports, while downtime, line speed, and defect rate are the input levers you actually pull -- and because raw potatoes dominate the cost, recovery is usually the single highest-leverage KPI in the whole plant.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(99, '2026-06-23', 8, 'What are some example KPIs for a potato distributor?',
'A distributor is the middle of the chain -- it buys potatoes (raw or processed) in bulk, warehouses them, and moves them to retailers and foodservice. The product is perishable, margins are thin, and the whole job is logistics, so the KPIs are about not running out, not spoiling inventory, and shipping complete orders on time.

SERVICE LEVEL (do customers get what they ordered?):
- Order fill rate -- the share of ordered units actually shipped from stock. A retailer that orders 100 cases and gets 90 had a 90% fill; chronic shortfalls lose the account.
- On-Time In-Full (OTIF) -- the stricter combined KPI: the order arrived on time AND complete. The gold-standard distribution service metric.
- Stockout rate -- how often an item is unavailable when a customer wants it; the flip side of fill rate and a direct lost-sale measure.

INVENTORY HEALTH (the perishable tightrope):
- Inventory turnover -- how many times you sell through and replace stock in a period. For fresh potatoes you WANT high turns because the product rots; slow turns mean spoilage.
- Spoilage / shrink % -- product written off to rot, damage, or expiry. The defining cost of perishable distribution, and the number that punishes over-ordering.
- Days of supply / days inventory outstanding -- how many days of demand your current stock covers; too low risks stockouts, too high risks spoilage. The balance IS the job.

OPERATIONS (the warehouse):
- Picking accuracy -- share of order lines picked correctly (right item, right count); errors cause returns and chargebacks.
- Warehouse throughput -- cases or pallets shipped per labor hour or per day.
- Cold-chain compliance -- share of time product stayed in the required temperature band, since a break means spoilage downstream.

ECONOMICS:
- Cost per case (or per pallet) shipped -- the unit logistics cost.
- Gross margin per SKU -- thin-margin businesses live and die on the mix of what they move.
- Customer retention / returns rate -- whether buyers keep coming back, and how much comes back rejected.

The tension that defines distributor KPIs: fill rate and spoilage pull in opposite directions -- carry more stock and you never stock out but you spoil more; carry less and you waste nothing but miss orders. Days-of-supply and inventory turnover are the dials you tune to sit in the narrow band between those two failures.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (96, 'yield per acre (cwt/acre)', 'The headline farm-output KPI: hundredweight of potatoes harvested per acre (or tons per hectare).'),
  (96, 'marketable yield / cull rate', 'The share of harvested potatoes that grade out as sellable vs culls (undersized, damaged, diseased) that are discarded.'),
  (96, 'specific gravity', 'A density measure predicting a potato''s solids content; processing buyers pay bonuses/penalties on it because it affects fry and chip quality.'),
  (96, 'shrink / storage loss', 'Weight lost during months of storage to dehydration, sprouting, and rot -- it can quietly erase a good harvest.'),
  (97, 'cost per mile (CPM)', 'Total operating cost divided by miles driven -- the central economic KPI in trucking.'),
  (97, 'deadhead', 'Miles driven empty while repositioning with no load -- pure cost, zero revenue; a key efficiency lever to minimize.'),
  (97, 'asset utilization', 'How fully an expensive asset (the truck) is used against its capacity -- e.g. loaded miles per truck per week.'),
  (97, 'cold chain / reefer compliance', 'Keeping perishable freight within a required refrigerated temperature band the whole trip; a break spoils the load.'),
  (98, 'recovery / yield rate', 'Finished product produced per ton of raw potatoes in -- the dominant processor KPI, since raw input is the biggest cost.'),
  (98, 'OEE (Overall Equipment Effectiveness)', 'A standard factory KPI = Availability x Performance x Quality; one number for how much of rated capacity a line actually delivers.'),
  (98, 'first-pass yield', 'The share of output that passes spec the first time with no rework or downgrade.'),
  (98, 'throughput', 'The rate of production -- tons or cases per hour -- over which fixed costs get spread.'),
  (99, 'order fill rate', 'The share of ordered units actually shipped from stock; the core distributor service KPI.'),
  (99, 'OTIF (On-Time In-Full)', 'The strict service KPI: an order delivered both on time and complete.'),
  (99, 'inventory turnover', 'How many times stock is sold through and replaced in a period; high turns matter most for perishables that rot.'),
  (99, 'days of supply', 'How many days of demand current inventory covers -- tuned between stockout risk (too low) and spoilage risk (too high).');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(96, 'A farmer''s field has a huge gross yield per acre, but 35% of the potatoes are culls. Which KPI exposes the problem that raw yield hides?',
 'Specific gravity',
 'Marketable yield % (sellable fraction after culls)',
 'Cost per acre',
 'Water-use efficiency',
 1,
 'Gross yield counts everything dug up; marketable yield % strips out culls to show how much is actually sellable -- a high gross with many culls is a weak result.'),
(97, 'Why is deadhead percentage such an important KPI for a trucker?',
 'It measures how fast the truck can legally drive',
 'It is the share of miles driven empty -- pure cost with no revenue, so cutting it directly improves margin',
 'It tracks how many drivers quit each year',
 'It measures the refrigeration temperature of the load',
 1,
 'Deadhead miles are driven empty: full operating cost, zero revenue. Reducing them is one of the highest-leverage ways to lift per-mile profitability.'),
(98, 'For a potato processor, why is recovery (yield) rate usually the single highest-leverage KPI?',
 'Because finished product never spoils',
 'Because raw potatoes are the biggest cost, so squeezing more finished product per ton of input drives the most margin',
 'Because it is the easiest number to measure',
 'Because customers see it on the package',
 1,
 'Raw input dominates a processor''s cost, so a few points more finished product per ton of potatoes is enormous margin -- recovery rate is the core lever.'),
(99, 'A potato distributor''s fill rate and spoilage % pull in opposite directions. Which KPI is the dial used to balance them?',
 'Cost per mile',
 'Specific gravity',
 'Days of supply (how many days of demand current stock covers)',
 'Overall Equipment Effectiveness',
 2,
 'More stock raises fill rate but spoils more; less stock cuts spoilage but risks stockouts. Days of supply is the dial tuned to sit between those two failures.');

INSERT INTO days (date, kind, title) VALUES
  ('2026-06-27', 'qa', 'Ontology and epistemology -- two words philosophers use, and where they show up in code');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(100, '2026-06-27', 1, 'What is ontology?',
'Ontology is the branch of philosophy that asks "what exists, and how is it organized?" Strip away the philosophy-class vibe and it is just this: a careful account of WHAT THINGS ARE and HOW THEY RELATE. What categories of thing exist, what counts as the same thing vs. a different thing, and which things are kinds of other things.

A plain example: is a "shadow" a thing that exists, or just the absence of light? Is a company a real entity, or just a label for a group of people? Those are ontological questions -- they are about the furniture of reality, not about how we know things (that is epistemology, its sister concept).

Here is why a developer should care: you do ontology every single time you design a data model, and most people never notice. When you decide your app has Users, and a User HAS MANY Orders, and an Order BELONGS TO a Customer (and you then have to decide whether a Customer is the same thing as a User or a different thing) -- that is ontology. You are declaring what exists in your system and how those things relate. A database schema is a small, enforced ontology. Class hierarchies are ontology. The is-a relationship ("a Dog is-a Animal") and the has-a relationship ("a Car has-a Engine") are the two backbone relations of both OOP and formal ontologies.

The word also has a hard technical meaning in computer science. In the Semantic Web / knowledge-graph world, an "ontology" is a literal, machine-readable file (written in languages like OWL or RDF Schema) that formally defines the entities, categories, properties, and relationships in some domain -- so that software can reason about them. Schema.org, the vocabulary that tells Google a web page is about a Recipe with a cookTime and an author, is exactly this kind of ontology.

The one-sentence version: ontology is the study of what exists and how it is categorized, and you are practicing it -- informally -- the moment you choose your tables, types, and relationships.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(101, '2026-06-27', 2, 'What is epistemology?',
'Epistemology is the branch of philosophy that asks "what is knowledge, and how do we know what we know?" If ontology is about WHAT EXISTS, epistemology is about HOW WE COME TO KNOW IT -- and how we tell justified, true belief apart from a lucky guess. The two are sisters: one is about reality, the other is about our access to reality.

The classic definition it wrestles with is "knowledge = justified true belief." To count as KNOWING something, three things have to line up: you believe it, it is actually true, AND you have good reason (justification) for believing it. Guessing the right answer is not knowledge, because the justification is missing. Most of epistemology is poking at the edges of that definition -- when is evidence good enough, how do we handle being wrong, what makes a source trustworthy.

Why this matters to a developer, concretely: software is full of moments where you have to ask "how do I actually KNOW this is true?" rather than just believing it.
- "The bug is fixed." Do you KNOW that, or do you believe it because the code looks right? Writing a failing test, then watching it pass, is epistemology in action -- it is the justification that upgrades a belief into knowledge.
- "Reading what Claude actually did vs. what it claims it did" (a fundamental in this very repo) is a pure epistemology move: do not accept the claim, check the evidence.
- Logs, tests, monitoring, and reproducible bug reports all exist for one reason -- to give you justified knowledge of what your system is really doing instead of a comfortable belief.

It also names the failure modes. When you assume a fix works without verifying, you have a belief that is not knowledge. When you trust a Stack Overflow answer because it has lots of upvotes, you are leaning on a specific (and sometimes weak) source of justification. Good engineering is largely applied epistemology: building cheap ways to find out whether what you believe is actually true, before it costs you.

The one-sentence version: epistemology is the study of knowledge and justification -- and as a developer you practice it every time you refuse to trust a claim until you have evidence for it.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (100, 'ontology', 'The philosophical study of what exists and how it is categorized; in CS, a machine-readable formal definition of the entities and relationships in a domain.'),
  (100, 'is-a / has-a relationships', 'The two backbone relations for organizing things: is-a expresses a kind/subtype (a Dog is-a Animal), has-a expresses composition (a Car has-a Engine).'),
  (100, 'schema as ontology', 'A database schema or class hierarchy is a small enforced ontology -- it declares what entities exist in a system and how they relate.'),
  (100, 'OWL / RDF (Semantic Web)', 'Languages for writing literal ontology files that let software reason about entities and relationships; schema.org is a widely used example.'),
  (101, 'epistemology', 'The philosophical study of knowledge -- what it is and how we come to know things, distinguishing justified belief from lucky guesses.'),
  (101, 'justified true belief', 'The classic definition of knowledge: to know something you must believe it, it must be true, AND you must have good reason for believing it.'),
  (101, 'justification', 'The good reason or evidence that upgrades a mere belief into knowledge; a passing test is justification that a fix works.'),
  (101, 'applied epistemology (in engineering)', 'Tests, logs, monitoring, and verification exist to convert beliefs about a system into justified knowledge of what it actually does.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(100, 'You design a schema where a User HAS MANY Orders and decide a Customer is a separate entity from a User. In philosophical terms, what are you doing?',
 'Epistemology -- deciding how you know the data is correct',
 'Ontology -- declaring what entities exist in your system and how they relate',
 'Just normalization, unrelated to philosophy',
 'Defining the justification for your beliefs',
 1,
 'Choosing what entities exist (User, Order, Customer) and how they relate (has-many, same-or-different) is ontology: an account of what exists and how it is categorized. A schema is a small enforced ontology.'),
(101, 'You believe a bug is fixed because the code "looks right," but you have not run any test. Epistemologically, what is missing for this to count as knowledge?',
 'The belief -- you do not actually believe it',
 'The truth -- the bug is definitely still there',
 'The justification -- you have no evidence (like a passing test) backing the belief',
 'Nothing; looking right is sufficient justification',
 2,
 'Knowledge is justified true belief. You have the belief, but without evidence such as a failing-then-passing test you lack justification, so it stays a belief, not knowledge.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(102, '2026-06-27', 3, 'What is tzimtzum?',
'Tzimtzum (Hebrew, roughly "contraction" or "withdrawal") is a core idea from Kabbalah -- Jewish mysticism -- specifically the system worked out by Rabbi Isaac Luria in 16th-century Safed. It is an answer to a deceptively simple puzzle: if God is infinite and fills literally all of reality, then there is no "room" anywhere for a world to exist. An infinite, all-filling presence leaves no empty space for anything that is not God.

Luria''s answer is tzimtzum: before creating, God CONTRACTS -- withdraws or conceals the infinite divine light from a region, creating a kind of vacated space (the "chalal" or void). Into that cleared-out space, a measured beam of light is then projected, and the finite world is built inside it. So creation begins not with an outpouring but with a SELF-LIMITATION. The first creative act is making absence, an empty room, so that something other than the creator can exist at all.

The big, counterintuitive move here is that creation requires the creator to STEP BACK, not lean in. Existence, autonomy, even the possibility of free will and of a world that feels separate from God -- all of it depends on the creator restraining presence rather than flooding the space. Withdrawal is the generous act.

Two related Lurianic terms usually travel with it: shevirat ha-kelim ("the shattering of the vessels") -- the vessels meant to hold the divine light could not contain it and broke, scattering sparks of holiness into the world -- and tikkun olam ("repair of the world"), the human task of gathering those scattered sparks. Tzimtzum is the opening move of that whole cosmic drama.

There is a clean cross-over to how you work, and it is worth naming rather than forcing. A creator who fills every gap leaves no room for the created thing to be itself. Good mentorship, good management, good API design, and -- bluntly -- good use of a tool like Claude all share this shape: you have to leave deliberate space for the other party to act. Over-specify every detail and you crowd out the collaborator''s contribution; withhold all structure and nothing coherent forms. The skill is the measured contraction -- clear enough space for real work to happen, then project just enough structure into it. That is tzimtzum as a working principle: sometimes the most creative thing you can do is withdraw and make room.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (102, 'tzimtzum', 'A Kabbalistic concept: God''s self-contraction or withdrawal of infinite light to make empty space in which a finite world can exist.'),
  (102, 'Kabbalah', 'The tradition of Jewish mysticism; tzimtzum comes from its Lurianic strand, systematized by Rabbi Isaac Luria in 16th-century Safed.'),
  (102, 'shevirat ha-kelim', '"Shattering of the vessels" -- the Lurianic idea that the vessels meant to hold the divine light broke, scattering holy sparks into the world.'),
  (102, 'tikkun olam', '"Repair of the world" -- the human task of gathering the scattered sparks; the redemptive counterpart to tzimtzum and the shattering.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(102, 'In Lurianic Kabbalah, what is the core move of tzimtzum, and why is it needed?',
 'God pours out infinite light to flood and fill all of creation',
 'God contracts/withdraws the infinite light to make empty space in which a finite world can exist',
 'Humans gather scattered sparks of holiness to repair the world',
 'The vessels holding the divine light shatter and scatter sparks',
 1,
 'Tzimtzum is self-limitation: an infinite, all-filling presence leaves no room for a world, so God withdraws to create vacated space. The shattering (shevirat ha-kelim) and repair (tikkun olam) are later steps in the drama, not tzimtzum itself.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(103, '2026-06-27', 4, 'What are the competing ideas on the expansion and contraction of the universe?',
'Start with the one thing that is NOT in dispute: the universe is expanding right now. Edwin Hubble showed in the 1920s that distant galaxies are racing away from us, and the farther they are the faster they go -- space itself is stretching. Rewind that expansion and everything was once hot and dense: the Big Bang. The genuine debate is not "is it expanding" but "what happens in the very long run -- does expansion continue forever, reverse into a collapse, or cycle?" The answer hinges on two unknowns: how much total stuff (gravity, which pulls inward) the universe contains, and the nature of DARK ENERGY (a mysterious pressure that pushes outward and currently dominates).

THE THREE CLASSIC FATES (these came from asking whether gravity can win):
- BIG FREEZE / HEAT DEATH -- expansion continues forever and gradually wins. Stars burn out, galaxies drift apart, everything cools toward a uniform, near-absolute-zero, maximally-disordered state where nothing more can happen. This is the current front-runner given the evidence.
- BIG CRUNCH -- if there were enough matter, gravity eventually halts the expansion and reverses it; the universe falls back together into a hot, dense point -- the Big Bang run in reverse. This was the leading "closed universe" idea before dark energy was discovered.
- THE FLAT/CRITICAL CASE -- exactly enough matter to slow expansion asymptotically toward a stop without ever reversing. A knife-edge balance.

THE DARK-ENERGY-ERA IDEAS (these came from the 1998 shock that expansion is ACCELERATING):
- ACCELERATING EXPANSION (the standard model today) -- dark energy is not just present but dominant and constant, so expansion speeds up over time. This points toward the Big Freeze, just faster and lonelier.
- BIG RIP -- if dark energy''s push GROWS stronger over time ("phantom dark energy"), it eventually overwhelms gravity at every scale: first galaxies, then solar systems, then atoms themselves are torn apart at a finite future moment. A violent, expansion-wins-totally ending.

THE CYCLIC IDEAS (these reject "one beginning, one end"):
- BIG BOUNCE / OSCILLATING UNIVERSE -- a crunch does not end in a point but "bounces" into a new expansion; the universe goes through endless bang-crunch-bang cycles. The old oscillating model ran into entropy problems (each cycle should get more disordered).
- CYCLIC / EKPYROTIC MODELS (Steinhardt-Turok) -- a modern revival using ideas from string theory where colliding higher-dimensional "branes" trigger repeating big bangs, sidestepping some of the old entropy objections.
- CONFORMAL CYCLIC COSMOLOGY (Roger Penrose) -- the far-future heat-death of one universe, once nothing with mass or scale is left, is geometrically equivalent to the Big Bang of the next "aeon," so the story repeats without a literal crunch.

A historical footnote: the STEADY STATE theory (Hoyle, mid-20th century) held the universe expands but has no beginning or end, with new matter continuously created to keep density constant. It was a real rival to the Big Bang until the cosmic microwave background -- the leftover heat-glow of the early hot universe -- was found in 1965 and effectively killed it.

The honest bottom line: current measurements favor a flat, dark-energy-dominated universe heading for an accelerating Big Freeze. But because we do not actually understand what dark energy IS, whether it stays constant (Freeze), strengthens (Rip), or could someday reverse (Crunch/Bounce) is genuinely open. The competing ideas are really competing bets about the behavior of a force we have measured but cannot explain.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (103, 'dark energy', 'A not-understood outward pressure that currently dominates the universe and drives accelerating expansion; whether it stays constant, grows, or reverses determines the universe''s fate.'),
  (103, 'Big Freeze / heat death', 'The fate where expansion continues forever and the universe cools to a uniform, maximally-disordered, near-absolute-zero state; the current front-runner.'),
  (103, 'Big Crunch', 'The fate where gravity halts and reverses expansion, collapsing the universe back into a hot dense point -- the Big Bang in reverse.'),
  (103, 'Big Rip', 'A fate where dark energy strengthens over time until it tears apart galaxies, solar systems, and finally atoms at a finite future moment.'),
  (103, 'Big Bounce / cyclic cosmology', 'Models where the universe repeats: a collapse bounces into a new expansion, or aeons/brane-collisions trigger endless big bangs.'),
  (103, 'cosmic microwave background (CMB)', 'The leftover heat-glow of the early hot universe, detected in 1965; its discovery confirmed the Big Bang and killed the steady-state theory.'),
  (103, 'critical density / flat universe', 'The knife-edge amount of matter-energy that separates a universe that recollapses from one that expands forever; measurements show ours is very close to flat.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(103, 'Which single unknown most directly determines whether the universe ends in a Big Freeze, a Big Rip, or a Big Crunch?',
 'The exact age of the universe',
 'The behavior of dark energy -- whether it stays constant, strengthens, or could reverse',
 'How many galaxies currently exist',
 'The temperature of the cosmic microwave background',
 1,
 'The fate hinges on dark energy: constant dark energy points to an accelerating Big Freeze, strengthening (phantom) dark energy gives a Big Rip, and a weakening or reversing push could allow a Crunch or Bounce. We have measured dark energy but cannot yet explain it.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(104, '2026-06-27', 5, 'What is hashing in computer science?',
'Hashing is taking some input of ANY size -- a word, a file, a whole database row -- and running it through a function that spits out a fixed-size value, called a HASH (or digest). The function is the HASH FUNCTION. Same input always produces the same output; a different input almost always produces a different output. The output looks scrambled and is usually much smaller than the input. Crucially, hashing is ONE-WAY by design: easy to compute forward (input -> hash), effectively impossible to run backward (hash -> input).

A useful mental image: a hash is a fingerprint. A fingerprint is tiny compared to the whole person, two different people essentially never share one, and you cannot reconstruct the person from the fingerprint. But if you have the person, you can always re-take the print and check it matches.

There are two big families of use, and they care about different properties.

1. HASH TABLES (the data-structure use -- this is the one that makes hashing a daily tool).
A hash table is the machinery behind a Python dict, a JavaScript object/Map, a Java HashMap, a Go map. The problem it solves: you want to store key-value pairs and look them up FAST. Naively, finding a key in a list means scanning every entry -- slow when there are millions. Instead, you hash the key to get a number, and use that number (mod the array size) as an INDEX into an array of "buckets." Now lookup is: hash the key, jump straight to that bucket. That turns search from O(n) -- check everything -- into roughly O(1) -- constant time, regardless of how big the table gets. That speed is why hash tables are everywhere.
The wrinkle is COLLISIONS: two different keys can hash to the same bucket (the output space is finite, the input space is not). Hash tables handle this with strategies like chaining (each bucket holds a small list) or open addressing (probe for the next free slot). A good hash function spreads keys evenly so collisions stay rare.

2. CRYPTOGRAPHIC HASHING (the security use).
Here you use a special, much stronger hash function (SHA-256, for example) and you lean on the one-way property. Key applications:
- INTEGRITY / verification: download a file plus its published hash, re-hash the file yourself, compare. If even one bit changed, the hash is wildly different (the "avalanche effect"), so you know the file was corrupted or tampered with.
- PASSWORD STORAGE: a server should NEVER store your actual password. It stores the hash. When you log in, it hashes what you typed and compares hashes. If the database leaks, attackers get hashes, not passwords. (In practice you add a random SALT to each password before hashing, so identical passwords do not produce identical hashes and precomputed "rainbow table" attacks fail.)
- Git, blockchains, deduplication, digital signatures all lean on content-addressing by hash -- the hash IS the identity of the content.

The properties that make a hash function "good" depend on the job:
- For hash tables: fast to compute, and spreads inputs evenly to minimize collisions.
- For cryptography: also deterministic and fast to verify, PLUS irreversible (cannot get input from output) and collision-RESISTANT (you cannot feasibly find two inputs with the same hash) -- properties an ordinary hash-table hash does not need and does not have.

The one-sentence version: hashing maps arbitrary data to a fixed-size fingerprint -- used either to find things instantly (hash tables) or to verify and protect things without revealing them (cryptographic hashing).');

INSERT INTO vocab (entry_id, term, def) VALUES
  (104, 'hash function', 'A function that maps input of any size to a fixed-size output (the hash/digest); deterministic and one-way -- easy forward, infeasible backward.'),
  (104, 'hash table', 'A data structure that stores key-value pairs and uses the hash of a key as an array index, giving roughly O(1) lookup; the engine behind dicts/maps/objects.'),
  (104, 'collision', 'When two different inputs hash to the same value/bucket; unavoidable because inputs are infinite and outputs finite, handled by chaining or open addressing.'),
  (104, 'O(1) constant time', 'An operation whose cost does not grow with the size of the data -- hash-table lookups approximate this, vs O(n) scanning every element.'),
  (104, 'cryptographic hash (e.g. SHA-256)', 'A hardened hash function that is irreversible and collision-resistant, used for integrity checks, password storage, and content addressing.'),
  (104, 'salt', 'A random value added to a password before hashing so identical passwords get different hashes, defeating precomputed rainbow-table attacks.'),
  (104, 'avalanche effect', 'The property that changing even one bit of input produces a drastically different hash -- what makes tampering detectable.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(104, 'Why does a hash table make key lookups roughly O(1) instead of O(n)?',
 'It keeps all keys sorted so it can binary-search them',
 'It hashes the key to compute an array index and jumps straight to that bucket, instead of scanning every entry',
 'It stores fewer items than a list does',
 'It compresses the keys so they take less memory',
 1,
 'Hashing the key yields a number used directly as an index into the bucket array, so lookup goes straight to the location instead of checking each element in turn -- constant time rather than linear scanning.');

INSERT INTO days (date, kind, title) VALUES
  ('2026-06-30', 'qa', 'Claude primitives -- goal, skill, and loop');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(105, '2026-06-30', 1, 'What is a Claude goal?',
'A goal is the end-state you hand Claude -- the "done" you are steering toward, stated as an OUTCOME rather than a list of keystrokes. Correction worth flagging loudly (the assistant got this wrong twice before checking the web): /goal IS a real built-in Claude Code command, shipped by Anthropic in version 2.1.139 on 2026-05-12. You set a COMPLETION CONDITION and Claude then works autonomously across multiple turns until the goal is met, tracking progress and monitoring resource usage (elapsed time, turns, tokens); it works in interactive CLI, programmatic (-p flag), and Remote Control modes. Note it is a built-in COMMAND/feature, not an installable Agent Skill -- it is NOT in the anthropics/skills repo. (Separately and confusingly, Brett also authored a CUSTOM project-scoped /goal at ~/Potatuhs/hpg/sod_tori/.claude/commands/goal.md -- a name collision that only loads inside that repo.) The deeper point stands regardless: a goal is the thing every other piece serves. The difference between a chatbot and an agent is exactly this: an agent is given a goal and keeps acting until the goal is met.

A useful contrast is OUTCOME vs OUTPUT. An output is a step ("add an INSERT to seed.sql, then run the build script"). An outcome is a destination ("today''s archive page shows my three new entries, each with a working quiz"). You own the destination. Let Claude find the route, and correct it when the route is wrong. If you hand over the route instead of the destination, you have stopped using an agent and started using a very expensive autocomplete.

A sharp goal carries three things:
- AN OUTCOME -- what is true in the world when the work is done.
- CONSTRAINTS -- what must NOT change, and which rules to respect (in this repo: never write entries straight into archive.db, always go through seed.sql).
- A CHECK -- how you will know it actually worked (the page renders, the quiz scores, the db rebuilt without error).

This is also why cyummu exists. "Building the wrong thing" is just "optimizing hard toward the wrong goal," and the expensive part is the optimizing. cyummu forces the goal to be explicit and shared BEFORE the loop spends any effort on it. Vague goal in, vague work out -- so the cheapest move you have is to make the destination unmistakable first.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (105, 'goal / objective', 'The desired end-state you hand an agent; what every action is steering toward. Not a command -- the thing commands serve.'),
  (105, 'outcome vs output', 'An outcome is the destination (what is true when done); an output is a single step. Steer by outcome, delegate the steps.'),
  (105, 'goal-directed (agentic)', 'Behavior that keeps acting until a goal is met, rather than emitting one fixed response. The defining trait of an agent.'),
  (105, 'acceptance criteria', 'The concrete check that says a goal is met -- how you and Claude both agree the work is actually done.'),
  (105, 'underspecification', 'Leaving the goal vague or implicit; the usual root cause of confidently-wrong work. cyummu is the fix.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(105, 'Which of these is a well-formed GOAL to hand Claude, rather than a list of steps?',
 'Open seed.sql, add an INSERT, then run the build script',
 'Today''s archive page shows my new entry with a working quiz, with seed.sql as the source of truth',
 'Run node scripts/build-db.mjs',
 'Edit line 3772 of seed.sql',
 1,
 'A goal states the outcome and its check (page renders, quiz works, seed.sql stays canonical) and leaves the route to Claude. The others are individual steps -- outputs, not the destination.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(106, '2026-06-30', 2, 'What is a Claude skill?',
'A Skill is a packaged, reusable capability that Claude loads ON DEMAND. Concretely it is a folder containing a SKILL.md file: a little FRONTMATTER (a name and a one-line description) plus a body of instructions written in plain language, and optionally some helper scripts and reference files alongside it. When your task matches what the skill is for, Claude pulls the body into context and follows it.

The mechanism that makes skills cheap is PROGRESSIVE DISCLOSURE. Only the short description sits in context all the time -- a single line per skill. The full instructions load only when a task actually matches that description. That is how a setup can have dozens of skills available (this environment lists cam-lesson, code-review, deep-research, the whole vercel:* family, and more) without drowning every conversation in their contents. The descriptions are a menu; the body is the meal, served only when ordered.

You invoke a skill with the Skill tool, or by typing its name as a slash command (/code-review, /deep-research).

It helps to keep four nearby things separate:
- A SKILL is knowledge plus a procedure -- "here is how we do X in this project." It runs in the SAME conversation.
- A TOOL is a single raw capability (Read a file, run Bash, edit text).
- A SUBAGENT is a separate context window doing a chunk of work and reporting back a result -- a second brain, not a procedure.
- An MCP SERVER is an external program that exposes extra tools to Claude.

So a skill is not a separate brain and not a single button; it is a reusable play in the playbook. This repo leans on that idea constantly -- the three event streams in CLAUDE.md (BusinessEvent, DevelopmentEvent, Transcript) each point at their own SKILL.md. The payoff is that you teach Claude a repeatable procedure ONCE, and reuse it every session instead of re-explaining it from scratch.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (106, 'Agent Skill / SKILL.md', 'A folder with a SKILL.md file -- frontmatter plus plain-language instructions (and optional scripts) -- that packages a reusable procedure Claude loads on demand.'),
  (106, 'frontmatter', 'The small metadata block at the top of a file (here: a skill''s name and one-line description) that tools read to decide relevance.'),
  (106, 'progressive disclosure', 'Keeping only short descriptions in context and loading a skill''s full body only when a task matches -- how many skills coexist without bloating the window.'),
  (106, 'slash command', 'Typing /name to invoke a skill or built-in command directly.'),
  (106, 'subagent vs skill vs tool', 'A subagent is a separate context window (a second brain); a skill is a procedure run in the same conversation; a tool is one raw capability.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(106, 'What keeps a setup with dozens of available skills from flooding every conversation''s context window?',
 'Skills are stored in a database and never enter context',
 'Progressive disclosure -- only each skill''s one-line description stays loaded; the full body loads only when a task matches',
 'Only one skill is allowed to exist at a time',
 'Skills run on a separate server so they use no context',
 1,
 'Progressive disclosure means the always-on cost is just a short description per skill; the full instructions are pulled in on demand when the task matches, so many skills can coexist cheaply.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(107, '2026-06-30', 3, 'What is a Claude loop?',
'"Loop" has two meanings worth holding at once -- one is the engine under everything, the other is a literal command.

1. THE AGENTIC LOOP (the engine). This is the core cycle that makes Claude an agent instead of a chatbot. Claude is given a goal, PICKS an action (calls a tool), the tool runs in the real world, Claude READS the result, DECIDES the next action based on what actually happened, and repeats -- until the goal is met or it is genuinely stuck. Observe, decide, act; observe, decide, act. A plain chatbot emits one block of text and stops. An agent keeps turning this loop, which is the only reason it can do multi-step work: edit a file, run the build, see the error, fix the error, run again. Every loop needs a TERMINATION CONDITION -- a way to know it is done (goal met) or should stop (stuck, or out of budget) -- otherwise it would spin forever.

2. THE /loop COMMAND (a literal feature). Separately, Claude Code has a /loop that runs a prompt or a slash command on a recurring INTERVAL -- "/loop 5m /check-deploys" runs that every five minutes -- or self-paced if you omit the interval and let the model decide when to fire again. It is for polling status, babysitting a long-running job, or repeating a task on a schedule. Do not confuse it with the agentic loop above: the agentic loop is the always-on heartbeat of a single task; /loop is a deliberate "keep doing this on a timer" wrapper you opt into.

The triad ties together cleanly. GOAL is where you are going. SKILL is packaged know-how for getting there. LOOP is the act-observe-repeat motion that actually carries you. And cyummu sits above all three -- it makes sure the goal is right BEFORE the loop spends real effort chasing it.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (107, 'agentic loop', 'The observe-decide-act cycle: given a goal, Claude calls a tool, reads the result, chooses the next action, and repeats until done. What makes an agent more than a chatbot.'),
  (107, 'tool call', 'A single action an agent takes in the world during the loop -- read a file, run a command, edit text -- whose result feeds the next decision.'),
  (107, 'termination condition', 'The rule that ends a loop: goal met, stuck, or out of budget. Without one, a loop never stops.'),
  (107, '/loop command', 'A Claude Code feature that re-runs a prompt or slash command on a recurring interval (or self-paced) -- for polling, babysitting jobs, or scheduled repetition.'),
  (107, 'chatbot vs agent', 'A chatbot emits one response and stops; an agent runs the act-observe loop toward a goal, taking many steps.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(107, 'What most fundamentally distinguishes an agent from a plain chatbot?',
 'An agent uses a larger model',
 'An agent runs an act-observe-repeat loop toward a goal, calling tools and reacting to real results, instead of emitting a single response',
 'An agent always finishes faster',
 'An agent never makes mistakes',
 1,
 'The defining trait is the agentic loop: taking an action, observing the real result, and deciding the next step, repeated until the goal is met -- not model size or speed.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(108, '2026-06-30', 4, 'What is Apache License 2.0?',
'A PERMISSIVE open-source license released by the Apache Software Foundation in 2004. "Permissive" means it lets you do almost anything with the code -- use it, modify it, distribute it, sell it, build proprietary closed-source products on top of it -- with very few strings attached. It is in the same family as the MIT and BSD licenses, but it is longer and more lawyer-grade because it spells out two things those shorter licenses leave implicit: PATENTS and ATTRIBUTION.

WHAT YOU ARE ALLOWED TO DO: use the code commercially, modify it, distribute it, sublicense it, and include it in closed-source products. You do NOT have to open-source your own changes -- this is the key difference from COPYLEFT licenses like the GPL, which force downstream code to stay open.

WHAT YOU MUST DO (the conditions, and they are light):
- KEEP THE NOTICES. Preserve the copyright notice, the license text, and any NOTICE file when you redistribute.
- STATE CHANGES. Mark the files you modified as having been changed.
That is essentially the whole obligation.

THE TWO FEATURES THAT MAKE APACHE 2.0 DISTINCT FROM MIT/BSD:
- EXPLICIT PATENT GRANT. Every contributor automatically grants users a license to any patents their contribution relies on. So you cannot be sued for patent infringement merely for using the software as intended. The shorter licenses are silent on patents, which leaves legal ambiguity; Apache closes it.
- PATENT RETALIATION CLAUSE. If you turn around and sue someone claiming the software infringes YOUR patent, your own patent license under Apache 2.0 terminates. A built-in "do not weaponize patents" deterrent.

WHAT IT DOES NOT DO: it provides NO WARRANTY and accepts NO LIABILITY -- the software is given "as is." And again, it is NOT copyleft: nothing forces downstream users to share their modifications.

A quick mental model: MIT says "do what you want, just keep my name on it." Apache 2.0 says the same thing PLUS "...and here is an explicit patent peace treaty so nobody gets ambushed in court." That patent clarity is exactly why many large companies and big projects -- Android, Kubernetes, Swift, and the Apache projects themselves -- prefer it.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (108, 'permissive license', 'An open-source license (Apache 2.0, MIT, BSD) that lets you use, modify, and redistribute code -- even in closed-source products -- with minimal conditions.'),
  (108, 'copyleft', 'The opposite stance (e.g. the GPL): derivative works must be released under the same open license, forcing downstream code to stay open. Apache 2.0 is NOT copyleft.'),
  (108, 'patent grant', 'A clause where contributors license the patents their code needs, so users cannot be sued for patent infringement for using the software as intended -- a headline feature of Apache 2.0.'),
  (108, 'patent retaliation clause', 'Apache 2.0 terms that revoke your patent license if you sue another user claiming the software infringes your patent -- a deterrent against patent attacks.'),
  (108, 'NOTICE file', 'A file Apache 2.0 requires you to preserve and pass along when redistributing, carrying required attributions and notices.'),
  (108, 'as is / no warranty', 'The disclaimer that the software comes with no guarantees and the authors accept no liability for problems it causes.'),
  (108, 'attribution', 'The requirement to keep the original copyright and license notices when you redistribute -- the light obligation common to permissive licenses.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(108, 'What is the main thing Apache License 2.0 adds that the shorter MIT license leaves unaddressed?',
 'It forces you to open-source any modifications you make',
 'An explicit patent grant (plus a retaliation clause) that protects users from patent suits',
 'It bans all commercial use of the code',
 'It requires you to pay a fee to the Apache Software Foundation',
 1,
 'Apache 2.0 is permissive like MIT, but its distinguishing feature is the explicit patent grant and retaliation clause. It does not force modifications open (that would be copyleft), and it allows commercial use freely.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(109, '2026-06-30', 5, 'What are standard coding licenses that help protect the creator of the project?',
'First untangle what "protect the creator" actually means, because there are FOUR different protections and the license you pick depends on which ones you care about:
1. LIABILITY / WARRANTY SHIELD -- "if my code breaks your stuff, you cannot sue me." Every mainstream open-source license includes an "as is, no warranty" disclaimer. This is the protection you almost certainly want, and you get it free in all of them.
2. ATTRIBUTION -- "you must keep my name and notices on it." Also present in essentially all of them.
3. PATENT PROTECTION -- "you cannot use my code and then turn around and sue me for patent infringement."
4. ANTI-APPROPRIATION (COPYLEFT) -- "you cannot take my open code, make it proprietary, and lock it away." This protects your project''s openness, not your wallet.

THE STANDARD LICENSES, ordered weakest-to-strongest in how much they constrain others on your behalf:
- MIT (permissive) -- liability shield + requires attribution. Simplest and most popular. Silent on patents.
- BSD, 2-clause or 3-clause (permissive) -- same as MIT; the 3-clause variant adds "do not use my name to endorse your derived product."
- APACHE 2.0 (permissive) -- everything MIT gives, PLUS an explicit patent grant and a patent-retaliation clause. The strongest creator protection among permissive licenses, and the modern default for serious permissive projects.
- MPL 2.0, Mozilla (weak copyleft) -- file-level: changes to YOUR files must stay open, but others may combine your code with proprietary code. A middle ground.
- GPL / AGPL (strong copyleft) -- forces anyone who distributes derivatives to release their source too. AGPL additionally closes the "SaaS loophole," covering code run over a network. This protects your work from ever being taken proprietary.

HOW TO CHOOSE:
- "I just do not want to get sued; take my code freely" -> MIT (or BSD).
- "Same, but I want patent safety too" -> APACHE 2.0.
- "Nobody should be able to make a closed-source product out of my work" -> GPL, or AGPL for a network/server app.
- "Somewhere in between" -> MPL 2.0.

TWO CAVEATS THAT TRIP PEOPLE UP:
- A license governs how others USE your code; it does NOT transfer copyright. You still need to actually OWN the copyright -- or have outside contributors sign a CLA (Contributor License Agreement) -- for the license to mean anything.
- None of these protect a TRADEMARK (your project name or logo). That is a separate legal tool entirely.

BOTTOM LINE: if "protect the creator" means shield me from liability and patent ambush while letting people use my work freely, the standard answer is APACHE 2.0. If it means stop people from privatizing my work, the standard answer is GPL / AGPL.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (109, 'warranty disclaimer ("as is")', 'The clause in every mainstream license that shields the author from liability if the code causes problems -- the protection most creators actually want.'),
  (109, 'MIT license', 'The simplest, most popular permissive license: use it however you like, just keep the copyright/license notice. Silent on patents.'),
  (109, 'BSD license', 'A permissive license like MIT; the 3-clause version adds a no-endorsement clause forbidding use of the author''s name to promote derivatives.'),
  (109, 'MPL 2.0 (weak copyleft)', 'Mozilla''s file-level copyleft: modified files stay open, but the code can be combined with proprietary code -- a middle ground between MIT and GPL.'),
  (109, 'GPL / AGPL (strong copyleft)', 'Licenses that force distributed derivatives to be open-sourced; AGPL extends this to software used over a network (the SaaS loophole).'),
  (109, 'CLA (Contributor License Agreement)', 'An agreement outside contributors sign granting the project rights to their contributions, so the maintainer can license the combined work cleanly.'),
  (109, 'trademark vs license', 'A license governs code use; a trademark protects a project''s name/logo. Separate legal tools -- a code license does not protect your brand.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(109, 'A creator wants people to use their code freely but wants protection from both lawsuits AND patent ambushes. Which standard license fits best?',
 'MIT, because it is the most popular',
 'Apache 2.0, because it adds an explicit patent grant and retaliation clause on top of a liability shield',
 'GPL, because it is the strongest license',
 'No license -- just post the code publicly',
 1,
 'All mainstream licenses give the liability shield, but only Apache 2.0 (among the common permissive ones) adds explicit patent protection. GPL is for preventing proprietary reuse, not for permissive sharing, and posting code with no license actually leaves it under default all-rights-reserved copyright.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(110, '2026-06-30', 6, 'What is a symlink?',
'A SYMLINK (symbolic link) is a special file whose entire content is just A PATH to another file or directory. It is a pointer -- a signpost that says "the real thing is over there." When a program opens the symlink, the operating system transparently redirects it to the TARGET, so you use the symlink as if it WERE the target.

You create one with ln -s:
  ln -s /actual/target/file.txt shortcut.txt
where /actual/target/file.txt is the target and shortcut.txt is the symlink you just made.

A good mental image: it is like a desktop shortcut or Mac alias, but it lives at the FILESYSTEM level, so every program respects it automatically -- cd, cat, your editor, build tools all follow it without knowing or caring that it is a link.

WHY THEY EXIST (real uses):
- STABLE NAMES over changing targets. /usr/bin/python3 or a node symlink points at the real versioned binary (node -> node-22.3.0). You reference the stable name and swap what it points to underneath.
- SHARING ONE FILE IN MANY PLACES without copying it. Package managers like pnpm lean on this hard: one real copy of a package on disk, symlinked into many projects, saving gigabytes.
- PUTTING CONFIG WHERE A TOOL EXPECTS IT while the real file lives in a dotfiles repo (~/.zshrc -> ~/dotfiles/zshrc).

THE THING THAT BITES PEOPLE -- SYMLINK vs HARD LINK:
- A SYMLINK stores a PATH. If you delete or move the target, the symlink still exists but now points at nothing -- a DANGLING (broken) link. cat shortcut.txt then errors with "No such file or directory" even though the link is sitting right there.
- A HARD LINK is a second NAME for the same underlying data (the same inode). Delete the original name and the data survives, because the hard link still references it directly. Hard links cannot cross filesystems or point to directories; symlinks can do both, which is why symlinks are far more common in everyday use.

INSPECTING THEM: ls -l shows the arrow (shortcut.txt -> /actual/target/file.txt), and readlink shortcut.txt prints just the target path.

One-sentence version: a symlink is a forwarding address, not a copy -- move the resident (the target) and your access bounces unless you update the address.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (110, 'symlink (symbolic link)', 'A file whose content is a path to another file/directory; opening it transparently redirects to the target. Created with ln -s.'),
  (110, 'target', 'The actual file or directory a symlink points at. If it moves or is deleted, the symlink breaks.'),
  (110, 'hard link', 'A second name for the same underlying data (same inode); the data survives as long as any hard link to it exists. Cannot cross filesystems or link directories.'),
  (110, 'inode', 'The filesystem''s internal record for a file''s actual data and metadata; multiple hard-link names can point to one inode.'),
  (110, 'dangling / broken link', 'A symlink whose target no longer exists, so following it errors even though the link file itself is still present.'),
  (110, 'ln -s / readlink', 'ln -s creates a symlink; readlink prints the path a symlink points to; ls -l shows the link with an -> arrow.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(110, 'You create a symlink shortcut.txt pointing at /data/file.txt, then delete /data/file.txt. What happens to shortcut.txt?',
 'It is automatically deleted too',
 'It still exists but becomes a dangling (broken) link -- following it now errors',
 'It silently keeps a copy of the old contents',
 'It converts itself into a hard link to preserve the data',
 1,
 'A symlink only stores a path to its target. Deleting the target leaves the symlink in place but pointing at nothing, so reading it fails with "No such file or directory". A hard link would have preserved the data because it references the inode directly.');

INSERT INTO days (date, kind, title) VALUES
  ('2026-07-02', 'qa', 'Attract mode -- the arcade cabinet performing for a room with no players');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(111, '2026-07-02', 1, 'In an arcade, what is attract mode?',
'ATTRACT MODE is the looping demo an arcade cabinet plays while nobody is playing it. Left idle, the machine cycles through a self-running show: the title screen and logo, a gameplay demo where the CPU "plays" the game against itself, the high-score table, and flashing "INSERT COIN" / "PRESS START" prompts.

Its entire job is right there in the name -- to ATTRACT a passerby. It shows a stranger what the game is, makes it look fun, and nudges them to drop a coin in. The instant you insert a coin or hit start, the cabinet drops OUT of attract mode and into the real game. When a game ends and the machine sits idle long enough, it falls back into attract mode and starts the pitch again.

Some historical texture: the self-playing demo is also called a DEMO LOOP or "demo play," and it was often a scripted or recorded run rather than the AI genuinely playing -- just enough to look alive. Attract mode is why an arcade full of unplayed machines is still loud and animated: every cabinet is performing for a room that has not engaged yet.

WHY IT MATTERS BEYOND ARCADES: "attract mode" has become a general UX term for ANY idle-but-selling state -- an interface that performs for an audience that has not interacted yet. A museum kiosk cycling promo screens, a smart-TV screen that demos features while parked on the home menu, a retail display running a product loop, even a landing-page hero that auto-plays a demo reel. All of these are attract mode: the screen working to convert a passive onlooker into an active user. The core pattern is "idle state as marketing," which is a deliberate design decision, not dead time.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (111, 'attract mode', 'The looping self-running demo an arcade cabinet plays while idle -- title, demo play, high scores, "insert coin" -- designed to lure a passerby into starting a game.'),
  (111, 'demo loop / demo play', 'The segment of attract mode where the game appears to play itself, often a scripted or pre-recorded run rather than live AI, just to look alive and show off gameplay.'),
  (111, 'idle state as UX pattern', 'The generalized idea behind attract mode: an unattended screen that actively markets the experience (kiosks, smart TVs, retail displays, auto-playing landing pages) instead of sitting blank.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(111, 'What is the primary purpose of attract mode on an arcade cabinet?',
 'To let the machine cool down between plays',
 'To pause the game so the current player can take a break',
 'To advertise the game and lure a passerby into inserting a coin while the machine sits idle',
 'To save the high scores to permanent storage',
 2,
 'Attract mode is the idle demo loop -- title, self-playing demo, high-score table, "insert coin" -- whose whole job is to attract a new player. Starting a game drops the cabinet out of attract mode.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(112, '2026-07-02', 2, 'What is scope creep?',
'SCOPE CREEP is when the SCOPE of a project -- the set of things it is supposed to do -- quietly grows over time without a matching adjustment to the schedule, budget, or plan. It is the "while you are in there, can you also..." problem, accumulated one small ask at a time.

Nobody ever decides "let us double this project." Instead it arrives in slivers:
- A feature ships, and someone adds "just one more small thing."
- An edge case turns into three edge cases turns into a whole subsystem.
- A stakeholder assumes something was always included when it never was.
- The builder GOLD-PLATES -- adds polish and refinement nobody asked for.

Each individual addition feels tiny and reasonable. The danger is the AGGREGATE: the deadline was set for the ORIGINAL scope, but you are now building something meaningfully bigger, so you blow the estimate, burn out, or ship late. And often nobody can point to the single decision that caused it, because there was not one -- it was death by a thousand reasonable cuts.

WHY IT IS THE VILLAIN THE CYUMMU LOOP FIGHTS: scope creep thrives on unstated, drifting understanding. Every "confirm your understanding matches my understanding" pins the scope down explicitly BEFORE work starts, so any addition has to be named as an addition ("that is new -- want me to fold it in?") rather than smuggled in as an assumption. A related discipline is the MVP (minimum viable product): deliberately defining the smallest thing worth shipping so you have a fixed line to defend against creep.

The healthy response to a new request is not "always say no" -- it is CHANGE CONTROL: accept the new thing AND openly adjust the timeline or budget for it, instead of silently absorbing it into the original estimate.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (112, 'scope creep', 'The gradual, uncontrolled growth of a project''s requirements over time without matching adjustments to schedule or budget -- added one small "reasonable" request at a time.'),
  (112, 'scope', 'The agreed-upon boundary of what is in vs. out of a project -- the definition of done that creep erodes.'),
  (112, 'gold-plating', 'A flavor of scope creep where the builder adds unrequested refinements or polish nobody asked for.'),
  (112, 'change control', 'The deliberate process of handling new requests -- accepting them AND adjusting timeline/budget -- instead of silently absorbing them into the original plan.'),
  (112, 'MVP (minimum viable product)', 'The smallest version of a product that still delivers value; defining it gives you a fixed line to defend against scope creep.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(112, 'Which situation best describes scope creep?',
 'A single stakeholder formally cancels the project halfway through',
 'A steady stream of small, individually reasonable additions grows the project well past its original plan without adjusting the deadline',
 'The team finishes the agreed work early and ships ahead of schedule',
 'A bug is discovered in production and must be hotfixed',
 1,
 'Scope creep is the aggregate of many small unmanaged additions, each of which seems reasonable alone but collectively blows the original estimate because the schedule/budget was never adjusted to match.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(113, '2026-07-02', 3, 'Why might it seem wasteful to close Claude Code sessions that have cultivated massive context windows?',
'The feeling is real, but it is mostly a SUNK-COST FALLACY wearing a productivity costume.

WHY IT SEEMS WASTEFUL: A session running for hours feels like it has become an expert on your project. Over that window Claude has read dozens of files and "knows" the layout, absorbed your conventions and naming, built a shared vocabulary with you ("the engine," "the reader," "cyummu"), and followed a long thread of reasoning -- false starts, corrections, decisions. Closing the tab feels like firing an employee the day they finally learned where everything is. All that warm, PRIMED context is gone, and tomorrow you re-explain while Claude re-reads the same files. That re-ramp does cost real time, so the instinct is not crazy.

WHY IT IS LARGELY A FALLACY: The catch is what "context" actually is. It is NOT learning -- the model did not get smarter or permanently absorb anything. It is just tokens sitting in a fixed-size window, and a giant window is a liability as much as an asset:
- CONTEXT ROT / DILUTION -- as the window fills, the signal you care about now competes for attention with thousands of stale tokens (abandoned approaches, old file versions, dead ends). The model can start answering as if a superseded decision were still live.
- COST AND LATENCY -- every new turn re-processes the whole window, so a massive context makes each response slower and more expensive for value that is mostly inert.
- STALENESS -- files edited on disk since they were read are now wrong in the window; the context can actively mislead.
So the "expertise" is partly an illusion: some genuinely useful priming, but a lot of ballast.

THE RESOLUTION: The value was never supposed to live in the window -- it is supposed to live in DURABLE ARTIFACTS: commits, CLAUDE.md, a memory directory, transcript and devlogs, journal entries. The move is not "never close" -- it is HARVEST BEFORE YOU CLOSE. Commit the code, update the docs and memory, journal the open threads. Do that and closing is not waste; it is clearing ballast while keeping every durable thing, and a fresh session rereads the CURRENT files with none of the rot. The genuinely wasteful act is closing a big-context session WITHOUT harvesting it first -- that is the only case where real value actually evaporates.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (113, 'context window', 'The fixed-size token buffer holding everything in the current session; it is working memory for this conversation, not permanent learning the model carries forward.'),
  (113, 'context rot', 'Degradation of output quality as a window fills with stale, contradictory, or irrelevant tokens that dilute the model''s attention away from what currently matters.'),
  (113, 'sunk cost fallacy', 'Valuing something by what you have already invested in it rather than by its remaining usefulness -- the reason a bloated session feels too valuable to close.'),
  (113, 'ephemeral vs durable state', 'The window is ephemeral (it dies with the session); files, commits, memory, and logs are durable (they survive it). Real value should be persisted to the durable layer.'),
  (113, 'harvest before you close', 'The practice of extracting a session''s value into durable artifacts (commits, docs, memory, journal) before ending it, so closing clears ballast without losing anything.'),
  (113, '/clear and /compact', 'Built-in Claude Code moves to reset or summarize a bloated context window without losing the working thread.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(113, 'Why is the instinct that closing a large-context Claude session is "wasteful" mostly a fallacy?',
 'Because context windows never fill up, so size is irrelevant',
 'Because the context is ephemeral working memory, not permanent learning -- and large windows suffer rot, cost, and staleness; the real value belongs in durable artifacts',
 'Because Claude permanently remembers everything from every past session anyway',
 'Because re-reading files in a new session is impossible, so nothing is lost',
 1,
 'The window is fixed-size working memory, not learning the model keeps. Big windows dilute attention, cost more per turn, and go stale. Persist the value to durable artifacts (commits, docs, memory, logs) and closing clears ballast rather than destroying value.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(114, '2026-07-02', 4, 'Why might a Flutter app that is a 4x4 grid (each cell with a timer) plus randomly placed, randomly jittering floating modals cause the entire screen to periodically go black?',
'The "goes black" symptom is loud and specific, and in Flutter it points at one of two very different failure families. The fix depends on which one you have.

MOST LIKELY: THE "MODALS" ARE REAL MODAL ROUTES AND YOU ARE SEEING THE BARRIER.
If the floating things are made with showDialog / showModalBottomSheet / showGeneralDialog (or any PageRoute with a barrierColor), each one inserts a MODAL BARRIER -- a full-screen scrim that defaults to Colors.black54 (54% opaque black). That scrim is literally a black overlay covering the whole screen. Now stack that on this setup: modals "randomly placed, randomly jittering" implies they are being pushed and popped rapidly. Every push lays another black-ish barrier over the ENTIRE screen; two or three overlapping black54 barriers composite toward fully opaque black (0.46^3 transmitted, ~90% black). If a barrier is pushed but its pop is missed (a leaked route, or jitter re-pushing faster than it pops), the screen STAYS dark; if they flap, it FLASHES black periodically. That single fact -- the barrier is black by design -- explains "the entire screen goes black" more cleanly than anything else. Check first: are these actual routes/dialogs, or just positioned widgets in a Stack? If routes, that is almost certainly it. Fix: use Positioned widgets in a Stack (or Overlay/OverlayEntry) for ambient floating UI, or at minimum barrierColor: Colors.transparent.

THE OTHER FAMILY: THE RENDER PIPELINE STALLS SO HARD THE COMPOSITOR PRESENTS EMPTY (BLACK) FRAMES.
Flutter runs two threads: the UI THREAD builds/lays out widgets; the RASTER (GPU) THREAD paints and presents them. Each has a ~16.6 ms budget at 60 fps. Blow it and you get jank -- and in severe cases a frame with nothing to present shows as black. With 16 cell timers plus N jittering modals, something animates every frame, continuously. Ways it blows the budget:
- TIMER / TICKER / ANIMATIONCONTROLLER LEAKS (the classic). If each cell timer or each modal jitter animation is not cancelled/disposed in dispose(), they accumulate. Recreated modals keep spawning new Timer.periodic and AnimationController objects that never die. Flutter often warns of a "ticker leak"; the runtime effect is CPU saturation -> UI thread stalls -> dropped/black frames. This gets WORSE over time, matching "periodically."
- setState AT THE WRONG ALTITUDE. A timer calling setState on a big ancestor 16x/sec rebuilds and repaints far more of the tree than changed.
- OVERDRAW + EXPENSIVE COMPOSITING. Translucent modals with shadows, BackdropFilter blur, or Opacity force saveLayer / offscreen compositing; many overlapping translucent layers overload the raster thread.
- MEMORY PRESSURE -> GPU SURFACE LOSS. Allocating fresh objects every tick spikes garbage collection; on weak devices the EGL/GPU surface can be lost and recreated, and during that gap the screen is black.

HOW TO TELL THEM APART: turn on showPerformanceOverlay (or DevTools Performance) -- red raster/UI bars during blackouts means the pipeline. Watch the console for a ticker/Timer leak warning and audit every dispose(). Grep for showDialog / barrierColor -- if present, suspect the barrier first. Wrap each animating cell/modal in a RepaintBoundary so constant repaints do not invalidate the whole screen. Best bet given the exact words "entire screen goes black" plus "modals": it is the modal barrier scrim; the pipeline explanation is the backup if they turn out to be plain Stack children.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (114, 'UI thread vs raster thread', 'Flutter splits work: the UI (Dart) thread builds and lays out widgets; the raster/GPU thread paints and presents them. Either one missing its frame budget causes jank.'),
  (114, 'modal barrier / scrim', 'The full-screen ModalBarrier a dialog or modal route inserts behind itself, defaulting to Colors.black54; overlapping barriers composite toward solid black -- a direct cause of a black screen.'),
  (114, 'ticker / AnimationController leak', 'An animation driver not disposed in dispose(), so it keeps firing forever; accumulation saturates the CPU and stalls the UI thread. Flutter warns about leaked tickers.'),
  (114, 'Timer.periodic leak', 'A repeating timer never cancel()-ed in dispose(); many accumulating timers hammer the CPU the same way ticker leaks do.'),
  (114, 'overdraw', 'Painting the same pixels many times via stacked translucent layers; expensive work on the raster thread and a common source of dropped frames.'),
  (114, 'saveLayer / offscreen compositing', 'What Opacity, BackdropFilter, and shadows trigger -- an offscreen buffer that is costly to allocate and blend; a frequent jank source.'),
  (114, 'RepaintBoundary', 'A widget that isolates a subtree so its constant repaints do not dirty (invalidate) the rest of the screen.'),
  (114, 'frame budget', 'The ~16.6 ms per frame available at 60 fps; the deadline both the UI and raster threads must hit or the frame is dropped.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(114, 'If the "floating modals" are created with showDialog, what is the single most direct reason the whole screen could go black?',
 'Dialogs disable the GPU while open',
 'Each modal route inserts a full-screen ModalBarrier scrim that defaults to Colors.black54, and overlapping/stuck barriers composite toward solid black',
 'showDialog always sets the app background to black',
 'Flutter cannot render a grid and a dialog at the same time',
 1,
 'A modal route places a ModalBarrier over the entire screen, black54 by default. Rapidly pushed/popped or leaked barriers stack and composite toward opaque black, which reads as the whole screen going (or flashing) black -- distinct from pipeline stalls that present empty frames.');

INSERT INTO days (date, kind, title) VALUES
  ('2026-07-04', 'qa', 'Made with, not made by -- prompting as the next rung on the abstraction ladder');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(115, '2026-07-04', 1, 'What is the correct way to discuss making things with AI? I am "making" software by prompting AI, but it does not feel like coding.',
'The discomfort is real and worth taking apart, because it comes from conflating two words that were never synonyms: CODING and MAKING SOFTWARE.

CODING is one implementation technique -- hand-writing instructions in a formal language. MAKING SOFTWARE is the whole job: deciding what should exist, specifying its behavior precisely, judging whether what got built is right, and owning it when it ships. Coding has always been just one layer of that stack, and it is the layer that has been getting automated away for seventy years.

THE ABSTRACTION LADDER. Every generation of tooling triggered exactly this feeling in the previous one. Assembly programmers said compilers were not real programming (you did not allocate the registers). C programmers said it about garbage-collected languages (you do not manage memory). Hand-rolled-everything web devs said it about frameworks. Prompting is the next rung: you now specify behavior in natural language and review the machine''s translation, instead of specifying it in Python and reviewing the compiler''s translation. What stays constant across every rung is the actual hard part: SPECIFICATION (saying precisely what you want -- vague in, wrong out), VERIFICATION (knowing whether what came back is actually correct rather than merely plausible), and ACCOUNTABILITY (it shipped under your name). Those never moved. They are the job.

WHY IT DOES NOT FEEL LIKE CODING. Two reasons. First: it is not coding, and that is fine -- it is closer to being an editor, a tech lead, or a director. Your work product is judgment, not keystrokes. Second: the EFFORT HEURISTIC. Humans use felt struggle as a proxy for legitimacy, and syntax-wrestling burns in a way that reviewing a diff does not, so the new work registers as "not real" even when it produces more and better software. But the struggle was never the point; the software was the point. And note: if prompting were nothing, everyone''s AI output would be equally good. It is not. Decomposing problems, catching wrong output, and knowing what good looks like are skills with a huge spread between people -- and they are the ones that compound now.

THE CORRECT WAY TO DISCUSS IT -- two rules:
1. MADE WITH, NOT MADE BY. Say "I built this with Claude." Honest in both directions. You direct, review, verify, and own the result. If it breaks in production, "the AI wrote it" is not a defense -- and the fact that the accountability stays with you is precisely why the making is really yours.
2. SHOW THE PROCESS. The two failure modes of AI discourse are OVERCLAIMING (hiding the AI, performing hand-wrought authorship -- dishonest, and increasingly transparent to everyone) and UNDERCLAIMING ("the AI did everything" -- which erases your actual contribution and teaches your audience nothing). The correct lane is process-honest: what you asked for, what came back wrong, how you verified, what you rejected. That is also the only interesting content. Nobody learns anything from "AI made this"; they learn from watching the loop.

THE REFRAME: the coding keeps getting cheaper. Reading code you did not write, specifying precisely, and verifying ruthlessly get more valuable every month. "It does not feel like coding" is accurate. It feels like the part of the job that was always above coding.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (115, 'abstraction ladder', 'The historical stack of tooling layers (assembly -> compilers -> high-level languages -> frameworks -> AI prompting), where each new rung is dismissed as "not real programming" by the rung below it.'),
  (115, 'specification', 'Saying precisely what you want built. The genuinely hard part of software, and it is identical work whether the target reading it is a compiler or a model -- vague in, wrong out.'),
  (115, 'verification', 'Confirming that output is actually correct rather than merely plausible. As generation gets cheap, this replaces typing as the bottleneck skill.'),
  (115, 'effort heuristic', 'The cognitive bias of using felt struggle as a proxy for value or legitimacy -- the reason low-friction work registers as "cheating" even when its results are better.'),
  (115, 'made with, not made by', 'The honest attribution frame for AI-assisted work: the AI drafts, the human directs, reviews, verifies, and owns what ships.'),
  (115, 'overclaiming vs underclaiming', 'The two dishonest poles of AI discourse -- hiding the AI entirely, or crediting it with everything. Both misrepresent where the judgment actually lives.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(115, 'Across every jump up the abstraction ladder -- assembly to compilers to high-level languages to AI prompting -- what stays constant as the actual job of making software?',
 'Typing speed and memorized syntax',
 'Specification, verification, and accountability for what ships',
 'Manual control of registers and memory',
 'Nothing -- each new layer replaces the entire job',
 1,
 'Each rung automates the translation layer below it, but saying precisely what you want, confirming what came back is correct, and owning the shipped result never move. That is why prompting an AI is still making software even though it is not coding.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(116, '2026-07-04', 2, 'A book says public-key encryption might involve transmitting ciphertext C = P_A(M). How do I read that, and what is the correct nomenclature in the context of number-theoretic algorithms?',
'Read it aloud as "C equals P-sub-A of M." This is the CLRS-style formalism (Introduction to Algorithms, ch. 31, Number-Theoretic Algorithms), and every piece has a name.

THE PIECES:
- M is the PLAINTEXT -- the message you want to send.
- C is the CIPHERTEXT -- the scrambled result you actually transmit.
- P_A is the PUBLIC KEY OF PARTICIPANT A (usually Alice). The subscript is not math being done to P; it is an INDEX saying whose key this is. P_B would be Bob''s public key.
- P_A(M) is ordinary FUNCTION APPLICATION, exactly like f(x).

The load-bearing idea is that the book treats a key not as a number but as a FUNCTION -- something you apply to a message. So the equation reads: "the ciphertext C is produced by applying Alice''s public-key function to the message M." Anyone can compute it, because P_A is public. That is the whole point of a public-key system.

THE OTHER HALF OF THE FORMALISM: each participant has a KEY PAIR (P_A, S_A) -- public and secret -- and the two functions are INVERSES of each other over D, the set of permissible messages:
- S_A(P_A(M)) = M -- decryption undoes encryption; only Alice can do this because only she holds S_A.
- P_A(S_A(M)) = M -- the reverse order also works, which is what makes DIGITAL SIGNATURES possible: Alice signs with S_A, anyone verifies with P_A.

THE CORRECT NOMENCLATURE:
- P_A and S_A form a family of functions INDEXED BY PARTICIPANT. You say "P sub A" or "A''s public-key function."
- Formally each is a PERMUTATION of D -- a one-to-one, onto mapping of the message set to itself, so nothing is lost and it can be undone.
- P_A is a TRAPDOOR ONE-WAY FUNCTION: easy to compute forward, computationally infeasible to invert -- unless you hold the trapdoor, which is exactly what the secret key S_A is.
- The inverse relationship is FUNCTION COMPOSITION: S_A composed with P_A is the identity on D.

In RSA, the concrete instance the book builds next, these abstract functions become modular arithmetic: P_A(M) = M^e mod n and S_A(C) = C^d mod n, and the pair works because e*d = 1 (mod phi(n)) -- which is where the "number-theoretic" part earns its name.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (116, 'plaintext / ciphertext', 'The message before encryption (M) and after (C). The ciphertext is what actually crosses the wire.'),
  (116, 'key pair (P_A, S_A)', 'A participant''s public and secret keys, treated as a pair of functions that are inverses of each other over the message set D.'),
  (116, 'subscript as index', 'In P_A, the subscript is not an operation -- it labels ownership. P_A and P_B are different members of the same family of functions, indexed by participant.'),
  (116, 'function application', 'The f(x) pattern: P_A(M) means "apply the function P_A to the input M." Keys in this formalism are functions, not numbers.'),
  (116, 'trapdoor one-way function', 'A function easy to compute forward but infeasible to invert -- except with a secret (the trapdoor). The secret key S_A is the trapdoor for P_A.'),
  (116, 'permutation (of a set)', 'A one-to-one, onto mapping of a set to itself. Encryption must be a permutation of D so that no two messages collide and decryption can undo it.'),
  (116, 'inverse functions / composition', 'S_A(P_A(M)) = M means composing the two functions yields the identity -- each undoes the other, in either order.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(116, 'In the expression C = P_A(M), what does the subscript A denote?',
 'The message M raised to the power A',
 'Which participant owns the key -- P_A is A''s public-key function, applied to M like f(x)',
 'The number of times the encryption is repeated',
 'A constant multiplied against P before encryption',
 1,
 'The subscript is an index, not an operation: it labels whose key the function is. P_A and S_A are A''s public and secret key functions, inverses of each other over the message set D, and P_A(M) is plain function application producing the ciphertext.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(117, '2026-07-04', 3, 'In a phrase like "on the nature of ____", what is the underscore called? And what is the X when we say "I read book X"?',
'THE UNDERSCORE IS A PLACEHOLDER -- a visible mark that holds open a SLOT in a TEMPLATE. "On the nature of ____" is not a sentence yet; it is a SCHEMA, a reusable pattern with a hole in it. The underscore says "something goes here, and I am deliberately not saying what." When you fill the slot ("On the Nature of Things"), the formal verb is that you INSTANTIATE the template. Read it aloud as "on the nature of blank."

THE X IS A VARIABLE -- the same idea as x in algebra, but ranging over books instead of numbers. Because it is used to talk ABOUT statements ("whenever someone says I read book X..."), the precise term is a METAVARIABLE (logicians also say SCHEMATIC LETTER): a symbol standing in for whatever expression would fill that position.

The underscore and the X are the same device in different clothes. The blank shows the slot visually; the letter NAMES the slot so you can refer to it or repeat it. "X is the new Y" needs two named slots -- "____ is the new ____" cannot tell you whether the two blanks must match.

RELATED NOMENCLATURE:
- CLOZE -- the education/psycholinguistics term for a fill-in-the-blank sentence; "cloze deletion" is what Anki flashcards call it.
- SNOWCLONE -- a phrasal template reused culturally with different fillers: "X is the new Y," "the mother of all X," and arguably "On the Nature of ____" itself, since philosophy-flavored titles riff on Lucretius''s De Rerum Natura (On the Nature of Things).
- METASYNTACTIC VARIABLE -- programming culture''s placeholder names: foo, bar, baz. Same job as X, but the names themselves conventionally signal "this is filler."

This connects directly to reading C = P_A(M): the A in P_A is doing exactly this job -- a variable holding a slot open for SOME participant, so a book can state facts about EVERY key pair at once. Placeholders are how you talk about the pattern instead of one instance of it.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (117, 'placeholder', 'Any mark (blank, underscore, letter) that holds open a position in an expression where a real value or phrase will later go.'),
  (117, 'template / schema', 'A reusable pattern containing one or more open slots; not a complete statement until the slots are filled.'),
  (117, 'instantiate', 'To fill a template''s slots with concrete values, turning the pattern into a specific instance.'),
  (117, 'variable / metavariable', 'A named placeholder (X, Y) that ranges over possible fillers; called a metavariable or schematic letter when it stands in for expressions in talk about language or logic.'),
  (117, 'cloze', 'The linguistics/education term for a fill-in-the-blank sentence, as in cloze tests and Anki cloze deletions.'),
  (117, 'snowclone', 'A culturally reused phrasal template with swappable fillers, e.g. "X is the new Y."'),
  (117, 'metasyntactic variable', 'Conventional placeholder names in programming (foo, bar, baz) whose very names signal that they are filler.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(117, 'What is the key advantage of writing a placeholder as a named letter ("X is the new Y") instead of a blank ("____ is the new ____")?',
 'Letters are more formal and therefore more correct',
 'A named slot can be referred to and repeated, so the template can express whether two positions must hold the same filler or different ones',
 'Blanks are only allowed in children''s worksheets',
 'A letter placeholder changes the sentence''s grammatical tense',
 1,
 'Both marks hold a slot open, but only a name lets you talk about the slot: repeat X to force the same filler, or use X and Y to allow different ones. Bare blanks cannot encode that relationship -- which is why math, logic, and books about algorithms use lettered variables.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(118, '2026-07-04', 4, 'If someone says they "read" a book but actually listened to the audiobook, neither claim feels wrong -- but on the nature of truth, is it always pretentious to say "you did not READ it"?',
'No, it is not always pretentious -- and the reason why dissolves the whole puzzle. The argument feels unresolvable because it is not actually a disagreement about facts. It is a VERBAL DISPUTE: two people using the same word in two different senses and mistaking that for a factual conflict.

"Read" is POLYSEMOUS -- it carries multiple related senses. Through SEMANTIC BROADENING it has acquired a loose sense, "consumed the content of the book," alongside its strict sense, "took in the text visually." Under the loose sense "I read Dune" is TRUE of the audiobook listener. Under the strict sense it is FALSE. Both parties can be right simultaneously because their claims have different TRUTH CONDITIONS. Nothing about truth itself is threatened; the sentence just has not settled which proposition it expresses until the sense is fixed.

The deeper structure is the TYPE-TOKEN DISTINCTION. "The book" is ambiguous between the WORK -- the abstract text, the type, identical across hardcover, ebook, and audiobook -- and the COPY -- the physical token in your hands. The loose sense of "read" is about the type; the strict sense involves a specific kind of encounter with a token. Notice what happened in the described conversation: it ran fine while both people were discussing the work, and broke exactly at the moment one person referenced a unique feature of the PHYSICAL COPY. That shifted the referent from type to token, and the listener''s claim -- true at the type level -- could no longer support it.

That breakage is the honest test for when the correction is legitimate. A distinction is PEDANTIC when it does no work in the conversation, and PRECISE when it does. Grice''s cooperative principle (specifically the maxim of relation) says speakers include what is relevant and omit what is not: in most conversations the medium is irrelevant, so "I read it" is perfectly cooperative shorthand and correcting it is pure status-play -- enforcing a distinction that changes nothing. But the moment the conversation turns on the medium -- typography, a map on the endpapers, marginalia, how a footnote sits on the page, or even the distinct cognitive experiences of eye versus ear -- the distinction becomes LOAD-BEARING, and drawing it is not pretension. It is repairing an EQUIVOCATION so the conversation can proceed truthfully.

So the rule: pretentiousness is not a property of the distinction; it is a property of whether the distinction is doing work. "You did not READ it" is obnoxious as a flex and correct as a repair -- and the audiobook conversation described here is the textbook case of the repair.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (118, 'verbal dispute', 'An apparent disagreement that is really two parties using the same word in different senses; dissolves once the senses are distinguished, because no fact is actually in contention.'),
  (118, 'polysemy', 'One word carrying multiple related senses, e.g. "read" as "visually took in text" versus "consumed the content of a book."'),
  (118, 'semantic broadening', 'A word''s meaning widening over time to cover more cases -- how "read" stretched to include audiobooks.'),
  (118, 'type-token distinction', 'The difference between an abstract kind (the work, the text of Dune) and its concrete instances (this hardcover, that audio file). "The book" is ambiguous between the two.'),
  (118, 'truth conditions', 'What the world must be like for a statement to be true. A sentence with an unresolved word sense has unsettled truth conditions -- which is how "I read it" can be both true and false.'),
  (118, 'equivocation', 'Letting a word silently shift senses mid-argument; the repair is naming the two senses explicitly.'),
  (118, 'maxim of relation (Grice)', 'The conversational norm of saying what is relevant; it explains why loose talk is cooperative when the medium does not matter, and why precision becomes required the moment it does.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(118, 'Someone says "I read Dune" (they listened to the audiobook). When does correcting them to "you LISTENED to it" stop being pedantic and become legitimate precision?',
 'Whenever strict dictionary accuracy is at stake, which is always',
 'When the distinction becomes load-bearing in the conversation -- e.g. the discussion turns on features of the physical text -- so the correction repairs an equivocation rather than scoring status',
 'Never; language change has made the two verbs fully interchangeable in every context',
 'Only when the correcter has read the physical copy themselves',
 1,
 'The dispute is verbal: "read" has a loose sense (consumed the work) and a strict sense (visually took in the text), true and false respectively for a listener. Correction is pedantry when the distinction does no work, and precision when the conversation actually depends on it -- like referencing a unique feature of the physical copy.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(119, '2026-07-04', 5, 'Who said that the writing system would be the death of memory / the end of an era?',
'That is PLATO -- specifically Socrates in the dialogue PHAEDRUS (~370 BC), and the attribution is layered in a way worth getting right.

THE PASSAGE: Socrates tells a myth about the Egyptian god THEUTH (Thoth), the inventor of writing, presenting his invention to KING THAMUS. Theuth pitches writing as "a recipe for memory and wisdom." Thamus rejects the pitch: "This discovery of yours will create FORGETFULNESS in the learners'' souls, because they will not use their memories; they will trust to the external written characters and not remember of themselves... you give your disciples not truth, but only the SEMBLANCE of truth; they will be hearers of many things and will have learned nothing."

WHO ACTUALLY SAID IT: the judgment belongs to Thamus, a character in a myth told by Socrates, written down by Plato. Socrates himself famously wrote nothing -- everything we have of him is Plato''s writing. Which lands the famous irony: the argument that writing kills memory only survived because someone wrote it down.

TWO PIECES OF NOMENCLATURE THAT TRAVEL WITH THE PASSAGE:
- PHARMAKON -- the Greek word for Theuth''s invention, meaning both REMEDY and POISON. Derrida built a whole essay ("Plato''s Pharmacy") on the ambiguity: writing is pitched as a memory-cure and diagnosed as a memory-poison, and the word refuses to pick a side.
- Thamus''s actual distinction: writing aids REMINDING (hypomnesis -- external marks that point you back to knowledge) but not MEMORY (mneme -- knowledge held in the soul). Learners get "the semblance of wisdom, not the reality."

WHY IT KEEPS COMING UP: this is the original instance of an argument that recurs with every cognitive technology -- writing, printing, calculators, Google, now AI. The claim is always the same: EXTERNALIZING THE FACULTY DESTROYS IT. The track record is more interesting than either side admits: the faculty really does atrophy in its old form (nobody recites the Iliad from memory anymore), AND the offloading buys a ceiling the unaided faculty could never reach. Both halves are true simultaneously -- which is exactly what pharmakon was flagging 2,400 years ago.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (119, 'Phaedrus', 'The Platonic dialogue (~370 BC) containing Socrates''s myth of Theuth and Thamus -- the classic source for the "writing will destroy memory" argument.'),
  (119, 'Theuth and Thamus', 'The Egyptian inventor-god who pitches writing as a recipe for memory, and the king who rejects it as a recipe for forgetfulness -- the two voices of the myth.'),
  (119, 'pharmakon', 'Greek for both remedy and poison; the word used for writing in the Phaedrus, capturing that a cognitive technology can cure and damage the same faculty at once.'),
  (119, 'hypomnesis vs mneme', 'Reminding versus remembering: external marks that point you back to knowledge, versus knowledge actually held in the mind. Thamus grants writing the first and denies it the second.'),
  (119, 'cognitive offloading', 'Delegating a mental faculty to an external tool (writing, calculators, search, AI); the recurring modern subject of the Thamus argument.'),
  (119, 'oral tradition', 'The memory-based transmission culture (recited epics, mnemonic verse) whose decline is exactly the atrophy Thamus predicted -- and the price paid for what literacy unlocked.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(119, 'In Plato''s Phaedrus, who actually delivers the judgment that writing will produce forgetfulness rather than memory?',
 'Socrates, speaking in his own voice as settled doctrine',
 'King Thamus, inside a myth Socrates tells about the god Theuth presenting his invention -- as recorded in writing by Plato',
 'Aristotle, reviewing Plato''s dialogues',
 'Theuth himself, warning about his own invention',
 1,
 'The attribution is three layers deep: Thamus says it, in a myth told by Socrates, preserved only because Plato wrote it down -- Socrates himself wrote nothing. The layering is the point: the anti-writing argument survives exclusively as writing.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(120, '2026-07-04', 6, 'Who are the creator, destroyer, and maintainer in the Hindu Trimurti?',
'The TRIMURTI ("three forms" in Sanskrit) assigns the three cosmic functions to three deities:

- BRAHMA -- THE CREATOR (srishti). Brings the universe into being at the start of each cosmic cycle. Distinct from BRAHMAN (the impersonal ultimate reality) and from BRAHMINS (the priestly class) -- three commonly confused words.
- VISHNU -- THE MAINTAINER / PRESERVER (sthiti). Sustains the cosmic order (dharma), and descends into the world as AVATARS -- Rama and Krishna being the most famous -- whenever that order is threatened.
- SHIVA -- THE DESTROYER (samhara). "Destroyer" deserves a footnote: it is dissolution that clears the way for the next creation, closer to TRANSFORMATION than annihilation. Shiva as NATARAJA (lord of the dance) dances the universe to its end so the cycle can begin again.

THE STRUCTURE IS THE POINT: the cosmology is CYCLICAL, not linear -- create, sustain, dissolve, repeat, forever. Destruction is a maintenance function of the universe, not a failure state.

A curious cultural asymmetry falls out of it: Vishnu and Shiva each anchor massive living devotional traditions (VAISHNAVISM and SHAIVISM), while Brahma has almost no temples dedicated to him (Pushkar being the famous exception). Creation is a job already done until the next cycle -- nobody petitions the creator.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (120, 'Trimurti', 'Sanskrit for "three forms": the grouping of Brahma, Vishnu, and Shiva as the creator, preserver, and destroyer functions of the cosmos.'),
  (120, 'Brahma vs Brahman vs Brahmin', 'Three commonly confused words: the creator deity, the impersonal ultimate reality of Hindu philosophy, and the priestly social class.'),
  (120, 'avatar', 'A descent or incarnation of a deity into the world -- classically Vishnu''s (Rama, Krishna). The source of the modern tech usage for an in-world representation of a user.'),
  (120, 'srishti / sthiti / samhara', 'The three phases of the cosmic cycle: creation, sustenance, and dissolution -- the functions the Trimurti personifies.'),
  (120, 'Nataraja', 'Shiva as lord of the dance, whose cosmic dance dissolves the universe at the end of each cycle so creation can begin again.'),
  (120, 'cyclical cosmology', 'A universe model of endless create-sustain-dissolve cycles rather than a single linear beginning and end; frames destruction as maintenance, not failure.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(120, 'In the Hindu Trimurti, which deity holds which cosmic function?',
 'Brahma destroys, Vishnu creates, Shiva preserves',
 'Brahma creates, Vishnu preserves/maintains, Shiva destroys (dissolves for the next cycle)',
 'Vishnu creates, Shiva preserves, Brahma destroys',
 'Shiva creates, Brahma preserves, Vishnu destroys',
 1,
 'Brahma is the creator (srishti), Vishnu the preserver of cosmic order (sthiti) who descends as avatars, and Shiva the destroyer (samhara) -- where destruction means the dissolution that clears the way for the next cycle of a cyclical cosmology.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(121, '2026-07-04', 7, 'Does "epoiesen" in Greek mean "to create"?',
'Close -- it is a form of the verb "to make," and the exact form matters.

THE WORD IS epoiEsen (Greek: epsilon-pi-omicron-iota-eta-sigma-epsilon-nu). It is not the dictionary form "to create"; it is a fully conjugated form meaning "HE/SHE/IT MADE": third person singular, AORIST tense (Greek''s simple past -- done, completed, once) of the verb POIEO, "to make, to do, to produce."

WHERE IT SHOWS UP -- two signature uses make it one of the most famous single words in Greek:
- ARTIST SIGNATURES. Greek potters and sculptors signed work "Exekias epoiesen" -- "Exekias MADE [this]." The maker''s mark, 2,500 years before "shipped it." Painters used a different verb -- "egrapsen," drew/painted it -- so the Greeks even distinguished making the pot from decorating it.
- THE SEPTUAGINT''S GENESIS 1:1. "En arche epoiesen ho theos ton ouranon kai ten gen" -- "In the beginning God MADE the heaven and the earth." The same everyday verb a potter used, applied to the universe.

DOES IT MEAN "CREATE"? The verb poieo covers the whole territory English splits between DO, MAKE, and CREATE. Greek did not fence off a special elevated verb for creation; making a pot and making a cosmos take the same word.

THE ROOT HIDING IN ENGLISH: poietes -- "maker" -- is where POET comes from. To the Greeks a poet was literally A MAKER (of verses), which is why poetry, POIESIS (the philosophical term for bringing-into-being), and even ONOMATOPOEIA ("name-making") share the root. The oldest word Western culture has for creative work does not distinguish between kinds of making at all.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (121, 'poieo', 'The Greek verb covering "do," "make," and "create" -- one undivided verb for the territory English splits into three.'),
  (121, 'epoiesen', 'Third person singular aorist of poieo: "he/she/it made." Famous from artist signatures ("Exekias epoiesen") and Genesis 1:1 in the Septuagint.'),
  (121, 'aorist', 'The Greek simple-past tense marking a completed, one-time action -- "made," not "was making."'),
  (121, 'epoiesen vs egrapsen', 'The two Greek vase-signature verbs: "made it" (the potter) versus "drew/painted it" (the painter) -- credit split by craft.'),
  (121, 'poietes / poiesis', '"Maker" -- the root of POET and POETRY; poiesis is the philosophical term for bringing something into being.'),
  (121, 'Septuagint', 'The ancient Greek translation of the Hebrew Bible (~3rd-2nd c. BC), source of the famous "epoiesen" in Genesis 1:1.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(121, 'What exactly does the Greek word "epoiesen" mean?',
 'The infinitive "to create," as in a dictionary entry',
 '"He/she/it made" -- third person singular aorist (completed past) of poieo, the verb covering do/make/create',
 'A noun meaning "the creation"',
 'A command meaning "make this!"',
 1,
 'Epoiesen is a conjugated form, not the infinitive: aorist third singular of poieo. It is the verb of the vase signature "Exekias epoiesen" (Exekias made this) and of Genesis 1:1 in the Septuagint -- and its root poietes ("maker") is where the word "poet" comes from.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(122, '2026-07-04', 8, 'Does "bara" in Hebrew mean "to create"? And do bara and epoiesen have different ontological groundings -- one creation from nothing, the other poised for making?',
'YES, BARA MEANS "TO CREATE" -- it is the verb of Genesis 1:1, "Bereshit bara Elohim." But its distinguishing feature is not the dictionary gloss; it is THE GRAMMAR OF WHO GETS TO USE IT. In its basic (Qal) stem, bara occurs ~48 times in the Hebrew Bible and GOD IS THE ONLY SUBJECT IT EVER TAKES. Humans never bara. Humans ASAH (make/do), YATSAR (form -- the potter''s verb), or BANAH (build). Isaiah 43:7 runs all three in one verse: "whom I created (bara), formed (yatsar), and made (asah)." Where Greek uses one undivided verb (poieo) for potter and cosmos alike, Hebrew fences off a verb exclusively for divine action. Bara also never names its material -- "bara out of X" does not occur.

THE ONTOLOGICAL COMPARISON -- the instinct is right, but the mechanism is different than usually told. The common claim is "bara = create from nothing, poieo = craft from material." The honest version: THE WORDS THEMSELVES DO NOT ENCODE THAT; THEIR USAGE PATTERNS DO, and the ex nihilo doctrine came later.

- BARA DOES NOT LEXICALLY MEAN "FROM NOTHING." Genesis 1:2 has pre-existing stuff sitting right there -- TOHU VABOHU (formless void), darkness, waters. The text reads at least as naturally as God ORDERING CHAOS as creating from nothing; the JPS translation even renders 1:1 as a dependent clause: "When God began to create..."
- CREATIO EX NIHILO as an explicit doctrine first surfaces around 2 Maccabees 7:28 ("God did not make them out of things that existed") and hardens into formal doctrine in the 2nd century AD -- argued AGAINST the Greek position.
- THE GREEK POSITION IS THE REAL CONTRAST: in Plato''s Timaeus, matter is ETERNAL, and the DEMIURGE (literally "craftsman") shapes pre-existing chaos after the Forms. Poieo is exactly that -- demiurgic craft language, continuous with human making.
- THE KICKER: when the Septuagint translated bara, it used EPOIESEN. The reserved divine verb got flattened into the common craft verb. That translation loss is why the ontological fight (eternal matter vs. ex nihilo) later had to be fought explicitly -- the Greek text could no longer carry the distinction the Hebrew grammar had been quietly enforcing.

So: different ontological groundings, yes -- but located in usage (divine-only subject, no material named) rather than in a lexical definition, and sharpened into doctrine only after translation blurred them.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (122, 'bara', 'The Hebrew verb of Genesis 1:1; in its basic stem it takes only God as subject and never names its material -- a verb grammatically reserved for divine creation.'),
  (122, 'asah / yatsar / banah', 'The Hebrew verbs humans do get: make/do, form (the potter''s verb), and build. Isaiah 43:7 uses all three alongside bara.'),
  (122, 'creatio ex nihilo', 'The doctrine that God created from nothing; not stated by the word bara itself, first explicit around 2 Maccabees 7:28 and formalized in the 2nd century AD against Greek eternal-matter cosmology.'),
  (122, 'tohu vabohu', 'The "formless void" already present in Genesis 1:2 -- the textual reason bara cannot be assumed to mean creation from nothing.'),
  (122, 'Demiurge', 'Plato''s cosmic "craftsman" in the Timaeus who shapes eternal pre-existing matter after the Forms -- the ontology embedded in Greek making-language.'),
  (122, 'lexical meaning vs usage pattern', 'The difference between what a word denotes by definition and what its distribution encodes (e.g., who may be its subject); bara''s theology lives in the second, not the first.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(122, 'What actually distinguishes Hebrew "bara" from Greek "poieo/epoiesen"?',
 'Bara is lexically defined as "create from nothing," while poieo means "craft from material"',
 'Bara''s distinctiveness is in its usage: God is its only subject and it never names material, while poieo is the common craft verb for any maker -- and the Septuagint flattened bara into epoiesen',
 'They are exact synonyms with no difference of any kind',
 'Poieo is the reserved divine verb and bara is the everyday human one',
 1,
 'Neither word lexically settles the ex nihilo question -- Genesis 1:2 has pre-existing chaos, and the doctrine was formalized centuries later. The real distinction is distributional: bara is grammatically reserved for divine action, poieo is universal craft language, and translating one into the other erased a distinction later theology had to rebuild explicitly.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(123, '2026-07-04', 9, 'In Aramaic, the translation of Genesis 1 speaks of the Memra -- what is that?',
'THE TARGUMS -- Aramaic renderings of the Hebrew Bible produced for synagogue audiences who no longer spoke Hebrew (Onkelos, Neofiti, Pseudo-Jonathan) -- do something striking in Genesis 1 and many other passages: where the Hebrew has God acting directly, the Targum says THE MEMRA OF THE LORD acted. Memra (from Aramaic AMAR, "to say") means "WORD." Targum Neofiti''s Genesis 1 opens roughly: "From the beginning, with wisdom, the MEMRA of the LORD created and perfected the heavens and the earth."

WHY INSERT IT? Partly REVERENTIAL DISTANCE -- a buffer against anthropomorphism, keeping God transcendent while His Word does the in-world acting. But it is not arbitrary: Genesis 1''s own creative mechanism IS speech -- "And God SAID, let there be light." The Memra personifies the saying that was already doing the creating.

THE CONVERGENCE: Philo of Alexandria (Greek-speaking Jew, ~1st century AD) had developed the LOGOS -- the Word as God''s instrument of creation -- out of Greek philosophy. John 1:1 then opens with a deliberate echo of the Septuagint''s Genesis 1:1: "En arche en ho Logos" -- "In the beginning was the WORD... all things were made through him." Hebrew bara-by-speech -> Aramaic Memra -> Greek Logos is ONE IDEA MIGRATING ACROSS THREE LANGUAGES: creation happens through utterance, and the utterance gradually becomes a figure in its own right.

TWO SCHOLARLY CAUTIONS: (1) whether the Memra is a mere CIRCUMLOCUTION (a respectful figure of speech) or a genuine divine intermediary (a HYPOSTASIS) is a live debate -- Moore argued buffer-phrase, Boyarin has argued real intermediary; (2) the Targums were WRITTEN DOWN centuries after Genesis (roughly 1st-7th century AD, with earlier oral roots), so they show how ancient Jews HEARD the text, not what it originally meant. Using them as evidence about Genesis itself is anachronistic; using them as evidence about the interpretive tradition is exactly right.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (123, 'Targum', 'An Aramaic translation-paraphrase of the Hebrew Bible for synagogue use (Onkelos, Neofiti, Pseudo-Jonathan); part translation, part interpretation.'),
  (123, 'Memra', 'Aramaic for "Word" (from amar, to say); the agent the Targums insert where the Hebrew has God acting directly -- "the Memra of the LORD created."'),
  (123, 'circumlocution', 'Saying something indirectly -- here, routing God''s actions through His Word as a reverential buffer against anthropomorphism.'),
  (123, 'hypostasis', 'An attribute of God developed into a quasi-independent figure (Word, Wisdom, Spirit); the live debate is whether the Memra is one or merely a figure of speech.'),
  (123, 'Logos', 'Greek "word/reason"; Philo''s term for God''s creative instrument, and the opening of John 1:1, which deliberately echoes Genesis 1:1''s "en arche."'),
  (123, 'anachronism (in interpretation)', 'Reading a later source''s ideas back into an earlier text -- the caution required when using centuries-later Targums to interpret Genesis itself.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(123, 'What is the Memra in the Aramaic Targums of Genesis 1?',
 'A separate creator deity borrowed from Babylonian religion',
 'The "Word of the LORD" (from amar, "to say") that the Targums insert as the acting agent where the Hebrew has God act directly -- personifying Genesis 1''s creation-by-speech',
 'The Aramaic name for the formless void of Genesis 1:2',
 'A scribal error later corrected in the Septuagint',
 1,
 'Memra means "Word." The Targums route divine action through it, partly as reverential distance from anthropomorphism and partly because Genesis 1''s own mechanism is speech ("And God said..."). It sits in the middle of the migration from Hebrew bara-by-speech to Philo''s and John 1:1''s Greek Logos.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(124, '2026-07-04', 10, 'Are potatoes seeds?',
'No. A potato is a TUBER -- a swollen underground STEM that the plant grows as a storage organ, packing away starch to survive winter and fuel next spring. It is not a seed, not a root, and botanically not even a vegetable-of-the-fruit kind. The giveaway is the EYES: each eye is a NODE with an axillary BUD, the same structure that produces leaves and branches on an above-ground stem. Roots do not have nodes and buds; stems do. That is why a potato left in the cupboard sprouts -- the buds are doing exactly what stem buds do.

"SEED POTATO" IS A MISNOMER. When you plant a chunk of potato with an eye, you are doing VEGETATIVE (asexual, CLONAL) propagation: the new plant is a genetic clone of the parent, grown from stored stem tissue, not from a fertilized seed. Calling it "seed" describes its role (the thing you plant), not its botany.

BUT POTATOES DO MAKE REAL SEEDS. The plant flowers, and the flowers can produce small green BERRIES (which look like tiny tomatoes -- and, like the rest of the plant, are toxic; potatoes are nightshades, Solanum tuberosum, kin to tomato and eggplant). Inside those berries are TRUE POTATO SEEDS (TPS), the product of actual sexual reproduction. So the plant has two propagation channels: clone yourself through tubers (fast, identical, what all farming uses), or make genetically varied seeds through flowers (slow, diverse, how breeders create new varieties).

THE PAYOFF: eating a potato is eating the plant''s STEM-BATTERY, not its offspring. And a field of potatoes is typically a field of CLONES -- one genotype repeated -- which is precisely why potato monocultures are so vulnerable to a single pathogen. The Irish potato famine ran on a nation''s worth of genetically identical tubers meeting one blight (Phytophthora infestans) they had no varied genetics to resist.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (124, 'tuber', 'A swollen underground stem used for food storage; the potato itself. Distinct from a root -- it has nodes and buds.'),
  (124, 'node / eye / axillary bud', 'A point on a stem where buds form; a potato''s "eyes" are nodes with buds, the proof it is stem tissue and the reason it sprouts.'),
  (124, 'vegetative (clonal) propagation', 'Growing a new plant from a piece of the parent (a tuber chunk) rather than from seed; the offspring is a genetic clone.'),
  (124, 'seed potato (misnomer)', 'A tuber piece planted to grow a crop; called "seed" for its planting role, but it is clonal stem tissue, not a botanical seed.'),
  (124, 'true potato seed (TPS)', 'Actual seeds from the plant''s flowers and berries -- the product of sexual reproduction, used by breeders to create new varieties.'),
  (124, 'nightshade / Solanum tuberosum', 'The potato''s family (Solanaceae) and species; relatives include tomato and eggplant, and the plant''s berries and green parts are toxic.'),
  (124, 'monoculture vulnerability', 'The fragility of a crop of genetic clones to a single pathogen -- the structural cause behind the Irish potato famine.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(124, 'Botanically, what is a potato -- and what does that make a "seed potato"?',
 'A root; and a seed potato is its true seed',
 'A tuber (a swollen underground stem); and a "seed potato" is a clonal piece of stem you plant, not a botanical seed -- the plant''s real seeds come from its flowers/berries',
 'A seed; the eyes are the embryos',
 'A fruit, like the tomato it is related to',
 1,
 'A potato is a tuber -- a storage stem, shown by its eyes (nodes with buds). Planting a piece is vegetative/clonal propagation, so "seed potato" is a role-name, not botany. The plant does make true seeds sexually, inside toxic berries on its flowers.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(125, '2026-07-04', 11, 'What is a formalism?',
'The word has two related senses worth holding apart.

SENSE 1 -- A FORMALISM (countable, the everyday technical use): a specific NOTATION-PLUS-RULES SYSTEM for expressing ideas precisely, stripped of ambiguity. When "C = P_A(M)" got called "the CLRS formalism," that meant that particular way of writing keys as indexed functions -- the symbols, plus the rules for what you may do with them. Other examples: Big-O notation is a formalism for growth rates; regular expressions are a formalism for text patterns; the lambda calculus is a formalism for computation; sheet music is a formalism for sound. A formalism is a language DESIGNED SO THAT FORM CARRIES THE MEANING -- you can manipulate the symbols correctly without re-deriving what they stand for at each step.

THE DEFINING MOVE of any formalism: it SEPARATES FORM FROM CONTENT so the form can be operated on MECHANICALLY. That is the payoff. Once "3 apples plus 2 apples" becomes "3 + 2," you can push the symbols around by rule -- and a machine, a compiler, or someone who does not understand the domain can do it correctly. This is exactly what makes each rung of the abstraction ladder possible: a compiler manipulates the FORMALISM of your source code without understanding your app.

SENSE 2 -- FORMALISM (uncountable, the -ism): the stance that THE FORM IS WHAT MATTERS -- reason from the rules of the system itself rather than from intuition or real-world meaning. In math, Formalism (Hilbert''s program) is the position that mathematics IS the manipulation of symbols by rules, with no need for the symbols to "mean" anything beyond that. In law or art the word turns mildly pejorative -- "that is just formalism" = obeying the letter of the rules while missing their point.

THE TENSION WORTH CARRYING (the thread through the whole day): a formalism''s power IS that it discards meaning to gain mechanical precision -- but that is also its risk. "epoiesen" flattening "bara" was a formalism losing a distinction the richer source encoded. Strip too much and the symbols march along correctly while the thing you cared about quietly drops out. Which is why the human job around any formalism is the same two things: SPECIFICATION (loading the right meaning into the form) and VERIFICATION (checking the mechanically-correct output still means what you wanted).

RULE OF THUMB: if you can be RIGHT BY FOLLOWING THE RULES without understanding the subject, you are looking at a formalism.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (125, 'formalism (countable)', 'A specific notation-plus-rules system for expressing ideas precisely -- e.g. Big-O, regex, lambda calculus, musical notation -- designed so the form itself carries the meaning.'),
  (125, 'Formalism (the -ism)', 'The stance that the form is what matters; in mathematics, Hilbert''s view that math is symbol-manipulation by rules with no need for the symbols to mean anything.'),
  (125, 'form vs content', 'The separation a formalism enforces: the shape of the expression versus what it refers to. Splitting them is what lets form be manipulated mechanically.'),
  (125, 'mechanical manipulation', 'Operating on symbols purely by rule, without understanding their meaning -- what compilers, calculators, and proof-checkers do, and the whole point of a formalism.'),
  (125, 'notation', 'The concrete symbols and syntax of a formalism; the visible surface through which its rules are applied.'),
  (125, 'formalism''s tradeoff', 'Gaining mechanical precision by discarding meaning -- powerful, but risky when a distinction the source encoded gets stripped away (as when epoiesen flattened bara).');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(125, 'What is the defining feature of a formalism (in the technical, countable sense)?',
 'It makes ideas sound more impressive and academic',
 'It separates form from content -- a notation plus rules where the form carries the meaning, so the symbols can be manipulated correctly and mechanically without understanding the subject',
 'It is any writing that uses Greek or mathematical letters',
 'It guarantees the conclusions are true in the real world',
 1,
 'A formalism is a notation-plus-rules system (Big-O, regex, lambda calculus, sheet music) engineered so form carries meaning. That lets a compiler or calculator operate on the symbols mechanically -- its power -- while the human keeps the jobs of specification and verification, since a formalism can also strip a distinction the source once encoded.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(126, '2026-07-04', 12, 'What does POLYSEMOUS mean?',
'POLYSEMOUS (adjective; noun POLYSEMY) describes a single word that carries MULTIPLE RELATED SENSES. The parts spell it out: Greek POLY- ("many") + SEMA ("sign, meaning") -- literally "many-meaninged." It came up earlier today for the verb "read," which has a strict sense (took in text visually) and a loose sense (consumed the content of a book); one word, several linked meanings.

THE KEY DISTINCTION -- polysemy vs. homonymy. Both are one spelling with more than one meaning, but:
- POLYSEMY = the senses are RELATED, branches off one root meaning. "Head" -> head of a body, head of a company, head of a beer, head of a bed. All radiate from a single core notion. One dictionary entry, several numbered senses.
- HOMONYMY = the meanings are UNRELATED and share a spelling by ACCIDENT. "Bank" (riverside) vs. "bank" (money) have no common thread -- they arrived from different origins and merely collided in spelling. Two separate dictionary entries.

Rule of thumb: if you can feel the metaphorical thread connecting the senses, it is polysemy; if the shared spelling feels like a coincidence, it is homonymy.

WHY IT MATTERS (the practical payoff, and why it keeps recurring today): polysemy is the fuel of VERBAL DISPUTES -- two people using the same polysemous word in different senses and mistaking that for a disagreement about facts (the audiobook "did you really READ it" argument). It is also exactly what makes "make/create" hard across languages: Greek poieo is broadly polysemous (do/make/create in one word) while Hebrew reserves bara for divine creation -- different languages carve the sense-space differently. Naming a word as polysemous is the move that lets you say "wait, which sense?" and dissolve the confusion.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (126, 'polysemous / polysemy', 'Of a word: having multiple related senses that branch from one core meaning (poly- "many" + sema "meaning"), e.g. the many senses of "head" or "read."'),
  (126, 'homonymy', 'One spelling with multiple UNRELATED meanings that share form by accident, e.g. "bank" (riverside) vs. "bank" (money) -- contrast with polysemy.'),
  (126, 'sense (lexical)', 'One distinct meaning of a word; a polysemous word has several senses listed under a single dictionary entry.'),
  (126, 'semantic field', 'The space of related meanings a word or set of words carves up; different languages divide it differently (Greek poieo vs. Hebrew bara for "make/create").'),
  (126, 'verbal dispute (recap)', 'An apparent disagreement that is really two speakers using one polysemous word in different senses -- resolved by asking "which sense?" See [[entry-4-on-2026-07-04]].');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(126, 'A word is POLYSEMOUS when it has:',
 'Multiple unrelated meanings that share a spelling by accident, like "bank" (river) and "bank" (money)',
 'Multiple related senses that branch from one core meaning, like "head" of a body, a company, and a beer',
 'Exactly one precise meaning with no ambiguity',
 'A meaning that changes randomly with no pattern',
 1,
 'Polysemy means many related senses radiating from a shared root notion (poly- "many" + sema "meaning"). Unrelated meanings that merely collide in spelling are homonymy instead -- the test is whether a metaphorical thread connects the senses.');

INSERT INTO days (date, kind, title) VALUES
  ('2026-07-05', 'qa', 'Relink before it breaks -- proactive reauth and the 30-day warning');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(127, '2026-07-05', 1, 'Why does proactive reauth UX matter given Stripe''s June 2026 changelog?',
'THE CHANGELOG ITEM: Stripe''s June 2026 API release (2026-06-24.dahlia) "adds information about upcoming deactivations to the Financial Connections Account object." Small line, real shift: the expiry signal for a linked bank account now lives ON THE ACCOUNT OBJECT itself, queryable any time -- not only in the fire-once `financial_connections.account.upcoming_deactivation` webhook Stripe sends ~30 days out.

WHY BANK LINKS DIE AT ALL: a Financial Connections link is not permanent. The OAuth token the bank issued to Stripe expires after a set period or from inactivity; the bank changes its MFA requirements; the user changes their password, locks the account, or revokes data sharing. Deactivation is a WHEN, not an IF. Every product built on linked bank accounts eventually faces reauth.

REACTIVE vs PROACTIVE is the whole game:
- REACTIVE: you find out the link is dead when something fails -- an off-session ACH debit bounces, a balance check errors, a data refresh returns nothing. The user finds out via a dunning email or a broken feature. That is the worst possible moment: trust is dented, revenue is delayed, and re-engaging a user AFTER a failure is dramatically harder than nudging them before one (this is the mechanics of INVOLUNTARY CHURN -- losing customers to plumbing, not to choice).
- PROACTIVE: with the deactivation date on the object, your app can render "your bank connection expires in 12 days -- relink now" in-product, at login, when the user is already authenticated and paying attention. Stripe''s RELINK flow is deliberately lighter than first-time linking (no bank picker -- the institution is already known), so the proactive path is one low-friction tap. The reactive path is a support ticket.

THE RESPONSIBILITY SHIFT: before, "we didn''t know it was about to expire" was at least partially Stripe''s problem (did you catch the webhook? was your endpoint up that day?). Now the signal sits on the object you already fetch. If a connection lapses silently, that is a PRODUCT failure -- yours -- not an information failure. Changelog lines like this quietly move the burden: the platform hands you the signal; the UX that acts on it is your job.

(SCOPE NOTE: nothing in the June 2026 changelog touches card reauthentication or SCA -- the other auth-flavored item, Visa DCAP / Data Only 3DS support, is about optimizing authentication cost on card payments, a different animal. The reauth story is the Financial Connections one.)');

INSERT INTO vocab (entry_id, term, def) VALUES
  (127, 'Stripe Financial Connections', 'Stripe''s open-banking product for linking a user''s bank account to an app -- for ACH payments, balance checks, and transaction data.'),
  (127, 'reauthentication (relink)', 'Having a user re-consent and re-verify an expired bank/OAuth connection. Stripe''s relink flow skips the bank picker, making it lighter than initial linking.'),
  (127, 'OAuth token expiry', 'Access tokens banks grant to aggregators expire after a set period or inactivity -- the structural reason every linked-account integration eventually needs reauth.'),
  (127, 'webhook vs. polling a field', 'A webhook is a fire-once push notification to your server; a field on an object can be read any time. June 2026 added the deactivation info to the object, enabling in-product UI without depending on having caught the webhook.'),
  (127, 'off-session payment', 'A charge made without the user present (e.g. a scheduled ACH debit). These fail silently when the underlying connection has lapsed -- the user is not there to fix it.'),
  (127, 'involuntary churn', 'Losing a customer to a mechanical failure (expired card, dead bank link) rather than a decision to leave. Proactive reauth UX is an anti-involuntary-churn measure.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(127, 'Stripe''s June 2026 changelog added upcoming-deactivation info to the Financial Connections Account object. Why does that make PROACTIVE reauth UX matter more?',
 'Because Stripe now automatically relinks accounts, so no UX is needed',
 'Because bank links now expire faster than they used to',
 'Because the expiry signal is now queryable on the object itself -- so apps can prompt users to relink in-product before off-session payments fail, and a silent lapse becomes a product failure rather than a missing-information problem',
 'Because the changelog made reauthentication mandatory for all card payments under SCA',
 2,
 'Bank links inevitably die (OAuth expiry, MFA changes, revoked access). Previously the 30-day warning arrived only as a fire-once webhook; putting it on the Account object means any app can read it any time and nudge the user to relink -- one light tap -- instead of discovering the lapse when an ACH debit bounces. The platform now hands you the signal; acting on it is your UX''s job.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(128, '2026-07-05', 2, 'Why does my .zshrc / profile get accessed from a non-interactive shell spawned by Claude?',
'FIRST, THE RULEBOOK. Which startup files zsh reads depends on two independent flags on the shell: is it a LOGIN shell, and is it INTERACTIVE?
- `~/.zshenv` -- read by EVERY zsh, always.
- `~/.zprofile` -- read by LOGIN shells.
- `~/.zshrc` -- read by INTERACTIVE shells only.
- `~/.zlogin` -- read by LOGIN shells, after zshrc.

MEASURED ON THIS MACHINE: asking Claude''s own spawned shell (`[[ -o interactive ]]`, `[[ -o login ]]`) reports interactive: NO, login: YES. So every Bash tool call runs a NON-INTERACTIVE LOGIN zsh -- which by the rulebook reads `.zshenv` and `.zprofile` on every single command. That is most of the "profile getting accessed" right there.

BUT `.zshrc` NEEDS THE INTERACTIVE FLAG -- so why does it get touched? THE SNAPSHOT MECHANISM: at session start, Claude Code launches your shell once with your full configuration loaded (that load reads `.zshrc`), then captures the resulting state -- functions, completions, environment -- into a SNAPSHOT FILE under `~/.claude/shell-snapshots/` (visible on this machine, ~8.5KB each, one per session). Each subsequent command then runs in a fresh non-interactive shell that SOURCES THE SNAPSHOT instead of re-running your rc files. Your `.zshrc` is read at snapshot-build time; your `.zprofile`/`.zshenv` are read every time because of the login flag.

WHY THIS IS DELIBERATE: without it, Claude''s shells would miss everything your terminal has -- the PATH entries added by Homebrew, nvm, pyenv, cargo; your functions; your env vars. Every `npm run dev` would be `command not found` or, worse, silently use the wrong Node. Initializing from your profile makes the agent''s shell match YOUR shell, so what works for you works for it.

THE GOTCHA THIS CREATES: anything in your rc files that assumes a human at a TTY -- printing banners, `exec tmux`, prompts that block for input, powerlevel10k instant prompt -- now runs (or breaks) inside automation. The fix is standard: guard interactive-only lines with `[[ -o interactive ]] || return` near the top of `.zshrc`, and keep pure environment setup in `.zshenv`/`.zprofile` where non-interactive shells are SUPPOSED to find it.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (128, 'login shell', 'A shell started as part of "logging in" (or with -l), which reads the profile files (.zprofile/.zlogin). Independent of whether it is interactive.'),
  (128, 'interactive shell', 'A shell attached to a human at a terminal (prompt, line editing). Only interactive zsh reads .zshrc. Test with [[ -o interactive ]].'),
  (128, 'non-interactive shell', 'A shell running a script or a -c command with no human attached -- what automation (including Claude Code) spawns.'),
  (128, 'shell snapshot', 'Claude Code''s captured copy of your shell state (functions, env) built once per session from your full config and sourced into each command''s fresh shell -- ~/.claude/shell-snapshots/.'),
  (128, 'zsh startup files', 'The read-order matrix: .zshenv (always), .zprofile (login), .zshrc (interactive), .zlogin (login, last). Which files run depends on the login/interactive flags.'),
  (128, 'TTY guard', 'A line like [[ -o interactive ]] || return that stops human-only rc config from running inside automation''s shells.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(128, 'Claude Code spawns a NON-INTERACTIVE LOGIN zsh for each command. By zsh''s rules, which files does that shell read directly on every command?',
 '.zshrc only -- rc files are for automation',
 '.zshenv and .zprofile -- .zshrc needs the interactive flag, and only gets loaded once when the session''s shell snapshot is built',
 'All four startup files, every time',
 'None -- non-interactive shells read no config at all',
 1,
 '.zshenv is read by every zsh and .zprofile by login shells, so both run on each command. .zshrc requires an interactive shell; Claude Code touches it once per session while building the shell snapshot it then sources into each command, so the agent''s environment matches your terminal.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(129, '2026-07-05', 3, 'What is a zshrc?',
'`~/.zshrc` is a PLAIN SHELL SCRIPT in your home directory that zsh automatically runs at the start of every INTERACTIVE shell -- every time you open a terminal tab and get a prompt. It is not a special format; it is just zsh code executed top to bottom before you get control.

THE NAME: "rc" is an old Unix suffix meaning RUN COMMANDS (from "runcom" on 1960s MIT systems). The pattern generalizes: .vimrc, .npmrc, .bashrc -- "the commands/config to run when this program starts."

WHAT BELONGS THERE: the things that shape your INTERACTIVE experience -- your prompt/theme, aliases, shell functions, key bindings, completion setup (`compinit`), history behavior, and the init lines version managers ask you to add (nvm, pyenv, rbenv). Frameworks like oh-my-zsh are essentially elaborate .zshrc files.

WHAT DOES NOT BELONG THERE (the classic mistake): environment variables and PATH entries that SCRIPTS need. Because .zshrc only runs for interactive shells, anything a cron job, an editor, or an agent-spawned shell needs must live in `.zshenv` (always read) or `.zprofile` (login shells). If a tool works in your terminal but "command not found"s everywhere else, the config is probably stranded in .zshrc.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (129, 'rc file / "run commands"', 'The Unix convention (.zshrc, .vimrc, .npmrc) of a dotfile of commands a program executes at startup; from 1960s "runcom".'),
  (129, 'dotfile', 'A file whose name starts with "." making it hidden by default in ls; the traditional home for per-user config.'),
  (129, 'alias', 'A shell shortcut expanding one word to a longer command (alias gs="git status"); defined per-shell, typically in .zshrc.'),
  (129, 'compinit', 'zsh''s completion-system initializer, conventionally called from .zshrc; powers tab-completion.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(129, 'What is ~/.zshrc, and when does it run?',
 'A binary config database zsh compiles at install time',
 'A plain zsh script run automatically at the start of every INTERACTIVE zsh -- home of prompt, aliases, functions, and completion',
 'A script run once at system boot for all users',
 'A log file where zsh records the commands you type',
 1,
 'It is ordinary shell code ("rc" = run commands) executed whenever an interactive zsh starts. Because non-interactive shells skip it, environment that scripts need belongs in .zshenv or .zprofile instead.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(130, '2026-07-05', 4, 'What is a bashrc?',
'`~/.bashrc` is bash''s counterpart to .zshrc -- a plain script bash runs at startup -- but bash carves the rules differently, and the difference bites people constantly.

BASH''S RULE: `.bashrc` runs for INTERACTIVE NON-LOGIN shells. Interactive LOGIN shells skip it and read `.bash_profile` instead. (zsh is saner: interactive means .zshrc, login means .zprofile, and both can apply to one shell.)

WHY THAT RULE BITES ON MACOS: Terminal.app and iTerm start every new tab as a LOGIN shell. So on a Mac, bash reads `.bash_profile` and IGNORES your `.bashrc` -- the classic "I put my alias in .bashrc and nothing happened" mystery. On most Linux desktops, new terminal windows are NON-login, so .bashrc is the file that matters. Same shell, opposite habits per OS.

THE STANDARD FIX is a one-line bridge in `.bash_profile`: `[ -f ~/.bashrc ] && source ~/.bashrc` -- so login shells pull in the rc too, and you keep all real config in one file.

ONE MORE BASH QUIRK: a non-interactive bash spawned by a remote command (e.g. `ssh host somecommand`) DOES read .bashrc -- which is why many distro-shipped .bashrc files start with a guard like `case $- in *i*) ;; *) return;; esac` (bail out if not interactive). NOTE: on macOS since Catalina (2019) the default shell is zsh, so .bashrc only matters where you explicitly run bash.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (130, '.bash_profile vs .bashrc split', 'bash reads .bash_profile for login shells and .bashrc for interactive non-login shells -- so config must be bridged (profile sources rc) to apply everywhere.'),
  (130, 'macOS login-shell convention', 'Terminal.app/iTerm start each tab as a LOGIN shell -- opposite of most Linux terminals -- flipping which bash startup file actually runs.'),
  (130, 'source (dot) command', 'Runs a script inside the CURRENT shell so its exports/aliases persist, rather than in a throwaway child process. `source ~/.bashrc` or `. ~/.bashrc`.'),
  (130, 'interactivity guard', 'The `case $- in *i*)` idiom at the top of a .bashrc that returns early for non-interactive shells, since bash sometimes reads .bashrc for those too.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(130, 'You add an alias to ~/.bashrc on a Mac using bash, open a new Terminal tab, and the alias is missing. Why?',
 'Aliases cannot be defined in .bashrc',
 'macOS Terminal starts each tab as a LOGIN shell, so bash reads .bash_profile and skips .bashrc -- the fix is having .bash_profile source .bashrc',
 'macOS caches shell config and needs a reboot',
 '.bashrc only applies to the root user',
 1,
 'bash splits its startup files: login shells read .bash_profile, interactive non-login shells read .bashrc. Mac terminals launch login shells (Linux terminals usually do not), so the conventional one-line bridge -- .bash_profile sourcing .bashrc -- keeps one canonical config file.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(131, '2026-07-05', 5, 'What is a zsh profile?',
'`~/.zprofile` is the startup script zsh runs for LOGIN SHELLS -- read after `.zshenv`, before `.zshrc`. Think of it as the ONCE-PER-SESSION layer: it runs when a session begins (a terminal tab on macOS, an SSH login, or any `zsh -l`), while `.zshrc` runs for every interactive shell including nested ones.

WHAT BELONGS THERE: ENVIRONMENT -- the stuff you want set once and inherited by everything downstream. PATH additions, `export`ed variables, language/locale settings. This is why Homebrew''s installer tells you to put `eval "$(/opt/homebrew/bin/brew shellenv)"` in `.zprofile`: set the PATH once at login, and every child process inherits it.

THE MACOS WRINKLE: before your `.zprofile`, the system runs `/etc/zprofile`, which calls PATH_HELPER -- a macOS utility that assembles PATH from /etc/paths and /etc/paths.d. Since Mac terminals open every tab as a login shell, this whole login chain runs per tab -- which is why "login shell" on macOS does not mean "only at actual login."

THE FULL LOGIN-SHELL READ ORDER: `.zshenv` (always) -> `.zprofile` (login) -> `.zshrc` (if also interactive) -> `.zlogin` (login, last -- a rarely-used post-rc hook). For automation the practical takeaway from today: a NON-INTERACTIVE login shell (what Claude Code spawns) runs .zshenv and .zprofile but not .zshrc -- so .zprofile is exactly where config should live if you want agents and scripts to see it.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (131, '.zprofile', 'zsh''s login-shell startup file; the once-per-session environment layer (PATH, exports), read between .zshenv and .zshrc.'),
  (131, '.zshenv', 'Read by EVERY zsh -- interactive, login, script, or agent-spawned. The most universal (and thus most performance-sensitive) startup file.'),
  (131, '.zlogin', 'The login shell''s final startup file, after .zshrc; a rarely-used post-setup hook.'),
  (131, 'path_helper', 'macOS utility invoked by /etc/zprofile that builds PATH from /etc/paths and /etc/paths.d before user config runs.'),
  (131, 'environment inheritance', 'Child processes receive a copy of the parent''s exported variables -- why setting PATH once in a login profile covers everything launched from that session.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(131, 'Homebrew asks you to put its PATH setup in ~/.zprofile rather than ~/.zshrc. What makes .zprofile the right layer?',
 '.zprofile runs for LOGIN shells -- once per session, inherited by children, and read even by non-interactive login shells (like agent-spawned ones) that skip .zshrc',
 '.zprofile is the only file allowed to modify PATH',
 '.zprofile runs faster because zsh compiles it',
 'There is no difference; the two files are aliases for each other',
 0,
 'Environment (PATH, exports) belongs in the login layer: set once, inherited downstream, and visible to non-interactive login shells that never read .zshrc. .zshrc is the interactive layer -- prompt, aliases, completion -- re-run per interactive shell.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(132, '2026-07-05', 6, 'What is a bash profile?',
'`~/.bash_profile` is bash''s LOGIN-SHELL startup script -- the bash counterpart of `.zprofile`, with two bash-specific twists.

TWIST 1 -- THE FIRST-MATCH RULE: at login, bash does not read every profile file. It searches in order -- `.bash_profile`, then `.bash_login`, then `.profile` -- and runs ONLY THE FIRST ONE that exists. Creating a .bash_profile therefore silently disables a .profile you may also have (a common way to "lose" config). `.profile` is the ancient Bourne-shell name, still honored so sh-compatible config keeps working.

TWIST 2 -- THE EXCLUSIVE SPLIT: unlike zsh (where a login+interactive shell reads BOTH .zprofile and .zshrc), a bash login shell reads .bash_profile INSTEAD OF .bashrc. Hence the universal convention: keep .bash_profile nearly empty except for environment exports plus the bridge line `[ -f ~/.bashrc ] && source ~/.bashrc`, and put everything else in .bashrc.

DIVISION OF LABOR (same principle as zsh): profile = once-per-session ENVIRONMENT (PATH, exports); rc = per-shell INTERACTIVE setup (prompt, aliases, functions). The names differ across shells; the layering idea is identical.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (132, '.bash_profile', 'bash''s login-shell startup file; conventionally holds exports plus one line sourcing .bashrc.'),
  (132, 'first-match rule', 'At login bash runs only the FIRST existing file of .bash_profile, .bash_login, .profile -- so adding .bash_profile silently disables .profile.'),
  (132, '.profile', 'The original Bourne-shell login file; the portable, shell-agnostic place for POSIX-compatible environment setup.'),
  (132, 'profile vs rc layering', 'The cross-shell pattern: profile files = once-per-session environment; rc files = per-shell interactive config.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(132, 'You create a new ~/.bash_profile and suddenly config in your old ~/.profile stops applying. Why?',
 'Creating .bash_profile corrupts .profile',
 'At login bash runs only the FIRST file found of .bash_profile, .bash_login, .profile -- your new file now shadows .profile entirely',
 '.profile is only read by zsh',
 'macOS deletes .profile when .bash_profile appears',
 1,
 'bash''s login search is first-match-only, so .bash_profile shadows .profile. Fix by sourcing .profile (and .bashrc) from .bash_profile. zsh avoids this class of surprise by reading its files additively.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(133, '2026-07-05', 7, 'What are the differences between zsh and bash?',
'BOTH ARE BOURNE-FAMILY SHELLS -- descendants of 1977''s sh, mostly POSIX-compatible, so everyday commands and 95% of scripts run identically in either. The differences live at the edges, and they sort into three buckets.

BUCKET 1 -- HISTORY AND DEFAULTS. bash (1989, GNU "Bourne Again SHell") is the lingua franca: default on most Linux systems, the assumed target of #!/bin/bash scripts everywhere. zsh (1990) became the macOS default in Catalina (2019) -- largely because bash moved to the GPLv3 license and Apple froze its shipped bash at ancient 3.2 rather than accept it. So: write FOR bash, live IN zsh is a common modern split.

BUCKET 2 -- INTERACTIVE EXPERIENCE (zsh''s home turf). Richer tab completion (menus you can arrow through, right-hand-side descriptions), stronger globbing (`**/*.ts` recursion, glob qualifiers like `*(.om[1])` = newest plain file), spelling correction, shared history across tabs, and a huge theming/plugin ecosystem (oh-my-zsh, powerlevel10k). Modern bash narrows the gap with bash-completion, but zsh''s defaults are further ahead out of the box.

BUCKET 3 -- SCRIPTING GOTCHAS (where "mostly compatible" bites):
- WORD SPLITTING: in bash, an unquoted `$var` containing spaces splits into multiple words; in zsh it does NOT. Hides quoting bugs in one direction, breaks assumptions in the other.
- ARRAYS: bash arrays are 0-indexed; zsh arrays are 1-INDEXED. `${arr[0]}` vs `$arr[1]` for the first element.
- Startup files differ (today''s whole thread: .bashrc/.bash_profile vs .zshrc/.zprofile, first-match vs additive).

PRACTICAL RULE: scripts get a `#!/bin/bash` (or `#!/bin/sh` for strict portability) shebang and run the same everywhere regardless of your interactive shell; your interactive shell is a comfort choice. The shebang decides what runs the script -- not the shell you typed it from.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (133, 'Bourne shell family', 'Shells descending from 1977''s sh (bash, zsh, dash, ksh) sharing core syntax; why most scripts run in any of them.'),
  (133, 'POSIX shell', 'The standardized common subset of shell behavior; #!/bin/sh scripts targeting it run under any compliant shell.'),
  (133, 'shebang (#!)', 'The first line of a script naming its interpreter (#!/bin/bash); it -- not your interactive shell -- decides what executes the script.'),
  (133, 'word splitting', 'The shell breaking an unquoted expansion into words on whitespace. bash does it to unquoted $var; zsh by default does not -- a top cross-shell gotcha.'),
  (133, 'glob qualifiers', 'zsh''s pattern suffixes filtering matches by attribute, e.g. *(.om[1]) = the most recently modified plain file.'),
  (133, 'GPLv3 / why macOS switched', 'The license change that stopped Apple updating bash past 3.2 and drove the Catalina (2019) switch to zsh as default.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(133, 'Which of these is a REAL scripting difference between bash and zsh?',
 'zsh cannot run scripts, only interactive sessions',
 'bash word-splits unquoted $var on spaces and 0-indexes arrays; zsh does not split unquoted expansions and 1-indexes arrays',
 'bash has no functions, so zsh was created to add them',
 'They share nothing; every command differs',
 1,
 'The shells are ~95% compatible (both Bourne-family), but the edges bite: unquoted-expansion word splitting and array indexing flip between them, and startup files differ. Hence the rule -- give scripts an explicit #!/bin/bash or #!/bin/sh shebang, and treat your interactive shell as a separate comfort choice.');

INSERT INTO days (date, kind, title) VALUES
  ('2026-07-07', 'qa', 'Saturate the window -- parallel sessions, shared quota, and the guilt of latent compute');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(134, '2026-07-07', 1, 'What is it called to kick off a bunch of Claude Code sessions in parallel -- say, before a live demo, to maximize token usage against quota?',
'There is no single official name for the pre-demo warm-up move, but the pieces you are describing each have a documented name, and they are different tools:

- **Parallel sessions with git worktrees** -- THE documented pattern for running multiple simultaneous Claude Code sessions on one repo. `claude --worktree feature-x` (or `-w`) gives each session its own working directory and branch, so parallel sessions never fight over files. Docs: code.claude.com/docs/en/worktrees.
- **Background agents** -- `claude --bg "task"` starts a session and returns your terminal immediately; monitor the fleet with `claude agents` (the agent view: Working / Needs input / Completed). This is the documented "kick off work that runs while you do something else."
- **Headless mode** -- `claude -p "prompt"` runs one non-interactive query and exits. Wrap it in a shell loop and you have scripted fan-out.
- **Subagents** -- parallel workers spawned INSIDE one session, each with its own context window. Parallelism within a conversation rather than across terminals.

The umbrella terms people use for the whole idea: **fan-out**, **multi-agent orchestration**, or informally an agent fleet/swarm.

The quota half of your question has a catch, though: your subscription quota is a SHARED bucket. Every parallel session, subagent, and background task draws from the same 5-hour rolling window and weekly cap. Parallelism does not get you more tokens -- it converts wall-clock time into throughput. So the pre-demo move is really about having long-running work already finished (or in flight) before the camera is on, not about extracting extra capacity.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (134, 'git worktree', 'A second (or Nth) working directory attached to one repo, each on its own branch -- what lets parallel Claude Code sessions edit the same repo without collisions.'),
  (134, 'background agent', 'A Claude Code session started with `claude --bg` that runs detached from your terminal; monitored via `claude agents`.'),
  (134, 'headless mode', 'Running Claude Code non-interactively with `claude -p "prompt"` -- one query, one response, exit. The scripting/CI building block for fan-out.'),
  (134, 'fan-out', 'Splitting one goal into many independent tasks dispatched in parallel, results collected after. The general pattern behind subagents, background agents, and worktree fleets.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(134, 'You kick off five parallel Claude Code sessions before a demo "to get more out of your quota." What actually happens to your quota?',
 'Each session gets its own fresh quota, so you now have 5x capacity',
 'All five draw from one shared bucket -- you spend the same quota faster, trading wall-clock time for throughput',
 'Parallel sessions are free; only the interactive session bills against quota',
 'Quota pauses while sessions run in the background',
 1,
 'Subscription quota is a shared bucket across all sessions, subagents, and background agents on the account. Parallelism buys speed (more done per hour of YOUR time), never extra tokens.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(135, '2026-07-07', 2, 'How do Claude Code usage quotas actually work -- what is the window, and what resets when?',
'Two layers, both on the same shared bucket (as of mid-2026; verified against May 2026 reporting, since the official support page could not be fetched directly):

LAYER 1 -- THE 5-HOUR ROLLING WINDOW. The window starts at your FIRST prompt, not on the clock hour: first prompt at 10:00 AM means that usage ages out at 3:00 PM. It is rolling, so capacity frees continuously as old usage falls out the back of the window -- there is no single "reset moment" to wait for.

LAYER 2 -- THE WEEKLY CAP. A longer-horizon ceiling on total compute, sitting above the 5-hour window. You can be fine on the short window and still hit the weekly wall.

THE SHARED-BUCKET RULE: Claude Code sessions, subagents, background agents, and claude.ai chat on the same account all draw from one pool. There is no per-session isolation.

Recent history worth knowing: on May 6, 2026, Anthropic doubled the 5-hour rate limits for Pro, Max, Team, and Enterprise plans and removed the peak-hours reduction for Pro/Max.

The demo-prep implication: "use it or lose it" is only half true. Unused window capacity does expire, but burning it on busywork buys nothing. What the rolling window actually rewards is having a QUEUE of real tasks ready, so capacity is always being converted into finished work.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (135, 'rolling window', 'A limit measured over the trailing N hours from now, not a fixed calendar block -- usage continuously ages out rather than resetting all at once.'),
  (135, 'rate limit vs quota', 'Rate limit = how fast you may spend (the 5-hour window); quota/cap = how much total you may spend (the weekly layer). You can hit either one first.'),
  (135, 'shared quota bucket', 'One pool of capacity per account that every surface (sessions, subagents, background agents, claude.ai chat) draws from -- no per-session allotment.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(135, 'Your first Claude Code prompt today was at 10 AM and you hit the 5-hour limit at noon. When can you work again?',
 'At exactly 3 PM, when the whole window resets at once',
 'Not until midnight, when daily quotas reset',
 'Gradually -- it is a rolling window, so capacity frees continuously as usage from 5 hours ago ages out',
 'Immediately, if you open a second terminal session',
 2,
 'The window rolls: each prompt ages out 5 hours after it happened, so capacity trickles back rather than resetting on a schedule. And a second session will not help -- all sessions share one bucket.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(136, '2026-07-07', 3, 'What is the difference between a subagent, a worktree session, and a background agent in Claude Code?',
'Three tiers of parallelism, sorted by how independent the worker is from you:

**SUBAGENT -- a worker inside your conversation.** Spawned by the session you are talking to (the Agent/Task tool). Gets its own fresh context window, its own tool permissions, does the work, and returns only a summary to the parent -- which is the point: a subagent can grep through 200 files without flooding your main context. It lives and dies within your session.

**WORKTREE SESSION -- a sibling conversation on an isolated copy.** A full interactive Claude Code session you start yourself (`claude -w branch-name`), running against its own git worktree so it can edit files without colliding with your main session. Fully independent context and history; YOU are the orchestrator switching between terminals.

**BACKGROUND AGENT -- a session running without you.** Started with `claude --bg "task"`, it is a complete Claude Code conversation that persists with no terminal attached, locally or on Anthropic''s cloud infrastructure (cloud sessions keep running even if you close the app). You check on the fleet with `claude agents`.

Rule of thumb: subagent when the MAIN conversation needs the result but not the mess; worktree session when you want to actively drive two workstreams; background agent when you want to fire-and-forget and collect later. All three bill against the same shared quota.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (136, 'subagent', 'A worker spawned inside one Claude Code session with its own context window and permissions; returns a summary so the parent conversation stays clean.'),
  (136, 'agent view', 'The `claude agents` screen -- the fleet monitor showing each background session''s state: Working, Needs input, or Completed.'),
  (136, 'context isolation', 'Giving a worker its own context window so its intermediate noise (search results, logs, file dumps) never enters the parent conversation.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(136, 'You want Claude to sweep the whole repo for usages of a deprecated API while your main conversation stays focused on the refactor plan. Which tier fits?',
 'A subagent -- it searches in its own context window and returns only the summary your main session needs',
 'A worktree session -- searching requires an isolated branch',
 'A background agent -- searches must run detached from the terminal',
 'None; searching always happens in the main context',
 0,
 'The deciding question is "who needs the result?" The MAIN conversation needs the findings but not the hundreds of grep hits -- exactly what subagent context isolation is for. Worktrees isolate FILE EDITS; background agents detach WHOLE TASKS from your attention.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(137, '2026-07-07', 4, 'Is "latent compute" a real term? Unused quota gives me the feeling of not fully committing as much as I should.',
'"Latent compute" is not a standard industry term, but it is a perfectly readable coinage for a real one: **idle capacity**, and the metric that measures the feeling is **utilization** -- the fraction of available capacity doing useful work. Your instinct is the classic ops instinct: an idle server is money burning, a quota window aging out unused is capacity you paid for evaporating. Cloud providers built entire billing models (spot instances, preemptible VMs) around selling exactly that latency.

But there is a trap on the other side, and it has a name too: **Goodhart''s law** -- when a measure becomes a target, it stops being a good measure. "Tokens burned" is a PROXY for work done. Optimize the proxy directly ("kick off sessions to max out the quota") and you get busywork: parallel sessions doing things nobody needed, which cost your attention to review afterward. Attention, not tokens, is usually the scarce resource.

The version of your instinct that survives the trap: the guilt should attach to the BACKLOG, not the meter. Full commitment looks like always having a queue of real, well-specified tasks ready to dispatch -- so that whenever capacity exists, a genuine task is there to soak it up (the fan-out patterns from entry 1 are the dispatch mechanisms). If the queue is empty, the honest move is writing better tasks, not burning tokens to feel thorough. Utilization is a lagging indicator of a good backlog, not a goal you chase directly.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (137, 'utilization', 'The fraction of available capacity doing useful work -- the ops metric behind the "idle compute = waste" instinct.'),
  (137, 'idle capacity', 'Provisioned-but-unused resources; the standard term for what "latent compute" gestures at. Cloud spot/preemptible pricing exists to sell it off.'),
  (137, 'Goodhart''s law', 'When a measure becomes a target, it ceases to be a good measure -- e.g. chasing "tokens burned" (a proxy for work) produces busywork instead of work.'),
  (137, 'proxy metric', 'A number you optimize because the thing you actually care about is hard to measure. Safe only while the proxy and the target stay correlated.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(137, 'Feeling guilty about unused quota, you spin up parallel sessions on invented tasks to "max utilization." Which concept names the mistake?',
 'Word splitting -- the tasks were split incorrectly',
 'Goodhart''s law -- token burn is a proxy for work done, and optimizing the proxy directly yields busywork',
 'Context isolation -- the sessions should have shared one context',
 'The rolling window -- utilization cannot be measured in rolling windows',
 1,
 'Tokens burned correlates with work done only when tasks are real. Target the proxy itself and the correlation breaks: you pay quota AND the attention to review output nobody needed. Fix the backlog (a queue of genuine tasks), and utilization follows.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(138, '2026-07-07', 5, 'What does a good pre-demo fan-out setup actually look like, step by step?',
'A runbook, not a vibe. The order matters because the expensive mistakes happen at the start (bad tasks) and the end (nothing to show):

1. **Write the backlog FIRST.** One well-specified task per agent: a paragraph of context, an explicit definition of done, and no dependency on any other task in the batch. This is where the commitment actually happens -- everything after is dispatch.

2. **Pick the tier per task** (entry 3''s triad): needs your steering as it goes -> worktree session (`claude -w`); fire-and-forget -> background agent (`claude --bg`); research the main session needs -> subagent. Keep tasks touching DIFFERENT parts of the repo so the fan-in later is clean.

3. **Kick off early.** The 5-hour window starts at your first prompt, so launching an hour before the demo costs nothing extra -- it just means long tasks are finished or visibly mid-flight when the camera is on.

4. **Make the fleet the set dressing.** `claude agents` showing five sessions in Working/Completed states IS the demo -- an arcade would call it attract mode (see 2026-07-02, entry 1): the machine performing before anyone touches it.

5. **Dry-run the finale.** Whatever you plan to show live, have one completed run already in hand from a rehearsal. Live demos fail in ways rehearsals do not -- every presenter knows the superstition as the "demo gods" -- so the rehearsal artifact is your fallback slide.

The through-line: steps 1 and 5 are the ones people skip, and they are the two that distinguish "prepared fan-out" from "burning quota to look busy" (entry 4).');

INSERT INTO vocab (entry_id, term, def) VALUES
  (138, 'runbook', 'A written, ordered procedure for an operation you cannot afford to improvise -- the difference between a repeatable demo and a lucky one.'),
  (138, 'dry run', 'A full rehearsal of the real procedure in advance; its output doubles as your fallback artifact if the live version misbehaves.'),
  (138, 'demo gods', 'Presenter superstition naming the observed law that software fails during live demos in ways it never did in testing -- appeased by rehearsal and fallback artifacts, not hope.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(138, 'Which two steps of a pre-demo fan-out are the ones most often skipped -- and the ones that separate preparation from busywork?',
 'Choosing the CLI flags and naming the worktrees',
 'Writing a well-specified backlog first, and dry-running the finale so a completed artifact exists as fallback',
 'Maximizing session count and starting as late as possible to keep the window fresh',
 'Disabling quota tracking and merging all agents into one session',
 1,
 'Dispatch (flags, tiers, kickoff) is the easy middle. The bookends -- real tasks in, rehearsed artifact out -- are what make the fleet produce a demo instead of token burn. Skipping step 1 recreates the Goodhart trap from entry 4; skipping step 5 leaves you betting the finale on the demo gods.');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(139, '2026-07-07', 6, 'After the fan-out, how does all the parallel work come back together?',
'The return trip is called **fan-in**, and it is the part nobody budgets for. Generation parallelizes; integration and review largely do not.

THE MECHANICS: each worktree session worked on its own branch, so fan-in is ordinary git -- merge or rebase each branch back, one at a time. Background agents likewise leave you branches/diffs plus a final summary. If the tasks were truly independent (different files, different subsystems), merges are clean; if two agents touched the same code, you inherit **merge conflicts** that neither agent knew it was creating, because parallel workers cannot see each other''s in-flight changes.

THE REAL BOTTLENECK: you still have to READ everything. Five agents can generate five diffs simultaneously, but one human reviews them serially -- so total wall-clock is roughly (longest generation) + (SUM of all reviews). Fan-out moves the constraint from Claude''s throughput to your attention; this is entry 4''s "attention is the scarce resource" showing up as schedule math.

GUARDRAILS THAT KEEP FAN-IN CHEAP:
- Orthogonal tasks: partition by directory/subsystem when writing the backlog, so conflicts are structurally impossible.
- Small diffs: many focused tasks beat few sprawling ones -- review time scales with diff size, and badly.
- Evidence over claims: have each agent end with what it changed AND how it verified (tests run, output shown), so review starts from proof instead of trust.
- Integrate as results land rather than batching all merges to the end -- earlier merges shrink the surface later ones can conflict with.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (139, 'fan-in', 'The collection phase after fan-out: merging branches, reconciling conflicts, and reviewing results back into one line of work.'),
  (139, 'integration cost', 'The hidden tax of parallel work -- merging, conflict resolution, and review -- paid AFTER generation finishes, and paid mostly serially.'),
  (139, 'merge conflict', 'Git''s refusal to auto-combine two changes to the same lines; between parallel agents it means two workers unknowingly edited the same code.'),
  (139, 'review bottleneck', 'The point where parallel output funnels through one serial reviewer -- the reason N agents do not make you N times faster.');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(139, 'Five parallel agents each take 30 minutes to generate a diff, and each diff takes you 20 minutes to review. Roughly how long until everything is integrated?',
 'About 30 minutes -- everything ran in parallel',
 'About 50 minutes -- longest generation plus one review, since reviews also parallelize',
 'About 130 minutes -- roughly the longest generation (30) plus five serial reviews (100), because one human reads diffs one at a time',
 'About 250 minutes -- parallel agents always take 5x longer overall',
 2,
 'Generation parallelizes; your reading does not. Wall-clock is about max(generation) + sum(review) -- which is why the fan-in guardrails (orthogonal tasks, small diffs, evidence attached) target REVIEW cost, the term that actually dominates.');

INSERT INTO days (date, kind, title) VALUES
  ('2026-07-08', 'qa', 'A parasite on the produce -- cyclospora, cyclosporiasis, and why it is a food outbreak and not a contagion');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(140, '2026-07-08', 1, 'What is cyclosporiasis and cyclospora?',
'**Cyclospora** (full name *Cyclospora cayetanensis*) is a microscopic single-celled **parasite** -- a protozoan in the coccidian group -- that infects the lining of the human small intestine. **Cyclosporiasis** is the illness it causes. The naming follows a standard pattern: the organism is *Cyclospora*, and the "-iasis" suffix means "the disease of being infected by it" (compare *Giardia* -> *giardiasis*).

HOW YOU GET IT: transmission is **fecal-oral** -- you ingest the parasite in food or water contaminated with infected feces. In practice that means **fresh produce**: documented outbreaks trace to imported raspberries, basil, cilantro, snow peas, and bagged leafy greens. A defining quirk is that it is NOT spread directly person-to-person. When passed in stool the parasite is an **oocyst** that is not yet infectious; it needs days to weeks in the environment to mature (**sporulate**) before it can infect anyone. That maturation delay is exactly why cyclospora appears as produce-and-water outbreaks rather than household contagion.

SYMPTOMS: after roughly a week of incubation -- watery diarrhea that is often **prolonged and relapsing** (weeks-long, coming in waves if untreated), loss of appetite, weight loss, cramping, bloating, nausea, fatigue, sometimes a low-grade fever.

DIAGNOSIS AND TREATMENT: it is easily missed on routine stool tests -- labs must specifically look for it (special ova-and-parasite testing, acid-fast staining, or molecular/PCR panels). Standard treatment is the antibiotic **TMP-SMX** (trimethoprim-sulfamethoxazole; Bactrim/co-trimoxazole), which clears it reliably where it would otherwise linger. Endemic in tropical/subtropical regions; in temperate countries it appears seasonally and via imported produce.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (140, 'protozoan parasite', 'A single-celled eukaryotic organism that lives in/on a host at the host''s expense. Cyclospora is one; so are Giardia and the malaria parasite.'),
  (140, 'coccidian', 'A group of intestinal protozoan parasites (includes Cyclospora and Cryptosporidium) that reproduce via environmentally shed oocysts.'),
  (140, 'oocyst', 'The tough encapsulated stage a coccidian parasite is shed in. For cyclospora it leaves the body NOT yet infectious.'),
  (140, 'sporulation', 'The maturation an oocyst undergoes in the environment (days to weeks) to become infectious -- the delay that makes cyclospora a food/water outbreak rather than a person-to-person contagion.'),
  (140, 'fecal-oral transmission', 'A route where a pathogen shed in feces is ingested via contaminated food, water, or hands.'),
  (140, 'TMP-SMX', 'Trimethoprim-sulfamethoxazole (Bactrim / co-trimoxazole), the standard antibiotic treatment for cyclosporiasis.'),
  (140, '-iasis', 'A medical suffix meaning "diseased condition caused by" -- attached to a parasite name to name its infection (cyclospora -> cyclosporiasis).');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(140, 'Why is cyclosporiasis spread through contaminated produce rather than directly from person to person?',
 'The parasite dies instantly outside a human host, so only fresh contact spreads it',
 'The oocyst shed in stool is not yet infectious and must sporulate in the environment for days to weeks before it can infect someone',
 'It is a virus, and viruses cannot survive on food surfaces',
 'Human stomach acid destroys it unless it is buffered by plant material',
 1,
 'Cyclospora is shed as an immature oocyst that needs days-to-weeks of environmental maturation (sporulation) to become infectious. That built-in delay means a freshly shed parasite cannot infect a nearby person, but it CAN contaminate produce or water that is eaten later -- hence food-and-water outbreaks, not household contagion.');

INSERT INTO days (date, kind, title) VALUES
  ('2026-07-11', 'qa', 'P&L -- the running scoreboard of a trade');

INSERT INTO entries (id, day_date, position, question, answer) VALUES
(141, '2026-07-11', 1, 'In investing, what is P&L?',
'**P&L** stands for **profit and loss** -- the running tally of how much money a position, or a whole portfolio, has made or lost. On a trading dashboard the "P&L" column is just shorthand for "how is this bet doing." It comes in two flavors that matter a lot:

**UNREALIZED P&L** -- the gain or loss on paper for positions you STILL HOLD. Buy a stock at $100, it trades at $120, and you are sitting on +$20 of unrealized profit. The word "unrealized" is the warning label: it is not yours yet. If the price falls back to $105 before you sell, most of that gain evaporates. It is a mark-to-market snapshot, not cash.

**REALIZED P&L** -- the gain or loss LOCKED IN because you actually closed the position (sold, or covered a short). This is the number that truly hits your account balance, and generally the one that triggers a taxable event. Realizing a gain converts paper profit into real profit; realizing a loss makes the loss permanent but can also offset other gains at tax time.

WHERE THE TERM COMES FROM: accounting. A company''s **P&L statement** (a.k.a. income statement) reports revenue minus expenses over a period to show whether the business made money. Traders borrowed the phrase, so in investing "P&L" carries the same meaning -- money in versus money out -- applied to a position instead of a company.

THE ONE THING TO INTERNALIZE: unrealized P&L is a hypothesis about your profit; realized P&L is the verdict. Plenty of traders watch a big unrealized gain and never sell, then give it all back. The number only becomes real when you close the trade.');

INSERT INTO vocab (entry_id, term, def) VALUES
  (141, 'P&L (profit and loss)', 'The net gain or loss on a position or portfolio -- money out versus money in. Borrowed from the accounting "P&L statement."'),
  (141, 'unrealized P&L', 'Paper gain/loss on a position you still hold, based on the current market price. Not cash; it can change or vanish before you sell.'),
  (141, 'realized P&L', 'Gain/loss locked in by closing the position (selling or covering). This is what actually affects your balance and generally what taxes apply to.'),
  (141, 'mark-to-market', 'Valuing an open position at its current market price to compute unrealized P&L, rather than at what you paid.'),
  (141, 'taxable event', 'An action -- typically realizing a gain or loss by selling -- that triggers a tax consequence.'),
  (141, 'P&L statement (income statement)', 'The accounting report of revenue minus expenses over a period; the origin of the trading term "P&L."');

INSERT INTO quizzes (entry_id, prompt, opt_a, opt_b, opt_c, opt_d, answer, explanation) VALUES
(141, 'You bought a stock at $100 and it is now trading at $130, but you have not sold. What kind of P&L is your +$30, and what does that imply?',
 'Realized P&L -- the $30 is already in your account and cannot be lost',
 'Unrealized P&L -- it is a paper gain that can shrink or disappear before you actually sell',
 'A taxable event has occurred, so you owe tax on the $30 now',
 'Nothing -- P&L only exists once per year on a statement',
 1,
 'Because the position is still open, the $30 is UNREALIZED -- a mark-to-market snapshot, not cash. It can grow, shrink, or vanish before you close the trade, and it generally is not taxed until you realize it by selling.');
