import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { Type } from "typebox";

// ─── Types ───────────────────────────────────────────────────────────────────

export const WebSearchInput = Type.Object({
  query: Type.String({ description: "Search query" }),
  maxResults: Type.Optional(
    Type.Number({ default: 5, minimum: 1, maximum: 20, description: "Max results to return" })
  ),
});

export const WebFetchInput = Type.Object({
  url: Type.String({ description: "URL to fetch" }),
  maxChars: Type.Optional(
    Type.Number({ default: 10000, minimum: 1000, maximum: 100000, description: "Max characters to return" })
  ),
});

// ─── Helpers ───────────────────────────────────────────────────────────────────

/** Search DuckDuckGo (HTML version) and extract result snippets */
async function duckduckgoSearch(query: string, maxResults: number): Promise<Array<{ title: string; url: string; snippet: string }>> {
  const url = `https://html.duckduckgo.com/html/?q=${encodeURIComponent(query)}`;
  const resp = await fetch(url, {
    headers: { "User-Agent": "Mozilla/5.0 (Pi-WebTools/1.0)" },
  });
  const html = await resp.text();

  const results: Array<{ title: string; url: string; snippet: string }> = [];

  // Extract all title links, URL links, and snippets separately, then pair by index
  const titleRe = /class="result__a"[^>]*href="([^"]*)"[^>]*>([^<]+)<\/a>/g;
  const urlRe = /class="result__url"[^>]*href="([^"]*)"[^>]*>([^<]+)<\/a>/g;
  const snippetRe = /class="result__snippet"[^>]*href="[^"]*"[^>]*>([^<]+)<\/a>/g;

  const titles: Array<{ href: string; text: string }> = [];
  const urls: Array<{ href: string; text: string }> = [];
  const snippets: Array<{ text: string }> = [];

  let m;
  while ((m = titleRe.exec(html)) !== null) {
    titles.push({ href: m[1].trim(), text: m[2].trim() });
  }
  while ((m = urlRe.exec(html)) !== null) {
    urls.push({ href: m[1].trim(), text: m[2].trim() });
  }
  while ((m = snippetRe.exec(html)) !== null) {
    snippets.push({ text: m[1].trim() });
  }

  // Pair by index (pad shorter arrays)
  const maxLen = Math.max(titles.length, urls.length, snippets.length);
  for (let i = 0; i < maxLen && results.length < maxResults; i++) {
    const t = titles[i] || { href: "", text: "" };
    const u = urls[i] || { href: "", text: "" };
    const s = snippets[i] || { text: "" };
    results.push({
      title: t.text,
      url: u.href,
      snippet: s.text,
    });
  }

  return results.slice(0, maxResults);
}

/** Fetch a URL and extract readable text content */
async function fetchText(url: string, maxChars: number): Promise<string> {
  const resp = await fetch(url, {
    headers: { "User-Agent": "Mozilla/5.0 (Pi-WebTools/1.0)" },
  });
  const html = await resp.text();

  // Strip scripts, styles, and HTML tags; preserve paragraphs and lists
  let text = html
    .replace(/<script[\s\S]*?<\/script>/gi, "")
    .replace(/<style[\s\S]*?<\/style>/gi, "")
    .replace(/<br\s*\/?>/gi, "\n")
    .replace(/<p[^>]*>/gi, "\n\n")
    .replace(/<li[^>]*>/gi, "\n  - ")
    .replace(/<[^>]+>/g, " ")
    .replace(/\s+/g, " ")
    .trim();

  return text.slice(0, maxChars);
}

// ─── Extension ─────────────────────────────────────────────────────────────────

export default function (pi: ExtensionAPI) {
  // web_search tool
  pi.registerTool({
    name: "web_search",
    label: "Web Search",
    description: "Search the web using DuckDuckGo and return results with titles, URLs, and snippets",
    parameters: WebSearchInput,
    async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
      const results = await duckduckgoSearch(params.query, params.maxResults);
      const content = results.length > 0
        ? results.map((r, i) => `[${i + 1}] ${r.title}\n${r.url}\n${r.snippet}`).join("\n\n")
        : "No results found.";

      return {
        content: [{ type: "text", text: content }],
        details: { resultCount: results.length },
      };
    },
  });

  // web_fetch tool
  pi.registerTool({
    name: "web_fetch",
    label: "Web Fetch",
    description: "Fetch a URL and extract readable text content, stripping scripts and styles",
    parameters: WebFetchInput,
    async execute(_toolCallId, params, signal, _onUpdate, _ctx) {
      const text = await fetchText(params.url, params.maxChars);
      return {
        content: [{ type: "text", text }],
        details: { charCount: text.length },
      };
    },
  });
}
