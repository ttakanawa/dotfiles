export interface StatuslineInput {
  model?: { display_name?: string };
  context_window?: {
    used_percentage?: number;
    context_window_size?: number;
    current_usage?: { input_tokens?: number; output_tokens?: number };
    total_input_tokens?: number;
    total_output_tokens?: number;
  };
  effort?: { level?: string };
  rate_limits?: {
    five_hour?: { used_percentage?: number; resets_at?: number };
    seven_day?: { used_percentage?: number; resets_at?: number };
  };
  session_id?: string;
  session_name?: string;
}

const c = {
  green:  "\x1b[0;32m",
  yellow: "\x1b[0;33m",
  cyan:   "\x1b[0;36m",
  purple: "\x1b[0;35m",
  reset:  "\x1b[0m",
};

export function formatSize(n: number): string {
  if (n >= 1_000_000) return `${Math.round(n / 1_000_000)}M`;
  if (n >= 1_000)     return `${Math.round(n / 1_000)}K`;
  return String(n);
}

/** Auto-detect the system timezone abbreviation (e.g. "JST", "PST"). */
function systemTzAbbr(date: Date): string {
  // Intl.DateTimeFormat with "short" timeZoneName produces e.g. "JST" or "GMT+9".
  const fmt = new Intl.DateTimeFormat("en-US", { timeZoneName: "short" });
  const parts = fmt.formatToParts(date);
  return parts.find((p) => p.type === "timeZoneName")?.value ?? "";
}

/**
 * Format a Unix epoch (seconds) as a human-readable reset time.
 * - includeDate=true  → "May 21 6:59pm JST"
 * - includeDate=false → "6:59pm JST"
 */
export function formatResetTime(resets_at: number, includeDate = true): string {
  const date = new Date(resets_at * 1000);
  const tzAbbr = systemTzAbbr(date);

  const timePart = date
    .toLocaleString("en-US", { hour: "numeric", minute: "2-digit", hour12: true })
    .replace(" ", "")   // "6:59 PM" → "6:59PM"
    .toLowerCase();     // "6:59pm"

  if (!includeDate) {
    return tzAbbr ? `${timePart} ${tzAbbr}` : timePart;
  }

  const month = date.toLocaleString("en-US", { month: "short" }); // "May"
  const day   = date.getDate();                                    // 21
  const dateStr = `${month} ${day}`;
  return tzAbbr ? `${dateStr} ${timePart} ${tzAbbr}` : `${dateStr} ${timePart}`;
}

function formatRateLimit(
  label: string,
  pct: number | undefined,
  resetsAt: number | undefined,
  includeDate = true,
): string {
  if (pct == null) return "";
  const rounded = Math.round(pct);
  const resetStr = resetsAt ? formatResetTime(resetsAt, includeDate) : "";
  const text = resetStr ? `${label}:${rounded}% (reset: ${resetStr})` : `${label}:${rounded}%`;
  return `⏱ ${c.yellow}${text}${c.reset}`;
}

export function buildLine1(data: StatuslineInput, branch: string): string {
  const parts: string[] = [];
  const ctxUsed  = data.context_window?.used_percentage;
  const turnIn   = data.context_window?.current_usage?.input_tokens;
  const turnOut  = data.context_window?.current_usage?.output_tokens;
  const totalIn  = data.context_window?.total_input_tokens;
  const totalOut = data.context_window?.total_output_tokens;

  if (branch) {
    parts.push(`${c.green}🌿 ${branch}${c.reset}`);
  }
  if (turnIn != null && turnOut != null) {
    parts.push(`📊 ${c.yellow}in:${turnIn} out:${turnOut}${c.reset}`);
  }
  if (totalIn != null && totalOut != null) {
    parts.push(`💬 ${c.cyan}${formatSize(totalIn + totalOut)}${c.reset}`);
  }
  if (ctxUsed != null) {
    parts.push(`🧠 ${c.purple}${Math.round(ctxUsed)}%${c.reset}`);
  }
  return parts.join("  |  ");
}

export function buildLine2(data: StatuslineInput): string {
  const parts: string[] = [];
  const model   = data.model?.display_name ?? "";
  const ctxSize = data.context_window?.context_window_size;
  const effort  = data.effort?.level ?? "";

  if (model) {
    const sizeStr = ctxSize ? ` ${formatSize(ctxSize)}` : "";
    parts.push(`${c.cyan}${model}${sizeStr}${c.reset}`);
  }
  if (effort) {
    parts.push(`${c.cyan}${effort}${c.reset}`);
  }
  return parts.join("  |  ");
}

export function buildLine3(data: StatuslineInput): string {
  const parts: string[] = [];
  const sessionId   = data.session_id ?? "";
  const sessionName = data.session_name ?? "";

  if (sessionId) {
    parts.push(`${c.yellow}${sessionId}${c.reset}`);
  }
  if (sessionName) {
    parts.push(`${c.cyan}${sessionName}${c.reset}`);
  }
  return parts.join("  |  ");
}

export function buildLine4(data: StatuslineInput): string {
  const parts: string[] = [];
  const rl5h = data.rate_limits?.five_hour;
  const rl7d = data.rate_limits?.seven_day;
  const rl5 = formatRateLimit("5h", rl5h?.used_percentage, rl5h?.resets_at, false);
  const rl7 = formatRateLimit("7d", rl7d?.used_percentage, rl7d?.resets_at, true);
  if (rl5) parts.push(rl5);
  if (rl7) parts.push(rl7);
  return parts.join("  |  ");
}
