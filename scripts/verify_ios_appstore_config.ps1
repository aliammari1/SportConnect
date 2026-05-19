$ErrorActionPreference = "Stop"

function Assert-Pattern {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Pattern
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing file: $Path"
    }

    $content = Get-Content -Raw -LiteralPath $Path
    if ($content -notmatch $Pattern) {
        throw "FAILED: $Name ($Path)"
    }

    Write-Host "PASS: $Name"
}

function Assert-NotPattern {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Pattern
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Missing file: $Path"
    }

    $content = Get-Content -Raw -LiteralPath $Path
    if ($content -match $Pattern) {
        throw "FAILED: $Name ($Path)"
    }

    Write-Host "PASS: $Name"
}

Write-Host "Running iOS/App Store static verification..."

$checks = @(
    @{
        Name = "Runner target supports iPhone + iPad device family"
        Path = "ios/Runner.xcodeproj/project.pbxproj"
        Pattern = 'TARGETED_DEVICE_FAMILY = "1,2";'
    },
    @{
        Name = "Info.plist includes iPhone UIDeviceFamily value"
        Path = "ios/Runner/Info.plist"
        Pattern = "<key>UIDeviceFamily</key>[\s\S]*?<integer>1</integer>"
    },
    @{
        Name = "Info.plist includes iPad UIDeviceFamily value"
        Path = "ios/Runner/Info.plist"
        Pattern = "<key>UIDeviceFamily</key>[\s\S]*?<integer>2</integer>"
    },
    @{
        Name = "Apple Sign-In entitlement exists"
        Path = "ios/Runner/Runner.entitlements"
        Pattern = "<key>com.apple.developer.applesignin</key>[\s\S]*?<string>Default</string>"
    },
    @{
        Name = "Privacy manifest declares required-reason APIs"
        Path = "ios/Runner/PrivacyInfo.xcprivacy"
        Pattern = "<key>NSPrivacyAccessedAPITypes</key>"
    },
    @{
        Name = "Login UI contains Sign in with Apple button"
        Path = "lib/features/auth/views/login_screen.dart"
        Pattern = "SignInWithAppleButton"
    },
    @{
        Name = "Auth repository contains Apple sign-in flow"
        Path = "lib/features/auth/repositories/auth_repository.dart"
        Pattern = "Future<SocialSignInResult> signInWithApple\(\) async"
    },
    @{
        Name = "Firebase App Check uses App Attest with DeviceCheck fallback on Apple"
        Path = "lib/core/services/firebase_service.dart"
        Pattern = "AppleAppAttestWithDeviceCheckFallbackProvider"
    },
    @{
        Name = "Firebase App Check enables token auto-refresh"
        Path = "lib/core/services/firebase_service.dart"
        Pattern = "setTokenAutoRefreshEnabled\(true\)"
    },
    @{
        Name = "Runner entitlements declare App Attest environment"
        Path = "ios/Runner/Runner.entitlements"
        Pattern = "<key>com.apple.developer.devicecheck.appattest-environment</key>[\s\S]*?<string>production</string>"
    },
    @{
        Name = "IAP service can restore purchases"
        Path = "lib/features/payments/services/premium_iap_service.dart"
        Pattern = "restorePurchases\(\)"
    },
    @{
        Name = "Premium screen exposes Restore Purchases action"
        Path = "lib/features/payments/views/premium_subscribe_screen.dart"
        Pattern = "restore_purchases"
    },
    @{
        Name = "Settings screen includes in-app account deletion flow"
        Path = "lib/features/profile/views/settings_screen.dart"
        Pattern = "settingsDeleteAccount|deleteAccount\(\)"
    },
    @{
        Name = "Premium screen links Terms and Privacy"
        Path = "lib/features/payments/views/premium_subscribe_screen.dart"
        Pattern = "termsOfServiceTitle[\s\S]*privacyPolicyTitle"
    },
    @{
        Name = "Settings includes Manage Subscription deep link"
        Path = "lib/features/profile/views/settings_screen.dart"
        Pattern = "apps\.apple\.com/account/subscriptions"
    },
    @{
        Name = "DevicePreview is disabled outside debug builds"
        Path = "lib/main.dart"
        Pattern = "DevicePreview\([\s\S]*enabled:\s*kDebugMode"
    },
    @{
        Name = "GoogleService-Info template includes DATABASE_URL placeholder"
        Path = "ios/Runner/GoogleService-Info.plist.example"
        Pattern = "<key>DATABASE_URL</key>"
    },
    @{
        Name = "GoogleService-Info template includes ANDROID_CLIENT_ID placeholder"
        Path = "ios/Runner/GoogleService-Info.plist.example"
        Pattern = "<key>ANDROID_CLIENT_ID</key>"
    }
)

foreach ($check in $checks) {
    Assert-Pattern -Name $check.Name -Path $check.Path -Pattern $check.Pattern
}

$negativeChecks = @(
    @{
        Name = "Chat list screen has no legacy FIX comment markers"
        Path = "lib/features/messaging/views/chat_list_screen.dart"
        Pattern = "//\s*FIX:"
    },
    @{
        Name = "Chat detail screen has no legacy FIX comment markers"
        Path = "lib/features/messaging/views/chat_detail_screen.dart"
        Pattern = "//\s*FIX:"
    },
    @{
        Name = "Login screen has no CORRECT FIX marker"
        Path = "lib/features/auth/views/login_screen.dart"
        Pattern = "CORRECT FIX:"
    },
    @{
        Name = "Signup wizard has no UX FIX markers"
        Path = "lib/features/auth/views/signup_wizard_screen.dart"
        Pattern = "UX FIX:"
    }
)

foreach ($check in $negativeChecks) {
    Assert-NotPattern -Name $check.Name -Path $check.Path -Pattern $check.Pattern
}

Write-Host ""
Write-Host "All static checks passed."
Write-Host "Note: Build/signing/runtime verification still requires macOS + Xcode + Apple credentials."
