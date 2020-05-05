# The `s2a` function maps `s2a <profile>` to `saml2aws login -a <profile>`,
# which updates `~/.aws/credentials`. It will also set the `AWS_PROFILE`
# environment variable for other commands (i.e., shell prompts) to use.
function s2a() {
    local profile="${1:?missing profile}"
    command saml2aws login -a "$profile"
    export AWS_PROFILE="$profile"
}
compdef _saml2aws_idp_accounts s2a

function _saml2aws_idp_accounts() {
    local -a idp_accounts
    idp_accounts=($(sed -n -e '/^\[/s/\[\([a-zA-Z0-9_\.-]*\).*/\1/p' "${SAML2AWS_CONFIGFILE:-$HOME/.saml2aws}" 2>/dev/null || :))
    _describe -t idp_accounts 'idp_accounts' idp_accounts && return 0
}

function _saml2aws_aws_profiles() {
    local -a aws_profiles
    aws_profiles=($(sed -n -e '/^\[/s/\[\([a-zA-Z0-9_\.-]*\).*/\1/p' "${AWS_SHARED_CREDENTIALS_FILE:-$HOME/.aws/credentials}"))
    _describe -t aws_profiles 'aws_profiles' aws_profiles && return 0
}

_saml2aws_global_flags=(
    '(- *)--help[Show context-sensitive help]'
    '(- *)--help-long[Show context-sensitive help]'
    '(- *)--help-man[Show context-sensitive help]'
    '(- *)--version[Show application version]'
    '--verbose[Enable verbose logging]'
    '(-i --provider)'{-i,--provider}'+[This flag is obsolete]:PROVIDER:'
    '(-a --idp-account)'{-a,--idp_account}'+[The name of the configured IDP account]:IDP-ACCOUNT:_saml2aws_idp_accounts'
    '--idp-provider+[The configured IDP provider]:IDP-PROVIDER:'
    '--mfa+[The name of the mfa]:MFA:'
    '(-s --skip-verify)'{-s,--skip-verify}'[Skip verification of server certificate]'
    '--url+[The URL of the SAML IDP server used to login]:URL:'
    '--username+[The username used to login]:USERNAME:'
    '--password+[The password used to login]:PASSWORD:'
    '--mfa-token+[The current MFA token]:MFA-TOKEN:'
    '--role+[The ARN of the role to assume]:ROLE:'
    '--aws-urn+[The URN used by SAML when you login]:AWS-URN:'
    '--skip-prompt[Skip prompting for parameters during login]'
    '--session-duration+[The duration of your AWS Session]:SESSION-DURATION:'
    '--disable-keychain[Do not use keychain at all]'
    '(-r --region)'{-r,--region}'+[AWS region to use for API requests]:REGION:'
)

function _saml2aws_commands() {
    local -a commands
    commands=(
        'help:Show help'
        'configure:Configure a new IDP account'
        'login:Login to a SAML 2.0 IDP and convert the SAML assertion to an STS token'
        'exec:Exec the supplied command with env vars from STS token'
        'console:Console will open the aws console after logging in'
        'list-roles:List available role ARNs'
        'script:Emit a script that will export environment variables'
    )
    _describe -t commands 'command' commands
}

function _saml2aws_help() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -C \
        '1:command:_saml2aws_commands' \
        && ret=0

    return ret
}

function _saml2aws_configure() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -C \
        $_saml2aws_global_flags[@] \
        '--app-id+[OneLogin app id required for SAML assertion]:APP-ID:' \
        '--client-id+[OneLogin client id, used to generate API access token]:CLIENT-ID:' \
        '--client-secret+[OneLogin client secret, used to generate API access token]:CLIENT-SECRET:' \
        '--subdomain+[OneLogin subdomain of your company account]:SUBDOMAIN:' \
        '(-p --profile)'{-p,--profile}'+[The AWS profile to save the temporary credentials]:PROFILE:_saml2aws_aws_profiles' \
        '--resource-id+[F5APM SAML resource ID of your company account]:RESOURCE-ID:' \
        '--config+[Path/filename of saml2aws config file]:CONFIG:_files' \
        && ret=0

    return ret
}

function _saml2aws_login() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -C \
        $_saml2aws_global_flags[@] \
        '(-p --profile)'{-p,--profile}'+[The AWS profile to save the temporary credentials]:PROFILE:_saml2aws_aws_profiles' \
        '--duo-mfa-option+[The MFA option you want to use to authenticate with]:DUO-MFA-OPTION:' \
        '--client-id+[OneLogin client id, used to generate API access token]:CLIENT-ID:' \
        '--client-secret+[OneLogin client secret, used to generate API access token]:CLIENT-SECRET:' \
        '--force[Refresh credentials even if not expired]' \
        && ret=0

    return ret
}

function _saml2aws_exec() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -C \
        $_saml2aws_global_flags[@] \
        '(-p --profile)'{-p,--profile}'+[The AWS profile to save the temporary credentials]:PROFILE:_saml2aws_aws_profiles' \
        '--exec-profile+[The AWS profile to utilize for command execution]:EXEC-PROFILE:' \
        '*:: :_normal' \
        && ret=0

    return ret
}

function _saml2aws_console() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -C \
        $_saml2aws_global_flags[@] \
        '--exec-profile+[The AWS profile to utilize for console execution]:EXEC-PROFILE:' \
        '(-p --profile)'{-p,--profile}'+[The AWS profile to save the temporary credentials]:PROFILE:_saml2aws_aws_profiles' \
        '--force[Refresh credentials even if not expired]' \
        '--link[Present link to AWS console instead of opening browser]' \
        && ret=0

    return ret
}

function _saml2aws_list_roles() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -C \
        $_saml2aws_global_flags[@] \
        && ret=0

    return ret
}

function _saml2aws_script() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -C \
        $_saml2aws_global_flags[@] \
        '(-p --profile)'{-p,--profile}'+[The AWS profile to save the temporary credentials]:PROFILE:_saml2aws_aws_profiles' \
        '--shell+[Type of shell environment]:SHELL:((bash powershell fish))' \
        && ret=0

    return ret
}

function _saml2aws() {
    local curcontext=$curcontext state state_descr line ret=1
    typeset -A opt_args

    _arguments -C \
        $_saml2aws_global_flags[@] \
        '1:command:_saml2aws_commands' \
        '*::arg:->args'

    case "$line[1]" in
        help)
            _saml2aws_help && ret=0
            ;;
        configure)
            _saml2aws_configure && ret=0
            ;;
        login)
            _saml2aws_login && ret=0
            ;;
        exec)
            _saml2aws_exec && ret=0
            ;;
        console)
            _saml2aws_console && ret=0
            ;;
        list-roles)
            _saml2aws_list_roles && ret=0
            ;;
        script)
            _saml2aws_script && ret=0
            ;;
    esac

    return ret
}
compdef _saml2aws saml2aws
