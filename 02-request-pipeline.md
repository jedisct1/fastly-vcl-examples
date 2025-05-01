# The HTTP Request Pipeline in Fastly VCL

## Overview

The HTTP request pipeline in Fastly VCL consists of a series of subroutines that are executed in a specific order as a request is processed. Each subroutine represents a different stage in the request lifecycle, and you can customize the behavior at each stage by adding your own VCL code.

Understanding this pipeline is crucial for effective VCL development, as it determines when and where your custom logic will be executed.

## The VCL State Machine

Fastly processes HTTP requests through a state machine, where each state corresponds to a VCL subroutine. The flow between states is determined by the return values from each subroutine.

Here's a visual representation of the VCL state machine:

```
           ┌─────────────┐
           │   Client    │
           │   Request   │
           └──────┬──────┘
                  │
                  ▼
           ┌─────────────┐
           │  vcl_recv   │◄────────────┐
           └──────┬──────┘             │
                  │                    │
         ┌────────┴────────┐           │
         │                 │           │
         ▼                 ▼           │
┌─────────────┐     ┌─────────────┐    │
│    pass     │     │   lookup    │    │
└──────┬──────┘     └──────┬──────┘    │
       │                   │           │
       │                   │           │
       │             ┌─────┴─────┐     │
       │             │           │     │
       │             ▼           ▼     │
       │      ┌─────────┐  ┌─────────┐ │
       │      │ vcl_hit │  │ vcl_miss│ │
       │      └────┬────┘  └────┬────┘ │
       │           │            │      │
       │           │            │      │
       │           │            ▼      │
       │           │      ┌──────────┐ │
       │           │      │ vcl_fetch│ │
       │           │      └────┬─────┘ │
       │           │           │       │
       ▼           ▼           ▼       │
┌─────────────────────────────────┐    │
│           vcl_deliver           │    │
└──────────────┬──────────────────┘    │
               │                       │
               ▼                       │
        ┌─────────────┐                │
        │   vcl_log   │                │
        └──────┬──────┘                │
               │                       │
               ▼                       │
        ┌─────────────┐                │
        │   restart?  │────yes─────────┘
        └──────┬──────┘
               │no
               ▼
        ┌─────────────┐
        │   Client    │
        │   Response  │
        └─────────────┘
```

## Subroutines in Detail

### vcl_recv

**Purpose**: This is the first subroutine executed when a request is received. It's used for request processing, manipulation, and routing decisions.

**Common Tasks**:
- URL normalization
- Header manipulation
- Backend selection
- Authentication checks
- Request filtering
- Bot detection
- A/B testing logic

**Possible Return Values**:
- `hash`: Proceed to `vcl_hash` to determine the cache key (default)
- `pass`: Bypass cache lookup and proceed to `vcl_pass`
- `error`: Jump to `vcl_error` with a specified status code
- `restart`: Restart the request processing from the beginning (limited to 3 restarts)

**Example**:
```vcl
sub vcl_recv {
    # Normalize URL to improve cache hit ratio
    if (req.url ~ "(\?|&)(utm_source|utm_medium|utm_campaign|gclid|fbclid)=") {
        set req.url = regsuball(req.url, "&?(utm_source|utm_medium|utm_campaign|gclid|fbclid)=([^&]*)", "");
        set req.url = regsuball(req.url, "\?&", "?");
        set req.url = regsub(req.url, "\?$", "");
    }
    
    # Route API requests to a specific backend
    if (req.url ~ "^/api/") {
        set req.backend = F_api_backend;
    }
    
    # Force cache miss for logged-in users
    if (req.http.Cookie ~ "session=") {
        return(pass);
    }
}
```

### vcl_hash

**Purpose**: Determines the cache key for the request, which is used to identify cached objects.

**Common Tasks**:
- Adding custom components to the cache key
- Varying cache based on cookies, headers, or other request attributes

**Possible Return Values**:
- `hash`: Proceed to cache lookup (default and only option)

**Example**:
```vcl
sub vcl_hash {
    # Default hash
    hash_data(req.url);
    
    if (req.http.host) {
        hash_data(req.http.host);
    } else {
        hash_data(server.ip);
    }
    
    # Vary cache based on mobile vs desktop
    if (req.http.User-Agent ~ "Mobile|Android|iPhone") {
        hash_data("mobile");
    } else {
        hash_data("desktop");
    }
    
    # Vary cache based on country
    if (req.http.X-Country-Code) {
        hash_data(req.http.X-Country-Code);
    }
    
    return(hash);
}
```

### vcl_hit

**Purpose**: Executed when the requested object is found in the cache.

**Common Tasks**:
- Deciding whether to serve the cached object
- Conditional cache invalidation
- Handling stale objects

**Possible Return Values**:
- `deliver`: Deliver the cached object to the client (default)
- `pass`: Bypass the cache and fetch from the backend
- `restart`: Restart the request processing
- `error`: Jump to `vcl_error` with a specified status code

**Example**:
```vcl
sub vcl_hit {
    # Don't serve cached content to authenticated users
    if (req.http.Cookie ~ "session=" && obj.ttl > 0s) {
        return(pass);
    }
    
    # Serve stale content if backend is unhealthy
    if (!req.backend.healthy && obj.ttl + obj.grace > 0s) {
        return(deliver);
    }
    
    # Force cache refresh for certain URLs every hour
    if (req.url ~ "^/dynamic-content/" && obj.ttl < 3600s) {
        return(pass);
    }
    
    return(deliver);
}
```

### vcl_miss

**Purpose**: Executed when the requested object is not found in the cache.

**Common Tasks**:
- Deciding whether to fetch the object from the backend
- Setting backend-specific parameters
- Conditional request routing

**Possible Return Values**:
- `fetch`: Fetch the object from the backend (default)
- `pass`: Bypass cache storage and fetch from the backend
- `error`: Jump to `vcl_error` with a specified status code
- `deliver_stale`: Deliver stale content if available

**Example**:
```vcl
sub vcl_miss {
    # Set longer timeout for specific URLs
    if (req.url ~ "^/api/long-running/") {
        set bereq.first_byte_timeout = 60s;
    }
    
    # Use a different backend for certain paths
    if (req.url ~ "^/legacy/") {
        set bereq.backend = F_legacy_backend;
    }
    
    # Add custom headers to backend request
    set bereq.http.X-Request-ID = digest.hash_sha256(now + req.url);
    
    return(fetch);
}
```

### vcl_pass

**Purpose**: Executed when cache lookup is bypassed.

**Common Tasks**:
- Setting backend-specific parameters
- Modifying the backend request

**Possible Return Values**:
- `pass`: Proceed with pass mode (default)
- `error`: Jump to `vcl_error` with a specified status code

**Example**:
```vcl
sub vcl_pass {
    # Set custom timeout for pass requests
    set bereq.first_byte_timeout = 15s;
    
    # Add custom headers to backend request
    set bereq.http.X-Cache-Mode = "pass";
    set bereq.http.X-Forwarded-For = client.ip;
    
    return(pass);
}
```

### vcl_fetch (also known as vcl_backend_response)

**Purpose**: Executed after receiving a response from the backend.

**Common Tasks**:
- Setting cache TTL
- Response header manipulation
- Content modification
- Error handling
- Deciding whether to cache the response

**Possible Return Values**:
- `deliver`: Cache the object and deliver it (default)
- `pass`: Do not cache the object
- `error`: Jump to `vcl_error` with a specified status code
- `restart`: Restart the request processing
- `hit_for_pass`: Do not cache this response, and pass subsequent requests for this object
- `deliver_stale`: Deliver stale content if available

**Example**:
```vcl
sub vcl_fetch {
    # Set different cache TTLs based on content type
    if (beresp.http.Content-Type ~ "text/html") {
        set beresp.ttl = 1h;
    } else if (beresp.http.Content-Type ~ "image/") {
        set beresp.ttl = 7d;
    } else if (beresp.http.Content-Type ~ "application/javascript") {
        set beresp.ttl = 24h;
    } else {
        set beresp.ttl = 4h;
    }
    
    # Don't cache error responses
    if (beresp.status >= 500) {
        return(pass);
    }
    
    # Enable gzip compression for text-based content
    if (beresp.http.Content-Type ~ "text/" || 
        beresp.http.Content-Type ~ "application/json" || 
        beresp.http.Content-Type ~ "application/javascript") {
        set beresp.gzip = true;
    }
    
    # Set a longer grace period for API responses
    if (bereq.url ~ "^/api/") {
        set beresp.grace = 24h;
    }
    
    return(deliver);
}
```

### vcl_error

**Purpose**: Executed when an error occurs or when explicitly called with `error`.

**Common Tasks**:
- Custom error page generation
- Error logging
- Conditional error handling

**Possible Return Values**:
- `deliver`: Deliver the error response (default)
- `restart`: Restart the request processing
- `deliver_stale`: Deliver stale content if available

**Example**:
```vcl
sub vcl_error {
    # Custom 404 page
    if (obj.status == 404) {
        set obj.http.Content-Type = "text/html; charset=utf-8";
        set obj.response = "Not Found";
        synthetic {"
<!DOCTYPE html>
<html>
<head>
    <title>Page Not Found</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        h1 { color: #333; }
    </style>
</head>
<body>
    <h1>Page Not Found</h1>
    <p>The page you requested could not be found. Please check the URL and try again.</p>
    <p><a href="/">Return to homepage</a></p>
</body>
</html>
        "};
        return(deliver);
    }
    
    # Custom maintenance page for 503 errors
    if (obj.status == 503) {
        set obj.http.Content-Type = "text/html; charset=utf-8";
        set obj.response = "Service Unavailable";
        set obj.http.Retry-After = "300";
        synthetic {"
<!DOCTYPE html>
<html>
<head>
    <title>Temporarily Unavailable</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        h1 { color: #c00; }
    </style>
</head>
<body>
    <h1>Temporarily Unavailable</h1>
    <p>We're sorry, but our service is currently undergoing maintenance.</p>
    <p>Please try again in a few minutes.</p>
</body>
</html>
        "};
        return(deliver);
    }
}
```

### vcl_deliver

**Purpose**: Executed before delivering the response to the client.

**Common Tasks**:
- Response header manipulation
- Adding debug information
- Setting cookies
- Response body modification

**Possible Return Values**:
- `deliver`: Deliver the response to the client (default)
- `restart`: Restart the request processing

**Example**:
```vcl
sub vcl_deliver {
    # Add cache status header
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
        set resp.http.X-Cache-Hits = obj.hits;
    } else {
        set resp.http.X-Cache = "MISS";
    }
    
    # Remove internal headers
    unset resp.http.X-Varnish;
    unset resp.http.Via;
    unset resp.http.X-Served-By;
    unset resp.http.X-Cache-Hits;
    unset resp.http.X-Timer;
    
    # Add security headers
    set resp.http.Strict-Transport-Security = "max-age=31536000; includeSubDomains";
    set resp.http.X-Content-Type-Options = "nosniff";
    set resp.http.X-Frame-Options = "DENY";
    set resp.http.X-XSS-Protection = "1; mode=block";
    
    # Add debug headers in development environment
    if (req.http.Host ~ "dev\.example\.com") {
        set resp.http.X-Debug-URL = req.url;
        set resp.http.X-Debug-TTL = obj.ttl;
        set resp.http.X-Debug-Grace = obj.grace;
    }
    
    return(deliver);
}
```

### vcl_log

**Purpose**: Executed after the response has been delivered to the client.

**Common Tasks**:
- Logging
- Analytics
- Post-processing

**Possible Return Values**:
- `deliver`: Complete the request (default)

**Example**:
```vcl
sub vcl_log {
    # Log detailed information about the request
    log {"syslog "} req.service_id {" request_info :: "} 
        {"client_ip="} client.ip {" "}
        {"request_method="} req.method {" "}
        {"url="} req.url {" "}
        {"protocol="} req.proto {" "}
        {"status="} resp.status {" "}
        {"cache_status="} fastly_info.state {" "}
        {"ttl="} obj.ttl {" "}
        {"server="} server.identity;
    
    return(deliver);
}
```

## Request Flow Examples

### Cache Hit Flow

1. Client sends request
2. `vcl_recv` processes the request
3. `vcl_hash` determines the cache key
4. Object is found in cache, so `vcl_hit` is executed
5. `vcl_deliver` prepares the response
6. `vcl_log` logs the request
7. Response is sent to the client

### Cache Miss Flow

1. Client sends request
2. `vcl_recv` processes the request
3. `vcl_hash` determines the cache key
4. Object is not found in cache, so `vcl_miss` is executed
5. Request is sent to the backend
6. Backend responds, and `vcl_fetch` processes the response
7. `vcl_deliver` prepares the response
8. `vcl_log` logs the request
9. Response is sent to the client and stored in cache

### Pass Flow

1. Client sends request
2. `vcl_recv` processes the request and returns `pass`
3. `vcl_pass` is executed
4. Request is sent to the backend
5. Backend responds, and `vcl_fetch` processes the response
6. `vcl_deliver` prepares the response
7. `vcl_log` logs the request
8. Response is sent to the client but not stored in cache

## Best Practices

1. **Be Mindful of Return Values**: The return value from each subroutine determines the flow of the request. Make sure you understand the implications of each return value.

2. **Use Conditional Logic**: Use conditions to apply different logic based on request attributes, such as URL, headers, or cookies.

3. **Keep Performance in Mind**: VCL code is executed for every request, so keep your code efficient and avoid unnecessary operations.

4. **Test Thoroughly**: Test your VCL code in a staging environment before deploying to production, as errors can affect all requests.

5. **Use Comments**: Document your VCL code with comments to explain the purpose of each section, especially for complex logic.

6. **Leverage Fastly's Debugging Tools**: Use Fastly's debugging headers and logging to troubleshoot issues with your VCL code.

7. **Consider Edge Cases**: Think about how your VCL code will handle edge cases, such as malformed requests or backend failures.

In the next section, we'll explore VCL syntax and basic constructs in more detail.