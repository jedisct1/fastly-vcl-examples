# HTTP Functions

This file demonstrates comprehensive examples of HTTP Functions in VCL.
These functions help manipulate HTTP requests and responses, including
header operations and status code handling.

## header.get

Retrieves the value of an HTTP header.

### Syntax

```vcl
STRING header.get(ID scope, STRING header_name)
```

### Parameters

- `scope`: The request/response scope (req, resp, bereq, beresp, obj)
- `header_name`: The name of the header to get

### Return Value

The value of the specified header, or an empty string if the header doesn't exist

### Examples

#### Basic header retrieval

```vcl
declare local var.user_agent STRING;
declare local var.content_type STRING;
declare local var.accept_encoding STRING;

# Get the User-Agent header
set var.user_agent = header.get(req, "User-Agent");

# Get the Content-Type header
set var.content_type = header.get(req, "Content-Type");

# Get the Accept-Encoding header
set var.accept_encoding = header.get(req, "Accept-Encoding");

# Log the headers for debugging
log "User-Agent: " + var.user_agent;
log "Content-Type: " + var.content_type;
log "Accept-Encoding: " + var.accept_encoding;
```

#### Extracting specific values from multi-value headers

```vcl
declare local var.accept_language STRING;
declare local var.primary_language STRING;

# Get the Accept-Language header
set var.accept_language = header.get(req, "Accept-Language");

# Extract the primary language using regex on the full header value
if (var.accept_language ~ "^([^,]+)") {
  set var.primary_language = re.group.1;
}

# Log the result
log "Full Accept-Language: " + var.accept_language;
log "Primary Language: " + var.primary_language;
```

#### Extracting specific cookie values

```vcl
declare local var.all_cookies STRING;
declare local var.session_cookie STRING;

# Get all cookies
set var.all_cookies = header.get(req, "Cookie");

# Extract a specific cookie value
set var.session_cookie = header.get(req, "Cookie:session_id");

# Log the result
log "All Cookies: " + var.all_cookies;
log "Session Cookie: " + var.session_cookie;
```

#### Conditional logic based on header presence

```vcl
if (header.get(req, "X-Requested-With") == "XMLHttpRequest") {
  # This is an AJAX request
  set req.http.X-Request-Type = "AJAX";
} else {
  # This is a regular request
  set req.http.X-Request-Type = "Regular";
}
```

#### Error handling for missing headers

```vcl
declare local var.authorization STRING;

# Get the Authorization header
set var.authorization = header.get(req, "Authorization");

# Check if the header exists
if (var.authorization == "") {
  # Header is missing
  log "Authorization header is missing";
  # Potentially return an error or set a default
  # error 401 "Authorization required";
} else {
  # Header exists
  log "Authorization header is present";
}
```

## header.set

Sets the value of an HTTP header.

### Syntax

```vcl
header.set(ID scope, STRING header_name, STRING header_value)
```

### Parameters

- `scope`: The request/response scope (req, resp, bereq, beresp)
- `header_name`: The name of the header to set
- `header_value`: The value to set for the header

### Return Value

None

### Examples

#### Basic header setting

```vcl
# Set a custom header
header.set(req, "X-Custom-Header", "Custom Value");

# Set the Host header
header.set(req, "Host", "example.com");
```

#### Setting headers based on conditions

```vcl
if (req.url ~ "^/api/") {
  # Set API-specific headers
  header.set(req, "X-API-Version", "1.0");
  header.set(req, "Accept", "application/json");
} else if (req.url ~ "^/admin/") {
  # Set admin-specific headers
  header.set(req, "X-Admin-Access", "true");
}
```

#### Setting security headers

This example demonstrates how to set security-related headers:

```vcl
# Set Content-Security-Policy
header.set(resp, "Content-Security-Policy", 
  "default-src 'self'; script-src 'self' https://trusted-cdn.com; style-src 'self' https://trusted-cdn.com; img-src 'self' data:;");

# Set X-XSS-Protection
header.set(resp, "X-XSS-Protection", "1; mode=block");

# Set X-Content-Type-Options
header.set(resp, "X-Content-Type-Options", "nosniff");

# Set X-Frame-Options
header.set(resp, "X-Frame-Options", "SAMEORIGIN");
```

#### Setting cache control headers

This example demonstrates how to set cache control headers:

```vcl
# Set Cache-Control header
header.set(resp, "Cache-Control", "public, max-age=86400");

# Set Expires header
header.set(resp, "Expires", time.add(now, 86400s));

# Set ETag header
header.set(resp, "ETag", digest.hash_md5(resp.body));
```

#### Setting headers for backend requests

This example demonstrates how to set headers for backend requests:

```vcl
# Set a custom header for the backend
header.set(bereq, "X-Forwarded-For", client.ip);

# Set the Host header for the backend
header.set(bereq, "Host", "backend.example.com");

# Set a custom header with the original client information
header.set(bereq, "X-Original-User-Agent", header.get(req, "User-Agent"));
```

## header.unset

Removes an HTTP header.

### Syntax

```vcl
header.unset(ID scope, STRING header_name)
```

### Parameters

- `scope`: The request/response scope (req, resp, bereq, beresp)
- `header_name`: The name of the header to remove

### Return Value

None

### Examples

#### Basic header removal

```vcl
# Remove the Cookie header
header.unset(req, "Cookie");

# Remove the User-Agent header
header.unset(req, "User-Agent");
```

#### Conditional header removal

This example demonstrates how to conditionally remove headers:

```vcl
# Remove the Referer header for privacy-sensitive paths
if (req.url ~ "^/private/") {
  header.unset(req, "Referer");
}

# Remove the Authorization header when proxying to certain backends
if (req.backend == F_public_backend) {
  header.unset(bereq, "Authorization");
}
```

#### Security-related header removal

This example demonstrates how to remove potentially sensitive headers:

```vcl
# Remove headers that might reveal server information
header.unset(resp, "Server");
header.unset(resp, "X-Powered-By");
header.unset(resp, "X-AspNet-Version");
header.unset(resp, "X-Runtime");
```

#### Cache optimization by removing unnecessary headers

This example demonstrates how to remove headers that might affect caching:

```vcl
# Remove headers that might prevent proper caching
header.unset(beresp, "Set-Cookie");
header.unset(beresp, "Pragma");
```

#### Cleaning up internal headers before sending response

This example demonstrates how to remove internal headers before sending the response:

```vcl
# Remove internal headers
header.unset(resp, "X-Internal-Debug");
header.unset(resp, "X-Cache-Status");
header.unset(resp, "X-Backend-Name");
```

## header.filter

Removes all HTTP headers that match a pattern.

### Syntax

```vcl
header.filter(ID scope, STRING header_name...)
```

### Parameters

- `scope`: The request/response scope (req, resp, bereq, beresp)
- `header_name...`: One or more header names to remove

### Return Value

None

### Examples

#### Basic header filtering

```vcl
# Remove all X-Debug headers
header.filter(req, "^X-Debug");

# Remove all temporary headers
header.filter(req, "^X-Temp-");
```

#### Security-related header filtering

This example demonstrates how to filter potentially sensitive headers:

```vcl
# Remove all headers that might contain sensitive information
header.filter(req, "^X-Auth-");
header.filter(req, "^X-Token-");
header.filter(req, "^X-API-Key");
```

#### Backend request optimization

This example demonstrates how to filter unnecessary headers for backend requests:

```vcl
# Remove all tracking-related headers when forwarding to the backend
header.filter(bereq, "^X-Track-");

# Remove all analytics-related headers
header.filter(bereq, "^X-Analytics-");
```

#### Response header cleanup

This example demonstrates how to clean up response headers:

```vcl
# Remove all internal headers from the response
header.filter(resp, "^X-Internal-");

# Remove all debug headers from the response
header.filter(resp, "^X-Debug-");
```

#### Compliance and privacy

This example demonstrates how to filter headers for compliance reasons:

```vcl
# Remove all headers that might contain PII (Personally Identifiable Information)
header.filter(req, "^X-User-");
header.filter(req, "^X-Account-");
header.filter(req, "^X-Email");
```

## header.filter_except

Removes all HTTP headers except those that match a pattern.

### Syntax

```vcl
header.filter_except(ID scope, STRING header_name...)
```

### Parameters

- `scope`: The request/response scope (req, resp, bereq, beresp)
- `header_name...`: One or more header names to keep (all others are removed)

### Return Value

None

### Examples

#### Basic header filtering except

```vcl
# Keep only essential headers, remove everything else
header.filter_except(req, "^(Host|User-Agent|Accept|Accept-Encoding|Authorization)$");
```

#### API request optimization

This example demonstrates how to keep only API-relevant headers:

```vcl
if (req.url ~ "^/api/") {
  # Keep only API-relevant headers
  header.filter_except(req, "^(Authorization|Content-Type|Accept|X-API-Version)$");
}
```

#### Security hardening

This example demonstrates how to keep only necessary headers for security reasons:

```vcl
if (req.url ~ "^/admin/") {
  # Keep only essential headers for admin requests
  header.filter_except(req, "^(Host|Authorization|X-CSRF-Token)$");
}
```

#### Backend request optimization

This example demonstrates how to optimize backend requests:

```vcl
# Keep only necessary headers for the backend
header.filter_except(bereq, "^(Host|X-Forwarded-For|Authorization|Content-Type|Accept)$");
```

#### Response header optimization

This example demonstrates how to optimize response headers:

```vcl
# Keep only necessary response headers
header.filter_except(resp, "^(Content-Type|Content-Length|Cache-Control|ETag|Expires|Vary)$");
```

## http\_status\_matches

Checks if an HTTP status code matches a pattern.

### Syntax

```vcl
BOOL http_status_matches(INTEGER status, STRING pattern)
```

### Parameters

- `status`: The HTTP status code to check
- `pattern`: A pattern to match against (e.g., "2xx", "404", "4xx", "client_error")

### Return Value

- TRUE if the status code matches the pattern
- FALSE otherwise

### Examples

#### Basic status code checking

```vcl
# Check if the response is successful
if (http_status_matches(resp.status, "2xx")) {
  set resp.http.X-Status-Category = "Success";
} else if (http_status_matches(resp.status, "3xx")) {
  set resp.http.X-Status-Category = "Redirect";
} else if (http_status_matches(resp.status, "4xx")) {
  set resp.http.X-Status-Category = "Client Error";
} else if (http_status_matches(resp.status, "5xx")) {
  set resp.http.X-Status-Category = "Server Error";
}
```

#### Specific error handling

This example demonstrates how to handle specific error codes:

```vcl
# Check for specific error codes
if (http_status_matches(resp.status, "404")) {
  # Handle 404 errors
  set resp.http.X-Error-Type = "Not Found";
  # Potentially modify the response or log the error
} else if (http_status_matches(resp.status, "403")) {
  # Handle 403 errors
  set resp.http.X-Error-Type = "Forbidden";
} else if (http_status_matches(resp.status, "500")) {
  # Handle 500 errors
  set resp.http.X-Error-Type = "Internal Server Error";
}
```

#### Logging based on status categories

This example demonstrates how to log based on status categories:

```vcl
# Log client errors
if (http_status_matches(resp.status, "client_error")) {
  log "Client Error: " + resp.status + " for " + req.url;
}

# Log server errors
if (http_status_matches(resp.status, "server_error")) {
  log "Server Error: " + resp.status + " for " + req.url;
}
```

#### Conditional response modification

This example demonstrates how to modify responses based on status:

```vcl
# Add debugging information for error responses
if (http_status_matches(resp.status, "error")) {
  set resp.http.X-Error-Debug = "Request ID: " + req.id + ", Backend: " + req.backend;
}
```

#### Cache control based on status

This example demonstrates how to adjust cache settings based on status:

```vcl
# Don't cache error responses
if (http_status_matches(resp.status, "error")) {
  set resp.http.Cache-Control = "no-store, no-cache, must-revalidate, max-age=0";
}

# Cache successful responses
if (http_status_matches(resp.status, "success")) {
  set resp.http.Cache-Control = "public, max-age=3600";
}
```

## Integrated Example: Complete HTTP header management system

This example demonstrates how all HTTP functions can work together to create a comprehensive header management system.

```vcl
sub vcl_recv {
  # Step 1: Clean up incoming request headers
  
  # Remove unnecessary headers
  header.filter_except(req, "^(Host|User-Agent|Accept|Accept-Encoding|Accept-Language|Authorization|Content-Type|Cookie|X-Forwarded-For)$");
  
  # Step 2: Extract important information from headers
  declare local var.user_agent STRING;
  declare local var.auth_token STRING;
  declare local var.content_type STRING;
  
  set var.user_agent = header.get(req, "User-Agent");
  set var.auth_token = header.get(req, "Authorization");
  set var.content_type = header.get(req, "Content-Type");
  
  # Step 3: Set custom headers based on the request
  
  # Set a request ID for tracking
  header.set(req, "X-Request-ID", digest.hash_md5(now + req.url + client.ip));
  
  # Set device type based on User-Agent
  if (var.user_agent ~ "(?i)mobile|android|iphone|ipod|blackberry") {
    header.set(req, "X-Device-Type", "mobile");
  } else if (var.user_agent ~ "(?i)ipad|tablet") {
    header.set(req, "X-Device-Type", "tablet");
  } else {
    header.set(req, "X-Device-Type", "desktop");
  }
  
  # Step 4: Handle authentication
  if (var.auth_token == "") {
    # No authentication provided
    header.set(req, "X-Auth-Status", "none");
  } else if (var.auth_token ~ "^Bearer ") {
    # JWT token authentication
    header.set(req, "X-Auth-Status", "jwt");
    header.set(req, "X-Auth-Type", "bearer");
  } else if (var.auth_token ~ "^Basic ") {
    # Basic authentication
    header.set(req, "X-Auth-Status", "basic");
    header.set(req, "X-Auth-Type", "basic");
  } else {
    # Unknown authentication type
    header.set(req, "X-Auth-Status", "unknown");
  }
  
  # Step 5: Prepare backend request headers
  
  # Set headers for the backend
  header.set(bereq, "X-Forwarded-For", client.ip);
  header.set(bereq, "X-Original-URL", req.url);
  header.set(bereq, "X-Device-Type", header.get(req, "X-Device-Type"));
  
  # Remove sensitive headers from backend request
  header.filter(bereq, "^Cookie");
  header.filter(bereq, "^X-Auth-");
}

sub vcl_deliver {
  # Step 6: Process response headers
  
  # Check response status
  if (http_status_matches(resp.status, "success")) {
    # Successful response
    header.set(resp, "X-Status-Category", "Success");
    
    # Set cache control headers for successful responses
    header.set(resp, "Cache-Control", "public, max-age=3600");
    header.set(resp, "Expires", time.add(now, 3600s));
    
  } else if (http_status_matches(resp.status, "redirect")) {
    # Redirect response
    header.set(resp, "X-Status-Category", "Redirect");
    
    # Set cache control headers for redirects
    header.set(resp, "Cache-Control", "public, max-age=300");
    header.set(resp, "Expires", time.add(now, 300s));
    
  } else if (http_status_matches(resp.status, "client_error")) {
    # Client error response
    header.set(resp, "X-Status-Category", "Client Error");
    
    # Don't cache client errors
    header.set(resp, "Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    header.unset(resp, "Expires");
    
    # Add debugging information
    header.set(resp, "X-Error-Debug", "Request ID: " + header.get(req, "X-Request-ID"));
    
  } else if (http_status_matches(resp.status, "server_error")) {
    # Server error response
    header.set(resp, "X-Status-Category", "Server Error");
    
    # Don't cache server errors
    header.set(resp, "Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    header.unset(resp, "Expires");
    
    # Add debugging information
    header.set(resp, "X-Error-Debug", "Request ID: " + header.get(req, "X-Request-ID") + ", Backend: " + req.backend);
  }
  
  # Step 7: Set security headers
  header.set(resp, "X-Content-Type-Options", "nosniff");
  header.set(resp, "X-XSS-Protection", "1; mode=block");
  header.set(resp, "X-Frame-Options", "SAMEORIGIN");
  
  # Step 8: Clean up internal headers
  header.filter(resp, "^X-Auth-");
  header.filter(resp, "^X-Internal-");
  header.filter(resp, "^X-Debug-");
  
  # Keep only necessary response headers
  header.filter_except(resp, "^(Content-Type|Content-Length|Cache-Control|ETag|Expires|Vary|X-Content-Type-Options|X-XSS-Protection|X-Frame-Options|X-Status-Category)$");
}
```

## Best Practices for HTTP Functions

1. Header Management:
   - Use header.filter_except to keep only necessary headers
   - Remove sensitive information from headers with header.filter
   - Set consistent security headers for all responses
   - Use descriptive names for custom headers (X-prefix for non-standard headers)

2. Status Code Handling:
   - Use http_status_matches for category-based status code handling
   - Implement different caching strategies based on status codes
   - Add debugging information for error responses
   - Log errors appropriately based on status categories

3. Security Considerations:
   - Remove headers that reveal server information
   - Set security headers like X-Content-Type-Options, X-XSS-Protection, etc.
   - Filter out sensitive headers before forwarding to backends
   - Validate and sanitize header values before using them

4. Performance Optimization:
   - Remove unnecessary headers to reduce payload size
   - Set appropriate cache control headers based on content type and status
   - Use Vary header correctly to ensure proper caching
   - Only forward necessary headers to backends

5. Debugging and Monitoring:
   - Add request IDs for tracking requests across systems
   - Include useful debugging information in error responses
   - Log important header values for troubleshooting
   - Use custom headers to track request flow through your system
