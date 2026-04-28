#!/usr/bin/env bun
// @ts-nocheck — Bun runtime types not available to tsserver
import { spawnSync } from "bun";
import type { StatuslineInput } from "./statusline-format";
import { buildLine1, buildLine2 } from "./statusline-format";

const raw = await Bun.stdin.text();
const data: StatuslineInput = JSON.parse(raw);
const branch = spawnSync(["git", "branch", "--show-current"]).stdout.toString().trim();

process.stdout.write(buildLine1(data, branch) + "\n");
process.stdout.write(buildLine2(data));
