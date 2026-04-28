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

export function formatK(n: number): string {
  if (n >= 1_000) return `${Math.round(n / 1_000)}K`;
  return String(n);
}

export function timeRemaining(resets_at: number, now = Date.now()): string {
  const diff = resets_at - Math.floor(now / 1000);
  if (diff <= 0) return "";
  const h = Math.floor(diff / 3600);
  const m = Math.floor((diff % 3600) / 60);
  return h > 0 ? `${h}h ${m}m` : `${m}m`;
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
    parts.push(`💬 ${formatK(totalIn + totalOut)}`);
  }
  if (ctxUsed != null) {
    parts.push(`🧠 ${c.purple}${Math.round(ctxUsed)}%${c.reset}`);
  }
  return parts.join("  |  ");
}

export function buildLine2(data: StatuslineInput): string {
  const parts: string[] = [];
  const model      = data.model?.display_name ?? "";
  const ctxSize    = data.context_window?.context_window_size;
  const effort     = data.effort?.level ?? "";
  const rl5hPct    = data.rate_limits?.five_hour?.used_percentage;
  const rl5hResets = data.rate_limits?.five_hour?.resets_at;
  const sessionId  = data.session_id ?? "";
  const sessionName = data.session_name ?? "";

  if (rl5hPct != null) {
    const pct = Math.round(rl5hPct);
    const remaining = rl5hResets ? timeRemaining(rl5hResets) : "";
    const label = remaining ? `5h:${pct}% (${remaining})` : `5h:${pct}%`;
    parts.push(`⏱ ${c.yellow}${label}${c.reset}`);
  }
  const rl7dPct    = data.rate_limits?.seven_day?.used_percentage;
  const rl7dResets = data.rate_limits?.seven_day?.resets_at;
  if (rl7dPct != null) {
    const pct = Math.round(rl7dPct);
    const remaining = rl7dResets ? timeRemaining(rl7dResets) : "";
    const label = remaining ? `7d:${pct}% (${remaining})` : `7d:${pct}%`;
    parts.push(`⏱ ${c.yellow}${label}${c.reset}`);
  }
  if (model) {
    const sizeStr = ctxSize ? ` ${formatSize(ctxSize)}` : "";
    parts.push(`${c.cyan}${model}${sizeStr}${c.reset}`);
  }
  if (effort) {
    parts.push(effort);
  }
  if (sessionName) {
    parts.push(`${c.cyan}${sessionName}${c.reset}`);
  }
  if (sessionId) {
    parts.push(`${c.yellow}${sessionId}${c.reset}`);
  }
  return parts.join("  |  ");
}
