/**
 * FASTLY VCL EXAMPLES - ACCEPT HEADER FUNCTIONS
 * 
 * This file demonstrates comprehensive examples of Accept Header Functions in VCL.
 * These functions help parse and work with HTTP Accept headers according to RFC standards.
 */

/**
 * FUNCTION: accept.language_lookup
 * 
 * PURPOSE: Selects the best match from an Accept-Language header value against available languages
 * SYNTAX: accept.language_lookup(STRING available_languages, STRING default_language, STRING accept_language_header)
 * 
 * PARAMETERS:
 *   - available_languages: Colon-separated list of languages available for the resource
 *   - default_language: Fallback language if no match is found
 *   - accept_language_header: The Accept-Language header value to parse
 * 
 * RETURN VALUE: The best matching language from the available list, or the default if no match
 * 
 * RFC COMPLIANCE: Conforms to RFC 4647, Section 3.4
 */

sub vcl_recv {
  # EXAMPLE 1: Basic language selection
  # This example selects the best language match from the Accept-Language header
  declare local var.selected_language STRING;
  set var.selected_language = accept.language_lookup(
    "en:fr:de:es:it:ja", # Available languages
    "en",                # Default language
    req.http.Accept-Language
  );
  
  # Use the selected language for content negotiation
  set req.http.X-Language = var.selected_language;
  
  # EXAMPLE 2: Language-based backend routing
  # This example demonstrates how to route to different backends based on language
  if (var.selected_language == "ja") {
    # Route Japanese users to a Japan-specific backend
    set req.backend = F_japan_backend;
  } else if (var.selected_language == "de" || var.selected_language == "fr") {
    # Route German and French users to European backend
    set req.backend = F_europe_backend;
  } else {
    # Default backend for other languages
    set req.backend = F_default_backend;
  }
  
  # EXAMPLE 3: Language-based URL rewriting
  # This example shows how to rewrite URLs based on language preference
  if (req.url.path == "/" || req.url.path == "/index.html") {
    set req.url = "/" + var.selected_language + req.url;
  }
  
  # EXAMPLE 4: Error handling with invalid Accept-Language header
  # This example demonstrates how to handle potentially invalid headers
  declare local var.safe_accept_language STRING;
  
  if (req.http.Accept-Language) {
    set var.safe_accept_language = req.http.Accept-Language;
  } else {
    # If Accept-Language header is missing, use a default value
    set var.safe_accept_language = "en";
  }
  
  # Now use the safe value
  set var.selected_language = accept.language_lookup(
    "en:fr:de:es:it:ja",
    "en",
    var.safe_accept_language
  );
}

/**
 * FUNCTION: accept.charset_lookup
 * 
 * PURPOSE: Selects the best match from an Accept-Charset header value against available charsets
 * SYNTAX: accept.charset_lookup(STRING available_charsets, STRING default_charset, STRING accept_charset_header)
 * 
 * PARAMETERS:
 *   - available_charsets: Colon-separated list of charsets available for the resource
 *   - default_charset: Fallback charset if no match is found
 *   - accept_charset_header: The Accept-Charset header value to parse
 * 
 * RETURN VALUE: The best matching charset from the available list, or the default if no match
 */

sub vcl_recv {
  # EXAMPLE 1: Basic charset selection
  declare local var.selected_charset STRING;
  set var.selected_charset = accept.charset_lookup(
    "utf-8:iso-8859-1:shift_jis:euc-jp", # Available charsets
    "utf-8",                             # Default charset
    req.http.Accept-Charset
  );
  
  # Use the selected charset
  set req.http.X-Charset = var.selected_charset;
  
  # EXAMPLE 2: Content negotiation with charset
  # This example demonstrates how to set the appropriate charset in backend requests
  if (var.selected_charset != "utf-8") {
    set bereq.http.Accept-Charset = var.selected_charset;
  }
}

/**
 * FUNCTION: accept.encoding_lookup
 * 
 * PURPOSE: Selects the best match from an Accept-Encoding header value against available encodings
 * SYNTAX: accept.encoding_lookup(STRING available_encodings, STRING default_encoding, STRING accept_encoding_header)
 * 
 * PARAMETERS:
 *   - available_encodings: Colon-separated list of encodings available for the resource
 *   - default_encoding: Fallback encoding if no match is found
 *   - accept_encoding_header: The Accept-Encoding header value to parse
 * 
 * RETURN VALUE: The best matching encoding from the available list, or the default if no match
 */

sub vcl_recv {
  # EXAMPLE 1: Content compression negotiation
  declare local var.selected_encoding STRING;
  set var.selected_encoding = accept.encoding_lookup(
    "br:gzip:deflate:identity", # Available encodings
    "identity",                 # Default encoding (no compression)
    req.http.Accept-Encoding
  );
  
  # EXAMPLE 2: Setting Fastly compression based on client capabilities
  if (var.selected_encoding == "br") {
    # Brotli compression is preferred and available
    set req.http.X-Compression = "br";
    # Enable Brotli compression in Fastly
    set req.http.X-Fastly-Compression = "br";
  } else if (var.selected_encoding == "gzip") {
    # Gzip compression is preferred and available
    set req.http.X-Compression = "gzip";
    # Enable gzip compression in Fastly
    set req.http.X-Fastly-Compression = "gzip";
  } else {
    # No compression or other type
    set req.http.X-Compression = var.selected_encoding;
    # Disable compression in Fastly
    set req.http.X-Fastly-Compression = "0";
  }
  
  # EXAMPLE 3: Vary header management for proper caching
  # Ensure responses are properly cached based on encoding
  if (var.selected_encoding != "identity") {
    # Make sure Vary header includes Accept-Encoding
    if (beresp.http.Vary) {
      if (beresp.http.Vary !~ "(?i)Accept-Encoding") {
        set beresp.http.Vary = beresp.http.Vary + ", Accept-Encoding";
      }
    } else {
      set beresp.http.Vary = "Accept-Encoding";
    }
  }
}

/**
 * FUNCTION: accept.media_lookup
 *
 * PURPOSE: Selects the best match from an Accept header value against available media types
 * SYNTAX: accept.media_lookup(STRING available_media_types, STRING default_media_type, STRING media_type_patterns, STRING accept_header)
 *
 * PARAMETERS:
 *   - available_media_types: Colon-separated list of media types available for the resource
 *   - default_media_type: Fallback media type if no match is found
 *   - media_type_patterns: Colon-separated list of media types, each corresponding to a media type pattern
 *   - accept_header: The Accept header value to parse
 *
 * RETURN VALUE: The best matching media type from the available list, or the default if no match
 */

sub vcl_recv {
  # EXAMPLE 1: Content type negotiation
  declare local var.selected_media_type STRING;
  set var.selected_media_type = accept.media_lookup(
    "application/json:application/xml:text/html:text/plain", # Available media types
    "application/json",                                      # Default media type
    "application/json:application/xml:text/html:text/plain", # Media type patterns
    req.http.Accept
  );
  
  # EXAMPLE 2: API version content negotiation
  # This example demonstrates how to handle API versioning through content negotiation
  if (req.url ~ "^/api/") {
    declare local var.api_media_types STRING;
    set var.api_media_types = "application/vnd.company.api.v2+json:" +
                             "application/vnd.company.api.v1+json:" +
                             "application/json";
    
    set var.selected_media_type = accept.media_lookup(
      var.api_media_types,
      "application/json", # Default to latest version
      var.api_media_types, # Media type patterns
      req.http.Accept
    );
    
    # Set API version based on selected media type
    if (var.selected_media_type == "application/vnd.company.api.v2+json") {
      set req.http.X-API-Version = "v2";
    } else if (var.selected_media_type == "application/vnd.company.api.v1+json") {
      set req.http.X-API-Version = "v1";
    } else {
      set req.http.X-API-Version = "v2"; # Default to latest
    }
  }
  
  # EXAMPLE 3: Format-based URL rewriting
  # This example shows how to rewrite URLs based on preferred format
  if (req.url !~ "\.(json|xml|html|txt)$") {
    if (var.selected_media_type == "application/json") {
      set req.url = req.url + ".json";
    } else if (var.selected_media_type == "application/xml") {
      set req.url = req.url + ".xml";
    } else if (var.selected_media_type == "text/html") {
      set req.url = req.url + ".html";
    } else if (var.selected_media_type == "text/plain") {
      set req.url = req.url + ".txt";
    }
  }
}

/**
 * INTEGRATED EXAMPLE: Complete content negotiation system
 * 
 * This example demonstrates how all accept header functions can work together
 * to create a comprehensive content negotiation system.
 */

sub vcl_recv {
  # Step 1: Determine the client's preferred language
  declare local var.language STRING;
  set var.language = accept.language_lookup(
    "en:fr:de:ja:es",
    "en",
    req.http.Accept-Language
  );
  
  # Step 2: Determine the client's preferred media type
  declare local var.format STRING;
  set var.format = accept.media_lookup(
    "application/json:application/xml:text/html",
    "text/html",
    "application/json:application/xml:text/html", # Media type patterns
    req.http.Accept
  );
  
  # Step 3: Determine the client's preferred charset
  declare local var.charset STRING;
  set var.charset = accept.charset_lookup(
    "utf-8:iso-8859-1",
    "utf-8",
    req.http.Accept-Charset
  );
  
  # Step 4: Determine the client's preferred encoding
  declare local var.encoding STRING;
  set var.encoding = accept.encoding_lookup(
    "br:gzip:identity",
    "identity",
    req.http.Accept-Encoding
  );
  
  # Step 5: Set headers for backend to use
  set req.http.X-Content-Language = var.language;
  set req.http.X-Content-Type = var.format;
  set req.http.X-Content-Charset = var.charset;
  set req.http.X-Content-Encoding = var.encoding;
  
  # Step 6: Implement content-based routing
  # Route to different backends based on content negotiation results
  if (var.format == "application/json") {
    # JSON API backend
    set req.backend = F_api_backend;
  } else if (var.format == "text/html") {
    # HTML website backend
    if (var.language == "ja") {
      # Japanese-specific backend
      set req.backend = F_japan_website_backend;
    } else {
      # Default website backend
      set req.backend = F_website_backend;
    }
  }
  
  # Step 7: Set appropriate Vary headers in vcl_deliver
  # This ensures proper caching based on content negotiation
}

sub vcl_deliver {
  # Set appropriate Vary headers based on content negotiation
  declare local var.vary_headers STRING;
  set var.vary_headers = "";
  
  if (resp.http.Content-Language) {
    set var.vary_headers = "Accept-Language";
  }
  
  if (resp.http.Content-Type) {
    if (var.vary_headers != "") {
      set var.vary_headers = var.vary_headers + ", Accept";
    } else {
      set var.vary_headers = "Accept";
    }
  }
  
  if (resp.http.Content-Encoding && resp.http.Content-Encoding != "identity") {
    if (var.vary_headers != "") {
      set var.vary_headers = var.vary_headers + ", Accept-Encoding";
    } else {
      set var.vary_headers = "Accept-Encoding";
    }
  }
  
  if (var.vary_headers != "") {
    set resp.http.Vary = var.vary_headers;
  }
}

/**
 * BEST PRACTICES FOR ACCEPT HEADER FUNCTIONS
 * 
 * 1. Always provide a sensible default value as the second parameter
 * 2. Handle missing Accept headers gracefully
 * 3. Keep the list of available options reasonably small for performance
 * 4. Set appropriate Vary headers when using content negotiation
 * 5. Consider caching implications when implementing content negotiation
 * 6. Use these functions for routing to different backends based on client preferences
 * 7. Combine with other VCL functions for comprehensive content delivery strategies
 */