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
  ('2026-06-04', 'qa',     'Kernels, containers, daemons, distros');

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
