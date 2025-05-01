# Crypto Functions

This file demonstrates comprehensive examples of Crypto Functions in VCL.
These functions provide symmetric key encryption and decryption capabilities
for securing sensitive data at the edge.

## FUNCTION GROUP: SYMMETRIC ENCRYPTION AND DECRYPTION

The following functions provide symmetric key encryption and decryption:
- crypto.encrypt_hex: Encrypts data and returns the result as a hex-encoded string
- crypto.encrypt_base64: Encrypts data and returns the result as a base64-encoded string
- crypto.decrypt_hex: Decrypts hex-encoded ciphertext
- crypto.decrypt_base64: Decrypts base64-encoded ciphertext

### FUNCTION: crypto.encrypt_hex

PURPOSE: Encrypts plaintext using symmetric key encryption and returns the result as a hex-encoded string
SYNTAX: crypto.encrypt_hex(ENUM cipher, ENUM mode, ENUM padding, STRING key_hex, STRING iv_hex, STRING plaintext_hex)

PARAMETERS:
- cipher: The cipher algorithm to use (aes128, aes192, aes256)
- mode: The block cipher mode of operation (cbc, ctr, gcm, ccm)
- padding: The padding method (pkcs7, nopad)
- key_hex: The encryption key as a hex-encoded string
- iv_hex: The initialization vector as a hex-encoded string
- plaintext_hex: The plaintext to encrypt as a hex-encoded string

RETURN VALUE: The encrypted ciphertext as a hex-encoded string

NOTES:
- The key must be the appropriate length for the chosen cipher (16 bytes for aes128, 24 bytes for aes192, 32 bytes for aes256)
- The IV must be 16 bytes (32 hex characters) for all AES ciphers
- When using ctr, gcm, or ccm modes, padding must be set to nopad
- For cbc mode with nopad, plaintext must be a multiple of the block size (16 bytes for AES)

### FUNCTION: crypto.encrypt_base64

PURPOSE: Encrypts plaintext using symmetric key encryption and returns the result as a base64-encoded string
SYNTAX: crypto.encrypt_base64(ENUM cipher, ENUM mode, ENUM padding, STRING key_hex, STRING iv_hex, STRING plaintext_base64)

PARAMETERS:
- cipher: The cipher algorithm to use (aes128, aes192, aes256)
- mode: The block cipher mode of operation (cbc, ctr, gcm, ccm)
- padding: The padding method (pkcs7, nopad)
- key_hex: The encryption key as a hex-encoded string
- iv_hex: The initialization vector as a hex-encoded string
- plaintext_base64: The plaintext to encrypt as a base64-encoded string

RETURN VALUE: The encrypted ciphertext as a base64-encoded string

NOTES:
- Same requirements as crypto.encrypt_hex, but input plaintext is base64-encoded and output ciphertext is base64-encoded
- Base64 decoding behaves as if by a call to digest.base64_decode()
- Base64 encoding behaves as if by a call to digest.base64()

### FUNCTION: crypto.decrypt_hex

PURPOSE: Decrypts hex-encoded ciphertext using symmetric key decryption
SYNTAX: crypto.decrypt_hex(ENUM cipher, ENUM mode, ENUM padding, STRING key_hex, STRING iv_hex, STRING ciphertext_hex)

PARAMETERS:
- cipher: The cipher algorithm to use (aes128, aes192, aes256)
- mode: The block cipher mode of operation (cbc, ctr, gcm, ccm)
- padding: The padding method (pkcs7, nopad)
- key_hex: The decryption key as a hex-encoded string
- iv_hex: The initialization vector as a hex-encoded string
- ciphertext_hex: The ciphertext to decrypt as a hex-encoded string

RETURN VALUE: The decrypted plaintext as a hex-encoded string

NOTES:
- Same requirements as crypto.encrypt_hex
- If decryption fails (wrong key, IV, or corrupted ciphertext), fastly.error will be set to EBADDECRYPT

### FUNCTION: crypto.decrypt_base64

PURPOSE: Decrypts base64-encoded ciphertext using symmetric key decryption
SYNTAX: crypto.decrypt_base64(ENUM cipher, ENUM mode, ENUM padding, STRING key_hex, STRING iv_hex, STRING ciphertext_base64)

PARAMETERS:
- cipher: The cipher algorithm to use (aes128, aes192, aes256)
- mode: The block cipher mode of operation (cbc, ctr, gcm, ccm)
- padding: The padding method (pkcs7, nopad)
- key_hex: The decryption key as a hex-encoded string
- iv_hex: The initialization vector as a hex-encoded string
- ciphertext_base64: The ciphertext to decrypt as a base64-encoded string

RETURN VALUE: The decrypted plaintext as a base64-encoded string

NOTES:
- Same requirements as crypto.decrypt_hex, but input ciphertext is base64-encoded and output plaintext is base64-encoded
- Base64 decoding behaves as if by a call to digest.base64_decode()
- Base64 encoding behaves as if by a call to digest.base64()

### Examples

#### Basic AES-256 CBC Encryption and Decryption with Hex Encoding

```vcl
declare local var.key STRING;
declare local var.iv STRING;
declare local var.plaintext STRING;
declare local var.ciphertext STRING;
declare local var.decrypted STRING;

# Set up encryption parameters
set var.key = "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"; # 256-bit key
set var.iv = "000102030405060708090a0b0c0d0e0f"; # 16-byte IV
set var.plaintext = "6bc1bee22e409f96e93d7e117393172a"; # Plaintext in hex

# Encrypt the plaintext
set var.ciphertext = crypto.encrypt_hex(aes256, cbc, nopad, var.key, var.iv, var.plaintext);

# Decrypt the ciphertext
set var.decrypted = crypto.decrypt_hex(aes256, cbc, nopad, var.key, var.iv, var.ciphertext);

# Verify the decryption worked correctly
if (var.decrypted == var.plaintext) {
  set req.http.X-Crypto-Test = "Encryption and decryption successful";
} else {
  set req.http.X-Crypto-Test = "Encryption and decryption failed";
}
```

#### AES-256 CTR Mode with Error Handling

```vcl
declare local var.key STRING;
declare local var.counter STRING; # In CTR mode, the IV is used as a counter
declare local var.plaintext STRING;
declare local var.ciphertext STRING;

# Set up encryption parameters
set var.key = "8e73b0f7da0e6452c810f32b809079e562f8ead2522c6b7b";
set var.counter = "f0f1f2f3f4f5f6f7f8f9fafbfcfdfeff"; # Counter block
set var.plaintext = "6bc1bee22e409f96e93d7e117393172aae2d8a571e03ac9c9eb76fac45af8e51";

# Clear any previous errors
unset fastly.error;

# Encrypt the plaintext using CTR mode
set var.ciphertext = crypto.encrypt_hex(aes256, ctr, nopad, var.key, var.counter, var.plaintext);

# Check for encryption errors
if (fastly.error) {
  if (fastly.error == "EINVAL") {
    set req.http.X-Crypto-Error = "Invalid parameters for encryption";
  } else {
    set req.http.X-Crypto-Error = "Encryption error: " + fastly.error;
  }
  # Handle the error appropriately
  error 500 "Encryption failed";
}

# Set the encrypted result in a header for demonstration
set req.http.X-Encrypted-Data = var.ciphertext;
```

#### Encrypting and Decrypting JSON Data with Base64

```vcl
declare local var.key STRING;
declare local var.iv STRING;
declare local var.json_data STRING;
declare local var.json_base64 STRING;
declare local var.encrypted STRING;
declare local var.decrypted_base64 STRING;
declare local var.decrypted_json STRING;

# Set up encryption parameters
set var.key = "000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f"; # 256-bit key
set var.iv = "101112131415161718191a1b1c1d1e1f"; # 16-byte IV

# JSON data to encrypt
set var.json_data = "{\"user_id\":\"12345\",\"email\":\"user@example.com\",\"role\":\"admin\"}";

# Convert JSON to base64
set var.json_base64 = digest.base64(var.json_data);

# Encrypt the base64-encoded JSON
set var.encrypted = crypto.encrypt_base64(aes256, cbc, pkcs7, var.key, var.iv, var.json_base64);

# Store the encrypted data (e.g., in a cookie or header)
set req.http.X-Encrypted-Token = var.encrypted;

# Later, to decrypt:
set var.decrypted_base64 = crypto.decrypt_base64(aes256, cbc, pkcs7, var.key, var.iv, req.http.X-Encrypted-Token);

# Convert from base64 back to JSON
set var.decrypted_json = digest.base64_decode(var.decrypted_base64);

# Use the decrypted JSON data
if (var.decrypted_json ~ "\"role\":\"admin\"") {
  set req.http.X-Is-Admin = "true";
}
```

#### Secure Cookie Encryption

This example demonstrates how to securely encrypt and decrypt cookie values:

```vcl
sub encrypt_cookie_value {
  # Parameters
  declare local var.value STRING;
  set var.value = urldecode(req.http.X-Cookie-Value);
  
  # Encryption keys (in production, store these securely)
  declare local var.encryption_key STRING;
  declare local var.encryption_iv STRING;
  set var.encryption_key = "000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f";
  set var.encryption_iv = table.lookup(encryption_ivs, "cookie_iv");
  
  # Convert to base64 first
  declare local var.base64_value STRING;
  set var.base64_value = digest.base64(var.value);
  
  # Encrypt the value
  declare local var.encrypted STRING;
  set var.encrypted = crypto.encrypt_base64(aes256, cbc, pkcs7, 
                                           var.encryption_key, 
                                           var.encryption_iv, 
                                           var.base64_value);
  
  # URL-encode for cookie safety
  set req.http.X-Encrypted-Cookie = urlencode(var.encrypted);
  
  return;
}

sub decrypt_cookie_value {
  # Get the encrypted cookie
  declare local var.encrypted STRING;
  set var.encrypted = urldecode(req.http.Cookie:secure_data);
  
  # Decryption keys (must match encryption keys)
  declare local var.encryption_key STRING;
  declare local var.encryption_iv STRING;
  set var.encryption_key = "000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f";
  set var.encryption_iv = table.lookup(encryption_ivs, "cookie_iv");
  
  # Decrypt the value
  declare local var.decrypted_base64 STRING;
  
  # Clear any previous errors
  unset fastly.error;
  
  set var.decrypted_base64 = crypto.decrypt_base64(aes256, cbc, pkcs7, 
                                                  var.encryption_key, 
                                                  var.encryption_iv, 
                                                  var.encrypted);
  
  # Check for decryption errors
  if (fastly.error) {
    if (fastly.error == "EBADDECRYPT") {
      set req.http.X-Cookie-Error = "Invalid cookie or tampering detected";
      unset req.http.Cookie:secure_data;
      return;
    } else {
      set req.http.X-Cookie-Error = "Decryption error: " + fastly.error;
      return;
    }
  }
  
  # Convert from base64 back to original value
  declare local var.decrypted STRING;
  set var.decrypted = digest.base64_decode(var.decrypted_base64);
  
  # Set the decrypted value for use
  set req.http.X-Decrypted-Cookie = var.decrypted;
  
  return;
}
```

## FUNCTION GROUP: CIPHER MODES AND THEIR USES

The crypto functions support several cipher modes, each with specific security properties and use cases:

### CBC (Cipher Block Chaining)

- **Properties**: Each block of plaintext is XORed with the previous ciphertext block before encryption
- **IV Requirement**: Requires a random IV for each encryption operation
- **Padding**: Requires padding (typically PKCS#7) when plaintext is not a multiple of the block size
- **Use Cases**: General-purpose encryption when authenticated encryption is not required

### CTR (Counter)

- **Properties**: Converts a block cipher into a stream cipher by encrypting sequential counter values
- **IV/Counter**: Uses a counter that must be unique for each encryption with the same key
- **Padding**: No padding required (nopad must be specified)
- **Use Cases**: Parallel encryption/decryption, random access to encrypted data

### GCM (Galois/Counter Mode)

- **Properties**: Provides both encryption and authentication (AEAD - Authenticated Encryption with Associated Data)
- **IV Requirement**: Requires a unique IV for each encryption with the same key
- **Padding**: No padding required (nopad must be specified)
- **Use Cases**: When both confidentiality and authenticity are required

### CCM (Counter with CBC-MAC)

- **Properties**: Combines CTR mode encryption with CBC-MAC authentication
- **IV Requirement**: Requires a unique IV for each encryption with the same key
- **Padding**: No padding required (nopad must be specified)
- **Use Cases**: Similar to GCM, used in some specific protocols

### Example: Using GCM Mode for Authenticated Encryption

```vcl
declare local var.key STRING;
declare local var.iv STRING;
declare local var.plaintext STRING;
declare local var.ciphertext STRING;
declare local var.decrypted STRING;

# Set up encryption parameters
set var.key = "000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f"; # 256-bit key
set var.iv = "cafebabefacedbaddecaf888"; # 12-byte IV for GCM
set var.plaintext = "48656c6c6f2c20776f726c6421"; # "Hello, world!" in hex

# Encrypt with GCM mode
set var.ciphertext = crypto.encrypt_hex(aes256, gcm, nopad, var.key, var.iv, var.plaintext);

# Decrypt with GCM mode
set var.decrypted = crypto.decrypt_hex(aes256, gcm, nopad, var.key, var.iv, var.ciphertext);

# GCM provides authentication - if the ciphertext is tampered with, decryption will fail
# with an EBADDECRYPT error
```

## Integrated Example: Secure Token System

This example demonstrates a complete system for creating and validating secure tokens:

```vcl
sub generate_secure_token {
  # Input data to include in the token
  declare local var.user_id STRING;
  declare local var.expiry TIME;
  declare local var.permissions STRING;
  
  set var.user_id = req.http.X-User-ID;
  set var.expiry = time.add(now, 1h); # Token valid for 1 hour
  set var.permissions = req.http.X-User-Permissions;
  
  # Create token payload
  declare local var.payload STRING;
  set var.payload = "{\"user_id\":\"" + var.user_id + 
                    "\",\"exp\":" + strftime({"%s"}, var.expiry) + 
                    ",\"permissions\":\"" + var.permissions + "\"}";
  
  # Encryption keys
  declare local var.key STRING;
  declare local var.iv STRING;
  set var.key = "000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f";
  set var.iv = digest.hash_md5(var.user_id + strftime({"%Y%m%d"}, now)); # Derive IV from user ID and current date
  
  # Encrypt the payload
  declare local var.base64_payload STRING;
  declare local var.encrypted STRING;
  
  set var.base64_payload = digest.base64(var.payload);
  set var.encrypted = crypto.encrypt_base64(aes256, gcm, nopad, var.key, var.iv, var.base64_payload);
  
  # Create the final token (URL-safe)
  declare local var.token STRING;
  set var.token = digest.base64url_nopad(var.iv) + "." + digest.base64url_nopad(var.encrypted);
  
  # Return the token
  set req.http.X-Secure-Token = var.token;
  
  return;
}

sub validate_secure_token {
  # Get the token
  declare local var.token STRING;
  set var.token = req.http.Authorization;
  set var.token = regsub(var.token, "^Bearer\s+", "");
  
  # Split the token into parts
  declare local var.parts STRING;
  declare local var.iv_b64 STRING;
  declare local var.encrypted_b64 STRING;
  
  if (var.token !~ "^[^.]+\.[^.]+$") {
    error 401 "Invalid token format";
  }
  
  set var.iv_b64 = regsub(var.token, "^([^.]+)\.[^.]+$", "\1");
  set var.encrypted_b64 = regsub(var.token, "^[^.]+\.([^.]+)$", "\1");
  
  # Convert from URL-safe base64 to standard base64
  declare local var.iv STRING;
  declare local var.encrypted STRING;
  
  set var.iv = digest.base64_decode(digest.base64url_nopad_decode(var.iv_b64));
  set var.encrypted = digest.base64url_nopad_decode(var.encrypted_b64);
  
  # Decryption key
  declare local var.key STRING;
  set var.key = "000102030405060708090a0b0c0d0e0f000102030405060708090a0b0c0d0e0f";
  
  # Decrypt the payload
  declare local var.decrypted_b64 STRING;
  declare local var.payload STRING;
  
  # Clear any previous errors
  unset fastly.error;
  
  set var.decrypted_b64 = crypto.decrypt_base64(aes256, gcm, nopad, var.key, var.iv, var.encrypted);
  
  # Check for decryption errors
  if (fastly.error) {
    if (fastly.error == "EBADDECRYPT") {
      error 401 "Invalid token or tampering detected";
    } else {
      error 500 "Decryption error: " + fastly.error;
    }
  }
  
  # Decode the payload
  set var.payload = digest.base64_decode(var.decrypted_b64);
  
  # Validate expiration
  if (var.payload ~ "\"exp\":(\d+)") {
    declare local var.expiry INTEGER;
    set var.expiry = std.atoi(re.group.1);
    
    if (var.expiry < time.start.sec) {
      error 401 "Token expired";
    }
  } else {
    error 401 "Invalid token payload";
  }
  
  # Extract user information
  if (var.payload ~ "\"user_id\":\"([^\"]+)\"") {
    set req.http.X-Auth-User-ID = re.group.1;
  }
  
  if (var.payload ~ "\"permissions\":\"([^\"]+)\"") {
    set req.http.X-Auth-Permissions = re.group.1;
  }
  
  # Token is valid
  set req.http.X-Auth-Valid = "true";
  
  return;
}
```

## Best Practices for Crypto Functions

1. **Key Management**
   - Never hardcode encryption keys in VCL; use edge dictionaries or other secure key management
   - Rotate keys periodically
   - Use different keys for different purposes

2. **IV/Nonce Management**
   - Always use a unique IV/nonce for each encryption operation with the same key
   - For CBC mode, use a cryptographically secure random IV
   - For CTR/GCM/CCM modes, ensure the nonce is never reused with the same key

3. **Mode Selection**
   - Use GCM or CCM when you need authenticated encryption
   - Avoid CBC mode when possible, especially for user-supplied data
   - Always use nopad with CTR, GCM, and CCM modes

4. **Error Handling**
   - Always check for encryption/decryption errors
   - Handle EBADDECRYPT errors appropriately, as they may indicate tampering
   - Don't expose detailed error information to clients

5. **Performance Considerations**
   - Encryption operations are computationally expensive
   - Cache encrypted results when possible
   - Consider using edge dictionaries for pre-computed values

6. **Security Boundaries**
   - Remember that data is decrypted at the edge, so it's protected in transit but not at the edge
   - Use encryption for data that needs to be protected from origin servers or in logs
   - Consider end-to-end encryption for highly sensitive data

7. **Compliance**
   - Ensure your encryption practices meet relevant compliance requirements (PCI DSS, HIPAA, etc.)
   - Document your encryption methods and key management procedures
   - Regularly audit and test your encryption implementation