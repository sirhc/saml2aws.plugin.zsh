# saml2aws plugin

This plugin provides command line completions for the
[`saml2aws`](https://github.com/Versent/saml2aws) command.

This plugin provides the following convenience function.

| Alias | Purpose |
| --- | --- |
| `s2a <profile>` | Execute `saml2aws login -a <profile>` and set `AWS_PROFILE` to `<profile>` |

To use the plugin, add `saml2aws` to the plugins array in your `~/.zshrc` file:

```zsh
plugins=(... saml2aws)
```
