This documents known issues that have not been fixed.

## Manual Vault Unseal Process

Vault server must be manually unsealed when host is rebooted.

## Nomad

On some occasions, restarting the Nomad client results in some running jobs being unreachable. The temporary fix is to restart the job (not alloc or task).

## ~Vault-agent not reloading TLS certs~

~Vault-agent does not reload its own TLS configuration after the certificate has
been renewed. Although this causes the agent to fail to authenticate with Vault,
it does not constitute a systemd service failure, and the service must be
manually restarted to read the new TLS configuration. Sending a `SIGHUP` sending
is [not supported](https://github.com/hashicorp/vault/issues/20538).~

~Similar issues: [#16266](https://github.com/hashicorp/vault/issues/16266) and
[#18562](https://github.com/hashicorp/vault/issues/18562). A
[fix](https://github.com/hashicorp/vault/pull/19002) is available in Vault
1.14.~
