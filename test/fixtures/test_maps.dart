const tFronteggConstantsMap = {
  "baseUrl": "https://base.url.com",
  "clientId": "clientId1",
  "useAssetsLinks": true,
  "useChromeCustomTabs": false,
  "bundleId": "com.test.1",
};

const tIOSFronteggConstantsMap = {
  "baseUrl": "https://base.url.com",
  "clientId": "clientId1",
  'useAssetsLinks': null,
  'useChromeCustomTabs': null,
  "bundleId": "com.test.1",
};

const tFronteggTenantMap = {
  "vendorId": "392b348b-a37c-471f-8f1b-2c35d23aa7e6",
  "id": " 9ca34b3c-8ab6-40b9-a582-bd8badb571cb",
  "creatorName": "Test User",
  "creatorEmail": "test@mail.com",
  "tenantId": "d130e118-8e56-4837-b70b-92943e567976",
  "updatedAt": "2024-05-13T13:03:31.533Z",
  "createdAt": "2024-05-13T13:03:31.533Z",
  "metadata": "{}",
  "isReseller": false,
  "name": "Test User account",
};

const tFronteggUserRolePermissionMap = {
  "fePermission": true,
  "id": "0e8c0103-feb1-4ae0-8230-00de5fd0f857",
  "categoryId": "0c587ef6-eb9e-4a10-b888-66ec4bcb1548",
  "updatedAt": "2024-03-21T07:27:46.000Z",
  "description": "View all applications in the account",
  "createdAt": "2024-03-21T07:27:46.000Z",
  "key": "fe.account-settings.read.app",
  "name": "Read application"
};

const tFronteggUserRoleMap = {
  "vendorId": "392b348b-a37c-471f-8f1b-2c35d23aa7e6",
  "id": "12c36cb2-67a7-4468-ad8f-c1a0e8128234",
  "isDefault": true,
  "updatedAt": "2024-05-13T11:59:55.000Z",
  "createdAt": "2024-05-13T11:59:55.000Z",
  "permissions": [
    "0e8c0103-feb1-4ae0-8230-00de5fd0f8566",
    "502b112e-50fd-4e8d-875e-3abda628d955",
    "da015508-7cb1-4dcd-9436-d0518a2ecd44",
  ],
  "name": "Admin",
  "key": "Admin",
};

const tFronteggUserMap = {
  "tenantId": "d230e118-8e56-4837-b70b-92943e567911",
  "verified": true,
  "activatedForTenant": true,
  "tenantIds": ["d230e118-8e56-4837-b70b-92943e567911"],
  "roles": [tFronteggUserRoleMap],
  "tenants": [
    tFronteggTenantMap,
  ],
  "name": "Test User",
  "mfaEnrolled": false,
  "profilePictureUrl":
      "https://lh3.googleusercontent.com/a/ACg8ocKc8DKSMBDaSp83L-7jJXvfHT0YdZ9w4_KnqLpvFhETmQsH_A=s96-c",
  "activeTenant": {
    "vendorId": "392b348b-a37c-441f-8f1b-2c35d23aa7e6",
    "id": "9ca34b3c-8ab6-40b9-a582-bd8badb571cb",
    "tenantId": "d230e118-8e56-4837-b70b-92943e567911",
    "creatorEmail": "test@mail.com",
    "creatorName": "Test User",
    "updatedAt": "2024-05-13T13:03:31.533Z",
    "createdAt": "2024-05-13T13:03:31.533Z",
    "isReseller": false,
    "name": "Test User account",
    "metadata": "{}"
  },
  "permissions": [
    {
      "fePermission": true,
      "id": "0e8c0103-feb1-4ae0-8230-00de5fd0f822",
      "categoryId": "0c587ef6-eb9e-4a10-b888-66ec4bcb1548",
      "updatedAt": "2024-03-21T07:27:46.000Z",
      "createdAt": "2024-03-21T07:27:46.000Z",
      "description": "View all applications in the account",
      "name": "Read application",
      "key": "fe.account-settings.read.app"
    },
    {
      "fePermission": true,
      "id": "502b112e-50fd-4e8d-875e-3abda628d921",
      "categoryId": "5c326535-c73b-4926-937e-170d6ad5c9bz",
      "key": "fe.connectivity.*",
      "description": "all connectivity permissions",
      "createdAt": "2021-02-11T10:58:31.000Z",
      "updatedAt": "2021-02-11T10:58:31.000Z",
      "name": " Connectivity general"
    },
    {
      "fePermission": true,
      "id": "502b112e-50fd-4e8d-822e-3abda628d921",
      "categoryId": "684202ce-2345-48f0-8d67-4c05fe6a4d9a",
      "key": "fe.secure.*",
      "description": "all secure access permissions",
      "createdAt": "2020-12-08T08:59:25.000Z",
      "updatedAt": "2020-12-08T08:59:25.000Z",
      "name": "Secure general"
    }
  ],
  "email": "test@mail.com",
  "id": "d89330b3-f581-493c-bcd7-0c4b1dff1111",
  "superUser": false
};

const tFronteggStateMap = {
  "accessToken": "accessToken1",
  "refreshToken": "refreshToken1",
  "user": null,
  "isAuthenticated": true,
  "isLoading": false,
  "initializing": false,
  "showLoader": false,
  "appLink": true,
  "refreshingToken": false,
};

const tLoadingFronteggStateMap = {
  "accessToken": null,
  "refreshToken": null,
  "user": null,
  "isAuthenticated": false,
  "isLoading": true,
  "initializing": false,
  "showLoader": true,
  "appLink": false,
  "refreshingToken": true,
};

const tLoadedFronteggStateMap = {
  "accessToken": "accessToken2",
  "refreshToken": "refreshToken2",
  "user": tFronteggUserMap,
  "isAuthenticated": false,
  "isLoading": true,
  "initializing": true,
  "showLoader": true,
  "appLink": false,
  "refreshingToken": false,
};
