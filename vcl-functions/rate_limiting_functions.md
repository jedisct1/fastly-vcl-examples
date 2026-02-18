# Rate Limiting Functions

This file demonstrates comprehensive examples of Rate Limiting Functions in VCL.
These functions help implement rate limiting, request throttling, and abuse prevention
at the edge, protecting origin servers from excessive traffic and potential attacks.

## ratelimit.ratecounter_increment

Increments a rate counter for a given entry by a specified amount.

### Syntax

```vcl
INTEGER ratelimit.ratecounter_increment(ID ratecounter, STRING entry, INTEGER delta)
```

### Parameters

- `ratecounter`: A declared `ratecounter` object ID
- `entry`: The entry key to increment (e.g., `client.ip`, a user ID)
- `delta`: The amount to increment the counter by

### Return Value

INTEGER -- the new counter value for this entry

### Examples

#### Basic rate counter increment

```vcl
# Increment the rc_requests rate counter for this client by 1
declare local var.count INTEGER;
set var.count = ratelimit.ratecounter_increment(rc_requests, client.ip, 1);
```

#### Incrementing counters with different weights

```vcl
# Track API requests with different weights based on resource intensity
declare local var.count INTEGER;
if (req.url ~ "^/api/light/") {
  # Light API requests count as 1
  set var.count = ratelimit.ratecounter_increment(rc_api, client.ip, 1);
} else if (req.url ~ "^/api/medium/") {
  # Medium API requests count as 2
  set var.count = ratelimit.ratecounter_increment(rc_api, client.ip, 2);
} else if (req.url ~ "^/api/heavy/") {
  # Heavy API requests count as 5
  set var.count = ratelimit.ratecounter_increment(rc_api, client.ip, 5);
}
```

#### User-specific rate counters

```vcl
declare local var.user_id STRING;
declare local var.count INTEGER;

# Get user identifier (from auth token, cookie, or IP)
if (req.http.Authorization) {
  set var.user_id = digest.hash_md5(req.http.Authorization);
} else if (req.http.Cookie:user_id) {
  set var.user_id = req.http.Cookie:user_id;
} else {
  set var.user_id = client.ip;
}

# Increment rate counter using the user ID as the entry key
set var.count = ratelimit.ratecounter_increment(rc_users, var.user_id, 1);
```

## ratelimit.check_rate

Checks if a rate limit has been exceeded for a single rate counter window,
and optionally adds the entry to a penalty box if the limit is exceeded.

### Syntax

```vcl
BOOL ratelimit.check_rate(STRING entry, ID ratecounter, INTEGER delta, INTEGER window, INTEGER limit, ID penaltybox, RTIME ttl)
```

### Parameters

- `entry`: The entry key to check (e.g., `client.ip`, a user ID string)
- `ratecounter`: A declared `ratecounter` object ID
- `delta`: The amount to increment the counter by for this request
- `window`: The time window in seconds to measure the rate over
- `limit`: The maximum number of requests allowed in the window
- `penaltybox`: A declared `penaltybox` object ID. If the limit is exceeded, the entry is added to this penalty box.
- `ttl`: How long (RTIME) to keep the entry in the penalty box when the limit is exceeded

### Return Value

- TRUE if the rate limit has been exceeded (entry is in the penalty box or the limit was just exceeded)
- FALSE otherwise

### Examples

#### Basic rate limiting

```vcl
declare local var.rate_exceeded BOOL;

# Check if this client exceeds 100 requests per 60 seconds.
# Increments the counter by 1 for each request.
# If exceeded, the client is added to pb_requests for 5 minutes.
set var.rate_exceeded = ratelimit.check_rate(client.ip, rc_requests, 1, 60, 100, pb_requests, 5m);

if (var.rate_exceeded) {
  error 429 "Too Many Requests";
}
```

#### User-specific rate limiting

```vcl
declare local var.user_id STRING;
declare local var.user_rate_exceeded BOOL;

# Get user identifier (from auth token, cookie, or IP)
if (req.http.Authorization) {
  set var.user_id = digest.hash_md5(req.http.Authorization);
} else if (req.http.Cookie:user_id) {
  set var.user_id = req.http.Cookie:user_id;
} else {
  set var.user_id = client.ip;
}

# Check if user exceeds 60 requests per 60s window.
# If exceeded, add to penalty box for 2 minutes.
set var.user_rate_exceeded = ratelimit.check_rate(var.user_id, rc_users, 1, 60, 60, pb_users, 2m);

if (var.user_rate_exceeded) {
  error 429 "User Rate Limit Exceeded";
}
```

#### Login endpoint rate limiting

```vcl
declare local var.login_limited BOOL;

# Limit login attempts to 5 per 60 seconds per IP.
# Offenders are put in the penalty box for 15 minutes.
if (req.url.path == "/login" && req.method == "POST") {
  set var.login_limited = ratelimit.check_rate(client.ip, rc_login, 1, 60, 5, pb_login, 15m);

  if (var.login_limited) {
    error 429 "Too Many Login Attempts";
  }
}
```

## ratelimit.check_rates

Checks two rate counter windows simultaneously. If either rate limit is exceeded,
the entry is added to the penalty box. This lets you enforce a short burst limit
and a longer sustained limit at the same time.

### Syntax

```vcl
BOOL ratelimit.check_rates(STRING entry, ID ratecounter_1, INTEGER delta_1, INTEGER window_1, INTEGER limit_1, ID ratecounter_2, INTEGER delta_2, INTEGER window_2, INTEGER limit_2, ID penaltybox, RTIME ttl)
```

### Parameters

- `entry`: The entry key to check (e.g., `client.ip`, a user ID string)
- `ratecounter_1`: First declared `ratecounter` object ID
- `delta_1`: Increment for the first counter
- `window_1`: Time window in seconds for the first counter
- `limit_1`: Max requests in the first window
- `ratecounter_2`: Second declared `ratecounter` object ID
- `delta_2`: Increment for the second counter
- `window_2`: Time window in seconds for the second counter
- `limit_2`: Max requests in the second window
- `penaltybox`: A declared `penaltybox` object ID
- `ttl`: How long (RTIME) to keep the entry in the penalty box

### Return Value

- TRUE if either rate limit has been exceeded
- FALSE otherwise

### Examples

#### Two-window rate limiting

```vcl
declare local var.rates_exceeded BOOL;

# Check two windows at once:
#   Window 1 (rc_short): 10 requests per 10 seconds
#   Window 2 (rc_long):  100 requests per 60 seconds
# If either is exceeded, add client to pb_global for 5 minutes.
set var.rates_exceeded = ratelimit.check_rates(client.ip, rc_short, 1, 10, 10, rc_long, 1, 60, 100, pb_global, 5m);

if (var.rates_exceeded) {
  error 429 "Rate Limit Exceeded";
}
```

#### User-specific two-window rate limiting

```vcl
declare local var.user_id STRING;
declare local var.user_rates_exceeded BOOL;

# Get user identifier
if (req.http.Authorization) {
  set var.user_id = digest.hash_md5(req.http.Authorization);
} else if (req.http.Cookie:user_id) {
  set var.user_id = req.http.Cookie:user_id;
} else {
  set var.user_id = client.ip;
}

# Two-window check per user:
#   Window 1 (rc_burst): 5 requests per 10 seconds
#   Window 2 (rc_sustained): 50 requests per 60 seconds
# If either is exceeded, penalize the user for 2 minutes.
set var.user_rates_exceeded = ratelimit.check_rates(var.user_id, rc_burst, 1, 10, 5, rc_sustained, 1, 60, 50, pb_users, 2m);

if (var.user_rates_exceeded) {
  error 429 "User Rate Limit Exceeded";
}
```

#### API two-window rate limiting

```vcl
declare local var.api_rates_exceeded BOOL;

# Protect API endpoints with a burst limit and a sustained limit:
#   Window 1 (rc_api_burst): 10 requests per 10 seconds
#   Window 2 (rc_api_sustained): 100 requests per 60 seconds
# Offenders go into pb_api for 10 minutes.
if (req.url ~ "^/api/") {
  set var.api_rates_exceeded = ratelimit.check_rates(client.ip, rc_api_burst, 1, 10, 10, rc_api_sustained, 1, 60, 100, pb_api, 10m);

  if (var.api_rates_exceeded) {
    error 429 "API Rate Limit Exceeded";
  }
}
```

## ratelimit.penaltybox_add

Adds an entry to a penalty box for a specified duration. While an entry is in the
penalty box, `ratelimit.penaltybox_has` will return TRUE for that entry.

### Syntax

```vcl
ratelimit.penaltybox_add(ID penaltybox, STRING entry, RTIME ttl)
```

### Parameters

- `penaltybox`: A declared `penaltybox` object ID
- `entry`: The entry key to add (e.g., `client.ip`, a user ID)
- `ttl`: How long to keep the entry in the penalty box (RTIME, e.g. `5m`, `1h`, `30s`)

### Return Value

None

### Examples

#### Basic penalty box usage

```vcl
declare local var.user_id STRING;
declare local var.rate_exceeded BOOL;

# Get user identifier
if (req.http.Authorization) {
  set var.user_id = digest.hash_md5(req.http.Authorization);
} else if (req.http.Cookie:user_id) {
  set var.user_id = req.http.Cookie:user_id;
} else {
  set var.user_id = client.ip;
}

# Manually add user to penalty box for 5 minutes
ratelimit.penaltybox_add(pb_users, var.user_id, 5m);

error 429 "Rate Limit Exceeded - Please try again later";
```

#### IP-based penalty box for suspicious activity

```vcl
declare local var.is_suspicious BOOL;

# Determine if request is suspicious (simplified example)
set var.is_suspicious = (
  req.http.User-Agent == "" ||
  req.http.User-Agent ~ "^$" ||
  req.url ~ "\.(php|asp|aspx|jsp)\.js$" ||
  req.url ~ "select.*from" ||
  req.url ~ "union.*select" ||
  req.url ~ "insert.*into"
);

if (var.is_suspicious) {
  # Add IP to penalty box for 1 hour
  ratelimit.penaltybox_add(pb_suspicious, client.ip, 1h);

  error 403 "Forbidden";
}
```

#### Different penalty box durations

```vcl
# Add to penalty box for 10 minutes after API abuse
ratelimit.penaltybox_add(pb_api, var.user_id, 10m);

# Add to penalty box for 15 minutes after login abuse
ratelimit.penaltybox_add(pb_login, client.ip, 15m);

# Add to penalty box for 24 hours for severe violations
ratelimit.penaltybox_add(pb_severe, client.ip, 24h);
```

## ratelimit.penaltybox_has

Checks if an entry is currently in a penalty box.

### Syntax

```vcl
BOOL ratelimit.penaltybox_has(ID penaltybox, STRING entry)
```

### Parameters

- `penaltybox`: A declared `penaltybox` object ID
- `entry`: The entry key to check

### Return Value

- TRUE if the identifier is in the penalty box
- FALSE otherwise

### Examples

#### Basic penalty box check

```vcl
declare local var.user_id STRING;
declare local var.in_penalty_box BOOL;

# Get user identifier
if (req.http.Authorization) {
  set var.user_id = digest.hash_md5(req.http.Authorization);
} else if (req.http.Cookie:user_id) {
  set var.user_id = req.http.Cookie:user_id;
} else {
  set var.user_id = client.ip;
}

# Check if user is in penalty box
set var.in_penalty_box = ratelimit.penaltybox_has(pb_users, var.user_id);

if (var.in_penalty_box) {
  error 429 "Too Many Requests - Please try again later";
}
```

#### IP-based penalty box check for suspicious activity

```vcl
declare local var.ip_blocked BOOL;

# Check if IP is in suspicious IPs penalty box
set var.ip_blocked = ratelimit.penaltybox_has(pb_suspicious, client.ip);

if (var.ip_blocked) {
  error 403 "Forbidden";
}
```

#### Checking multiple penalty boxes

```vcl
declare local var.in_any_penalty_box BOOL;

# Check if user/IP is in any penalty box
set var.in_any_penalty_box = (
  ratelimit.penaltybox_has(pb_users, var.user_id) ||
  ratelimit.penaltybox_has(pb_api, var.user_id) ||
  ratelimit.penaltybox_has(pb_login, client.ip) ||
  ratelimit.penaltybox_has(pb_suspicious, client.ip)
);

if (var.in_any_penalty_box) {
  error 429 "Access Temporarily Restricted";
}
```

#### Different handling based on penalty box type

```vcl
declare local var.in_api_penalty BOOL;
declare local var.in_login_penalty BOOL;

# Check specific penalty boxes
set var.in_api_penalty = ratelimit.penaltybox_has(pb_api, var.user_id);
set var.in_login_penalty = ratelimit.penaltybox_has(pb_login, client.ip);

# Handle differently based on penalty box type
if (var.in_api_penalty) {
  if (req.url ~ "^/api/") {
    error 429 "API Access Restricted";
  }
}

if (var.in_login_penalty) {
  if (req.url.path == "/login") {
    error 429 "Too Many Login Attempts";
  }
}
```

#### Penalty box check with custom response headers

```vcl
declare local var.in_penalty BOOL;

# Check if in penalty box
set var.in_penalty = ratelimit.penaltybox_has(pb_users, var.user_id);

if (var.in_penalty) {
  set req.http.X-Rate-Limited = "true";
  set req.http.Retry-After = "300";

  error 429 "Rate Limit Exceeded";
}
```

## Integrated Example: Complete Rate Limiting System

This example demonstrates how multiple rate limiting functions work together.
You need to declare `ratecounter` and `penaltybox` objects at the top level of
your VCL, then reference them by ID in the function calls.

```vcl
ratecounter rc_global {}
ratecounter rc_api_burst {}
ratecounter rc_api_sustained {}
ratecounter rc_login {}
penaltybox pb_global {}
penaltybox pb_api {}
penaltybox pb_login {}

sub vcl_recv {
  declare local var.user_id STRING;

  # Get user identifier (from auth token, cookie, or IP)
  if (req.http.Authorization) {
    set var.user_id = digest.hash_md5(req.http.Authorization);
  } else if (req.http.Cookie:user_id) {
    set var.user_id = req.http.Cookie:user_id;
  } else {
    set var.user_id = client.ip;
  }

  # Early exit: check if user is already in any penalty box
  declare local var.in_penalty_box BOOL;

  set var.in_penalty_box = (
    ratelimit.penaltybox_has(pb_global, var.user_id) ||
    ratelimit.penaltybox_has(pb_api, var.user_id) ||
    ratelimit.penaltybox_has(pb_login, var.user_id)
  );

  if (var.in_penalty_box) {
    error 429 "Too Many Requests - Please try again later";
  }

  # Check global rate limit: 100 requests per 60 seconds
  declare local var.global_exceeded BOOL;
  set var.global_exceeded = ratelimit.check_rate(var.user_id, rc_global, 1, 60, 100, pb_global, 5m);

  if (var.global_exceeded) {
    error 429 "Global Rate Limit Exceeded";
  }

  # Check API rate limits with two windows (burst + sustained)
  if (req.url ~ "^/api/") {
    declare local var.api_exceeded BOOL;
    set var.api_exceeded = ratelimit.check_rates(var.user_id, rc_api_burst, 1, 10, 10, rc_api_sustained, 1, 60, 100, pb_api, 10m);

    if (var.api_exceeded) {
      error 429 "API Rate Limit Exceeded";
    }
  }

  # Check login rate limit: 5 attempts per 60 seconds
  if (req.url.path == "/login" && req.method == "POST") {
    declare local var.login_exceeded BOOL;
    set var.login_exceeded = ratelimit.check_rate(var.user_id, rc_login, 1, 60, 5, pb_login, 15m);

    if (var.login_exceeded) {
      error 429 "Login Rate Limit Exceeded";
    }
  }
}
```

## Best Practices for Rate Limiting Functions

1. User Identification:
   - Use a consistent identifier for users (auth token, cookie, IP)
   - Consider the implications of using IP addresses (shared IPs, proxies)
   - Hash sensitive identifiers for privacy

2. Rate Limit Design:
   - Implement multi-window rate limits for comprehensive protection
   - Set different limits for different endpoints based on resource intensity
   - Consider tiered rate limits for different user types

3. Penalty Box Usage:
   - Use penalty boxes for temporary blocking after rate limit violations
   - Implement graduated penalty durations for repeat offenders
   - Check penalty boxes early in the request flow for efficiency

4. Response Handling:
   - Return appropriate status codes (429 Too Many Requests)
   - Include helpful headers (Retry-After, X-Rate-Limit-*)
   - Provide clear error messages to help clients understand limits

5. Counter Naming:
   - Use consistent naming conventions for counters
   - Include user identifiers in counter names for user-specific limits
   - Consider namespace prefixes for different types of rate limits

6. Performance Considerations:
   - Check penalty boxes before incrementing counters
   - Use the most specific rate limit checks first
   - Be mindful of the performance impact of complex rate limiting logic

7. Monitoring and Tuning:
   - Monitor rate limit violations and adjust limits as needed
   - Track penalty box additions to identify potential attacks
   - Regularly review and tune rate limits based on traffic patterns
