-- Source of truth for archive.db.
-- Edit this file. Then run `npm run db:build` (or just `npm run dev`).
-- All tables are dropped and recreated; no migrations to maintain.

PRAGMA foreign_keys = ON;

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

-- =====================================================
-- Days
-- =====================================================

INSERT INTO days (date, kind, title) VALUES
  ('2026-06-03', 'manual', 'Salesman School, Volume I'),
  ('2026-06-04', 'qa',     'Kernels, containers, daemons, distros'),
  ('2026-06-06', 'qa',     'Automation runbooks'),
  ('2026-06-07', 'qa',     'Shells, PATH, binaries, network interfaces');

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
