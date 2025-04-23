# Frontegg Flutter API Reference

## Properties

| Property | Description |
|----------|-------------|
| `currentState` | Gets the current state of the Frontegg instance. Returns a `FronteggState` which includes information such as authentication status, loading status, and user details. |
| `stateChanged` | A stream that emits changes to the FronteggState. Provides real-time updates on the state of authentication, user details, and loading statuses. |

## Methods

### Authentication Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `login` | `loginHint` (optional): String | Initiates the authentication process. `loginHint` pre-fills the login field in the Frontegg Login Box. |
| `loginWithPasskeys` | None | Authenticates the user using passkeys. |
| `registerPasskeys` | None | Registers passkeys for the user. |
| `logout` | None | Logs out the user and clears user-related data. |
| `refreshToken` | None | Refreshes the authentication token if needed. Returns `true` if successful. |

### Social & Direct Login Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `directLogin` | - `url` (required): String<br>- `ephemeralSession`: bool = true<br>- `additionalQueryParams`: Map<String, String>? | Initiates a direct login using a provided URL. |
| `socialLogin` | - `provider` (required): FronteggSocialProvider<br>- `ephemeralSession`: bool = true<br>- `additionalQueryParams`: Map<String, String>? | Initiates a social login using the specified provider (e.g., Google, Facebook). |
| `customSocialLogin` | - `id` (required): String<br>- `ephemeralSession`: bool = true<br>- `additionalQueryParams`: Map<String, String>? | Initiates a custom social login using a unique identifier. |

### Tenant Management

| Method | Parameters | Description |
|--------|------------|-------------|
| `switchTenant` | `tenantId` (required): String | Switches the user's active tenant. IDs available from `User.tenants.tenantId`. |

### Authorization & Security

| Method | Parameters | Description |
|--------|------------|-------------|
| `requestAuthorize` | - `refreshToken` (required): String<br>- `deviceTokenCookie`: String? | Initiates authorization request. Returns `FronteggUser` if successful, `null` if fails. |
| `isSteppedUp` | `maxAge`: Duration? | Checks if user has completed step-up authentication. |
| `stepUp` | `maxAge`: Duration? | Initiates the step-up authentication process. |

### Utility Methods

| Method | Parameters | Description |
|--------|------------|-------------|
| `dispose` | None | Cancels the subscription to the state stream. Call when object is no longer needed. |
| `getConstants` | None | Fetches the Frontegg constants containing configuration values. Returns `FronteggConstants`. |

## Error Handling

All methods can throw a `FronteggException` for platform-specific errors. The error handling system automatically converts platform exceptions to `FronteggException` instances.

### Common Error Scenarios:
- Authentication failures
- Network connectivity issues
- Invalid parameters
- Platform-specific errors

