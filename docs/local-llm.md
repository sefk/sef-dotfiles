# 2026-07-06

## Why move off ollama

Prompted by <https://sleepingrobots.com/dreams/stop-using-ollama/>. Its
complaints, cross-checked and basically legit:

- Built on llama.cpp without attribution for over a year (MIT license
  requires the notice).
- ~1.8x slower than raw llama.cpp on identical hardware/models.
- Modelfile system reinvents what GGUF's single-file format already solves.
- Registry restricts quantization formats and creates lock-in via
  hash-named blob storage (see below — hit this directly during migration).
- A credential-leak CVE (2025-51471) sits oddly next to "local-first"
  positioning.

Article's suggested alternatives: llama.cpp, LM Studio, llamafile, Jan,
koboldcpp, ramalama.

## What Simon Willison (simonwillison.net) actually does

He doesn't pick one tool — runs Ollama, LM Studio, and llama.cpp side by
side depending on task, plus his own `llm` CLI as a provider-agnostic
frontend. Also runs an M3 Ultra Mac Studio (256GB), same class of machine
as this one.

- **LM Studio**: casual GGUF testing, vision/multimodal models. No real
  complaints about the proprietary bits; notes it went free-for-commercial
  in July 2025.
- **Ollama**: everyday/easy model management.
- **llama.cpp / `llama-server` directly**: his pick for "serious inference
  work" — plain OpenAI-compatible server, e.g.
  `llama-server -hf ggml-org/gpt-oss-20b-GGUF --ctx-size 0 --jinja`.
  The `--jinja` flag is his fix for chat-template correctness — directly
  relevant to the `qwen3-coder:30b` tool-calling breakage we'd already
  hit under ollama (his words: "fragility remains in the harness — chat
  templates and prompt construction").

Net effect on the decision: nothing here ruled out LM Studio, but
`llama-server` is a legitimate lower-friction alternative for the
headless-server piece specifically, if LM Studio's Anthropic-endpoint
convenience (below) ever stops paying for itself.

## Decision: LM Studio via `llmster`, not the GUI app

This machine (studio) is reached only over SSH. That ruled out the
straightforward install paths:

- **Homebrew cask (`lm-studio`)** just installs the same `LM Studio.app`
  bits as a manual download — brew doesn't even manage its updates
  (the cask is `auto_updates`). No benefit over what was already installed.
- **The bundled `lms` CLI** (inside the GUI app) only gets wired onto
  `PATH` by running `lms bootstrap` *after first launching the GUI app* —
  which needs an active window-server session. Awkward-to-impossible
  over pure SSH.

Instead: **`llmster`**, LM Studio's actual headless distribution, built
for servers/CI/no-GUI boxes. Installs the daemon + `lms` CLI directly,
no Electron app involved.

```sh
curl -fsSL https://lmstudio.ai/install.sh | bash
lms daemon up
```

Bonus finding: LM Studio 0.4.1+ exposes a **native Anthropic-compatible
`/v1/messages` endpoint** — `claude-local` became a near drop-in swap,
no OpenAI→Anthropic translation shim needed. This is the main practical
win over plain `llama-server`, which only speaks OpenAI-style.

### What we did

1. Moved `/Applications/LM Studio.app` to `~/.Trash` (recoverable, not
   deleted outright).
2. Installed `llmster` via the script above; added
   `export PATH="$PATH:$HOME/.lmstudio/bin"` to `zshrc`.
3. Added `launchd/com.sefk.llmster.plist` (mirrors the existing
   claude-backup/claude-nightly/agentsview pattern) so the daemon starts
   on every login without the GUI app. Key detail: `lms daemon up` starts
   llmster in the background and exits immediately — so the plist uses
   `RunAtLoad = true`, `KeepAlive = false` (not a supervised long-running
   process; the daemon persists independently once started).
   ```sh
   make ~/Library/LaunchAgents/com.sefk.llmster.plist
   launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/com.sefk.llmster.plist
   ```

## Can ollama and LM Studio share a models directory?

No — tried to find a shortcut here and it doesn't exist.

1. **Format mismatch.** Ollama stores models as content-addressed blobs
   named by hash with no extension (`~/.ollama/models/blobs/sha256-...`),
   referenced by a separate manifest. LM Studio's scanner expects real
   filenames (`.gguf`, or an MLX folder with `config.json`/tokenizer
   files) — it can't parse ollama's manifest format.
2. **Ownership conflicts.** Both tools assume they exclusively own their
   models directory (GC on removal, live rescans, in-flight partial
   writes). Pointing both at the same live directory risks one yanking a
   file out from under the other.

### The MLX-served model turned out to be unrecoverable anyway

Inspected `~/.ollama/models/manifests/registry.ollama.ai/library/qwen3.6/35b-a3b-mxfp8`
directly. Because ollama served this one through `--mlx-engine`
(confirmed via `ps -ef`: `ollama runner --mlx-engine --model
qwen3.6:35b-a3b-mxfp8 --port 54611`), it isn't a single GGUF blob —
it's fragmented into **hundreds of individual per-tensor blobs**
(`application/vnd.ollama.image.tensor`, each layer/tensor separately
content-hashed, e.g. `language_model.model.layers.0.linear_attn.in_proj_qkv.weight`).
No ollama export command reassembles that into anything LM Studio (or
anything else) could load. Re-downloading was the only real option for
this model.

By contrast, the other ollama models on this box —
`gemma3:27b`, `qwen3-coder:30b`, `qwen2.5-coder:32b`, `qwen3:32b` — are
plain single-file GGUFs under the hood (verified `GGUF` magic bytes on
the blob directly). Those *are* reusable, cheaply, via:

```sh
lms import <path-to-ollama-blob> --hard-link --user-repo <user/repo> -y
```

`--hard-link` registers the file into LM Studio's store without copying
or watching a live shared directory — safe, one-time, zero extra disk.
(Not yet done for these — noted here for when/if they're needed in LM
Studio.)

## Context window

Qwen3.6-35B-A3B natively supports **262,144 tokens**, extensible via
RoPE scaling to ~1,010,000 — not a separate downloadable variant, just a
runtime setting. Qwen's own guidance: keep context ≥128k even for short
conversations, or reasoning/"thinking" quality reportedly degrades.
Going to the full 1M would be architecturally possible but the KV-cache
memory cost is impractical against 64GB unified memory alongside a 35B
model — 262144 (the native max) is the practical ceiling here.

Set as the **global default** (not per-load) in
`~/.lmstudio/settings.json`:

```json
"defaultContextLength": { "type": "custom", "value": 262144 }
```

No `lms` CLI command exposes this — it's a hand-edit only. Stopped the
daemon first so it wouldn't get overwritten on next write-back:

```sh
lms daemon down
# edit ~/.lmstudio/settings.json
lms daemon up
```

## Downloading and loading the model

```sh
lms get qwen/qwen3.6-35b-a3b --mlx -y     # MLX build, matches old ollama mxfp8 quant
lms load qwen/qwen3.6-35b-a3b --context-length 262144 --gpu max -y
lms server start --port 1234
```

Gotchas hit along the way:

- `lms get ... --select` (interactive variant picker) **requires a real
  TTY** — doesn't work piped/non-interactive. Use plain `-y` to accept
  the hardware-preselected default instead.
- The download looked stalled at ~80% (3MB/s, 22min ETA) — this was
  checksum verification on the tail end reading as near-zero progress,
  not an actual network stall. Confirmed by cancelling and re-running:
  `lms get` immediately reported "Everything is already downloaded."
- `lms load` printed `Error: Model loading was stopped due to
  insufficient system resources` — but `lms ps` showed the model loaded
  successfully anyway (full 262144 context, 37.75GB). Read `lms ps`
  output as ground truth over the CLI's own exit-time error message when
  they disagree.

## Reconfigured to point at LM Studio instead of ollama

**`claude-local`** (`bash_startup/claude.sh`):
- `ANTHROPIC_BASE_URL`: `http://localhost:11434` → `http://localhost:1234`
- `ANTHROPIC_AUTH_TOKEN`: `ollama` → `lmstudio`
- default `--model`: `qwen3.6:35b-a3b-mxfp8` → `qwen/qwen3.6-35b-a3b`
- LAN override comment updated: `lms server start --bind 0.0.0.0`
  instead of `OLLAMA_HOST=0.0.0.0`.

**`pi`** (separate multi-provider coding-agent CLI, `/opt/homebrew/bin/pi`,
config at `~/.pi/agent/` — not part of this dotfiles repo, live app
config):
- `~/.pi/agent/models.json`: replaced the `ollama` provider block with
  an `lmstudio` one (`baseUrl: http://localhost:1234/v1`,
  `api: openai-completions`, `apiKey: lmstudio`, model id
  `qwen/qwen3.6-35b-a3b`).
- `~/.pi/agent/settings.json`: `defaultProvider`/`defaultModel` updated
  to match.

Both verified end-to-end with real prompts (`claude-local --print ...`,
`pi --print ...`) — both came back correctly.

Tool-calling behavior notes carried over from the ollama era
(`qwen3.6:35b-a3b-mxfp8` tool-calls work but code judgments can be
confidently wrong; `qwen3-coder:30b` was flat-out broken via ollama's
chat-template path) **need re-validation** under LM Studio's serving
stack — that's a different backend and may behave differently either
direction.

## Resource check while the model is loaded/generating

Verdict: healthy, not under real pressure, despite a 37.75GB model +
262144 context resident on a 64GB machine.

The reliable signal is **`sysctl kern.memorystatus_vm_pressure_level`**
(1 = normal, 2 = warning, 4 = critical) — this is macOS's own real-time
classifier and should be trusted over raw `vm_stat`/swap numbers, which
can look alarming on a healthy system:

- Low "pages free" alone doesn't mean much — macOS aggressively uses
  "free" RAM for caching/compression by design.
- A large cumulative "swap used" figure (`sysctl vm.swapusage`) can be
  leftover from past pressure (uptime here was 10 days). What matters is
  whether swap is **actively growing right now** — sample
  `vm_stat`'s `Swapins`/`Swapouts` twice a few seconds apart; flat deltas
  mean no live thrashing.
- Also worth checking: `uptime` load average against core count, and
  `pmset -g therm` for thermal throttling.

Also noteworthy: `ps` showed the actual model worker process
(`llmworker.js`) using only ~4.5GB RSS despite the model being 37.75GB —
not a real discrepancy. On Apple Silicon, MLX's Metal-backed weight
buffers are wired into unified memory outside normal per-process RSS
accounting, so the real footprint shows up in system-wide **wired
memory** instead of that process's own number. Don't use `ps` RSS to
judge an MLX model's actual footprint — check `lms ps`'s reported size
and system-wide wired pages instead.

## Left for later

- Ollama is still installed and running alongside LM Studio — not
  decommissioned yet, kept as a fallback while the new path gets
  exercised for real.
- The four reusable GGUF models sitting in ollama's blob store
  (`gemma3:27b`, `qwen3-coder:30b`, `qwen2.5-coder:32b`, `qwen3:32b`)
  haven't been hard-link-imported into LM Studio yet — only worth doing
  if/when actually needed there.
- Loaded model has a 1-hour idle TTL (`jitModelTTL`, inherited default) —
  fine for now, but worth revisiting if the reload-on-cold-start cost
  becomes annoying.

## Useful `lms` command reference

```sh
lms daemon up|down|status         # the llmster background service itself
lms get <user/repo> [--mlx|--gguf] [-y]   # search/download a model
lms load <model-key> [-c <ctx>] [--gpu max|off|0-1] [--identifier <name>]
lms unload [--all]
lms ps                             # models currently resident in memory
lms ls                             # models on disk
lms import <file> [--hard-link|--copy|--symbolic-link] [--user-repo <u/r>]
lms server start|stop|status [--port <p>] [--bind 0.0.0.0]
```
