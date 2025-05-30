# DreamFactory Heroku Cloud Native PHP Buildpack Configuration

This directory contains the configuration files needed to deploy DreamFactory on Heroku using the [Heroku Cloud Native PHP Buildpack](https://github.com/heroku/buildpacks-php).

## Overview

DreamFactory is a PHP/Laravel application that generates REST APIs for databases and other services. This buildpack configuration provides:

- **PHP 8.3** with all required extensions
- **Nginx** web server optimized for DreamFactory
- **PostgreSQL** database support
- **Production-ready** configuration

## File Structure

```
.bp-config/
├── README.md                    # This file
├── options.json                 # PHP and Nginx version/extension configuration
└── nginx/
    └── conf.d/
        └── dreamfactory.conf    # Nginx server configuration
```

## Prerequisites

1. **Heroku CLI** installed and logged in
2. **Git** repository access to DreamFactory
3. **PostgreSQL addon** (heroku-postgresql)

## Quick Start

### 1. Create Heroku App

```bash
# Create new Heroku app
heroku create your-dreamfactory-app --stack heroku-24

# Add PostgreSQL database
heroku addons:create heroku-postgresql:essential-0 --app your-dreamfactory-app
```

### 2. Deploy from GitHub

```bash
# Deploy using Heroku Platform API (recommended for large repos)
curl -n -X POST https://api.heroku.com/apps/your-dreamfactory-app/builds \
  -d '{"source_blob":{"url":"https://github.com/dreamfactorysoftware/dreamfactory/archive/basic-bp.tar.gz"}}' \
  -H "Content-Type: application/json" \
  -H "Accept: application/vnd.heroku+json; version=3" \
  -H "Authorization: Bearer $(heroku auth:token)"
```

### 3. Configure Environment

```bash
# Set required environment variables
heroku config:set \
  APP_KEY=base64:$(openssl rand -base64 32) \
  APP_ENV=production \
  APP_DEBUG=false \
  APP_URL=https://your-dreamfactory-app.herokuapp.com \
  DB_CONNECTION=pgsql \
  --app your-dreamfactory-app

# Extract and set database credentials from DATABASE_URL
# Get DATABASE_URL first
DATABASE_URL=$(heroku config:get DATABASE_URL --app your-dreamfactory-app)

# Parse DATABASE_URL and set individual variables
# Format: postgres://username:password@host:port/database
# Example: postgres://user:pass@host.amazonaws.com:5432/dbname

heroku config:set \
  DB_HOST=your-db-host \
  DB_PORT=5432 \
  DB_DATABASE=your-db-name \
  DB_USERNAME=your-db-user \
  DB_PASSWORD=your-db-password \
  --app your-dreamfactory-app
```

### 4. Initialize Database

```bash
# Run database migrations
heroku run "php artisan migrate --force" --app your-dreamfactory-app

# Seed initial data
heroku run "php artisan db:seed --force" --app your-dreamfactory-app
```

### 5. Open Application

```bash
heroku open --app your-dreamfactory-app
```

## Configuration Files Explained

### `options.json`

```json
{
  "PHP_VERSION": "8.3.*",
  "WEBDIR": "public",
  "PHP_EXTENSIONS": [
    "pdo", "pdo_mysql", "pdo_pgsql", "pgsql", "pdo_sqlite",
    "curl", "openssl", "zip", "fileinfo", "mbstring", 
    "tokenizer", "xml", "ctype", "json", "bcmath"
  ],
  "NGINX_VERSION": "1.22.*"
}
```

**Key settings:**
- **PHP_VERSION**: Uses PHP 8.3 (compatible with DreamFactory)
- **WEBDIR**: Sets document root to `public/` directory
- **PHP_EXTENSIONS**: All extensions required by DreamFactory
- **NGINX_VERSION**: Nginx 1.22 for optimal performance

### `nginx/conf.d/dreamfactory.conf`

Nginx configuration optimized for DreamFactory with:
- **PHP-FPM integration** via Unix socket
- **Heroku port binding** using `${PORT}` environment variable
- **Laravel-friendly URL rewriting** for `index.php`
- **Security headers** (X-Frame-Options, X-XSS-Protection)
- **Gzip compression** for better performance
- **Large file upload** support (100MB max)

## Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `APP_KEY` | Laravel application key | `base64:randomstring` |
| `APP_ENV` | Application environment | `production` |
| `APP_DEBUG` | Debug mode | `false` |
| `APP_URL` | Application URL | `https://your-app.herokuapp.com` |
| `DB_CONNECTION` | Database driver | `pgsql` |
| `DB_HOST` | Database host | `host.amazonaws.com` |
| `DB_PORT` | Database port | `5432` |
| `DB_DATABASE` | Database name | `your_db_name` |
| `DB_USERNAME` | Database username | `your_username` |
| `DB_PASSWORD` | Database password | `your_password` |

## Alternative Deployment Methods

### Method 1: GitHub Integration (Web Dashboard)

1. Go to Heroku Dashboard → Your App → Deploy tab
2. Connect to GitHub repository
3. Select the `basic-bp` branch
4. Enable automatic deploys (optional)
5. Click "Deploy Branch"

### Method 2: Git Push (Small repos only)

```bash
# Add Heroku remote
heroku git:remote -a your-dreamfactory-app

# Push to deploy (may fail for large repos)
git push heroku basic-bp:master
```

## Troubleshooting

### Database Connection Issues

**Problem**: `could not find driver` error
**Solution**: Ensure `pgsql` and `pdo_pgsql` are in PHP_EXTENSIONS list

**Problem**: Connection refused to 127.0.0.1:5432
**Solution**: Set individual DB_* environment variables from DATABASE_URL

### Build Failures

**Problem**: Repository too large for git push
**Solution**: Use Platform API method or GitHub integration

**Problem**: Missing files error during setup
**Solution**: Ensure all DreamFactory files are included (resources/, storage/, etc.)

### Application Errors

**Problem**: 500 Internal Server Error
**Solution**: Check logs with `heroku logs --tail --app your-app`

**Problem**: Setup page 404 error
**Solution**: Ensure `resources/views/setup.blade.php` exists

## Performance Optimization

### Recommended Heroku Dyno Types

- **Development**: Basic ($7/month)
- **Production**: Standard-1X ($25/month) or higher
- **High Traffic**: Performance-M ($250/month)

### Additional Add-ons

```bash
# Redis for caching (recommended)
heroku addons:create heroku-redis:premium-0

# New Relic for monitoring
heroku addons:create newrelic:wayne

# Papertrail for log management
heroku addons:create papertrail:choklad
```

## Security Considerations

1. **Always use HTTPS** in production
2. **Set APP_DEBUG=false** in production
3. **Use strong APP_KEY** (generated with openssl)
4. **Regularly update dependencies** with `composer update`
5. **Monitor application logs** for security issues

## Support

- **DreamFactory Documentation**: https://docs.dreamfactory.com/
- **Heroku PHP Buildpack**: https://github.com/heroku/buildpacks-php
- **DreamFactory GitHub**: https://github.com/dreamfactorysoftware/dreamfactory

## License

This configuration is provided under the same license as DreamFactory (Apache 2.0).

---

**Created for DreamFactory Cloud Native PHP Buildpack deployment on Heroku** 