# Brain sync convention

- Every route/feature ships its `.claude/brain/feature/NNN-{kebab-name}.md` entry (YAML frontmatter: route, entry_point, category + one-line description) in the SAME commit as the code — never a follow-up.
- Add its row to `000-index.md` under the matching category.
- Removing a route deletes both the brain file and its index row instead of leaving stale entries.
- Source of truth is the actual route/registry file in code — if the brain and the code ever disagree, regenerate the brain from the code, never the other way around.
- A change that doesn't add/remove a route (new util, new section on an existing page) doesn't need a new brain file — update the existing entry's description only if the change is significant enough to matter to a future session.
