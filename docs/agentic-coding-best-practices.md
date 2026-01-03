# Claude Code: Best Practices for Agentic Coding

> Published Apr 18, 2025 - Anthropic Engineering

Claude Code is a command line tool for agentic coding. This document covers tips and tricks that have proven effective for using Claude Code across various codebases, languages, and environments.

---

## 1. Customize Your Setup

Claude Code automatically pulls context into prompts. This context gathering consumes time and tokens, but you can optimize it through environment tuning.

### a. Create CLAUDE.md Files

CLAUDE.md is a special file that Claude automatically pulls into context when starting a conversation. Ideal for documenting:

- Common bash commands
- Core files and utility functions
- Code style guidelines
- Testing instructions
- Repository etiquette (branch naming, merge vs. rebase, etc.)
- Developer environment setup (pyenv use, compilers, etc.)
- Unexpected behaviors or warnings particular to the project
- Other information you want Claude to remember

**Example CLAUDE.md:**

```markdown
# Bash commands
- npm run build: Build the project
- npm run typecheck: Run the typechecker

# Code style
- Use ES modules (import/export) syntax, not CommonJS (require)
- Destructure imports when possible (eg. import { foo } from 'bar')

# Workflow
- Be sure to typecheck when you're done making a series of code changes
- Prefer running single tests, and not the whole test suite, for performance
```

**CLAUDE.md Locations:**

| Location | Description |
|----------|-------------|
| Root of repo | Most common. Name it `CLAUDE.md` and check into git (recommended), or `CLAUDE.local.md` and .gitignore it |
| Parent directories | Useful for monorepos - Claude will pull in CLAUDE.md files from parent directories |
| Child directories | Claude will pull in CLAUDE.md files on demand when working with files in child directories |
| Home folder | `~/.claude/CLAUDE.md` applies to all sessions |

### b. Tune Your CLAUDE.md Files

- Refine like any frequently used prompt
- Press `#` key to give Claude an instruction that it will automatically incorporate
- Add emphasis with "IMPORTANT" or "YOU MUST" to improve adherence
- Include CLAUDE.md changes in commits so team members benefit

### c. Curate Claude's List of Allowed Tools

Manage allowed tools in four ways:

1. Select "Always allow" when prompted during a session
2. Use `/permissions` command to add or remove tools
3. Manually edit `.claude/settings.json` or `~/.claude.json`
4. Use `--allowedTools` CLI flag for session-specific permissions

**Examples:**
- `Edit` - always allow file edits
- `Bash(git commit:*)` - allow git commits
- `mcp__puppeteer__puppeteer_navigate` - allow Puppeteer navigation

### d. Install the gh CLI (for GitHub)

Claude knows how to use the gh CLI to:
- Create issues
- Open pull requests
- Read comments
- And more

---

## 2. Give Claude More Tools

Claude has access to your shell environment and can leverage more complex tools through MCP and REST APIs.

### a. Use Claude with Bash Tools

Claude inherits your bash environment. To help Claude know about your custom tools:

- Tell Claude the tool name with usage examples
- Tell Claude to run `--help` to see tool documentation
- Document frequently used tools in CLAUDE.md

### b. Use Claude with MCP

Claude Code functions as both an MCP server and client. Connect to MCP servers via:

- Project config (available when running Claude Code in that directory)
- Global config (available in all projects)
- Checked-in `.mcp.json` file (available to anyone working in your codebase)

**Tip:** Use `--mcp-debug` flag to help identify configuration issues.

### c. Use Custom Slash Commands

Store prompt templates in Markdown files within `.claude/commands` folder. These become available through the slash commands menu when you type `/`.

**Example: `.claude/commands/fix-github-issue.md`**

```markdown
Please analyze and fix the GitHub issue: $ARGUMENTS.

Follow these steps:

1. Use `gh issue view` to get the issue details
2. Understand the problem described in the issue
3. Search the codebase for relevant files
4. Implement the necessary changes to fix the issue
5. Write and run tests to verify the fix
6. Ensure code passes linting and type checking
7. Create a descriptive commit message
8. Push and create a PR

Remember to use the GitHub CLI (`gh`) for all GitHub-related tasks.
```

Usage: `/project:fix-github-issue 1234` to fix issue #1234

---

## 3. Common Workflows

### a. Explore, Plan, Code, Commit

This versatile workflow suits many problems:

1. **Explore:** Ask Claude to read relevant files, images, or URLs - explicitly tell it not to write code yet
   - Use subagents for complex problems to preserve context

2. **Plan:** Ask Claude to make a plan. Use "think" to trigger extended thinking mode
   - Thinking levels: `"think"` < `"think hard"` < `"think harder"` < `"ultrathink"`
   - Have Claude create a document or GitHub issue with its plan

3. **Code:** Ask Claude to implement its solution

4. **Commit:** Ask Claude to commit and create a pull request

### b. Write Tests, Commit; Code, Iterate, Commit (TDD)

1. Ask Claude to write tests based on expected input/output pairs
2. Tell Claude to run tests and confirm they fail (no implementation code yet)
3. Ask Claude to commit the tests when satisfied
4. Ask Claude to write code that passes the tests (without modifying tests)
5. Ask Claude to commit the code once satisfied

### c. Write Code, Screenshot Result, Iterate

1. Give Claude a way to take browser screenshots (Puppeteer MCP, iOS simulator, etc.)
2. Give Claude a visual mock
3. Ask Claude to implement, screenshot, and iterate until it matches the mock
4. Ask Claude to commit when satisfied

### d. Safe YOLO Mode

Use `claude --dangerously-skip-permissions` to bypass all permission checks.

**Warning:** Risky - can result in data loss, system corruption, or data exfiltration. Use in a container without internet access.

### e. Codebase Q&A

Use Claude for learning and exploration:

- "How does logging work?"
- "How do I make a new API endpoint?"
- "What does `async move { ... }` do on line 134 of foo.rs?"
- "What edge cases does CustomerOnboardingFlowImpl handle?"
- "Why are we calling foo() instead of bar() on line 333?"

### f. Use Claude to Interact with Git

- Search git history ("What changes made it into v1.2.3?", "Who owns this feature?")
- Write commit messages
- Handle complex git operations (reverting, resolving rebases, comparing patches)

### g. Use Claude to Interact with GitHub

- Create pull requests
- Implement one-shot resolutions for code review comments
- Fix failing builds or linter warnings
- Categorize and triage open issues

### h. Use Claude to Work with Jupyter Notebooks

Claude can read and write Jupyter notebooks, interpreting outputs including images. Open Claude Code and a .ipynb file side-by-side in VS Code.

---

## 4. Optimize Your Workflow

### a. Be Specific in Your Instructions

| Poor | Good |
|------|------|
| add tests for foo.py | write a new test case for foo.py, covering the edge case where the user is logged out. avoid mocks |
| why does ExecutionFactory have such a weird api? | look through ExecutionFactory's git history and summarize how its api came to be |
| add a calendar widget | look at how existing widgets are implemented on the home page to understand the patterns. HotDogWidget.php is a good example. then, follow the pattern to implement a new calendar widget that lets the user select a month and paginate forwards/backwards. Build from scratch without libraries other than the ones already used. |

### b. Give Claude Images

- Paste screenshots (`cmd+ctrl+shift+4` on macOS to screenshot to clipboard, `ctrl+v` to paste)
- Drag and drop images directly into the prompt input
- Provide file paths for images

### c. Mention Files You Want Claude to Look at or Work On

Use tab-completion to quickly reference files or folders anywhere in your repository.

### d. Give Claude URLs

Paste specific URLs alongside your prompts. Use `/permissions` to add domains to your allowlist.

### e. Course Correct Early and Often

Four tools for course correction:

1. **Ask Claude to plan first** - explicitly tell it not to code until you confirm
2. **Press Escape** to interrupt Claude during any phase
3. **Double-tap Escape** to jump back in history and edit a previous prompt
4. **Ask Claude to undo changes** and take a different approach

### f. Use /clear to Keep Context Focused

Use `/clear` frequently between tasks to reset the context window.

### g. Use Checklists and Scratchpads for Complex Workflows

For large tasks (migrations, fixing many lint errors, complex builds):

1. Tell Claude to run the lint command and write errors to a Markdown checklist
2. Instruct Claude to address each issue one by one, checking them off

### h. Pass Data into Claude

- Copy and paste directly into your prompt
- Pipe into Claude Code: `cat foo.txt | claude`
- Tell Claude to pull data via bash commands, MCP tools, or custom slash commands
- Ask Claude to read files or fetch URLs

---

## 5. Use Headless Mode for Automation

Use `-p` flag with a prompt to enable headless mode, and `--output-format stream-json` for streaming JSON output.

### a. Use Claude for Issue Triage

Trigger automations on GitHub events (e.g., new issues created).

### b. Use Claude as a Linter

Claude can provide subjective code reviews beyond traditional linting - identifying typos, stale comments, misleading function names, etc.

---

## 6. Multi-Claude Workflows

### a. Have One Claude Write Code; Use Another to Verify

1. Use Claude to write code
2. Run `/clear` or start a second Claude in another terminal
3. Have the second Claude review the first Claude's work
4. Start another Claude to read both the code and review feedback
5. Have this Claude edit the code based on the feedback

### b. Have Multiple Checkouts of Your Repo

1. Create 3-4 git checkouts in separate folders
2. Open each folder in separate terminal tabs
3. Start Claude in each folder with different tasks
4. Cycle through to check progress and approve/deny permission requests

### c. Use Git Worktrees

Git worktrees allow you to check out multiple branches from the same repository into separate directories:

```bash
# Create worktree
git worktree add ../project-feature-a feature-a

# Launch Claude in each worktree
cd ../project-feature-a && claude

# Clean up when finished
git worktree remove ../project-feature-a
```

**Tips:**
- Use consistent naming conventions
- Maintain one terminal tab per worktree
- Set up notifications for when Claude needs attention (iTerm2 on Mac)
- Use separate IDE windows for different worktrees

### d. Use Headless Mode with a Custom Harness

Two primary patterns:

**1. Fanning out** (large migrations or analyses):

```bash
claude -p "migrate foo.py from React to Vue. Return OK if succeeded, FAIL if failed." --allowedTools Edit Bash(git commit:*)
```

**2. Pipelining** (integrating into data/processing pipelines):

```bash
claude -p "<your prompt>" --json | your_command
```

Use `--verbose` flag for debugging. Turn off in production for cleaner output.

---

## Summary

These best practices are starting points - experiment and find what works best for your workflow. The key principles are:

1. **Customize your setup** with CLAUDE.md files and tool permissions
2. **Give Claude more tools** through bash, MCP, and custom commands
3. **Use proven workflows** like TDD, visual iteration, and explore-plan-code-commit
4. **Be specific and course correct** early and often
5. **Leverage automation** with headless mode
6. **Scale with multi-Claude workflows** for complex tasks

---

*Source: Anthropic Engineering Blog - Claude Code: Best practices for agentic coding*
