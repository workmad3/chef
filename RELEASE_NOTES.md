<!---
This file is reset every time a new release is done. The contents of this file are for the currently unreleased version.

Example Note:

## Example Heading
Details about the thing that changed that needs to get included in the Release Notes in markdown.
-->
# Chef Client Release Notes:

#### CHEF-5223 OS X Service provider regression.

This commit: https://github.com/opscode/chef/commit/024b1e3e4de523d3c1ebbb42883a2bef3f9f415c
introduced a requirement that a service have a plist file for any
action, but a service that is being created will not have a plist file
yet. Chef now only requires that a service have a plist for the enable
and disable actions.

#### Signal Regression Fix

CHEF-1761 introduced a regression for signal handling when not in daemon mode
(see CHEF-5172). Chef will now, once again, exit immediately on SIGTERM if it
is not in daemon mode, otherwise it will complete it's current run before
existing.

#### Ubuntu 13.10+ uses Upstart service provider.

The "compatibility interface" for /etc/init.d/ is no longer used at least as of
13.10 (per the Ubuntu wiki page). The default service provider in Chef for Ubuntu
is C:\:\P::S::Debian, which uses /etc/init.d/service_name with the start, stop,
etc commands to manage the script. If you are able to use the init provider just
fine, you will need to manually override the provider back to Debian.

#### BREAKING CHANGE: New `guard_interpreter defaults for `powershell_script` and `batch` resources

The `guard_interpreter` attribute was introduced for all resources in the earlier **Chef
11.12** release with a default of `:default` which left guard behavior
unchanged from. Now in this release, it is set to `:powershell_script` for the `powershell_script` resource
and `:batch` for the `batch` resource. This will change the interpretation and
behavior of some guard expressions for these resources. To revert back to the
default behavior of **Chef 11** and earlier releases, set the
`guard_interpreter` attribute to `:default`.

With the new defaults, some guard expressions used in **Chef 11** recipes that evaluated as `true` or
`false` in specific circumstances may evaluate with the opposite value, or may
always evaluate the same in all cases, or may simply evaluate with
unpredictable results. For the `powershell_script` resource, these differences
are more likely since **Chef** previously evaluated guards using the `cmd.exe`
batch language, and will now use a completely different language,
*PowerShell* instead. The change for `batch` is more subtle since the same
*batch* language is being used and really only the processor architecture of
the process used to interpret it, i.e. now a 64-bit rather than 32-bit
processor architecture previously, has changed.

Thus, behavior changes for these resources could include the following:

* For `powershell_script` resources, guard expressions that include any of the
  following characteristics may have new or incorrect behavior:
  * Expressions that include the `cmd.exe` batch language environment variable
    syntaxes `%VARIABLENAME%` or `!VARIABLENAME!` will not be valid
    *PowerShell* syntax.
  * Quoting: Expressions with double quotes or single quotes may not evaluate
    the same in the *PowerShell* language as in batch due to the different
    quoting rules in those languages.
  * Built-in *batch* interpreter commands such as `copy`, `xcopy`, `type`, `if`,
    etc., may not be available in *PowerShell* or may not have the same
    arguments.
  * Escape characters: Expressions in *batch* that contain the *PowerShell*
    back tic ('\`') character will cause *PowerShell* to treat the subsequent
    character as part of some escape sequence. Also, some characters in
    *batch* may need to be escaped when using *PowerShell*.
* For the `batch` resource, when the resource's `architecture` attribute is 
  unspecified or set to `x86_64`, guards will continue to be evaluated with
  `cmd.exe`, but the process will now be 64-bit, which may invalidate
  assumptions that the process was 32-bit.
  * For example, if you were to read a *Windows registry* value from within a
    guard expression in previous releases, the expression may not be able to
    access the same registry value if that value had a 32-bit value vs. a
    64-bit value.
  * If you were to launch `powershell.exe` from within the guard expression,
    you may now be running the 64-bit `powershell.exe` rather than the 32-bit
    one, which may have a different *execution policy* or a different set of
    imported or accessible *PowerShell* modules or cmdlets.

To work around these differences, the following approaches may be used:

* In all cases for both the `powershell_script` and `batch` resources, setting
  the `guard_interpreter` attribute for those resources to `:default` will
  restore the behavior from **Chef 11**. Any recipes where these resources
  have the `guard_interpreter` attribute set to `:default` will behave as they
  always had prior to **Chef 12**.
* Instead of the `:default` workaround, the following narrower changes can be
  used which also allow other features of `guard_interpreter` to be used for
  simpler syntax and greater flexibility for guard expressions:
  * For `batch` resources, undesired use of the 64-bit `cmd.exe` interpreter
  to evaluate guards instead of the 32-bit interpreter always used for guards in
  **Chef 11** can be undone simply by passing `:architecture => :i386` as a
  parameter to the guard. This instructs Chef to use the 32-bit (i.e. `:i386`)
  `cmd.exe` to evaluate the guard, as was done in **Chef 11**. 
  * For `powershell_script` resources, `:guard_interpreter` could also just be
    set to `:batch` rather than `:default`, to make the usage of the `cmd.exe`
    *batch* interpreter and explicit override; this approach also allows for
    other features of `guard_interpreter` to be used rather than to disable
    them as a value of `:default` would do.
  * For `powershell_script` resources, if a guard contains an expression to
    launch `powershell.exe` with the intent of using `powershell.exe` to
    evalute a *PowerShell* expression, the complicated guard expression
    command can simply be replaced by whatever expression was being passed to
    `powershell.exe` rather than `powershell.exe` followed by the commands
    necessary to evaluate the expression. Care must be taken here to correctly
    observe *PowerShell* quoting rules. It's also possible that the default
    value of the `convert_boolean_return` attribute for `powershell_script`
    resources used to evaluate guards may be treated as a failure if the
    expression ends with a `boolean` data type. The `convert_boolean_return`
    attribute may be set to `false` to avoid that behavior.
  
