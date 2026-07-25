/**
 * LM Studio model sync extension.
 *
 * Discovers whatever chat models LM Studio currently has downloaded and
 * publishes them as the `lmstudio` provider's model list, so pi's model picker
 * and Ctrl+P cycling stay in sync with LM Studio without hand-editing
 * models.json.
 *
 * Uses LM Studio's native `/api/v0/models` endpoint (richer than the OpenAI
 * compatible `/v1/models`): it reports model `type` (llm / vlm / embeddings)
 * and `max_context_length`, so embedding models can be filtered out and vision
 * models can advertise image input.
 *
 * Actually loading the model is left to LM Studio: with JIT loading enabled
 * (the default) the server loads a model on the first request naming it.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { readFileSync } from "node:fs";
import { join } from "node:path";

const LMSTUDIO_BASE_URL = "http://localhost:1234/v1";
const LMSTUDIO_NATIVE_MODELS = "http://localhost:1234/api/v0/models";

const MODELS_JSON_PATH = join(
  process.env.HOME ?? "",
  ".pi",
  "agent",
  "models.json",
);

const DEFAULT_CONTEXT_WINDOW = 262144;
const MAX_TOKENS = 32768;
const FREE = { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 };

interface LmStudioModel {
  id: string;
  type?: string;
  max_context_length?: number;
}

interface ModelsJsonProvider {
  baseUrl?: string;
  api?: string;
  apiKey?: string;
  compat?: Record<string, unknown>;
}

/** Read the lmstudio provider block from models.json, if present. */
function readLmStudioConfig(): ModelsJsonProvider {
  try {
    const config = JSON.parse(readFileSync(MODELS_JSON_PATH, "utf-8")) as {
      providers?: Record<string, ModelsJsonProvider>;
    };
    return config.providers?.lmstudio ?? {};
  } catch {
    return {};
  }
}

export default function (pi: ExtensionAPI) {
  const cfg = readLmStudioConfig();
  const baseUrl = cfg.baseUrl ?? LMSTUDIO_BASE_URL;

  // An extension's model list *replaces* the models.json list for this
  // provider, so provider-level compat from models.json has to be folded into
  // each model definition here or it is silently dropped.
  const baseCompat = {
    ...(cfg.compat ?? {}),
    thinkingFormat: "qwen-chat-template",
  };

  pi.registerProvider("lmstudio", {
    baseUrl,
    api: (cfg.api ?? "openai-completions") as never,
    apiKey: cfg.apiKey ?? "lmstudio",

    async refreshModels({ signal }: { signal?: AbortSignal }) {
      const response = await fetch(LMSTUDIO_NATIVE_MODELS, { signal });
      const { data } = (await response.json()) as { data: LmStudioModel[] };

      return data
        .filter((m) => m.type === "llm" || m.type === "vlm")
        .map((m) => ({
          id: m.id,
          name: m.id,
          reasoning: true,
          // Required by pi: an undefined `input` blows up every request with
          // "Cannot read properties of undefined (reading 'includes')", and an
          // undefined `cost` breaks usage accounting. Unlike models.json,
          // extension-registered models get no defaults filled in.
          input: (m.type === "vlm"
            ? ["text", "image"]
            : ["text"]) as ("text" | "image")[],
          cost: FREE,
          contextWindow: m.max_context_length ?? DEFAULT_CONTEXT_WINDOW,
          maxTokens: MAX_TOKENS,
          compat: baseCompat as never,
        }));
    },
  });
}
