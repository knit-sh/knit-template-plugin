# knit-template-plugin

A template for a [Knit](https://github.com/knit-sh/knit) plugin. A plugin adds
commands, decorators, and shorthands to a Knit experiment. Click **Use this
template** on GitHub to start your own plugin from this one.

## What a plugin is

A plugin is a git repository with an entry file **`plugin.sh`** at its root.
Knit sources `plugin.sh` after it sources `knit.sh`, so every public Knit
function is available. A plugin uses the same public API that an experiment
uses.

## How a user imports your plugin

A Knit user adds one line near the top of the experiment, after
`source knit.sh`:

```bash
source knit.sh

# Full form: host, owner, repository, and an optional ref (tag, branch, commit).
knit_import github.com/your-org/knit-example@v1.0.0

# Short form: the host defaults to github.com and the owner to knit-sh, and the
# repository name gets the "knit-" prefix. So this is the same as
# github.com/knit-sh/knit-example:
knit_import example
```

Knit resolves the ref to an exact commit, fetches the repository, verifies its
checksum, and sources `plugin.sh`. It records the commit and checksum in
`knit-plugins.lock` so a later run and a fresh checkout use the same code.

## What this template provides

`plugin.sh` shows the four things a plugin usually does:

1. **Import a dependency** (optional) — `knit_import <other-plugin>`. Knit
   sources the dependency first.
2. **Register a command** — `knit_register` with `knit_with_*` options and
   `knit_done`. The example command `template hello` greets a name and writes a
   line under the experiment's `.knit` directory (located with `knit_prefix`).
3. **Write a decorator and a shorthand** — `knit_register_shorthand` makes a
   decorator available as `@with_banner`. The decorator uses the public
   registration surface (`knit_run_before`, `knit_add_command_note`,
   `knit_command_set_marker` / `knit_command_has_marker`).
4. **Extend a command that already exists** — `knit_extend` reopens a closed
   command so the decorators apply again. It works on any command, including a
   core Knit command.

Try the example after you import the plugin:

```bash
knit template hello --name World
knit template hello --name World --shout
knit template hello --help
```

## Make it your own

1. Rename the repository. Keep the `knit-` prefix if you want the short import
   form (`knit_import <name>` needs the repository to be
   `github.com/knit-sh/knit-<name>`).
2. Edit `plugin.sh`: remove the example code and add your own commands,
   decorators, and shorthands. Change the `template` names.
3. Keep `plugin.sh` at the repository root.
4. Run `shellcheck plugin.sh` to check your code.

## Naming

- Use your own prefix for function and variable names (for example
  `knit_myplugin_*`) to avoid a collision with Knit or another plugin.
- Do not use the private Knit prefixes `_knit_*` and `__knit_*` for new API; they
  are internal to Knit and can change.
- In `plugin.sh`, call the Knit API by its canonical name (for example
  `knit_register`, `knit_with_required`), not the `@` shorthand form. A user can
  disable shorthands (`KNIT_WITHOUT_SHORTHAND`), which would leave a shorthand
  undefined and break your plugin as it loads. A shorthand that your plugin
  registers with `knit_register_shorthand` is a convenience for the user's own
  experiment, not for `plugin.sh` itself.
