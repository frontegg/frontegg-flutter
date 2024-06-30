import 'package:frontegg_flutter/frontegg_flutter.dart';
import 'package:frontegg_flutter/src/models/frontegg_user_role_permission.dart';

const tFronteggConstants = FronteggConstants(
  baseUrl: "https://base.url.com",
  clientId: "clientId1",
  useAssetsLinks: true,
  useChromeCustomTabs: false,
  bundleId: "com.test.1",
);

const tIOSFronteggConstants = FronteggConstants(
  baseUrl: "https://base.url.com",
  clientId: "clientId1",
  bundleId: "com.test.1",
);

final tFronteggTenant = FronteggTenant(
  vendorId: "392b348b-a37c-471f-8f1b-2c35d23aa7e6",
  id: " 9ca34b3c-8ab6-40b9-a582-bd8badb571cb",
  creatorName: "Test User",
  creatorEmail: "test@mail.com",
  tenantId: "d130e118-8e56-4837-b70b-92943e567976",
  updatedAt: DateTime.utc(2024, 5, 13, 13, 3, 31, 533, 0),
  createdAt: DateTime.utc(2024, 5, 13, 13, 3, 31, 533, 0),
  metadata: "{}",
  isReseller: false,
  name: "Test User account",
);

final tFronteggUserRolePermission = FronteggUserRolePermission(
  fePermission: true,
  id: "0e8c0103-feb1-4ae0-8230-00de5fd0f857",
  categoryId: "0c587ef6-eb9e-4a10-b888-66ec4bcb1548",
  updatedAt: DateTime.utc(2024, 3, 21, 7, 27, 46),
  description: "View all applications in the account",
  createdAt: DateTime.utc(2024, 3, 21, 7, 27, 46),
  key: "fe.account-settings.read.app",
  name: "Read application",
);

final tFronteggUserRole = FronteggUserRole(
  vendorId: "392b348b-a37c-471f-8f1b-2c35d23aa7e6",
  id: "12c36cb2-67a7-4468-ad8f-c1a0e8128234",
  isDefault: true,
  updatedAt: DateTime.utc(2024, 5, 13, 11, 59, 55, 0, 0),
  createdAt: DateTime.utc(2024, 5, 13, 11, 59, 55, 0, 0),
  permissions: [
    "0e8c0103-feb1-4ae0-8230-00de5fd0f8566",
    "502b112e-50fd-4e8d-875e-3abda628d955",
    "da015508-7cb1-4dcd-9436-d0518a2ecd44",
  ],
  name: "Admin",
  key: "Admin",
);

final tFronteggUser = FronteggUser(
  tenantId: "d230e118-8e56-4837-b70b-92943e567911",
  verified: true,
  activatedForTenant: true,
  tenantIds: ["d230e118-8e56-4837-b70b-92943e567911"],
  roles: [tFronteggUserRole],
  tenants: [tFronteggTenant],
  name: "Test User",
  mfaEnrolled: false,
  profilePictureUrl:
      "https://lh3.googleusercontent.com/a/ACg8ocKc8DKSMBDaSp83L-7jJXvfHT0YdZ9w4_KnqLpvFhETmQsH_A=s96-c",
  activeTenant: FronteggTenant(
      vendorId: "392b348b-a37c-441f-8f1b-2c35d23aa7e6",
      id: "9ca34b3c-8ab6-40b9-a582-bd8badb571cb",
      tenantId: "d230e118-8e56-4837-b70b-92943e567911",
      creatorEmail: "test@mail.com",
      creatorName: "Test User",
      updatedAt: DateTime.utc(2024, 5, 13, 13, 3, 31, 533),
      createdAt: DateTime.utc(2024, 5, 13, 13, 3, 31, 533),
      isReseller: false,
      name: "Test User account",
      metadata: "{}"),
  permissions: [
    FronteggUserRolePermission(
        fePermission: true,
        id: "0e8c0103-feb1-4ae0-8230-00de5fd0f822",
        categoryId: "0c587ef6-eb9e-4a10-b888-66ec4bcb1548",
        updatedAt: DateTime.utc(2024, 3, 21, 7, 27, 46),
        createdAt: DateTime.utc(2024, 3, 21, 7, 27, 46),
        description: "View all applications in the account",
        name: "Read application",
        key: "fe.account-settings.read.app"),
    FronteggUserRolePermission(
      fePermission: true,
      id: "502b112e-50fd-4e8d-875e-3abda628d921",
      categoryId: "5c326535-c73b-4926-937e-170d6ad5c9bz",
      key: "fe.connectivity.*",
      description: "all connectivity permissions",
      createdAt: DateTime.utc(2021, 2, 11, 10, 58, 31),
      updatedAt: DateTime.utc(2021, 2, 11, 10, 58, 31),
      name: " Connectivity general",
    ),
    FronteggUserRolePermission(
      fePermission: true,
      id: "502b112e-50fd-4e8d-822e-3abda628d921",
      categoryId: "684202ce-2345-48f0-8d67-4c05fe6a4d9a",
      key: "fe.secure.*",
      description: "all secure access permissions",
      createdAt: DateTime.utc(2020, 12, 8, 8, 59, 25),
      updatedAt: DateTime.utc(2020, 12, 8, 8, 59, 25),
      name: "Secure general",
    ),
  ],
  email: "test@mail.com",
  id: "d89330b3-f581-493c-bcd7-0c4b1dff1111",
  superUser: false,
);

const tEmptyFronteggState = FronteggState();

const tFronteggState = FronteggState(
  accessToken: "accessToken1",
  refreshToken: "refreshToken1",
  user: null,
  isAuthenticated: true,
  isLoading: false,
  initializing: false,
  showLoader: false,
  appLink: true,
);

const tLoadingFronteggState = FronteggState(
  accessToken: null,
  refreshToken: null,
  user: null,
  isAuthenticated: false,
  isLoading: true,
  initializing: false,
  showLoader: true,
  appLink: false,
);

final tLoadedFronteggState = FronteggState(
  accessToken: "accessToken2",
  refreshToken: "refreshToken2",
  user: tFronteggUser,
  isAuthenticated: false,
  isLoading: true,
  initializing: true,
  showLoader: true,
  appLink: false,
);
