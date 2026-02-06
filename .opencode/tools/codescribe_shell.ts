import { tool } from "@opencode-ai/plugin"
import { readdirSync, statSync, existsSync, lstatSync } from "node:fs"
import { resolve, relative } from "node:path"

/**
 * Validate that a path is within the root directory (no escape)
 */
function isWithinRoot(targetPath: string, root: string): boolean {
  const resolved = resolve(root, targetPath)
  const rel = relative(root, resolved)
  // If relative path starts with "..", it's outside root
  // An empty rel means it's the root itself (valid)
  return rel === "" || (!rel.startsWith("..") && !rel.startsWith("/"))
}

export default tool({
  name: "codescribe.shell",
  description: `Minimal filesystem operations: pwd, ls, path_info.

Commands:
  - pwd: Returns the current working directory (repository root)
  - ls: Lists entries in a directory (non-recursive)
  - path_info: Check if a path exists and its type (file/dir/symlink)

This tool does NOT execute shell commands. It uses Node.js filesystem APIs only.
No recursive scanning or file filtering is provided.`,

  args: {
    command: tool.schema.enum([
      "pwd",
      "ls",
      "path_info"
    ]).describe("The command to run"),
    path: tool.schema.string().optional().describe("Path for ls or path_info (default: '.' for ls)")
  },

  async execute({ command, path }) {
    const root = process.cwd()

    if (command === "pwd") {
      return JSON.stringify({ cwd: root }, null, 2)
    }

    if (command === "path_info") {
      if (!path) {
        return JSON.stringify({ error: "path parameter is required for path_info command" }, null, 2)
      }

      const resolvedPath = resolve(root, path)

      if (!isWithinRoot(path, root)) {
        return JSON.stringify({
          path,
          exists: false,
          kind: null,
          error: "Path is outside repository root"
        }, null, 2)
      }

      if (!existsSync(resolvedPath)) {
        return JSON.stringify({ path, exists: false, kind: null }, null, 2)
      }

      try {
        const lstats = lstatSync(resolvedPath)
        let kind: "file" | "dir" | "symlink" | "other" = "other"
        if (lstats.isSymbolicLink()) kind = "symlink"
        else if (lstats.isFile()) kind = "file"
        else if (lstats.isDirectory()) kind = "dir"

        return JSON.stringify({ path, exists: true, kind }, null, 2)
      } catch {
        return JSON.stringify({ path, exists: false, kind: null }, null, 2)
      }
    }

    if (command === "ls") {
      const targetPath = path || "."
      const resolvedPath = resolve(root, targetPath)

      if (!isWithinRoot(targetPath, root)) {
        return JSON.stringify({
          error: "Path is outside repository root",
          path: targetPath
        }, null, 2)
      }

      if (!existsSync(resolvedPath)) {
        return JSON.stringify({
          error: "Path does not exist",
          path: targetPath
        }, null, 2)
      }

      try {
        const stats = statSync(resolvedPath)
        if (!stats.isDirectory()) {
          return JSON.stringify({
            error: "Path is not a directory",
            path: targetPath
          }, null, 2)
        }

        const entries = readdirSync(resolvedPath, { withFileTypes: true })
        const items: Array<{ name: string; kind: "file" | "dir" | "symlink" | "other" }> = []

        for (const entry of entries) {
          const fullPath = resolve(resolvedPath, entry.name)
          let kind: "file" | "dir" | "symlink" | "other" = "other"

          try {
            const lstats = lstatSync(fullPath)
            if (lstats.isSymbolicLink()) kind = "symlink"
            else if (lstats.isFile()) kind = "file"
            else if (lstats.isDirectory()) kind = "dir"
          } catch {
            kind = "other"
          }

          items.push({ name: entry.name, kind })
        }

        // Sort entries: directories first, then files, alphabetically within each group
        items.sort((a, b) => {
          if (a.kind === "dir" && b.kind !== "dir") return -1
          if (a.kind !== "dir" && b.kind === "dir") return 1
          return a.name.localeCompare(b.name)
        })

        return JSON.stringify({
          path: targetPath,
          entries: items,
          count: items.length
        }, null, 2)
      } catch (err) {
        return JSON.stringify({
          error: `Failed to list directory: ${err}`,
          path: targetPath
        }, null, 2)
      }
    }

    return JSON.stringify({ error: `Unknown command: ${command}` }, null, 2)
  }
})
