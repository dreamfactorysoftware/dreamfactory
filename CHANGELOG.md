# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]

## [3.0.0-beta]
### Added
- Debian and Ubuntu genie installation script

### Changed
- DF-1411 df-database fix
- DF-1421 df-azure fix

## [2.14.2]
### Changed
- Bumped Composer files for df-sqldb 0.15.4 release

## [2.14.1]
### Changed
- Bumped config/app.php version number so no confusion

## [2.14.0]
### Changed
- Upgraded to PHP 7.1 minimum

## [2.13.1] - 2018-09-05
### Added
- Non-interactive flags to Homestead environment script
### Changed
- Rebuilt lock file due to PHP conflict issue
- Improved README

## [2.13.0] - 2018-08-01
### Added
- Numerous improvements to AngularJS front end

## [2.12.0] - 2018-02-25
### Added 
- Beta support for MemSQL
- Bitbucket support for Git storage 

## [2.11.1] - 2018-01-25
### Added
- Updated vagrant configuration script

## [2.11.0] - 2017-12-29
### Added
- Added GraphQL API interface for database services - beta
- Add use of df-system repo pulled from df-core
- DF-1251 Added alternative means (external db) of authentication
- DF-1224 Added ability to set different default limits (max_records_returned) per service
### Changed
- Upgraded Laravel to 5.5 - Note: Requires PHP >= 7.0
- DF-1150 Updated copyright and support email
- Updated homestead config to support --dev option
- Updated for routing changes
- DF-1249 Removed first user check middleware from DF base, moved to df-core

## [2.10.0] - 2017-11-03
### Added
- Adding CloudFoundry manifest/setup files to Dreamfactory.
### Changed
- Updated test_rest.html to support api_key when testing package import
- Updated Homestead configs

## [2.9.0] - 2017-09-18
### Added
- Support for setting df.scripting.default_protocol in config and DF_SCRIPTING_DEFAULT_PROTOCOL in .env 
- DF-1209 Support for setting app.log_max_files in config and APP_LOG_MAX_FILES in .env
- DF-1131 Support for AD SSO and SQLServer windows authentication
- DF-1177 & DF-1161 Added services for GitHub and GitLab with linking to server side scripting

## [2.8.1] - 2017-08-18
### Added
- Add env setting for controlling database query logging
- Fix grammar on app description
- Exchanging df-swagger-ui for new df-api-docs-ui

## [2.8.0] - 2017-07-28
### Added
- DF-1142 Added ldap_username field to user table
- Added DF_JWT_USER_CLAIM env option to include user attribute in JWT
- Support IBM Informix as a service
### Fixed
- Fixed vagrant box provisioning script for cassandra driver

## [2.7.0] - 2017-06-06
### Added
- New BASH installer.sh for customizing environment and packages included

### Changed
- Cleanup after removing php-utils library
- Config and DatabaseSeeder changes for new installer
- Documentation of env settings to config and installer
- Cleanup gitignore
- Remove cipher option of RIJNDAEL-128 from environment

## [2.6.0] - 2017-04-21
### Added
- DF-895 Added support for username based authentication
- Added support for Firebird SQL Database
- Added support for using Redis as cache for Limits feature
- Added support for "upsert" on database services where supported (using PUT verb)
- Added support for Admin user email invites

## [2.5.0] - 2017-03-04
- Restructuring to upgrade to Laravel 5.4

### Added
- Adding support for limits feature cache store
- Added an APP_KEY placeholder for easy config in docker deployment

### Changed
- DF-954 Made 'Bad request. No token or api key provided.' error message more verbose
- Updated vagrant provisioning script

### Fixed
- Fixed cassandra driver install for homestead setup

## [2.4.2] - 2017-01-17
### Added
- DF-926 SAML 2.0 support as an authentication service
- Support for Homestead ^4.0 with PHP7.1

### Changed
- Updating v8js support on homestead for PHP7.1
- Updating vagrant provision script
- Refactored out database, email, and script services, updating dependencies

### Fixed
- DF-958 Verb tunneling handling before routing for proper role access checking
- Correcting DatabaseSeeder class for default services

## [2.4.1] - 2016-11-30
### Changed
- Updated composer.lock for df-admin-app 2.4.2

## [2.4.0] - 2016-11-18
### Added
- DF-867 Added a pre-configured local file service for the logs directory
- DF-552 Added support for Couchbase database
- Lookup modifier configuration options

### Changed
- CORS correction for global middleware addition

## [2.3.1] - 2016-10-04
### Added
- DF-742 Customizable user confirmation code length
- DF-249 Configurable expiration for user confirmation codes
- Adding python command path setting to distributed env file
- Example WSDL added for Salesforce connections

### Changed
- DF-641 File services now support chunking for downloading large files

## [2.3.0] - 2016-08-22
### Added
- Added Cache service (df-cache) and Cassandra (df-cassandra) as well as Queued scripting feature

### Changed
- Updating homestead provisioning script to install v8js and php cassandra extension
- Better exception responses

### Fixed
- Ignore public path trailing slash
- Public path error on remote file storage

## [2.2.1] - 2016-07-08
### Changed
- Using latest homestead with php7
- Updating vagrant provisioning script
- Updating splash screen version number
- DF-764 Updating API error messages

### Fixed
- DF-662 Fixing file streaming using file service over CORS

## [2.2.0] - 2016-05-27
### Changed
The following services are now under a commercial license and have been removed from the default installation. Please contact support@dreamfactory.com for further information.

- AD/LDAP, SOAP, Salesforce, MS SQL Server, SAP SQL Anywhere, and Oracle.

### Added
- New service type migration command for pre-2.2 database upgrade, run after migration and seeding.
- Including predis/predis package by default
- Including df-azure using microsoftazure/storage by default
- Added laravel/homestead support for php5.6 and php7
- Added locales.conf for running sqlsrv as system db

### Fixed
- Auto login after creating first admin

## [2.1.2] - 2016-04-25
### Added
- Redesigned Packaging feature, including new system/package API and artisan commands for import and export.
- Added Redis and Memcached config options to dreamfactory:setup command 
- Added Memcached config values in environment 
- Updated dreamfactory:import-pkg command to use new package format
- Updating initial setup to import any packages available
- Added artisan dreamfactory:config-hhvm command to create hhvm config file 
- Basic support for www-form-urlencoded payload in API requests
- Add rewrite rule to allow basic auth on AWS cloud and VM. 

### Changed
- Cleanup service providers 
- Handling file stream output using StreamedResponse 

## [2.1.1] - 2016-03-14
### Added
- More env config option in setup command
- Now allowing login with JWT passed as URL parameter
- Added log level support, see DF_LOG_LEVEL in .env-dist for options

### Changed
- Upgraded Laravel framework to 5.2
- File Manager app is now standalone composer pulled app

## [2.1.0] - 2016-01-29

### Changed
- **MAJOR** Updated code base to use OpenAPI (fka Swagger) Specification 2.0 from 1.2
- Replacing old swagger UI with fork of latest Swagger 2.0 UI

## [2.0.4] - 2016-01-06
### Fixed
- Bug fixes for df-core dependencies
- FileManager app to include OpenStack Object Storage

## [2.0.3] - 2015-12-22
### Added
- Laravel Homestead setup for quick launch of testing environment.
- More environment changes for managed instances, including limit tracking.

### Changed
- Using 'AES-256-CBC' as default Cipher in config/app.php, mirroring Laravel 5.1. 
For older installs, see DF_CIPHER in .env or .env-dist for more details.

### Fixed
- SQLite storage location for managed instances.

## [2.0.2] - 2015-11-30
### Added
- New migration check for upgrade scenarios.
- AD enhancements.
- This changelog!

### Changed
- Rework AccessCheck middleware, move AuthCheck to global for easier usage in enterprise scenarios.
- Email templates back to original html/text based instead of blade.
- Composer additions.

## [2.0.1] - 2015-10-28
### Fixed
- A bug that prevented proper logout when token is invalid.

## 2.0.0 - 2015-10-27
First official release of the new open-source DreamFactory project.

[Unreleased]: https://github.com/dreamfactorysoftware/dreamfactory/compare/3.0.0-beta...HEAD
[2.14.2]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.14.1...2.14.2
[2.14.1]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.14.0...2.14.1
[Unreleased]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.14.2...HEAD
[2.14.2]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.14.1...2.14.2
[2.14.1]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.14.0...2.14.1
[2.14.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.13.1...2.14.0
[2.13.1]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.13.0...2.13.1
[2.13.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.12.0...2.13.0
[2.12.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.11.1...2.12.0
[2.11.1]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.11.0...2.11.1
[2.11.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.10.0...2.11.0
[2.10.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.9.0...2.10.0
[2.9.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.8.1...2.9.0
[2.8.1]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.8.0...2.8.1
[2.8.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.7.0...2.8.0
[2.7.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.6.0...2.7.0
[2.6.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.5.0...2.6.0
[2.5.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.4.2...2.5.0
[2.4.2]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.4.1...2.4.2
[2.4.1]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.4.0...2.4.1
[2.4.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.3.1...2.4.0
[2.3.1]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.3.0...2.3.1
[2.3.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.2.1...2.3.0
[2.2.1]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.2.0...2.2.1
[2.2.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.1.2...2.2.0
[2.1.2]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.1.1...2.1.2
[2.1.1]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.1.0...2.1.1
[2.1.0]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.0.4...2.1.0
[2.0.4]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.0.3...2.0.4
[2.0.3]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.0.2...2.0.3
[2.0.2]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.0.1...2.0.2
[2.0.1]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.0.0...2.0.1
