#!/bin/bash

# A script to test config and workflow locally without interacting with GitHub Actions
# Focused on the backend/frontend examples

export OCUROOT_LOCAL_MODE=true

test() {
    # Release the frontend
    echo "ocuroot release new ./-/frontend.ocu.star"
    ocuroot release new ./-/frontend.ocu.star
    if [ $? -ne 0 ]; then
        echo "Failed to release frontend"
        exit 1
    fi

    # Should not have deployed due to dependency on backend
    assert_not_deployed "frontend.ocu.star" "dev"
    assert_not_deployed "frontend.ocu.star" "staging"
    assert_not_deployed "frontend.ocu.star" "production"

    # Release the backend
    echo "ocuroot release new backend.ocu.star"
    ocuroot release new backend.ocu.star
    if [ $? -ne 0 ]; then
        echo "Failed to release backend"
        exit 1
    fi

    # Should have deployed, no dependencies
    assert_deployed "backend.ocu.star" "dev"
    assert_deployed "backend.ocu.star" "staging"
    assert_deployed "backend.ocu.star" "production"

    # The frontend needs to be updated again
    ocuroot work continue -l
    if [ $? -ne 0 ]; then
        echo "Failed to continue work"
        exit 1
    fi

    assert_deployed "frontend.ocu.star" "dev"
    assert_deployed "frontend.ocu.star" "staging"
    assert_deployed "frontend.ocu.star" "production"

    echo "Test succeeded"
}

# Function to check if a ref exists in state
# Usage: check_ref_exists "path/to/package.ocu.star/@/ref/path" "Error message if not found"
check_ref_exists() {
    local ref_path="$1"
    local error_message="${2:-"Ref $ref_path not found in state"}"
    
    ocuroot state get "$ref_path" > /dev/null 2> /dev/null
    if [ $? -ne 0 ]; then
        echo "$error_message"
        return 1
    fi
    return 0
}

check_ref_does_not_exist() {
    local ref_path="$1"
    local error_message="${2:-"Ref $ref_path exists in state"}"
    
    ocuroot state get "$ref_path" > /dev/null 2> /dev/null
    if [ $? -eq 0 ]; then
        echo "$error_message"
        return 1
    fi
    return 0
}

# Function to check if a package is deployed to an environment
# Usage: check_deployment "package/path.ocu.star" "environment"
assert_deployed() {
    local package_path="$1"
    local environment="$2"
    local ref_path="${package_path}/@/deploy/${environment}"
    local error_message="${3:-"${package_path} not deployed to ${environment}"}"
    
    check_ref_exists "$ref_path" "$error_message"
    if [ $? -ne 0 ]; then
        exit 1
    fi
}

assert_not_deployed() {
    local package_path="$1"
    local environment="$2"
    local ref_path="${package_path}/@/deploy/${environment}"
    local error_message="${3:-"${package_path} deployed to ${environment}"}"
    
    check_ref_does_not_exist "$ref_path" "$error_message"
    if [ $? -ne 0 ]; then
        exit 1
    fi
}

# Clean up any previous runs
rm -rf .store

# Set up environments
echo "ocuroot release new environments.ocu.star"
ocuroot release new environments.ocu.star
if [ $? -ne 0 ]; then
    echo "Failed to set up environments"
    exit 1
fi

test
