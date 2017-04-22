# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added
- DF-895 Added support for username based authentication

### Changed
### Fixed

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

[Unreleased]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.5.0...HEAD
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
