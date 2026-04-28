// Run: bun test ./.claude/scripts/statusline-format.test.ts
// @ts-nocheck — Bun runtime types not available to tsserver
import { describe, test, expect } from "bun:test";
import { formatSize, timeRemaining, buildLine1, buildLine2 } from "./statusline-format";

function stripAnsi(str: string): string {
  return str.replace(/\x1b\[[0-9;]*m/g, "");
}

describe("formatSize", () => {
  test("returns plain number for values under 1K", () => {
    expect(formatSize(0)).toBe("0");
    expect(formatSize(999)).toBe("999");
  });
  test("rounds to K for values between 1K and 1M", () => {
    expect(formatSize(1_000)).toBe("1K");
    expect(formatSize(1_500)).toBe("2K");
    expect(formatSize(500_000)).toBe("500K");
  });
  test("rounds to M for values >= 1M", () => {
    expect(formatSize(1_000_000)).toBe("1M");
    expect(formatSize(1_500_000)).toBe("2M");
    expect(formatSize(200_000_000)).toBe("200M");
  });
});

describe("timeRemaining", () => {
  const nowMs = 1_000_000_000 * 1000;

  test("returns empty string when already expired", () => {
    expect(timeRemaining(999_999_999, nowMs)).toBe("");
    expect(timeRemaining(1_000_000_000, nowMs)).toBe("");
  });
  test("returns minutes only when under an hour", () => {
    expect(timeRemaining(1_000_000_000 + 30 * 60, nowMs)).toBe("30m");
    expect(timeRemaining(1_000_000_000 + 59 * 60, nowMs)).toBe("59m");
    expect(timeRemaining(1_000_000_000 + 1 * 60, nowMs)).toBe("1m");
  });
  test("returns hours and minutes when over an hour", () => {
    expect(timeRemaining(1_000_000_000 + 3600, nowMs)).toBe("1h 0m");
    expect(timeRemaining(1_000_000_000 + 3600 + 30 * 60, nowMs)).toBe("1h 30m");
    expect(timeRemaining(1_000_000_000 + 2 * 3600 + 15 * 60, nowMs)).toBe("2h 15m");
  });
});

describe("buildLine1", () => {
  test("includes branch when present", () => {
    const out = stripAnsi(buildLine1({}, "main"));
    expect(out).toContain("🌿 main");
  });
  test("includes turn tokens when both present", () => {
    const out = stripAnsi(buildLine1(
      { context_window: { current_usage: { input_tokens: 100, output_tokens: 50 } } },
      ""
    ));
    expect(out).toContain("📊");
    expect(out).toContain("in:100 out:50");
  });
  test("omits turn tokens when only one side is present", () => {
    const out = stripAnsi(buildLine1(
      { context_window: { current_usage: { input_tokens: 100 } } },
      ""
    ));
    expect(out).not.toContain("📊");
  });
  test("includes context percentage rounded", () => {
    const out = stripAnsi(buildLine1({ context_window: { used_percentage: 42.7 } }, ""));
    expect(out).toContain("🧠 43%");
  });
  test("returns empty string when no data and no branch", () => {
    expect(buildLine1({}, "")).toBe("");
  });
  test("includes total token count", () => {
    const out = stripAnsi(buildLine1(
      { context_window: { total_input_tokens: 5_000, total_output_tokens: 3_000 } },
      ""
    ));
    expect(out).toContain("💬 8K");
  });
  test("joins multiple parts with separator", () => {
    const out = stripAnsi(buildLine1(
      {
        context_window: {
          used_percentage: 10,
          current_usage: { input_tokens: 1, output_tokens: 2 },
        },
      },
      "feat/test"
    ));
    expect(out.split("  |  ").length).toBeGreaterThanOrEqual(2);
  });
});

describe("buildLine2", () => {
  test("includes 5h rate limit without remaining when resets_at is absent", () => {
    const out = stripAnsi(buildLine2({
      rate_limits: { five_hour: { used_percentage: 55.4 } },
    }));
    expect(out).toContain("5h:55%");
    expect(out).not.toContain("(");
  });
  test("includes 5h rate limit with remaining when resets_at is in the future", () => {
    const out = stripAnsi(buildLine2({
      rate_limits: { five_hour: { used_percentage: 40, resets_at: 4_000_000_000 } },
    }));
    expect(out).toContain("5h:40%");
    expect(out).toMatch(/\(\d+h \d+m\)/);
  });
  test("includes 7d rate limit", () => {
    const out = stripAnsi(buildLine2({
      rate_limits: { seven_day: { used_percentage: 30 } },
    }));
    expect(out).toContain("7d:30%");
  });
  test("includes model name without size when context_window_size is absent", () => {
    const out = stripAnsi(buildLine2({ model: { display_name: "Sonnet" } }));
    expect(out).toContain("Sonnet");
  });
  test("includes model name with size", () => {
    const out = stripAnsi(buildLine2({
      model: { display_name: "Sonnet" },
      context_window: { context_window_size: 200_000 },
    }));
    expect(out).toContain("Sonnet 200K");
  });
  test("includes effort when present", () => {
    const out = buildLine2({ effort: { level: "high" } });
    expect(out).toContain("high");
  });
  test("includes session name and id", () => {
    const out = stripAnsi(buildLine2({ session_name: "my-session", session_id: "abc123" }));
    expect(out).toContain("my-session");
    expect(out).toContain("abc123");
  });
  test("returns empty string when no data", () => {
    expect(buildLine2({})).toBe("");
  });
});
