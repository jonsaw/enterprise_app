#!/bin/bash

# Run build_runner in packages/api_auth
echo "Running build_runner in packages/api_auth..."
cd packages/api_auth
dart run build_runner build --delete-conflicting-outputs
cd ../..

echo "Running build_runner in packages/api_management..."
cd packages/api_management
dart run build_runner build --delete-conflicting-outputs
cd ../..

# Run build_runner in main app
echo "Running build_runner in main app..."
dart run build_runner build --delete-conflicting-outputs

echo "Build runner completed in both locations."
