#!/bin/bash
#
# plugin.sh — entry file of a Knit plugin.
#
# Knit sources this file after it sources knit.sh, so every public knit function
# is available. A plugin adds commands, decorators, and shorthands with the same
# public API that an experiment uses. Keep this file at the root of the
# repository: Knit looks for "plugin.sh" there.
#
# This template shows the four things a plugin usually does:
#   1. It imports a dependency plugin (optional).
#   2. It registers a command.
#   3. It writes its own decorator and shorthand.
#   4. It extends a command that already exists.
#
# Replace the example code with your own. The "template" names below are only
# examples.

# -----------------------------------------------------------------------------
# 1. Import a dependency (optional)
#
# A plugin can import another plugin. Knit sources the dependency first, so its
# commands and decorators are available to this file. Remove the comment to use
# it. Do not import a plugin that does not exist; the import must resolve.
#
#     knit_import spack
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# 2. A decorator and its shorthand
#
# A decorator is a function that changes the command that is being registered.
# It uses the same registration surface as the built-in knit_with_* functions.
# This decorator makes the command print a banner before it runs.
# -----------------------------------------------------------------------------

# @fn template_print_banner()
#
# Print a one-line banner. The decorator installs this function as a
# "run before" callback, so Knit runs it before the command body.
#
# @param[in] text The banner text.
template_print_banner() {
    printf '=== %s ===\n' "$1"
}

# @fn template_with_banner()
#
# A decorator for the command that is being registered. It prints a banner
# before the command runs, adds a note to the command help, and rejects a
# second use of itself on the same command.
#
# @param[in] text The banner text (optional; defaults to "template plugin").
template_with_banner() {
    local text="${1:-template plugin}"

    # Reject a second use of this decorator on the same command.
    if knit_command_has_marker banner; then
        knit_fatal "@with_banner is used more than once on \"$(knit_current_command)\"."
    fi
    knit_command_set_marker banner

    # Add a line to the "Requirements" block of the command help.
    knit_add_command_note "Prints a \"${text}\" banner before it runs."

    # Install the callback that runs before the command body.
    knit_run_before template_print_banner "${text}"
}

# Make the decorator available as "@with_banner". Register the shorthand after
# the function exists. Knit rejects a token that collides with a built-in
# shorthand or a shorthand that another plugin already registered.
knit_register_shorthand with_banner template_with_banner

# -----------------------------------------------------------------------------
# 3. A command
#
# This command greets a name and writes a line to a file under the experiment's
# ".knit" directory. knit_prefix returns that directory.
# -----------------------------------------------------------------------------

# @fn template_hello()
#
# Greet the given name. Write the name to a log file under the ".knit"
# directory, and print the greeting. The "--shout" flag, added by the
# knit_extend block below, prints the greeting in upper case.
template_hello() {
    local name
    name="$(knit_get_parameter name "$@")"
    local shout
    shout="$(knit_get_parameter shout "$@")"

    local greeting="Hello, ${name}!"
    if [[ "${shout}" == "true" ]]; then
        greeting="${greeting^^}"
    fi

    # Write under the experiment's ".knit" directory. Create the sub-directory
    # first; knit_prefix returns the path whether or not it exists yet.
    local dir
    dir="$(knit_prefix)/template-plugin"
    mkdir -p "${dir}"
    printf '%s\n' "${name}" >> "${dir}/greeted.log"

    printf '%s\n' "${greeting}"
}

# Register the parent command first. A nested command (one with a colon in its
# name) needs its parent to exist. knit_empty is a body that does nothing; the
# parent only groups its subcommands.
knit_register "template" knit_empty "Example commands from the template plugin."
knit_done

knit_register "template:hello" template_hello \
    "Greet a name and record it under the .knit directory."
knit_with_required "name:string" "The name to greet."
@with_banner "template plugin"
knit_done

# -----------------------------------------------------------------------------
# 4. Extend a command that already exists
#
# knit_extend reopens the registration of a command that is already closed, so
# the decorators apply again. It works on any command, including a core Knit
# command. For example, "knit_extend bootstrap" adds an option to the built-in
# bootstrap command.
#
# Here it adds a flag to this plugin's own command. The command body above
# already reads the flag.
# -----------------------------------------------------------------------------
knit_extend "template:hello"
knit_with_flag "shout" "Print the greeting in upper case."
knit_done
