# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [Unreleased]
### Added

### Changed

### Fixed

## [2.0.4]
### Fixed
- Bug fixes for df-core dependencies
- FileManager app to include OpenStack Object Storage

## [2.0.3]
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

[Unreleased]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.0.4...HEAD
[2.0.4]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.0.3...2.0.4
[2.0.3]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.0.2...2.0.3
[2.0.2]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.0.1...2.0.2
[2.0.1]: https://github.com/dreamfactorysoftware/dreamfactory/compare/2.0.0...2.0.1
