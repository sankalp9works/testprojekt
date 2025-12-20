FROM httpd:2.4

# Copy static website to Apache document root
COPY index.html /usr/local/apache2/htdocs/index.html

# Expose Apache port
EXPOSE 80

