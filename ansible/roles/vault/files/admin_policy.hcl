## System Backend

# Read system health check
path "sys/health" {
  capabilities = ["read", "sudo"]
}

# Manage leases
path "sys/leases/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

## ACL Policies

# Create, manage ACL policies
path "/sys/policies/acl/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List existing policies
path "sys/policies/acl" {
  capabilities = ["list"]
}

## Auth Methods

# Manage auth methods
path "auth/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# Create, update, delete auth methods
path "sys/auth/*" {
  capabilities = ["create", "update", "delete", "sudo"]
}

# List auth methods
path "sys/auth" {
  capabilities = ["read"]
}

## KV Secrets Engine

# Manage secrets engine
path "sys/mounts/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List secrets engine
path "sys/mounts" {
  capabilities = ["read"]
}

## PKI - Intermediate CA

# Create, update roles
path "pki_int/roles/*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}

# List roles
path "pki_int/roles" {
  capabilities = ["list"]
}

# Issue certs
path "pki_int/issue/*" {
  capabilities = ["create"]
}

# Read certs
path "pki_int/cert/*" {
  capabilities = ["read"]
}

# Revoke certs
path "pki_int/revoke" {
  capabilities = ["create", "update", "read"]
}

# List certs
path "pki_int/certs" {
  capabilities = ["list"]
}

# Tidy certs
path "pki_int/tidy" {
  capabilities = ["create", "update", "read"]
}

path "pki_int/tidy-status" {
  capabilities = ["read"]
}
