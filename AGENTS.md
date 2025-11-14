# VersunCMS - AI Coding Agent Guide

## Project Overview

VersunCMS is a Ruby on Rails-based content management system designed for personal website management with advanced multisite functionality. The system supports subdomain-based site management, allowing multiple independent sites to run from a single Rails application with complete data isolation.

**Key Features:**
- Multisite architecture with subdomain routing
- Article and page management with markdown support
- User authentication and admin interface
- Social media crossposting (Mastodon, Twitter/X)
- Newsletter integration (Listmonk)
- RSS feed generation and sitemap
- Performance optimization with Redis caching
- Docker-based deployment with Kamal

## Technology Stack

**Core Framework:**
- Ruby 3.4.1
- Rails 8.1.1
- SQLite3 (development) / PostgreSQL (production)

**Frontend:**
- Hotwire (Turbo + Stimulus)
- Importmap for JavaScript management
- Propshaft for asset pipeline

**Background Processing:**
- Solid Queue for job processing
- Mission Control for job monitoring

**Caching & Performance:**
- Redis for caching and session storage
- Solid Cache for Rails caching
- Site-specific caching strategies

**Deployment:**
- Docker containers
- Kamal for deployment automation
- Thruster for web acceleration
- Nginx for reverse proxy

## Project Structure

```
app/
├── assets/          # Static assets (CSS, images)
├── channels/        # Action Cable channels
├── controllers/     # Application controllers
│   ├── admin/      # Admin namespace controllers
│   └── concerns/   # Shared controller modules
├── helpers/         # View helpers
├── javascript/      # Stimulus controllers
├── jobs/           # Background jobs
├── mailers/        # Email functionality
├── models/         # ActiveRecord models
│   ├── concerns/   # Shared model modules
│   └── integrations/ # External service integrations
├── services/       # Business logic services
├── validators/     # Custom validators
└── views/          # ERB templates

config/
├── deploy.yml      # Kamal deployment configuration
├── deploy_multisite.yml # Multisite deployment config
├── locales/        # I18n translations
└── *.yml          # Rails configuration files

lib/
├── subdomain_middleware.rb    # Multisite routing middleware
└── subdomain_constraint.rb    # Route constraints for subdomains

test/               # Test suite (fixtures, models, controllers)
db/                 # Database migrations and schema
```

## Key Models and Architecture

### Core Models
- **Site**: Manages individual sites with subdomain routing
- **Article**: Blog posts with markdown support and publishing features
- **Page**: Static pages with hierarchical structure
- **User**: Authentication and user management
- **Setting**: Site-specific configuration storage
- **Crosspost**: Social media posting configuration
- **Listmonk**: Newsletter integration settings

### Multisite Architecture
- **SubdomainMiddleware**: Automatically detects and sets current site based on subdomain
- **Current.site**: Thread-safe current site context
- **Site-scoped queries**: All models use `default_scope { where(site: Current.site) }`
- **Data isolation**: Complete separation of data between sites

## Development Commands

### Setup and Development
```bash
# Initial setup
bin/setup

# Start development server
bin/dev

# Rails console
bin/rails console

# Database operations
bin/rails db:migrate
bin/rails db:seed
bin/rails db:prepare
```

### Testing
```bash
# Run all tests
bin/rails test

# Run specific test file
bin/rails test test/models/article_test.rb

# Run system tests
bin/rails test:system
```

### Code Quality
```bash
# Run RuboCop for code style
bin/rubocop

# Run Brakeman for security analysis
bin/brakeman
```

### Deployment
```bash
# Docker development setup
docker-compose -f docker-compose.multisite.yml up -d

# Kamal deployment
kamal setup
kamal deploy
```

## Code Style Guidelines

### Ruby Code Style
- Follow Rails conventions and best practices
- Use Omakase Ruby styling (configured via RuboCop)
- Prefer descriptive method and variable names
- Keep controllers thin, move logic to models/services
- Use concerns for shared functionality

### Rails Conventions
- Use RESTful routes and controllers
- Follow Rails naming conventions (plural/singular)
- Use strong parameters in controllers
- Implement proper model validations
- Use ActiveRecord associations appropriately

### Multisite-Specific Guidelines
- Always scope queries to current site: `Model.for_current_site`
- Use `Current.site` for site context, never hardcode site IDs
- Implement proper error handling for missing sites
- Test subdomain routing thoroughly
- Cache site-specific data appropriately

## Testing Strategy

### Test Structure
- **Unit tests**: Model validations, business logic
- **Controller tests**: Request handling, authentication
- **Integration tests**: Cross-cutting functionality
- **System tests**: End-to-end user workflows

### Test Data
- Use fixtures for consistent test data
- Create site-specific test data
- Test both single-site and multisite scenarios
- Verify data isolation between sites

### Key Test Scenarios
- Subdomain routing and site detection
- Data isolation between sites
- User authentication across sites
- Admin interface site switching
- Cross-site data access prevention

## Security Considerations

### Authentication & Authorization
- User sessions are site-specific
- Admin access requires proper authentication
- Cross-site request forgery protection enabled
- Secure password handling with bcrypt

### Data Isolation
- Site-scoped database queries prevent cross-site data access
- Subdomain validation prevents unauthorized site access
- File uploads are site-specific
- Cache keys include site identifiers

### Input Validation
- Strong parameters in all controllers
- Model validations for data integrity
- Sanitization of user-generated content
- Protection against SQL injection and XSS

## Performance Optimization

### Caching Strategy
- Site-specific Redis caching
- Fragment caching for complex views
- Query optimization with includes()
- Cache warming for frequently accessed data

### Database Optimization
- Proper database indexing
- Site-scoped queries for better performance
- Background job processing for heavy operations
- Database connection pooling

### Asset Management
- Propshaft for modern asset pipeline
- Image optimization with ruby-vips
- CDN integration for static assets
- Asset fingerprinting for caching

## Deployment Configuration

### Environment Variables
Required environment variables:
```
SECRET_KEY_BASE=your_secret_key
PGHOST=your_database_host
PGUSER=your_database_user
PGPASSWORD=your_database_password
DATABASE=your_database_name
SOLID_QUEUE_IN_PUMA=1
DEFAULT_DOMAIN=your_domain.com
RAILS_MASTER_KEY=your_master_key
```

### Docker Deployment
- Multi-stage Dockerfile for optimized builds
- Non-root user for security
- Volume mounts for persistent storage
- Health checks for container monitoring

### Kamal Deployment
- Multi-server deployment support
- SSL/TLS configuration
- Rolling deployments
- Accessory services (database, Redis)

## Troubleshooting Common Issues

### Multisite Issues
- **Subdomain not detected**: Check SubdomainMiddleware configuration
- **Wrong site context**: Verify Current.site is set correctly
- **Cross-site data**: Ensure all queries are site-scoped

### Performance Issues
- **Slow queries**: Check for missing indexes, use includes()
- **Cache misses**: Verify Redis connection and cache keys
- **High memory usage**: Review background job processing

### Deployment Issues
- **Database connection**: Verify environment variables
- **Asset compilation**: Check Dockerfile build stage
- **Subdomain routing**: Configure DNS and proxy settings

## Development Workflow

1. **Feature Development**
   - Create feature branch
   - Implement with tests
   - Follow code style guidelines
   - Test multisite functionality

2. **Code Review**
   - Check for security issues
   - Verify multisite compatibility
   - Review performance implications
   - Ensure proper error handling

3. **Testing**
   - Run full test suite
   - Test subdomain scenarios
   - Verify data isolation
   - Check performance metrics

4. **Deployment**
   - Update environment variables if needed
   - Run database migrations
   - Deploy using Kamal
   - Monitor application health

## External Integrations

### Social Media
- Mastodon API integration
- Twitter/X API support
- Configurable crossposting rules
- Rate limiting and error handling

### Newsletter
- Listmonk integration
- Subscriber management
- Campaign creation and sending
- Subscription form embedding

### File Storage
- AWS S3 support for file uploads
- Local storage for development
- Image processing with ruby-vips
- CDN integration for delivery

This guide should be updated as the project evolves and new features are added. Always refer to the latest codebase and configuration files for the most accurate information.