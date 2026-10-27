import os
import re

# 1. Update AndroidManifest.xml
manifest_path = 'android/app/src/main/AndroidManifest.xml'
if os.path.exists(manifest_path):
    with open(manifest_path, 'r', encoding='utf-8') as f:
        manifest = f.read()

    permissions = (
        '    <uses-permission android:name="android.permission.INTERNET"/>\n'
        '    <uses-permission android:name="android.permission.RECORD_AUDIO"/>\n'
        '    <uses-permission android:name="android.permission.VIBRATE"/>\n'
    )

    if 'android.permission.INTERNET' not in manifest:
        manifest = manifest.replace('<application', permissions + '    <application')
    manifest = manifest.replace('android:label="meoxu"', 'android:label="Meo Xu"')

    with open(manifest_path, 'w', encoding='utf-8') as f:
        f.write(manifest)
    print("Updated AndroidManifest.xml")

# 2. Update build.gradle SDK levels
gradle_path = 'android/app/build.gradle'
if os.path.exists(gradle_path):
    with open(gradle_path, 'r', encoding='utf-8') as f:
        gradle = f.read()

    gradle = gradle.replace('flutter.compileSdkVersion', '34')
    gradle = gradle.replace('flutter.minSdkVersion', '21')
    gradle = gradle.replace('flutter.targetSdkVersion', '34')

    with open(gradle_path, 'w', encoding='utf-8') as f:
        f.write(gradle)
    print("Updated android/app/build.gradle")
