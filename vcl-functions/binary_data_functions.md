# Binary Data Functions

This file demonstrates comprehensive examples of Binary Data Functions in VCL.
These functions help work with binary data, including conversion between
different encodings such as hex and base64.

## bin.base64_to_hex

Converts a base64-encoded string to a hexadecimal string.

### Syntax

```vcl
STRING bin.base64_to_hex(STRING base64_encoded_string)
```

### Parameters

- `base64_encoded_string`: A base64-encoded string to convert

### Return Value

- A hexadecimal string representation of the binary data
- Empty string if the input is not valid base64

### Examples

#### Basic base64 to hex conversion

```vcl
declare local var.base64_data STRING;
declare local var.hex_data STRING;

# Set a base64-encoded string
# "SGVsbG8gV29ybGQ=" is base64 for "Hello World"
set var.base64_data = "SGVsbG8gV29ybGQ=";

# Convert to hex
set var.hex_data = bin.base64_to_hex(var.base64_data);

# var.hex_data is now "48656c6c6f20576f726c64" (hex for "Hello World")
set req.http.X-Hex-Data = var.hex_data;
```

#### Error handling for invalid base64 input

```vcl
declare local var.invalid_base64 STRING;
declare local var.converted_hex STRING;

# Set an invalid base64 string (contains invalid characters)
set var.invalid_base64 = "SGVsbG8gV29ybGQ=!@#";

# Attempt conversion with error handling
set var.converted_hex = bin.base64_to_hex(var.invalid_base64);

if (var.converted_hex == "") {
  # Conversion failed, handle the error
  set req.http.X-Conversion-Error = "Invalid base64 input";
  
  # Use a fallback or sanitized input
  set var.invalid_base64 = regsub(var.invalid_base64, "[^A-Za-z0-9+/=]", "");
  set var.converted_hex = bin.base64_to_hex(var.invalid_base64);
}
```

#### Processing JWT tokens

This example demonstrates how to extract and process parts of a JWT token:

```vcl
declare local var.jwt_token STRING;
declare local var.jwt_payload_b64 STRING;
declare local var.jwt_payload_hex STRING;

# Sample JWT token (header.payload.signature)
set var.jwt_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c";

# Extract the payload part (second segment)
set var.jwt_payload_b64 = regsub(var.jwt_token, "^[^.]*\.([^.]*)\.[^.]*$", "\1");

# Convert payload from base64 to hex for further processing
set var.jwt_payload_hex = bin.base64_to_hex(var.jwt_payload_b64);

# Now you could use this hex data for further processing
# For example, you could look for specific patterns in the hex data
if (var.jwt_payload_hex ~ "6e616d65") {  # "name" in hex
  set req.http.X-JWT-Contains-Name = "true";
}
```

## bin.hex_to_base64

Converts a hexadecimal string to a base64-encoded string.

### Syntax

```vcl
STRING bin.hex_to_base64(STRING hex_string)
```

### Parameters

- `hex_string`: A hexadecimal string to convert

### Return Value

- A base64-encoded string representation of the binary data
- Empty string if the input is not valid hexadecimal

### Examples

#### Basic hex to base64 conversion

```vcl
declare local var.hex_data STRING;
declare local var.base64_data STRING;

# Set a hex string
# "48656c6c6f20576f726c64" is hex for "Hello World"
set var.hex_data = "48656c6c6f20576f726c64";

# Convert to base64
set var.base64_data = bin.hex_to_base64(var.hex_data);

# var.base64_data is now "SGVsbG8gV29ybGQ="
set req.http.X-Base64-Data = var.base64_data;
```

#### Error handling for invalid hex input

```vcl
declare local var.invalid_hex STRING;
declare local var.converted_base64 STRING;

# Set an invalid hex string (contains non-hex characters)
set var.invalid_hex = "48656c6c6f20576f726c64ZZ";

# Attempt conversion with error handling
set var.converted_base64 = bin.hex_to_base64(var.invalid_hex);

if (var.converted_base64 == "") {
  # Conversion failed, handle the error
  set req.http.X-Conversion-Error = "Invalid hex input";
  
  # Use a fallback or sanitized input
  set var.invalid_hex = regsub(var.invalid_hex, "[^0-9A-Fa-f]", "");
  set var.converted_base64 = bin.hex_to_base64(var.invalid_hex);
}
```

#### Creating a data URL for inline images

This example demonstrates how to create a data URL for an inline image:

```vcl
declare local var.image_hex STRING;
declare local var.image_base64 STRING;
declare local var.data_url STRING;

# Hex representation of a tiny image (would be much longer in practice)
set var.image_hex = "89504e470d0a1a0a0000000d49484452000000100000001008060000001ff3ff61";

# Convert to base64
set var.image_base64 = bin.hex_to_base64(var.image_hex);

# Create a data URL
set var.data_url = "data:image/png;base64," + var.image_base64;

# Use the data URL in a response header or for other purposes
set req.http.X-Image-Data-URL = var.data_url;
```

## Integrated Example: Complete binary data processing system

This example demonstrates how `bin.base64_to_hex` and `bin.hex_to_base64` can work together to process binary data passed as headers.

```vcl
sub vcl_recv {
  # Step 1: Extract binary data from request header
  declare local var.raw_data STRING;
  declare local var.normalized_hex STRING;

  set var.raw_data = req.http.X-Binary-Data;

  # Determine if the data is base64-encoded and normalize to hex
  if (req.http.X-Data-Encoding == "base64") {
    set var.normalized_hex = bin.base64_to_hex(var.raw_data);
  } else {
    # Assume hex-encoded
    set var.normalized_hex = var.raw_data;
  }

  # Step 2: Process the hex data
  # Extract header information from a simple binary format
  # Format: [1 byte type][2 bytes length][variable data]
  declare local var.data_valid BOOL;
  declare local var.data_type STRING;
  declare local var.data_length INTEGER;

  if (std.strlen(var.normalized_hex) >= 6) {
    set var.data_type = substr(var.normalized_hex, 0, 2);
    set var.data_length = std.strtol(substr(var.normalized_hex, 2, 4), 16);

    if (std.strlen(var.normalized_hex) >= (6 + var.data_length * 2)) {
      set var.data_valid = true;
    } else {
      set var.data_valid = false;
    }
  } else {
    set var.data_valid = false;
  }

  # Step 3: Take action based on the processed data
  if (var.data_valid) {
    if (var.data_type == "01") {
      # Type 0x01: Authentication token
      declare local var.token_hex STRING;
      set var.token_hex = substr(var.normalized_hex, 6, var.data_length * 2);

      # Convert hex token to base64 for use in Authorization header
      declare local var.token_base64 STRING;
      set var.token_base64 = bin.hex_to_base64(var.token_hex);
      set req.http.Authorization = "Bearer " + var.token_base64;

    } else if (var.data_type == "02") {
      # Type 0x02: Encrypted payload - pass hex along
      declare local var.encrypted_hex STRING;
      set var.encrypted_hex = substr(var.normalized_hex, 6, var.data_length * 2);
      set req.http.X-Encrypted-Data = var.encrypted_hex;

    } else {
      set req.http.X-Unknown-Data-Type = var.data_type;
    }
  } else {
    set req.http.X-Data-Error = "Invalid binary data format";
  }

  # Step 4: Pass the processed data to the backend as base64
  set req.http.X-Processed-Data = bin.hex_to_base64(var.normalized_hex);
}
```

## Best Practices for Binary Data Functions

1. Always validate input data before conversion to avoid errors
2. Use appropriate error handling for conversion failures
3. Choose the right encoding for your use case:
   - base64 for compact representation in headers and URLs
   - hex for human-readable debugging and logging
4. Use `bin.base64_to_hex` and `bin.hex_to_base64` to convert between the two formats
5. Consider performance implications for large data conversions
6. Normalize binary data to a common format (like hex) for consistent processing
7. Document binary data formats and protocols clearly
8. Use appropriate Content-Type headers when returning binary data
9. Consider security implications when processing binary data (validate before use)
