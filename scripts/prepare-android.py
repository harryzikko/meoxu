import os
import re

gradle_path = 'android/app/build.gradle'
if not os.path.exists(gradle_path):
    if os.path.exists('android/app/build.gradle.kts'):
        gradle_path = 'android/app/build.gradle.kts'

with open(gradle_path, 'r', encoding='utf-8') as f:
    content = f.read()

# 1. Update SDK levels to modern standards (SDK 34 / minSdk 21)
content = re.sub(r'compileSdkVersion\s+flutter\.compileSdkVersion', 'compileSdkVersion 34', content)
content = re.sub(r'minSdkVersion\s+flutter\.minSdkVersion', 'minSdkVersion 21', content)
content = re.sub(r'targetSdkVersion\s+flutter\.targetSdkVersion', 'targetSdkVersion 34', content)
content = re.sub(r'compileSdk\s*=\s*flutter\.compileSdkVersion', 'compileSdk = 34', content)
content = re.sub(r'minSdk\s*=\s*flutter\.minSdkVersion', 'minSdk = 21', content)
content = re.sub(r'targetSdk\s*=\s*flutter\.targetSdkVersion', 'targetSdk = 34', content)

# 2. Ensure release build uses debug signing configuration for sideload installation
if 'signingConfigs.debug' not in content:
    content = re.sub(
        r'buildTypes\s*\{',
        'buildTypes {\n        release {\n            signingConfig signingConfigs.debug\n        }',
        content
    )
else:
    content = re.sub(r'signingConfig\s+(?:=\s*)?signingConfigs\.release', 'signingConfig signingConfigs.debug', content)

with open(gradle_path, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"Successfully configured {gradle_path}")
