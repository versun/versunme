# VersunCMS Multisite Deployment Guide

This guide covers deploying VersunCMS with multisite functionality using subdomain-based routing.

## Overview

The multisite deployment supports:
- Subdomain-based site routing (e.g., `blog.example.com`, `tech.example.com`)
- Site-specific content isolation
- Shared authentication across sites (configurable)
- Site management through admin interface
- Performance optimization with caching
- SSL/TLS support for all subdomains

## Prerequisites

- Domain name with DNS management access
- Server with Docker and Docker Compose installed
- SSL certificates (Let's Encrypt recommended)
- PostgreSQL database
- Redis for caching (optional but recommended)

## Deployment Options

### Option 1: Docker Compose (Recommended for Development/Small Deployments)

1. **Clone and setup the application:**
   ```bash
   git clone <repository-url>
   cd versuncms
   cp .env.multisite.example .env
   # Edit .env with your configuration
   ```

2. **Configure DNS:**
   - Point your main domain to your server IP
   - Create a wildcard DNS record: `*.example.com` → your server IP
   - Create specific subdomain records as needed

3. **Deploy with Docker Compose:**
   ```bash
   docker-compose -f docker-compose.multisite.yml up -d
   ```

4. **Setup the database and multisite:**
   ```bash
   docker-compose -f docker-compose.multisite.yml exec app bin/rails multisite:setup
   ```

5. **Warm up caches:**
   ```bash
   docker-compose -f docker-compose.multisite.yml exec app bin/rails cache:warm_all
   ```

### Option 2: Kamal Deployment (Production)

1. **Configure Kamal:**
   ```bash
   cp config/deploy_multisite.yml config/deploy.yml
   # Edit config/deploy.yml with your server details
   ```

2. **Setup DNS and SSL:**
   - Configure DNS records as described above
   - Kamal will automatically obtain SSL certificates via Let's Encrypt

3. **Deploy:**
   ```bash
   kamal setup
   kamal deploy
   ```

### Option 3: Manual Deployment with Nginx

1. **Setup Nginx:**
   ```bash
   sudo cp config/nginx_multisite.conf /etc/nginx/sites-available/versuncms
   sudo ln -s /etc/nginx/sites-available/versuncms /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

2. **Configure SSL:**
   ```bash
   sudo certbot --nginx -d example.com -d *.example.com
   ```

3. **Deploy Rails application:**
   ```bash
   # Setup your Rails application
   bundle install
   RAILS_ENV=production bundle exec rails assets:precompile
   RAILS_ENV=production bundle exec rails db:migrate
   RAILS_ENV=production bundle exec rails multisite:setup
   ```

## Configuration

### Environment Variables

Configure these environment variables in your `.env` file:

```bash
# Domain configuration
DEFAULT_DOMAIN=yourdomain.com
MULTISITE_ENABLED=true

# Database
DATABASE_URL=postgresql://username:password@host:5432/database

# Redis (optional but recommended)
REDIS_URL=redis://redis_host:6379/0

# SSL
SSL_ENABLED=true
```

### DNS Configuration

Required DNS records:

```
# Main domain
example.com     A     YOUR_SERVER_IP
www.example.com A     YOUR_SERVER_IP

# Wildcard for all subdomains
*.example.com   A     YOUR_SERVER_IP

# Or specific subdomains
blog.example.com    A     YOUR_SERVER_IP
tech.example.com    A     YOUR_SERVER_IP
```

### SSL/TLS Configuration

For production deployments, use Let's Encrypt with wildcard certificates:

```bash
# Generate wildcard certificate
certbot certonly --manual --preferred-challenges dns -d "*.example.com" -d example.com

# Or use DNS challenge for automation
certbot certonly --dns-cloudflare --dns-cloudflare-credentials ~/.secrets/cloudflare.ini -d "*.example.com" -d example.com
```

## Site Management

After deployment, you can manage sites through the admin interface:

1. **Access admin panel:** `https://yourdomain.com/admin`
2. **Navigate to Sites:** Click "Sites" in the admin navigation
3. **Create/Manage Sites:** Add new sites, configure subdomains, activate/deactivate sites

### Initial Site Setup

Run these commands to setup your initial sites:

```bash
# Create default site
rails multisite:create_site["Main Site","www"]

# Create additional sites
rails multisite:create_site["Blog","blog"]
rails multisite:create_site["Tech","tech"]

# Check site status
rails multisite:status
```

## Performance Optimization

### Caching

Enable Redis caching for better performance:

```bash
# Warm up caches
rails cache:warm_all

# Check cache statistics
rails cache:stats

# Clear caches if needed
rails cache:clear_all
```

### Database Optimization

Ensure proper indexes are in place:

```sql
-- Site-specific indexes
CREATE INDEX index_articles_on_site_id_and_slug ON articles(site_id, slug);
CREATE INDEX index_pages_on_site_id_and_slug ON pages(site_id, slug);
CREATE INDEX index_settings_on_site_id ON settings(site_id);
CREATE INDEX index_users_on_site_id_and_user_name ON users(site_id, user_name);

-- Performance indexes
CREATE INDEX index_articles_on_site_id_and_status ON articles(site_id, status);
CREATE INDEX index_articles_on_site_id_and_created_at ON articles(site_id, created_at DESC);
```

### Nginx Optimization

Add these optimizations to your Nginx configuration:

```nginx
# Enable HTTP/2
listen 443 ssl http2;

# Enable Gzip compression
gzip on;
gzip_vary on;
gzip_min_length 1024;
gzip_types text/plain text/css text/xml text/javascript application/javascript application/xml+rss application/json;

# Cache static assets
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# Rate limiting
limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=general:10m rate=100r/s;
```

## Monitoring

### Health Checks

Monitor application health:

```bash
# Check application health
curl -f http://yourdomain.com/up

# Check specific subdomain
curl -f http://blog.yourdomain.com/up
```

### Log Monitoring

Monitor logs for issues:

```bash
# Application logs
docker-compose logs -f app

# Nginx logs
tail -f /var/log/nginx/versuncms_access.log
tail -f /var/log/nginx/versuncms_error.log
```

### Performance Monitoring

Check performance metrics:

```bash
# Cache performance
rails cache:stats

# Site statistics
rails multisite:status
```

## Troubleshooting

### Common Issues

1. **Subdomain not working:**
   - Check DNS configuration
   - Verify Nginx/Traefik configuration
   - Check subdomain middleware logs

2. **SSL certificate issues:**
   - Verify certificate paths
   - Check certificate expiration
   - Ensure wildcard certificate covers all subdomains

3. **Site content not isolated:**
   - Verify Current.site is set correctly
   - Check model scopes are working
   - Ensure subdomain middleware is loaded

4. **Performance issues:**
   - Enable caching with Redis
   - Check database indexes
   - Monitor query performance

### Debug Mode

Enable debug logging:

```bash
# Set debug log level
RAILS_LOG_LEVEL=debug

# Check middleware execution
tail -f log/development.log | grep "SubdomainMiddleware"
```

## Security Considerations

1. **SSL/TLS:** Always use HTTPS in production
2. **Rate Limiting:** Implement rate limiting for API endpoints
3. **Input Validation:** Validate all user inputs
4. **Database Security:** Use connection pooling and prepared statements
5. **File Uploads:** Validate and sanitize uploaded files
6. **Admin Access:** Secure admin panel with strong authentication

## Scaling

### Horizontal Scaling

For high traffic sites:

1. **Load Balancing:** Use multiple application servers
2. **Database Replication:** Set up read replicas
3. **CDN:** Use CDN for static assets
4. **Caching:** Implement Redis cluster for caching

### Vertical Scaling

For resource-intensive operations:

1. **CPU:** Add more CPU cores for background jobs
2. **Memory:** Increase RAM for caching
3. **Storage:** Use SSD storage for database
4. **Network:** Ensure adequate bandwidth

## Backup and Recovery

### Database Backup

```bash
# Create backup
pg_dump -h host -U user -d database > backup.sql

# Restore backup
psql -h host -U user -d database < backup.sql
```

### File Storage Backup

```bash
# Backup uploads and storage
rsync -av /path/to/storage/ backup@backup-server:/backups/versuncms/
```

## Support

For issues and questions:

1. Check the troubleshooting section above
2. Review application logs
3. Check GitHub issues
4. Contact support team

## License

See LICENSE file for licensing information.