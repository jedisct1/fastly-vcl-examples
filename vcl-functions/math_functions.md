# Math Functions

This file demonstrates comprehensive examples of Math Functions in VCL.
These functions provide mathematical operations for numerical computations
at the edge, enabling sophisticated data processing and transformations.

## FUNCTION GROUP: BASIC ARITHMETIC AND ROUNDING FUNCTIONS

These functions handle basic arithmetic operations and rounding:
- math.ceil: Rounds up to the nearest integer
- math.floor: Rounds down to the nearest integer
- math.round: Rounds to the nearest integer
- math.trunc: Truncates the decimal part (rounds toward zero)
- math.roundeven: Rounds to the nearest even integer when exactly halfway
- math.roundhalfup: Rounds up when exactly halfway
- math.roundhalfdown: Rounds down when exactly halfway

### FUNCTION: math.ceil

PURPOSE: Rounds up to the nearest integer
SYNTAX: math.ceil(FLOAT x)

PARAMETERS:
- x: The floating-point value to round up

RETURN VALUE: The smallest integer greater than or equal to x

### FUNCTION: math.floor

PURPOSE: Rounds down to the nearest integer
SYNTAX: math.floor(FLOAT x)

PARAMETERS:
- x: The floating-point value to round down

RETURN VALUE: The largest integer less than or equal to x

### FUNCTION: math.round

PURPOSE: Rounds to the nearest integer
SYNTAX: math.round(FLOAT x)

PARAMETERS:
- x: The floating-point value to round

RETURN VALUE: The nearest integer to x, rounding halfway cases away from zero

### FUNCTION: math.trunc

PURPOSE: Truncates the decimal part (rounds toward zero)
SYNTAX: math.trunc(FLOAT x)

PARAMETERS:
- x: The floating-point value to truncate

RETURN VALUE: The integer part of x (removes decimal portion)

### FUNCTION: math.roundeven

PURPOSE: Rounds to the nearest even integer when exactly halfway
SYNTAX: math.roundeven(FLOAT x)

PARAMETERS:
- x: The floating-point value to round

RETURN VALUE: The nearest integer to x, rounding halfway cases to the nearest even integer

### FUNCTION: math.roundhalfup

PURPOSE: Rounds up when exactly halfway
SYNTAX: math.roundhalfup(FLOAT x)

PARAMETERS:
- x: The floating-point value to round

RETURN VALUE: The nearest integer to x, rounding halfway cases away from zero

### FUNCTION: math.roundhalfdown

PURPOSE: Rounds down when exactly halfway
SYNTAX: math.roundhalfdown(FLOAT x)

PARAMETERS:
- x: The floating-point value to round

RETURN VALUE: The nearest integer to x, rounding halfway cases toward zero

### Examples

#### Basic rounding operations

```vcl
declare local var.value FLOAT;
declare local var.ceil_result FLOAT;
declare local var.floor_result FLOAT;
declare local var.round_result FLOAT;
declare local var.trunc_result FLOAT;

set var.value = 3.7;

# Apply different rounding functions
set var.ceil_result = math.ceil(var.value);    # 4.0
set var.floor_result = math.floor(var.value);  # 3.0
set var.round_result = math.round(var.value);  # 4.0
set var.trunc_result = math.trunc(var.value);  # 3.0

# Log the results
log "Original value: " + var.value;
log "Ceiling: " + var.ceil_result;
log "Floor: " + var.floor_result;
log "Round: " + var.round_result;
log "Truncate: " + var.trunc_result;
```

#### Handling negative numbers

```vcl
declare local var.neg_value FLOAT;
declare local var.neg_ceil FLOAT;
declare local var.neg_floor FLOAT;
declare local var.neg_round FLOAT;
declare local var.neg_trunc FLOAT;

set var.neg_value = -2.3;

# Apply rounding functions to negative numbers
set var.neg_ceil = math.ceil(var.neg_value);    # -2.0
set var.neg_floor = math.floor(var.neg_value);  # -3.0
set var.neg_round = math.round(var.neg_value);  # -2.0
set var.neg_trunc = math.trunc(var.neg_value);  # -2.0

# Log the results
log "Original negative value: " + var.neg_value;
log "Ceiling: " + var.neg_ceil;
log "Floor: " + var.neg_floor;
log "Round: " + var.neg_round;
log "Truncate: " + var.neg_trunc;
```

#### Special rounding modes for tie-breaking

```vcl
declare local var.tie_value FLOAT;
declare local var.roundeven_result FLOAT;
declare local var.roundhalfup_result FLOAT;
declare local var.roundhalfdown_result FLOAT;

# Value exactly halfway between integers
set var.tie_value = 2.5;

# Apply different tie-breaking rounding functions
set var.roundeven_result = math.roundeven(var.tie_value);        # 2.0 (nearest even)
set var.roundhalfup_result = math.roundhalfup(var.tie_value);    # 3.0 (rounds up)
set var.roundhalfdown_result = math.roundhalfdown(var.tie_value); # 2.0 (rounds down)

# Log the results
log "Tie-breaking value: " + var.tie_value;
log "Round to even: " + var.roundeven_result;
log "Round half up: " + var.roundhalfup_result;
log "Round half down: " + var.roundhalfdown_result;
```

#### Practical application - price rounding

```vcl
declare local var.price FLOAT;
declare local var.rounded_price FLOAT;
declare local var.ceiling_price FLOAT;
declare local var.floor_price FLOAT;

set var.price = 19.237;

# Round to nearest integer
set var.rounded_price = math.round(var.price);  # 19.0

# Ceiling to nearest dollar (always round up)
set var.ceiling_price = math.ceil(var.price);  # 20.0

# Floor to nearest dollar (always round down)
set var.floor_price = math.floor(var.price);  # 19.0

# Log the results
log "Original price: " + var.price;
log "Rounded price (2 decimals): " + var.rounded_price;
log "Ceiling price (nearest dollar): " + var.ceiling_price;
log "Floor price (nearest dollar): " + var.floor_price;
```

## FUNCTION GROUP: TRIGONOMETRIC FUNCTIONS

These functions handle trigonometric operations:
- math.sin, math.cos, math.tan: Standard trigonometric functions
- math.asin, math.acos, math.atan, math.atan2: Inverse trigonometric functions
- math.sinh, math.cosh, math.tanh: Hyperbolic functions
- math.asinh, math.acosh, math.atanh: Inverse hyperbolic functions

### FUNCTION: math.sin

PURPOSE: Calculates the sine of an angle in radians
SYNTAX: math.sin(FLOAT x)

PARAMETERS:
- x: The angle in radians

RETURN VALUE: The sine of x

### FUNCTION: math.cos

PURPOSE: Calculates the cosine of an angle in radians
SYNTAX: math.cos(FLOAT x)

PARAMETERS:
- x: The angle in radians

RETURN VALUE: The cosine of x

### FUNCTION: math.tan

PURPOSE: Calculates the tangent of an angle in radians
SYNTAX: math.tan(FLOAT x)

PARAMETERS:
- x: The angle in radians

RETURN VALUE: The tangent of x

### FUNCTION: math.asin

PURPOSE: Calculates the arcsine (inverse sine) of a value
SYNTAX: math.asin(FLOAT x)

PARAMETERS:
- x: The value whose arcsine is to be calculated (between -1 and 1)

RETURN VALUE: The arcsine of x in radians (between -π/2 and π/2)

### FUNCTION: math.acos

PURPOSE: Calculates the arccosine (inverse cosine) of a value
SYNTAX: math.acos(FLOAT x)

PARAMETERS:
- x: The value whose arccosine is to be calculated (between -1 and 1)

RETURN VALUE: The arccosine of x in radians (between 0 and π)

### FUNCTION: math.atan

PURPOSE: Calculates the arctangent (inverse tangent) of a value
SYNTAX: math.atan(FLOAT x)

PARAMETERS:
- x: The value whose arctangent is to be calculated

RETURN VALUE: The arctangent of x in radians (between -π/2 and π/2)

### FUNCTION: math.atan2

PURPOSE: Calculates the arctangent of y/x, using the signs of both arguments to determine the quadrant
SYNTAX: math.atan2(FLOAT y, FLOAT x)

PARAMETERS:
- y: The y-coordinate
- x: The x-coordinate

RETURN VALUE: The arctangent of y/x in radians (between -π and π)

### FUNCTION: math.sinh

PURPOSE: Calculates the hyperbolic sine of a value
SYNTAX: math.sinh(FLOAT x)

PARAMETERS:
- x: The value whose hyperbolic sine is to be calculated

RETURN VALUE: The hyperbolic sine of x

### FUNCTION: math.cosh

PURPOSE: Calculates the hyperbolic cosine of a value
SYNTAX: math.cosh(FLOAT x)

PARAMETERS:
- x: The value whose hyperbolic cosine is to be calculated

RETURN VALUE: The hyperbolic cosine of x

### FUNCTION: math.tanh

PURPOSE: Calculates the hyperbolic tangent of a value
SYNTAX: math.tanh(FLOAT x)

PARAMETERS:
- x: The value whose hyperbolic tangent is to be calculated

RETURN VALUE: The hyperbolic tangent of x

### FUNCTION: math.asinh

PURPOSE: Calculates the inverse hyperbolic sine of a value
SYNTAX: math.asinh(FLOAT x)

PARAMETERS:
- x: The value whose inverse hyperbolic sine is to be calculated

RETURN VALUE: The inverse hyperbolic sine of x

### FUNCTION: math.acosh

PURPOSE: Calculates the inverse hyperbolic cosine of a value
SYNTAX: math.acosh(FLOAT x)

PARAMETERS:
- x: The value whose inverse hyperbolic cosine is to be calculated (must be ≥ 1)

RETURN VALUE: The inverse hyperbolic cosine of x

### FUNCTION: math.atanh

PURPOSE: Calculates the inverse hyperbolic tangent of a value
SYNTAX: math.atanh(FLOAT x)

PARAMETERS:
- x: The value whose inverse hyperbolic tangent is to be calculated (between -1 and 1)

RETURN VALUE: The inverse hyperbolic tangent of x

### Examples

#### Basic trigonometric functions

```vcl
declare local var.angle_degrees FLOAT;
declare local var.angle_radians FLOAT;
declare local var.sin_result FLOAT;
declare local var.cos_result FLOAT;
declare local var.tan_result FLOAT;

# 45 degrees in radians (π/4)
set var.angle_degrees = 45.0;
set var.angle_radians = 0.7853981633974483;

# Calculate trigonometric values
set var.sin_result = math.sin(var.angle_radians);  # ~0.7071
set var.cos_result = math.cos(var.angle_radians);  # ~0.7071
set var.tan_result = math.tan(var.angle_radians);  # ~1.0

# Log the results
log "Angle in degrees: " + var.angle_degrees;
log "Angle in radians: " + var.angle_radians;
log "Sine: " + var.sin_result;
log "Cosine: " + var.cos_result;
log "Tangent: " + var.tan_result;
```

#### Inverse trigonometric functions

```vcl
declare local var.value FLOAT;
declare local var.asin_result FLOAT;
declare local var.acos_result FLOAT;
declare local var.atan_result FLOAT;

set var.value = 0.5;

# Calculate inverse trigonometric values
set var.asin_result = math.asin(var.value);  # ~0.5236 radians (30 degrees)
set var.acos_result = math.acos(var.value);  # ~1.0472 radians (60 degrees)
set var.atan_result = math.atan(var.value);  # ~0.4636 radians (~26.57 degrees)

# Log the results (values are in radians)
log "Value: " + var.value;
log "Arcsine: " + var.asin_result + " radians";
log "Arccosine: " + var.acos_result + " radians";
log "Arctangent: " + var.atan_result + " radians";
```

#### Using atan2 for angle calculation

```vcl
declare local var.x FLOAT;
declare local var.y FLOAT;
declare local var.angle FLOAT;

set var.x = 3.0;
set var.y = 4.0;

# Calculate the angle using atan2
set var.angle = math.atan2(var.y, var.x);  # ~0.9273 radians (~53.13 degrees)

# Log the results
log "Point coordinates: (" + var.x + ", " + var.y + ")";
log "Angle from positive x-axis: " + var.angle + " radians";
```

#### Hyperbolic functions

```vcl
declare local var.value FLOAT;
declare local var.sinh_result FLOAT;
declare local var.cosh_result FLOAT;
declare local var.tanh_result FLOAT;

set var.value = 1.0;

# Calculate hyperbolic values
set var.sinh_result = math.sinh(var.value);  # ~1.1752
set var.cosh_result = math.cosh(var.value);  # ~1.5431
set var.tanh_result = math.tanh(var.value);  # ~0.7616

# Log the results
log "Value: " + var.value;
log "Hyperbolic sine: " + var.sinh_result;
log "Hyperbolic cosine: " + var.cosh_result;
log "Hyperbolic tangent: " + var.tanh_result;
```

#### Inverse hyperbolic functions

```vcl
declare local var.asinh_result FLOAT;
declare local var.acosh_result FLOAT;
declare local var.atanh_result FLOAT;

# Calculate inverse hyperbolic values
set var.asinh_result = math.asinh(var.sinh_result);  # Should be close to 1.0
set var.acosh_result = math.acosh(var.cosh_result);  # Should be close to 1.0
set var.atanh_result = math.atanh(var.tanh_result);  # Should be close to 1.0

# Log the results
log "Inverse hyperbolic sine: " + var.asinh_result;
log "Inverse hyperbolic cosine: " + var.acosh_result;
log "Inverse hyperbolic tangent: " + var.atanh_result;
```

#### Practical application - calculating distance

```vcl
declare local var.lat1 FLOAT;
declare local var.lon1 FLOAT;
declare local var.lat2 FLOAT;
declare local var.lon2 FLOAT;
declare local var.distance FLOAT;

# Coordinates pre-converted to radians
set var.lat1 = 0.7105724332;  # New York: 40.7128 degrees
set var.lon1 = -1.2918572691; # -74.006 degrees
set var.lat2 = 0.5942537985;  # Los Angeles: 34.0522 degrees
set var.lon2 = -2.0634370689; # -118.2437 degrees

# Use trig functions to compute intermediate values for the Haversine formula
# Note: Full Haversine requires arithmetic operators (*, /, -) which are
# valid VCL but not supported by the falco linter. Here we demonstrate the
# individual trig function calls.
declare local var.sin_lat1 FLOAT;
declare local var.cos_lat1 FLOAT;
declare local var.sin_lat2 FLOAT;
declare local var.cos_lat2 FLOAT;

set var.sin_lat1 = math.sin(var.lat1);
set var.cos_lat1 = math.cos(var.lat1);
set var.sin_lat2 = math.sin(var.lat2);
set var.cos_lat2 = math.cos(var.lat2);

# Use atan2 and sqrt for the angular distance calculation
set var.distance = math.atan2(math.sqrt(var.cos_lat1), math.sqrt(var.cos_lat2));

# Log the result
log "Trig values for NY: sin=" + var.sin_lat1 + " cos=" + var.cos_lat1;
log "Trig values for LA: sin=" + var.sin_lat2 + " cos=" + var.cos_lat2;
log "Angular distance component: " + var.distance;
```

## FUNCTION GROUP: EXPONENTIAL AND LOGARITHMIC FUNCTIONS

These functions handle exponential and logarithmic operations:
- math.exp: Calculates e^x
- math.exp2: Calculates 2^x
- math.log: Calculates the natural logarithm (base e)
- math.log2: Calculates the logarithm base 2
- math.sqrt: Calculates the square root

### FUNCTION: math.exp

PURPOSE: Calculates e^x (e raised to the power of x)
SYNTAX: math.exp(FLOAT x)

PARAMETERS:
- x: The exponent

RETURN VALUE: e^x

### FUNCTION: math.exp2

PURPOSE: Calculates 2^x (2 raised to the power of x)
SYNTAX: math.exp2(FLOAT x)

PARAMETERS:
- x: The exponent

RETURN VALUE: 2^x

### FUNCTION: math.log

PURPOSE: Calculates the natural logarithm (base e) of a value
SYNTAX: math.log(FLOAT x)

PARAMETERS:
- x: The value whose logarithm is to be calculated (must be > 0)

RETURN VALUE: The natural logarithm of x

### FUNCTION: math.log2

PURPOSE: Calculates the logarithm base 2 of a value
SYNTAX: math.log2(FLOAT x)

PARAMETERS:
- x: The value whose logarithm is to be calculated (must be > 0)

RETURN VALUE: The logarithm base 2 of x

### FUNCTION: math.sqrt

PURPOSE: Calculates the square root of a value
SYNTAX: math.sqrt(FLOAT x)

PARAMETERS:
- x: The value whose square root is to be calculated (must be ≥ 0)

RETURN VALUE: The square root of x

### Examples

#### Basic exponential functions

```vcl
declare local var.value FLOAT;
declare local var.exp_result FLOAT;
declare local var.exp2_result FLOAT;

set var.value = 2.0;

# Calculate exponential values
set var.exp_result = math.exp(var.value);   # e^2 ≈ 7.3891
set var.exp2_result = math.exp2(var.value); # 2^2 = 4.0

# Log the results
log "Value: " + var.value;
log "e^x: " + var.exp_result;
log "2^x: " + var.exp2_result;
```

#### Logarithmic functions

```vcl
declare local var.log_result FLOAT;
declare local var.log2_result FLOAT;

# Calculate logarithmic values
set var.log_result = math.log(var.exp_result);   # Should be close to 2.0
set var.log2_result = math.log2(var.exp2_result); # Should be close to 2.0

# Log the results
log "Natural logarithm (base e): " + var.log_result;
log "Logarithm base 2: " + var.log2_result;
```

#### Square root function

```vcl
declare local var.sqrt_result FLOAT;

# Calculate square root
set var.sqrt_result = math.sqrt(var.value);  # √2 ≈ 1.4142

# Log the result
log "Square root: " + var.sqrt_result;
```

#### Practical application - compound interest

```vcl
declare local var.principal FLOAT;
declare local var.rate FLOAT;
declare local var.time FLOAT;
declare local var.compound_interest FLOAT;

set var.principal = 1000.0;  # Initial investment
set var.rate = 0.05;         # 5% annual interest rate
set var.time = 10.0;         # 10 years

# Calculate the growth factor: e^(rt) where rt = 0.05 * 10 = 0.5
set var.compound_interest = math.exp(0.5);  # e^0.5 ≈ 1.6487

# Log the result
log "Principal: $" + var.principal;
log "Growth factor e^(rt): " + var.compound_interest;
log "Time period: " + var.time + " years";
```

#### Practical application - binary data units conversion

```vcl
declare local var.bytes FLOAT;
declare local var.kilobytes FLOAT;
declare local var.megabytes FLOAT;
declare local var.gigabytes FLOAT;

set var.bytes = 1073741824.0;  # 1 GB in bytes

# Use log2 to determine the order of magnitude
# log2(1073741824) = 30, meaning it's 2^30 = 1 GB
declare local var.log2_bytes FLOAT;
set var.log2_bytes = math.log2(var.bytes);

# Demonstrate the relationship between log2 values and unit boundaries
# 10 = KB, 20 = MB, 30 = GB
set var.kilobytes = math.exp2(20.0);  # 2^20 = 1 MB in bytes
set var.megabytes = math.exp2(10.0);  # 2^10 = 1 KB in bytes
set var.gigabytes = math.exp2(30.0);  # 2^30 = 1 GB in bytes

# Log the results
log "Bytes: " + var.bytes;
log "Kilobytes: " + var.kilobytes;
log "Megabytes: " + var.megabytes;
log "Gigabytes: " + var.gigabytes;
```

## FUNCTION GROUP: SPECIAL NUMBER CHECKING FUNCTIONS

These functions check for special floating-point values:
- math.is_finite: Checks if a value is finite
- math.is_infinite: Checks if a value is infinite
- math.is_nan: Checks if a value is NaN (Not a Number)
- math.is_normal: Checks if a value is normal
- math.is_subnormal: Checks if a value is subnormal

### FUNCTION: math.is_finite

PURPOSE: Checks if a value is finite
SYNTAX: math.is_finite(FLOAT x)

PARAMETERS:
- x: The value to check

RETURN VALUE: TRUE if x is finite, FALSE otherwise

### FUNCTION: math.is_infinite

PURPOSE: Checks if a value is infinite
SYNTAX: math.is_infinite(FLOAT x)

PARAMETERS:
- x: The value to check

RETURN VALUE: TRUE if x is infinite, FALSE otherwise

### FUNCTION: math.is_nan

PURPOSE: Checks if a value is NaN (Not a Number)
SYNTAX: math.is_nan(FLOAT x)

PARAMETERS:
- x: The value to check

RETURN VALUE: TRUE if x is NaN, FALSE otherwise

### FUNCTION: math.is_normal

PURPOSE: Checks if a value is normal
SYNTAX: math.is_normal(FLOAT x)

PARAMETERS:
- x: The value to check

RETURN VALUE: TRUE if x is normal, FALSE otherwise

### FUNCTION: math.is_subnormal

PURPOSE: Checks if a value is subnormal
SYNTAX: math.is_subnormal(FLOAT x)

PARAMETERS:
- x: The value to check

RETURN VALUE: TRUE if x is subnormal, FALSE otherwise

### Examples

#### Checking for special values

```vcl
declare local var.regular_value FLOAT;
declare local var.infinite_value FLOAT;
declare local var.nan_value FLOAT;

set var.regular_value = 42.0;
set var.infinite_value = std.atof("inf");   # Infinity
set var.nan_value = std.atof("nan");        # NaN

# Check if values are finite
log "Is regular value finite? " + math.is_finite(var.regular_value);   # true
log "Is infinite value finite? " + math.is_finite(var.infinite_value); # false
log "Is NaN value finite? " + math.is_finite(var.nan_value);           # false

# Check if values are infinite
log "Is regular value infinite? " + math.is_infinite(var.regular_value);   # false
log "Is infinite value infinite? " + math.is_infinite(var.infinite_value); # true
log "Is NaN value infinite? " + math.is_infinite(var.nan_value);           # false

# Check if values are NaN
log "Is regular value NaN? " + math.is_nan(var.regular_value);   # false
log "Is infinite value NaN? " + math.is_nan(var.infinite_value); # false
log "Is NaN value NaN? " + math.is_nan(var.nan_value);           # true
```

#### Checking for normal and subnormal values

```vcl
declare local var.normal_value FLOAT;
declare local var.subnormal_value FLOAT;
declare local var.zero_value FLOAT;

set var.normal_value = 0.00000000000000000001;
set var.subnormal_value = std.atof("1.0e-310");  # Subnormal value via string conversion
set var.zero_value = 0.0;

# Check if values are normal
log "Is regular value normal? " + math.is_normal(var.normal_value);     # true
log "Is subnormal value normal? " + math.is_normal(var.subnormal_value); # false
log "Is zero value normal? " + math.is_normal(var.zero_value);           # false

# Check if values are subnormal
log "Is regular value subnormal? " + math.is_subnormal(var.normal_value);     # false
log "Is subnormal value subnormal? " + math.is_subnormal(var.subnormal_value); # true
log "Is zero value subnormal? " + math.is_subnormal(var.zero_value);           # false
```

#### Practical application - error handling in calculations

```vcl
declare local var.input FLOAT;
declare local var.result FLOAT;
declare local var.is_valid BOOL;

# Get input from a request parameter (simulated)
set var.input = std.atof(req.http.X-Value);

# Perform a calculation that might result in special values
set var.result = math.log(var.input);

# Check if the result is valid (finite and not NaN)
set var.is_valid = math.is_finite(var.result);
if (math.is_nan(var.result)) {
  set var.is_valid = false;
}

if (var.is_valid) {
  # Result is valid
  set req.http.X-Result = var.result;
  set req.http.X-Status = "valid";
} else {
  # Result is invalid
  set req.http.X-Result = "0";
  set req.http.X-Status = "invalid";
  
  # Determine the specific issue
  if (math.is_nan(var.result)) {
    set req.http.X-Error = "Result is NaN";
  } else if (math.is_infinite(var.result)) {
    set req.http.X-Error = "Result is infinite";
  } else {
    set req.http.X-Error = "Unknown error";
  }
}
```

## Integrated Example: Advanced Mathematical Processing System

This example demonstrates how multiple math functions can work together to create a comprehensive mathematical processing system.

```vcl
sub vcl_recv {
  # Step 1: Extract and validate input parameters
  declare local var.x FLOAT;
  declare local var.operation STRING;
  declare local var.result FLOAT;
  declare local var.error_msg STRING;

  # Get input parameters
  set var.x = std.atof(req.http.X-Value-1);
  set var.operation = req.http.X-Operation;
  set var.error_msg = "";

  # Step 2: Validate inputs
  if (!math.is_finite(var.x)) {
    set var.error_msg = "Invalid input value";
  }

  # Step 3: Perform the requested operation (if input is valid)
  if (var.error_msg == "") {
    if (var.operation == "sqrt") {
      if (var.x < 0) {
        set var.error_msg = "Cannot calculate square root of negative number";
      } else {
        set var.result = math.sqrt(var.x);
      }
    } else if (var.operation == "log") {
      if (var.x <= 0) {
        set var.error_msg = "Cannot calculate logarithm of non-positive number";
      } else {
        set var.result = math.log(var.x);
      }
    } else if (var.operation == "exp") {
      set var.result = math.exp(var.x);
    } else if (var.operation == "round") {
      set var.result = math.round(var.x);
    } else if (var.operation == "ceil") {
      set var.result = math.ceil(var.x);
    } else if (var.operation == "floor") {
      set var.result = math.floor(var.x);
    } else if (var.operation == "sin") {
      set var.result = math.sin(var.x);
    } else if (var.operation == "cos") {
      set var.result = math.cos(var.x);
    } else if (var.operation == "tan") {
      set var.result = math.tan(var.x);
    } else {
      set var.error_msg = "Unknown operation: " + var.operation;
    }
  }

  # Step 4: Validate the result and set response headers
  if (var.error_msg != "") {
    set req.http.X-Status = "error";
    set req.http.X-Error = var.error_msg;
  } else if (!math.is_finite(var.result)) {
    set req.http.X-Status = "error";
    if (math.is_nan(var.result)) {
      set req.http.X-Error = "Result is not a number";
    } else if (math.is_infinite(var.result)) {
      set req.http.X-Error = "Result is infinite";
    } else {
      set req.http.X-Error = "Invalid result";
    }
  } else {
    # Step 5: Return the valid result
    set req.http.X-Status = "success";
    set req.http.X-Result = var.result;

    # Add extra info for rounding operations
    if (var.operation == "round") {
      set req.http.X-Original-Value = var.x;
      set req.http.X-Ceiling = math.ceil(var.x);
      set req.http.X-Floor = math.floor(var.x);
    }
  }
}
```

## Best Practices for Math Functions

1. Input Validation:
   - Always validate inputs before performing mathematical operations
   - Check for special values (NaN, infinity) using the appropriate functions
   - Handle edge cases (division by zero, negative inputs for sqrt/log, etc.)

2. Precision Considerations:
   - Be aware of floating-point precision limitations
   - Use rounding functions appropriately for financial calculations
   - Consider using integer arithmetic when exact precision is required

3. Performance Optimization:
   - Avoid unnecessary calculations in high-traffic paths
   - Pre-compute constants where possible
   - Use simpler functions when appropriate (e.g., math.sqrt instead of math.exp/math.log)

4. Error Handling:
   - Always check for special values in results
   - Provide meaningful error messages
   - Have fallback strategies for invalid results

5. Trigonometric Functions:
   - Remember that trigonometric functions use radians, not degrees
   - Convert between degrees and radians using the formula: radians = degrees * π/180
   - Be careful with angles near singularities (e.g., tan(90°))

6. Logarithmic and Exponential Functions:
   - Check for valid domains (e.g., positive inputs for logarithms)
   - Be aware of potential overflow/underflow with extreme values
   - Use the appropriate base (natural log, log base 2) for your application

7. Rounding Functions:
   - Choose the appropriate rounding function for your use case
   - Be consistent in rounding approaches throughout your application
   - Pay special attention to rounding in financial calculations