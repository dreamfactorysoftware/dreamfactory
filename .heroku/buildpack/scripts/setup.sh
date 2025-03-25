#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

# Setup directory paths
BUILD_DIR=$1
LAYERS_DIR=$2
PLATFORM_DIR=$3
ENV_DIR=$PLATFORM_DIR/env

# Function to print status messages
status() {
  echo "-----> $*"
}

# Function to handle errors
error() {
  echo " !     $*" >&2
  exit 1
}

# Export environment variables directly from the platform dir
export_env_vars() {
  local env_dir=$1
  if [ -d "$env_dir" ]; then
    for e in $(ls $env_dir); do
      echo "$e" | grep -E -q -v '^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH|LANG)$'
      if [ $? -eq 0 ]; then
        export "$e=$(cat $env_dir/$e)"
      fi
    done
  fi
}

# Export environment variables
export_env_vars "$ENV_DIR"

status "Setting up DreamFactory environment"

# Set up environment
if [ -f "$BUILD_DIR/artisan" ]; then
  php "$BUILD_DIR/artisan" df:env --db_connection=${DB_CONNECTION:-sqlite} --df_install=${DF_INSTALL:-Heroku} || echo "Warning: df:env command failed, continuing with setup"
  php "$BUILD_DIR/artisan" key:generate --force || echo "Warning: key:generate command failed, continuing with setup"
  
  # Touch sqlite database file if using sqlite
  if [ "${DB_CONNECTION:-sqlite}" = "sqlite" ]; then
    mkdir -p "$BUILD_DIR/storage/databases"
    touch "$BUILD_DIR/storage/databases/database.sqlite"
    status "Created SQLite database file"
  fi
else
  error "Artisan file not found. This doesn't appear to be a valid DreamFactory installation."
fi

# Set appropriate permissions
status "Setting file permissions"
if [ -d "$BUILD_DIR/storage" ]; then
  chmod -R 755 $BUILD_DIR/storage
else
  echo "Warning: storage directory not found. Creating it..."
  mkdir -p $BUILD_DIR/storage/logs
  mkdir -p $BUILD_DIR/storage/app
  mkdir -p $BUILD_DIR/storage/framework/{cache,sessions,views}
  chmod -R 755 $BUILD_DIR/storage
fi

if [ -d "$BUILD_DIR/bootstrap/cache" ]; then
  chmod -R 755 $BUILD_DIR/bootstrap/cache
else
  echo "Warning: bootstrap/cache directory not found. Creating it..."
  mkdir -p $BUILD_DIR/bootstrap/cache
  chmod -R 755 $BUILD_DIR/bootstrap/cache
fi

# Set up NGINX configuration
status "Setting up NGINX"
mkdir -p $BUILD_DIR/nginx
# Create mime.types file
cat > $BUILD_DIR/nginx/mime.types << 'EOL'
types {
    text/html                             html htm shtml;
    text/css                              css;
    text/xml                              xml;
    image/gif                             gif;
    image/jpeg                            jpeg jpg;
    application/javascript                js;
    application/atom+xml                  atom;
    application/rss+xml                   rss;

    text/mathml                           mml;
    text/plain                            txt;
    text/vnd.sun.j2me.app-descriptor      jad;
    text/vnd.wap.wml                      wml;
    text/x-component                      htc;

    image/png                             png;
    image/tiff                            tif tiff;
    image/vnd.wap.wbmp                    wbmp;
    image/x-icon                          ico;
    image/x-jng                           jng;
    image/x-ms-bmp                        bmp;
    image/svg+xml                         svg svgz;
    image/webp                            webp;

    application/font-woff                 woff;
    application/java-archive              jar war ear;
    application/json                      json;
    application/mac-binhex40              hqx;
    application/msword                    doc;
    application/pdf                       pdf;
    application/postscript                ps eps ai;
    application/rtf                       rtf;
    application/vnd.apple.mpegurl         m3u8;
    application/vnd.ms-excel              xls;
    application/vnd.ms-fontobject         eot;
    application/vnd.ms-powerpoint         ppt;
    application/vnd.wap.wmlc              wmlc;
    application/vnd.google-earth.kml+xml  kml;
    application/vnd.google-earth.kmz      kmz;
    application/x-7z-compressed           7z;
    application/x-cocoa                   cco;
    application/x-java-archive-diff       jardiff;
    application/x-java-jnlp-file          jnlp;
    application/x-makeself                run;
    application/x-perl                    pl pm;
    application/x-pilot                   prc pdb;
    application/x-rar-compressed          rar;
    application/x-redhat-package-manager  rpm;
    application/x-sea                     sea;
    application/x-shockwave-flash         swf;
    application/x-stuffit                 sit;
    application/x-tcl                     tcl tk;
    application/x-x509-ca-cert            der pem crt;
    application/x-xpinstall               xpi;
    application/xhtml+xml                 xhtml;
    application/xspf+xml                  xspf;
    application/zip                       zip;

    application/octet-stream              bin exe dll;
    application/octet-stream              deb;
    application/octet-stream              dmg;
    application/octet-stream              iso img;
    application/octet-stream              msi msp msm;

    application/vnd.openxmlformats-officedocument.wordprocessingml.document    docx;
    application/vnd.openxmlformats-officedocument.spreadsheetml.sheet          xlsx;
    application/vnd.openxmlformats-officedocument.presentationml.presentation  pptx;

    audio/midi                            mid midi kar;
    audio/mpeg                            mp3;
    audio/ogg                             ogg;
    audio/x-m4a                           m4a;
    audio/x-realaudio                     ra;

    video/3gpp                            3gpp 3gp;
    video/mp2t                            ts;
    video/mp4                             mp4;
    video/mpeg                            mpeg mpg;
    video/quicktime                       mov;
    video/webm                            webm;
    video/x-flv                           flv;
    video/x-m4v                           m4v;
    video/x-mng                           mng;
    video/x-ms-asf                        asx asf;
    video/x-ms-wmv                        wmv;
    video/x-msvideo                       avi;
}
EOL

# Create fastcgi_params file
cat > $BUILD_DIR/nginx/fastcgi_params << 'EOL'
fastcgi_param  QUERY_STRING       $query_string;
fastcgi_param  REQUEST_METHOD     $request_method;
fastcgi_param  CONTENT_TYPE       $content_type;
fastcgi_param  CONTENT_LENGTH     $content_length;

fastcgi_param  SCRIPT_NAME        $fastcgi_script_name;
fastcgi_param  REQUEST_URI        $request_uri;
fastcgi_param  DOCUMENT_URI       $document_uri;
fastcgi_param  DOCUMENT_ROOT      $document_root;
fastcgi_param  SERVER_PROTOCOL    $server_protocol;
fastcgi_param  REQUEST_SCHEME     $scheme;
fastcgi_param  HTTPS              $https if_not_empty;

fastcgi_param  GATEWAY_INTERFACE  CGI/1.1;
fastcgi_param  SERVER_SOFTWARE    nginx/$nginx_version;

fastcgi_param  REMOTE_ADDR        $remote_addr;
fastcgi_param  REMOTE_PORT        $remote_port;
fastcgi_param  SERVER_ADDR        $server_addr;
fastcgi_param  SERVER_PORT        $server_port;
fastcgi_param  SERVER_NAME        $server_name;

# PHP only, required if PHP was built with --enable-force-cgi-redirect
fastcgi_param  REDIRECT_STATUS    200;
EOL

# Create nginx.conf
cat > $BUILD_DIR/nginx/nginx.conf << 'EOL'
worker_processes auto;
daemon off;

events {
  worker_connections 1024;
}

http {
  include /app/nginx/mime.types;
  default_type application/octet-stream;
  server_tokens off;
  client_max_body_size 100m;
  
  # Rate limiting zone definition
  limit_req_zone $binary_remote_addr zone=mylimit:10m rate=1r/s;
  
  server {
    listen $PORT default_server;
    server_name _;

    root /app/public;
    index index.php index.html index.htm;
    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    
    gzip on;
    gzip_disable "msie6";
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_buffers 16 8k;
    gzip_http_version 1.1;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;

    location / {
      try_files $uri $uri/ /index.php?$args;
    }

    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;

    location = /50x.html {
      root /usr/share/nginx/html;
    }
    
    location ~ \.php$ {
      try_files $uri rewrite ^ /index.php?$query_string;
      fastcgi_split_path_info ^(.+\.php)(/.+)$;
      fastcgi_pass 127.0.0.1:9000;
      fastcgi_index index.php;
      fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
      include /app/nginx/fastcgi_params;
    }
    
    location ~ /\.ht {
      deny all;
    }
    
    location ~ /web.config {
      deny all;
    }
    
    #By default we will limit login calls here using the limit_req_zone set above. The below will allow 1 per second over
    # 5 seconds (so 5 in 5 seconds)from a single IP before returning a 429 too many requests. Adjust as needed.
    location /api/v2/user/session {
      try_files $uri $uri/ /index.php?$args;
      limit_req zone=mylimit burst=5 nodelay;
      limit_req_status 429;
    }
    
    location /api/v2/system/admin/session {
      try_files $uri $uri/ /index.php?$args;
      limit_req zone=mylimit burst=5 nodelay;
      limit_req_status 429;
    }
  }
}
EOL

# Create PHP-FPM configuration
status "Creating PHP-FPM configuration"
mkdir -p $BUILD_DIR/.heroku/php/etc
mkdir -p $BUILD_DIR/.heroku/php/etc/php-fpm.d

# Main PHP-FPM config
cat > $BUILD_DIR/.heroku/php/etc/php-fpm.conf << 'EOL'
[global]
daemonize = no
include = /app/.heroku/php/etc/php-fpm.d/*.conf
EOL

# Pool config
cat > $BUILD_DIR/.heroku/php/etc/php-fpm.d/www.conf << 'EOL'
[www]
listen = 127.0.0.1:9000
user = nobody
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
EOL

# Create start script
status "Creating start script"
cat > $BUILD_DIR/start.sh << 'EOL'
#!/bin/bash
cd /app
php artisan migrate --force

# Replace $PORT in the nginx config
sed -i "s/\$PORT/$PORT/g" /app/nginx/nginx.conf

# Start PHP-FPM in background
php-fpm -y /app/.heroku/php/etc/php-fpm.conf &

# Start Nginx in foreground (to keep the container running)
exec nginx -p /app -c /app/nginx/nginx.conf
EOL
chmod +x $BUILD_DIR/start.sh

# Create CNB layer settings
status "Setting up CNB layer settings"
DREAMFACTORY_LAYER_DIR="${LAYERS_DIR}/dreamfactory"
mkdir -p "$DREAMFACTORY_LAYER_DIR"

# Create proper CNB layer metadata following the CNB spec
cat > "${DREAMFACTORY_LAYER_DIR}.toml" << 'EOL'
[types]
build = true
cache = true
launch = true
EOL

status "DreamFactory setup complete"
