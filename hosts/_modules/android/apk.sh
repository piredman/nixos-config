#!/usr/bin/env bash
set -e

# Script to verify any APK with PGP signature and extract information for AppVerifier
# Automatically finds APK file, extracts key ID from signature, and manages GPG keys

# Check for required tools
command -v gpg >/dev/null 2>&1 || {
    echo "Error: gpg not found"
    exit 1
}
command -v apksigner >/dev/null 2>&1 || {
    echo "Error: apksigner not found - install Android SDK Build-Tools"
    exit 1
}
command -v aapt2 >/dev/null 2>&1 || {
    echo "Error: aapt2 not found."
    echo "Run with: nix shell nixpkgs#aapt --command bash apk-verify.sh"
    exit 1
}

# Find APK file in current directory
APK_FILE=$(find . -maxdepth 1 -name "*.apk" | head -1)

if [[ -z "$APK_FILE" ]]; then
    echo "Error: No APK file found in current directory"
    exit 1
fi
ASC_FILE="${APK_FILE}.asc"

echo "Found APK: $APK_FILE"

# Read expected values from app-verifier.info if present
if [[ -f "app-verifier.info" ]]; then
    EXPECTED_PACKAGE=$(head -1 app-verifier.info)
    EXPECTED_SHA256=$(tail -1 app-verifier.info | tr -d ':' | tr '[:upper:]' '[:lower:]')
    if [[ -z "$EXPECTED_PACKAGE" || -z "$EXPECTED_SHA256" ]]; then
        echo "Error: app-verifier.info must contain package name and SHA-256 on separate lines"
        exit 1
    fi
else
    echo "Warning: app-verifier.info not found - skipping verification"
fi

# Check if .asc file exists
if [[ ! -f "$ASC_FILE" ]]; then
    echo "Error: PGP signature file not found: $ASC_FILE"
    exit 1
fi

echo "Found PGP signature: $ASC_FILE"

# Get signature verification output
VERIFY_OUTPUT=$(gpg --verify "$ASC_FILE" 2>&1)

# Extract key ID from verification output
KEY_ID=$(echo "$VERIFY_OUTPUT" | sed -n 's/.*using \w* key \([A-F0-9]*\).*/\1/p' | head -1)

if [[ -z "$KEY_ID" ]]; then
    echo "Error: Could not extract key ID from GPG verification output."
    echo "$VERIFY_OUTPUT"
    exit 1
fi

echo "Key ID found: $KEY_ID"

# Check if key is already in keyring
KEY_EXISTS=$(gpg --list-keys "$KEY_ID" 2>/dev/null | wc -l)

if [[ $KEY_EXISTS -eq 0 ]]; then
    echo "Public key not found in keyring. Importing from keyserver..."
    if ! gpg --keyserver-timeout 10 --recv-keys "$KEY_ID"; then
        echo "Error: Failed to import key $KEY_ID from keyserver."
        echo "Try: gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys $KEY_ID"
        exit 1
    fi
    echo "Key $KEY_ID successfully imported."
else
    echo "Key $KEY_ID already in keyring."
fi

# Extract certificate information
echo "Extracting APK signing certificate information..."
CERT_INFO=$(apksigner verify --print-certs "$APK_FILE" 2>&1)

# Extract SHA-256 certificate digest
SHA256_FINGERPRINT=$(echo "$CERT_INFO" | awk -F': ' '/Signer #1 certificate SHA-256 digest/ {print $2}' | xargs)

if [[ -z "$SHA256_FINGERPRINT" ]]; then
    echo "Error: Could not find SHA-256 certificate digest in apksigner output."
    echo "$CERT_INFO"
    exit 1
fi

# Extract package name
PACKAGE_NAME=$(aapt2 dump badging "$APK_FILE" | awk -F"'" '/package: name=/ {print $2}')

if [[ -z "$PACKAGE_NAME" ]]; then
    echo "Error: Could not extract package name from APK."
    exit 1
fi

# Display results
echo "Verification complete."
echo "Information for AppVerifier:"
echo "Package Name: $PACKAGE_NAME"
echo "SHA-256 Certificate Fingerprint: $SHA256_FINGERPRINT"
echo "Summary:"
echo "- APK file: $APK_FILE"
echo "- PGP signature verified: yes"
echo "- PGP signing key ID: $KEY_ID"
echo "- Package: $PACKAGE_NAME"
echo "- Certificate SHA-256: $SHA256_FINGERPRINT"

# Verify against expected values if provided
if [[ -n "$EXPECTED_PACKAGE" && -n "$EXPECTED_SHA256" ]]; then
    FAIL_REASONS=""
    if [[ "$PACKAGE_NAME" != "$EXPECTED_PACKAGE" ]]; then
        FAIL_REASONS+="- Package mismatch: expected $EXPECTED_PACKAGE, got $PACKAGE_NAME\n"
    fi
    EXTRACTED_SHA256_LOWER=$(echo "$SHA256_FINGERPRINT" | tr '[:upper:]' '[:lower:]')
    if [[ "$EXTRACTED_SHA256_LOWER" != "$EXPECTED_SHA256" ]]; then
        FAIL_REASONS+="- SHA-256 mismatch: expected $EXPECTED_SHA256, got $SHA256_FINGERPRINT\n"
    fi
    if [[ -n "$FAIL_REASONS" ]]; then
        echo "Verification: FAILED"
        echo -e "$FAIL_REASONS"
        exit 1
    else
        echo "Verification: PASSED"
    fi
fi

exit 0
