/**
 * Lean Tools - Single-line, background-less rendering for built-in tools.
 *
 * Overrides renderCall/renderResult for every built-in tool (read, bash, edit,
 * write, grep, find, ls) so each tool row collapses to one tight line and
 * loses the default boxed background and 1-line top/bottom padding.
 *
 * - renderShell: "self" removes the Box(1, 1, theme.bg("toolPendingBg", ...))
 *   that normally wraps the row. The tool controls its own padding (0, 0).
 * - Default view: `bold title · accent target · dim meta`. No body shown.
 * - Expanded view (Ctrl+O): body appears below, still tight (no background,
 *   no horizontal padding) and truncated to ~20 lines.
 * - Errors are red; the first line of the error is shown when one exists.
 *
 * Built-in execution is preserved by delegating to createXxxTool() and reusing
 * its .execute(). Registering a tool with the same name as a built-in replaces
 * the built-in entirely, so we re-declare description + parameters from the
 * original to keep the schema identical.
 */

import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import {
  type BashToolDetails,
  createBashTool,
  createEditTool,
  createFindTool,
  createGrepTool,
  createLsTool,
  createReadTool,
  createWriteTool,
  type EditToolDetails,
  type FindToolDetails,
  type GrepToolDetails,
  type LsToolDetails,
  type ReadToolDetails,
  type TruncationResult,
} from "@earendil-works/pi-coding-agent";
import { Text } from "@earendil-works/pi-tui";
import path from "node:path";

// ---------------------------------------------------------------------------
// Tiny helpers
// ---------------------------------------------------------------------------

/**
 * Show a path relative to `cwd` when it's inside the working directory, and
 * keep it absolute otherwise. Resolves relative inputs against `cwd` first.
 * Returns "." for the cwd itself.
 */
function relativize(p: string | undefined, cwd: string): string {
  if (!p) return ".";
  const abs = path.isAbsolute(p) ? p : path.resolve(cwd, p);
  const rel = path.relative(cwd, abs);
  // `..` prefix or absolute result means the file is outside cwd.
  if (rel.startsWith("..") || path.isAbsolute(rel)) return abs;
  return rel || ".";
}

/**
 * Truncate a string to at most `max` display cells, keeping the end (most
 * informative for paths/commands). Adds "…" as the ellipsis prefix.
 */
function clipRight(s: string, max: number): string {
  if (max <= 1) return "…";
  if (s.length <= max) return s;
  return "…" + s.slice(s.length - (max - 1));
}

/**
 * Strip pi's trailing bracket-notice lines (truncation/limit messages) so
 * they don't inflate line counts or leak into single-line summaries.
 * Examples: "[Showing lines 100-412 of 412. Full output: /tmp/...]",
 *           "[Truncated: showing 100 of 412 lines ...]".
 */
function stripFooterNotices(text: string): string {
  return text
    .replace(/\n*\n\[[^\]]*\]+\s*$/g, "")
    .replace(/\n?\[[^\]]*\]+\s*$/g, (m) => (m.includes("\n") ? "" : m));
}

/** Count non-empty, non-notice lines in a string. */
function countContentLines(text: string): number {
  const cleaned = stripFooterNotices(text);
  if (!cleaned) return 0;
  let n = 0;
  for (const line of cleaned.split("\n")) {
    const t = line.trim();
    if (!t) continue;
    if (/^\[.*\]$/.test(t)) continue;
    n++;
  }
  return n;
}

/** Plain content lines (no empty, no `[…]` notices) for the expanded view. */
function contentLines(text: string): string[] {
  const cleaned = stripFooterNotices(text);
  const out: string[] = [];
  for (const line of cleaned.split("\n")) {
    const t = line.trim();
    if (!t) continue;
    if (/^\[.*\]$/.test(t)) continue;
    out.push(line);
  }
  return out;
}

/** First non-empty, non-notice line of a string, clipped — used for errors. */
function firstContentLine(text: string, max = 120): string {
  for (const raw of text.split("\n")) {
    const line = raw.trim();
    if (!line) continue;
    if (/^\[.*\]$/.test(line)) continue;
    // Skip bash's "Command exited with code N" / "Command timed out …" trailer.
    if (/^Command (exited with code|timed out|aborted)/i.test(line)) continue;
    return clipRight(line, max);
  }
  return "";
}

/**
 * Per-tool title color. Each tool gets a distinct theme token so the tool
 * word is easy to scan visually. Falls back to `toolTitle` if a theme does
 * not define the chosen token.
 */
/**
 * Per-tool title color. Each tool gets a distinct theme token so the tool
 * word is easy to scan visually.
 *
 * `theme.fg()` only accepts tokens that exist in the active theme — it
 * throws "Unknown theme color" for hex strings. So these token choices
 * are pinned to what `ampere-tokyonight-moon` actually maps them to:
 *
 *   bash   customMessageLabel -> magenta  #c099ff
 *   read   accent             -> blue     #82aaff
 *   grep   thinkingMedium     -> cyan     #86e1fc
 *   find   toolDiffAdded      -> teal     #4fd6be
 *   ls     success            -> green    #c3e88d
 *   write  syntaxType         -> yellow   #ffc777
 *   edit   warning            -> orange   #ff966c
 *
 * In other themes these tokens may map to different colors; the abstract
 * intent (cool tones for read-only, warm tones for mutating, magenta for
 * bash) is what matters.
 */
const TOOL_COLORS = {
  bash: "customMessageLabel",
  read: "accent",
  write: "syntaxType",
  edit: "warning",
  grep: "thinkingMedium",
  find: "toolDiffAdded",
  ls: "success",
} as const;

type ToolColor = (typeof TOOL_COLORS)[keyof typeof TOOL_COLORS]; // hex string like "#c099ff"

/**
 * Nerd Font icons for each tool. Requires a Nerd Font installed in the
 * terminal (the same one neovim uses for devicons). The codepoints are
 * Unicode escapes so the file stays plain ASCII.
 *
 *   bash   fa-terminal
 *   read   fa-file-lines
 *   write  fa-pencil
 *   edit   fa-edit (pencil-square)
 *   grep   fa-search
 *   find   fa-folder
 *   ls     fa-list
 *
 * Note: Seti-UI glyphs (e.g. `nf-seti-terminal`) bake a trailing space into
 * the icon itself, so combining them with the `icon + " " + title` joiner
 * in `line()` produces 2 spaces before the tool name. Sticking to Font
 * Awesome glyphs here keeps the spacing consistent across all tools.
 */
const TOOL_ICONS = {
  bash: "\uF120",
  read: "\uF15C",
  write: "\uF040",
  edit: "\uF044",
  grep: "\uF002",
  find: "\uF07B",
  ls: "\uF03A",
} as const;

type ToolIcon = (typeof TOOL_ICONS)[keyof typeof TOOL_ICONS];

/** Render a tool's call line: bold colored "icon name" + dim target. */
function toolCall(
  theme: { fg: (c: string, t: string) => string; bold: (t: string) => string },
  name: string,
  color: ToolColor,
  icon: ToolIcon,
  target: string,
): string {
  return (
    theme.fg(color, theme.bold(icon + " " + name)) +
    " " +
    theme.fg("dim", target)
  );
}

/** Build a single-line "icon name · target · meta" render. Target may be empty. */
function line(
  theme: { fg: (c: string, t: string) => string; bold: (t: string) => string },
  title: string,
  titleColor: ToolColor | "toolTitle",
  icon: ToolIcon,
  target: string,
  meta: { status: "ok" | "warn" | "err"; label: string; extra?: string },
): string {
  let out = theme.fg(titleColor, theme.bold(icon + " " + title));
  if (target) out += " " + theme.fg("dim", target);
  out += theme.fg("dim", " · ");
  const color =
    meta.status === "ok"
      ? "success"
      : meta.status === "warn"
        ? "warning"
        : "error";
  out += theme.fg(color, meta.label);
  if (meta.extra) out += theme.fg("dim", " " + meta.extra);
  return out;
}

/** Suffix for truncation notices when present in details. */
function truncSuffix(t: TruncationResult | undefined): string {
  if (!t?.truncated) return "";
  if (t.totalLines != null && t.totalLines !== t.outputLines) {
    return ` (truncated, ${t.outputLines}/${t.totalLines} lines)`;
  }
  return " (truncated)";
}

/**
 * Extract the exit code (or "timeout"/"aborted" sentinel) from a bash result
 * whose content text ends in a `Command exited with code N` / `timed out` /
 * `aborted` trailer that the bash tool adds on failure.
 */
function parseBashStatus(text: string): {
  code: number | "timeout" | "aborted" | null;
} {
  const m = text.match(/Command exited with code (-?\d+)\s*$/m);
  if (m) return { code: parseInt(m[1]!, 10) };
  if (/Command timed out after \d+ seconds\s*$/m.test(text))
    return { code: "timeout" };
  if (/Command aborted\s*$/m.test(text)) return { code: "aborted" };
  return { code: null };
}

// ---------------------------------------------------------------------------
// Extension
// ---------------------------------------------------------------------------

export default function (pi: ExtensionAPI) {
  const cwd = process.cwd();

  // ----------------------------- bash ---------------------------------------
  const originalBash = createBashTool(cwd);
  pi.registerTool({
    name: "bash",
    label: "bash",
    description: originalBash.description,
    parameters: originalBash.parameters,
    renderShell: "self",

    async execute(toolCallId, params, signal, onUpdate) {
      return originalBash.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme, context) {
      // While running: show the full line with `· running…` appended.
      // Once the result arrives, this slot returns empty so the result
      // slot can own the line — keeping the tool row to exactly one row.
      if (context.isPartial) {
        return new Text(
          line(theme, "bash", TOOL_COLORS.bash, TOOL_ICONS.bash, args.command, {
            status: "warn",
            label: "running",
          }),
            3,
            0,
        );
      }
      return new Text("", 3, 0);
    },

    renderResult(result, { expanded, isPartial }, theme, context) {
      // While running the call slot already shows `· running…`; stay empty.
      if (isPartial) return new Text("", 3, 0);

      const details = result.details as BashToolDetails | undefined;
      const content = result.content[0];
      const output = content?.type === "text" ? content.text : "";
      const cleaned = stripFooterNotices(output);

      const { code } = parseBashStatus(cleaned);
      const isErr =
        result.isError ||
        (code !== null && code !== 0 && typeof code === "number");
      const lines = countContentLines(cleaned);
      const isTimedOut = code === "timeout";
      const isAborted = code === "aborted";

      let label: string;
      if (isTimedOut) label = "timeout";
      else if (isAborted) label = "aborted";
      else if (isErr)
        label = typeof code === "number" ? `exit ${code}` : "error";
      else label = "ok";

      const status: "ok" | "warn" | "err" = isErr ? "err" : "ok";
      const extra =
        lines > 0
          ? `${lines} line${lines === 1 ? "" : "s"}` +
            truncSuffix(details?.truncation)
          : undefined;

      // Combined line: `bash <command> · status · extra`. The target is
      // reconstructed from context.args so the result slot can render
      // the same line the call slot would have shown.
      let out = line(
        theme,
        "bash",
        TOOL_COLORS.bash,
        TOOL_ICONS.bash,
        context.args.command,
        {
          status,
          label,
          extra,
        },
      );

      if (isErr) {
        const first = firstContentLine(cleaned, 200);
        if (first) out += `\n${theme.fg("error", "  ↳ " + first)}`;
      }

      if (expanded) {
        const body = contentLines(cleaned)
          .slice(0, 20)
          .map((l) => theme.fg("dim", l))
          .join("\n");
        if (body) out += `\n${body}`;
        const total = contentLines(cleaned).length;
        if (total > 20)
          out += `\n${theme.fg("muted", "  … " + (total - 20) + " more lines")}`;
        if (details?.fullOutputPath) {
          out += `\n${theme.fg("dim", "  full: " + details.fullOutputPath)}`;
        }
      }

      return new Text(out, 3, 0);
    },
  });

  // ----------------------------- read ---------------------------------------
  const originalRead = createReadTool(cwd);
  pi.registerTool({
    name: "read",
    label: "read",
    description: originalRead.description,
    parameters: originalRead.parameters,
    renderShell: "self",

    async execute(toolCallId, params, signal, onUpdate) {
      return originalRead.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme, context) {
      let target = relativize(args.path, context.cwd);
      if (args.offset || args.limit) {
        const parts: string[] = [];
        if (args.offset != null) parts.push(`from ${args.offset}`);
        if (args.limit != null) parts.push(`limit ${args.limit}`);
        target += ` (${parts.join(", ")})`;
      }
      if (context.isPartial) {
        return new Text(
          line(theme, "read", TOOL_COLORS.read, TOOL_ICONS.read, target, {
            status: "warn",
            label: "loading",
          }),
            3,
            0,
        );
      }
      return new Text("", 3, 0);
    },

    renderResult(result, { expanded, isPartial }, theme, context) {
      if (isPartial) return new Text("", 3, 0);

      const details = result.details as ReadToolDetails | undefined;
      const content = result.content[0];

      let target = relativize(context.args.path, context.cwd);
      if (context.args.offset || context.args.limit) {
        const parts: string[] = [];
        if (context.args.offset != null)
          parts.push(`from ${context.args.offset}`);
        if (context.args.limit != null)
          parts.push(`limit ${context.args.limit}`);
        target += ` (${parts.join(", ")})`;
      }

      if (content?.type === "image") {
        return new Text(
          line(theme, "read", TOOL_COLORS.read, TOOL_ICONS.read, target, {
            status: "ok",
            label: "image",
          }),
            3,
            0,
        );
      }

      if (result.isError) {
        const msg =
          content?.type === "text"
            ? firstContentLine(content.text) || "error"
            : "error";
        return new Text(
          line(theme, "read", TOOL_COLORS.read, TOOL_ICONS.read, target, {
            status: "err",
            label: "error",
            extra: msg,
          }),
            3,
            0,
        );
      }

      if (content?.type !== "text") {
        return new Text(
          line(theme, "read", TOOL_COLORS.read, TOOL_ICONS.read, target, {
            status: "err",
            label: "no content",
          }),
            3,
            0,
        );
      }

      const text = content.text;
      const lines = countContentLines(text);
      const extra =
        `${lines} line${lines === 1 ? "" : "s"}` +
        truncSuffix(details?.truncation);

      let out = line(theme, "read", TOOL_COLORS.read, TOOL_ICONS.read, target, {
        status: "ok",
        label: "ok",
        extra,
      });

      if (expanded) {
        const body = contentLines(text)
          .slice(0, 20)
          .map((l) => theme.fg("dim", l))
          .join("\n");
        if (body) out += `\n${body}`;
        const total = contentLines(text).length;
        if (total > 20)
          out += `\n${theme.fg("muted", "  … " + (total - 20) + " more lines")}`;
      }

      return new Text(out, 3, 0);
    },
  });

  // ----------------------------- write --------------------------------------
  const originalWrite = createWriteTool(cwd);
  pi.registerTool({
    name: "write",
    label: "write",
    description: originalWrite.description,
    parameters: originalWrite.parameters,
    renderShell: "self",

    async execute(toolCallId, params, signal, onUpdate) {
      return originalWrite.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme, context) {
      const target = relativize(args.path, context.cwd);
      if (context.isPartial) {
        return new Text(
          line(theme, "write", TOOL_COLORS.write, TOOL_ICONS.write, target, {
            status: "warn",
            label: "writing",
          }),
            3,
            0,
        );
      }
      return new Text("", 3, 0);
    },

    renderResult(result, { isPartial }, theme, context) {
      if (isPartial) return new Text("", 3, 0);
      const target = relativize(context.args.path, context.cwd);
      const content = result.content[0];
      if (result.isError) {
        const msg =
          content?.type === "text"
            ? firstContentLine(content.text) || "error"
            : "error";
        return new Text(
          line(theme, "write", TOOL_COLORS.write, TOOL_ICONS.write, target, {
            status: "err",
            label: "error",
            extra: msg,
          }),
            3,
            0,
        );
      }
      return new Text(
        line(theme, "write", TOOL_COLORS.write, TOOL_ICONS.write, target, {
          status: "ok",
          label: "ok",
        }),
          3,
          0,
      );
    },
  });

  // ----------------------------- edit ---------------------------------------
  const originalEdit = createEditTool(cwd);
  pi.registerTool({
    name: "edit",
    label: "edit",
    description: originalEdit.description,
    parameters: originalEdit.parameters,
    renderShell: "self",

    async execute(toolCallId, params, signal, onUpdate) {
      return originalEdit.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme, context) {
      const target = relativize(args.path, context.cwd);
      if (context.isPartial) {
        return new Text(
          line(theme, "edit", TOOL_COLORS.edit, TOOL_ICONS.edit, target, {
            status: "warn",
            label: "applying",
          }),
            3,
            0,
        );
      }
      return new Text("", 3, 0);
    },

    renderResult(result, { expanded, isPartial }, theme, context) {
      if (isPartial) return new Text("", 3, 0);

      const target = relativize(context.args.path, context.cwd);
      const details = result.details as EditToolDetails | undefined;
      const content = result.content[0];

      if (result.isError) {
        const msg =
          content?.type === "text"
            ? firstContentLine(content.text) || "error"
            : "error";
        return new Text(
          line(theme, "edit", TOOL_COLORS.edit, TOOL_ICONS.edit, target, {
            status: "err",
            label: "error",
            extra: msg,
          }),
            3,
            0,
        );
      }

      if (!details?.diff) {
        return new Text(
          line(theme, "edit", TOOL_COLORS.edit, TOOL_ICONS.edit, target, {
            status: "ok",
            label: "no changes",
          }),
            3,
            0,
        );
      }

      // Count adds/dels for the inline summary.
      let adds = 0;
      let dels = 0;
      for (const l of details.diff.split("\n")) {
        if (l.startsWith("+")) adds++;
        else if (l.startsWith("-")) dels++;
      }

      let out = line(theme, "edit", TOOL_COLORS.edit, TOOL_ICONS.edit, target, {
        status: "ok",
        label: "applied",
        extra: `+${adds} / -${dels}`,
      });

      // Diff only on demand: render up to 40 diff lines when the user
      // presses Ctrl+O to expand. + green, - red, context dim, the
      // `  ...` skipped marker muted.
      if (expanded) {
        const limit = 40;
        const allLines = details.diff.split("\n");
        for (const l of allLines.slice(0, limit)) {
          if (l.startsWith("+")) out += `\n${theme.fg("success", "  " + l)}`;
          else if (l.startsWith("-")) out += `\n${theme.fg("error", "  " + l)}`;
          else if (l.startsWith("  ..."))
            out += `\n${theme.fg("muted", "  " + l)}`;
          else out += `\n${theme.fg("dim", "  " + l)}`;
        }
        if (allLines.length > limit) {
          out += `\n${theme.fg("muted", "  … " + (allLines.length - limit) + " more diff lines")}`;
        }
      }

      return new Text(out, 3, 0);
    },
  });

  // ----------------------------- grep ---------------------------------------
  const originalGrep = createGrepTool(cwd);
  pi.registerTool({
    name: "grep",
    label: "grep",
    description: originalGrep.description,
    parameters: originalGrep.parameters,
    renderShell: "self",

    async execute(toolCallId, params, signal, onUpdate) {
      return originalGrep.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme, context) {
      let target = `/${args.pattern}/`;
      if (args.path) target += ` in ${relativize(args.path, context.cwd)}`;
      if (args.glob) target += ` (${args.glob})`;
      if (args.ignoreCase) target += " -i";
      if (args.context) target += ` -C ${args.context}`;
      if (context.isPartial) {
        return new Text(
          line(theme, "grep", TOOL_COLORS.grep, TOOL_ICONS.grep, target, {
            status: "warn",
            label: "searching",
          }),
            3,
            0,
        );
      }
      return new Text("", 3, 0);
    },

    renderResult(result, { expanded, isPartial }, theme, context) {
      if (isPartial) return new Text("", 3, 0);

      const a = context.args;
      let target = `/${a.pattern}/`;
      if (a.path) target += ` in ${relativize(a.path, context.cwd)}`;
      if (a.glob) target += ` (${a.glob})`;
      if (a.ignoreCase) target += " -i";
      if (a.context) target += ` -C ${a.context}`;

      const details = result.details as GrepToolDetails | undefined;
      const content = result.content[0];
      const output = content?.type === "text" ? content.text : "";

      if (output === "No matches found") {
        return new Text(
          line(theme, "grep", TOOL_COLORS.grep, TOOL_ICONS.grep, target, {
            status: "ok",
            label: "0 matches",
          }),
            3,
            0,
        );
      }

      if (result.isError) {
        const msg = firstContentLine(output) || "error";
        return new Text(
          line(theme, "grep", TOOL_COLORS.grep, TOOL_ICONS.grep, target, {
            status: "err",
            label: "error",
            extra: msg,
          }),
            3,
            0,
        );
      }

      const matchCount = countContentLines(output);
      const status: "ok" | "warn" =
        details?.truncation?.truncated || details?.matchLimitReached
          ? "warn"
          : "ok";
      const extra =
        truncSuffix(details?.truncation) ||
        (details?.matchLimitReached
          ? `limit ${details.matchLimitReached}`
          : "") ||
        (details?.linesTruncated ? "lines truncated" : "");

      let out = line(theme, "grep", TOOL_COLORS.grep, TOOL_ICONS.grep, target, {
        status,
        label: `${matchCount} match${matchCount === 1 ? "" : "es"}`,
        extra: extra || undefined,
      });

      if (expanded) {
        const body = contentLines(output)
          .slice(0, 20)
          .map((l) => theme.fg("dim", l))
          .join("\n");
        if (body) out += `\n${body}`;
        const total = contentLines(output).length;
        if (total > 20)
          out += `\n${theme.fg("muted", "  … " + (total - 20) + " more matches")}`;
      }

      return new Text(out, 3, 0);
    },
  });

  // ----------------------------- find ---------------------------------------
  const originalFind = createFindTool(cwd);
  pi.registerTool({
    name: "find",
    label: "find",
    description: originalFind.description,
    parameters: originalFind.parameters,
    renderShell: "self",

    async execute(toolCallId, params, signal, onUpdate) {
      return originalFind.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme, context) {
      let target = args.pattern;
      if (args.path) target += ` in ${relativize(args.path, context.cwd)}`;
      if (context.isPartial) {
        return new Text(
          line(theme, "find", TOOL_COLORS.find, TOOL_ICONS.find, target, {
            status: "warn",
            label: "searching",
          }),
            3,
            0,
        );
      }
      return new Text("", 3, 0);
    },

    renderResult(result, { expanded, isPartial }, theme, context) {
      if (isPartial) return new Text("", 3, 0);

      const a = context.args;
      let target = a.pattern;
      if (a.path) target += ` in ${relativize(a.path, context.cwd)}`;

      const details = result.details as FindToolDetails | undefined;
      const content = result.content[0];
      const output = content?.type === "text" ? content.text : "";

      if (output === "No files found matching pattern") {
        return new Text(
          line(theme, "find", TOOL_COLORS.find, TOOL_ICONS.find, target, {
            status: "ok",
            label: "0 matches",
          }),
            3,
            0,
        );
      }

      if (result.isError) {
        const msg = firstContentLine(output) || "error";
        return new Text(
          line(theme, "find", TOOL_COLORS.find, TOOL_ICONS.find, target, {
            status: "err",
            label: "error",
            extra: msg,
          }),
            3,
            0,
        );
      }

      const count = countContentLines(output);
      const status: "ok" | "warn" =
        details?.truncation?.truncated || details?.resultLimitReached
          ? "warn"
          : "ok";
      const extra =
        truncSuffix(details?.truncation) ||
        (details?.resultLimitReached
          ? `limit ${details.resultLimitReached}`
          : "");

      let out = line(theme, "find", TOOL_COLORS.find, TOOL_ICONS.find, target, {
        status,
        label: `${count} match${count === 1 ? "" : "es"}`,
        extra: extra || undefined,
      });

      if (expanded) {
        const body = contentLines(output)
          .slice(0, 20)
          .map((l) => theme.fg("dim", l))
          .join("\n");
        if (body) out += `\n${body}`;
        const total = contentLines(output).length;
        if (total > 20)
          out += `\n${theme.fg("muted", "  … " + (total - 20) + " more paths")}`;
      }

      return new Text(out, 3, 0);
    },
  });

  // ----------------------------- ls -----------------------------------------
  const originalLs = createLsTool(cwd);
  pi.registerTool({
    name: "ls",
    label: "ls",
    description: originalLs.description,
    parameters: originalLs.parameters,
    renderShell: "self",

    async execute(toolCallId, params, signal, onUpdate) {
      return originalLs.execute(toolCallId, params, signal, onUpdate);
    },

    renderCall(args, theme, context) {
      const target = relativize(args.path, context.cwd);
      if (context.isPartial) {
        return new Text(
          line(theme, "ls", TOOL_COLORS.ls, TOOL_ICONS.ls, target, {
            status: "warn",
            label: "listing",
          }),
            3,
            0,
        );
      }
      return new Text("", 3, 0);
    },

    renderResult(result, { expanded, isPartial }, theme, context) {
      if (isPartial) return new Text("", 3, 0);

      const target = relativize(context.args.path, context.cwd);

      const details = result.details as LsToolDetails | undefined;
      const content = result.content[0];
      const output = content?.type === "text" ? content.text : "";

      if (output === "(empty directory)") {
        return new Text(
          line(theme, "ls", TOOL_COLORS.ls, TOOL_ICONS.ls, target, {
            status: "ok",
            label: "(empty)",
          }),
            3,
            0,
        );
      }

      if (result.isError) {
        const msg = firstContentLine(output) || "error";
        return new Text(
          line(theme, "ls", TOOL_COLORS.ls, TOOL_ICONS.ls, target, {
            status: "err",
            label: "error",
            extra: msg,
          }),
            3,
            0,
        );
      }

      const count = countContentLines(output);
      const status: "ok" | "warn" =
        details?.truncation?.truncated || details?.entryLimitReached
          ? "warn"
          : "ok";
      const extra =
        truncSuffix(details?.truncation) ||
        (details?.entryLimitReached
          ? `limit ${details.entryLimitReached}`
          : "");

      let out = line(theme, "ls", TOOL_COLORS.ls, TOOL_ICONS.ls, target, {
        status,
        label: `${count} entr${count === 1 ? "y" : "ies"}`,
        extra: extra || undefined,
      });

      if (expanded) {
        const body = contentLines(output)
          .slice(0, 20)
          .map((l) => theme.fg("dim", l))
          .join("\n");
        if (body) out += `\n${body}`;
        const total = contentLines(output).length;
        if (total > 20)
          out += `\n${theme.fg("muted", "  … " + (total - 20) + " more entries")}`;
      }

      return new Text(out, 3, 0);
    },
  });
}
