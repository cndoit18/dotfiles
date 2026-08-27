// memory-palace extension — 会话开始时注入 Obsidian vault 索引上下文。
// 对应原 Claude Code 的 SessionStart hook（hooks/memory-palace.sh）。
// 每个 session 只注入一次：vault 索引随会话持久化，无需逐 turn 重建。

import { spawnSync } from "node:child_process";
import type { ExtensionAPI, ExtensionContext } from "@earendil-works/pi-coding-agent";

const INTRO = `# Memory Palace

The vault below is a curated LLM Wiki. When the user's question touches on any topic, system, component, or concept that matches or relates to a note listed in the vault index, delegate a query to the \`memory-palace\` agent before answering. The agent will search the vault and return evidence-grounded answers with provenance.

When to query:
- The user mentions any name, term, or concept that appears in a vault note title or path below
- The user asks about how something works, why a decision was made, or what the current status is
- The user asks you to create or update a note
- You are about to state a fact that the vault may already document

How to query: send the user's original question or a short description of what you need to know. Do NOT try to classify the domain or aspect yourself — the memory-palace agent will infer the right domain and search strategy from the vault structure. Example: "the user wants to know how the control plane works" or "check if we already have notes about monitoring dashboards before creating a new one"`;

function isObsidianNoise(line: string): boolean {
	return (
		line.trim().length === 0 ||
		line.includes("Loading updated app package") ||
		line.includes("installer is out of date")
	);
}

function quotePath(path: string): string {
	return `"${path.replaceAll("\\", "\\\\").replaceAll('"', '\\"')}"`;
}

/** 调用 Obsidian CLI，失败返回 undefined。 */
function obsidian(args: string[]): string | undefined {
	try {
		const result = spawnSync("obsidian", args, {
			encoding: "utf8",
			timeout: 5000,
		});
		if (result.error || result.status !== 0) return undefined;
		return result.stdout ?? "";
	} catch {
		return undefined;
	}
}

function buildContext(): string {
	const vaultsOutput = obsidian(["vaults", "verbose"]);
	if (vaultsOutput === undefined) return "";

	const entries = new Map<string, string>(); // vault -> path
	for (const line of vaultsOutput.split("\n")) {
		if (isObsidianNoise(line)) continue;
		const [vault, ...rest] = line.split("\t");
		if (!vault || entries.has(vault)) continue;
		entries.set(vault, rest.join("\t"));
	}

	if (entries.size === 0) {
		return `${INTRO}\n\nMemory Palace cache is unavailable: Obsidian CLI returned no vaults.\n`;
	}

	const sections: string[] = [INTRO];
	for (const [vault, vaultPath] of entries) {
		let header = `## Vault: ${vault} (obsidian: ${vault}`;
		if (vaultPath) header += `, path: ${quotePath(vaultPath)}`;
		header += ")";
		const lines: string[] = [header];

		const filesOutput = obsidian(["files", `vault=${vault}`, "ext=md"]);
		if (filesOutput !== undefined) {
			for (const path of filesOutput.split("\n")) {
				if (isObsidianNoise(path)) continue;
				let entry = `- ${quotePath(path)}`;
				if (vaultPath) entry += ` (path: ${quotePath(`${vaultPath.replace(/\/$/, "")}/${path}`)})`;
				lines.push(entry);
			}
		} else {
			lines.push("Unavailable: failed to list Markdown files.");
		}
		sections.push(lines.join("\n"));
	}
	return sections.join("\n\n") + "\n";
}

const injected = new Set<string>();

export default function memoryPalaceExtension(pi: ExtensionAPI): void {
	pi.on("before_agent_start", async (_event, ctx: ExtensionContext) => {
		const sessionId = ctx.sessionManager.getSessionId();
		if (!sessionId || injected.has(sessionId)) return;
		injected.add(sessionId);

		const content = buildContext();
		if (!content) return;
		return {
			message: {
				customType: "memory-palace",
				content,
				display: false,
			},
		};
	});
}
