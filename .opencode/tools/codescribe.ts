import { tool } from "@opencode-ai/plugin"
import { spawnSync } from "node:child_process"

export default tool({
  description: "Run CodeScribe CLI commands",

  args: {
    command: tool.schema.enum([
      "index",
      "inspect",
      "draft",
      "generate",
      "translate",
      "format",
      "update"
    ]),
    args: tool.schema.array(tool.schema.string()).default([]),
    cwd: tool.schema.string().optional()
  },

  async execute({ command, args, cwd }) {
    const proc = spawnSync(
      "code-scribe",
      [command, ...args],
      {
        cwd,
        encoding: "utf-8"
      }
    )

    return [
      `exitCode: ${proc.status}`,
      proc.stdout?.trim() ?? "",
      proc.stderr?.trim() ?? ""
    ].filter(Boolean).join("\n")
  }
})
