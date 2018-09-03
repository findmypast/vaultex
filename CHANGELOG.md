# Changelog

## 0.8.0
* Authentication methods are more generic

## 0.7.0
* Add support for certificate files in request
* Add timeout to client
* Upgrade httpoison to 1.0

## 0.6.2
* Add support for VAULT_SSL_VERIFY environment variable - this brings VaultEx in line with equivalent Vault libraries in Ruby, Node, etc

## 0.6.1
* Use atom instead of sting for econnrefused
* On error don't stringify the error reason - this adds too much noise

## 0.6.0
* Added support for token authentication
* Misc documentation changes

## 0.5.1
* Fixing deployment error

## 0.5.0
* Fix missing VERSION file

## 0.4.0
* Add support for LDAP authentication
* Fix minor bugs in unit tests and Dockerfile

## 0.3.4
* Adding eliver tool for easier version bumping
