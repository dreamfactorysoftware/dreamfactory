# DreamFactory Heroku Cloud Native Buildpack

This directory contains the necessary files for deploying DreamFactory on Heroku Fir using Cloud Native Buildpacks (CNB).

## Architecture

This setup follows a streamlined approach:

1. **Application Code**: The DreamFactory application code (this repository)
2. **Buildpack**: The [DreamFactory Cloud Native Buildpack](https://github.com/dreamfactorysoftware/df-cloud-native-buildpack)

The setup scripts that were previously in a separate repository have been integrated directly into the application repo for simplicity.

## Directory Structure

- `.heroku/buildpack/scripts/setup.sh`: The main setup script that configures DreamFactory
- `.heroku/buildpack/README.md`: This documentation file

## How It Works

When deploying to Heroku Fir, the buildpack:

1. Detects this application as a DreamFactory instance
2. Runs the setup script located in `.heroku/buildpack/scripts/setup.sh`
3. Configures the environment based on your settings
4. Sets up NGINX web server and PHP-FPM configurations
5. Creates necessary storage directories and sets file permissions
6. Configures the start script that will run when the application launches

## Deployment Instructions

To deploy this repository to Heroku Fir:

1. Create a new Heroku Fir app:
   ```
   heroku create my-dreamfactory-app --stack heroku-24
   ```

2. Create a `project.toml` file in your repo with:
   ```toml
   [_]
   schema-version = "0.2"
   
   [stack]
   id = "heroku/heroku-24"
   
   [[io.buildpacks.group]]
   id = "heroku/php"
   version = "1.0.0"
   
   [[io.buildpacks.group]]
   id = "dreamfactory/cloud-native-buildpack"
   uri = "https://github.com/dreamfactorysoftware/df-cloud-native-buildpack.git"
   ```

3. Push to Heroku:
   ```
   git push heroku main
   ```

## Configuration

You can customize your DreamFactory installation by setting environment variables:

```bash
# Database Configuration
heroku config:set DB_CONNECTION=mysql
heroku config:set DB_HOST=your-db-host
heroku config:set DB_DATABASE=your-db-name
heroku config:set DB_USERNAME=your-db-username
heroku config:set DB_PASSWORD=your-db-password

# DreamFactory Configuration
heroku config:set DF_INSTALL=Heroku
heroku config:set DF_INSTANCE_NAME="My DreamFactory Instance"
heroku config:set APP_ENV=production
heroku config:set APP_DEBUG=false
```

By default, SQLite is used for storage.

## Troubleshooting

Common issues:

1. **Database connectivity issues**: Ensure your database credentials are correct and the database server is accessible from Heroku.

2. **File permission errors**: The buildpack should handle permissions automatically, but if you encounter issues, you may need to adjust permissions in the setup script.

3. **Startup errors**: Check the logs with `heroku logs --tail` to see what might be failing during startup. 