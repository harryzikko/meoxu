import sys
import os
import json
import urllib.request

log_file = sys.argv[1] if len(sys.argv) > 1 else 'build.log'
if not os.path.exists(log_file):
    sys.exit(0)

try:
    with open(log_file, 'r', encoding='utf-8', errors='replace') as f:
        lines = f.readlines()
    tail = ''.join(lines[-80:])
    
    token = os.environ.get('GITHUB_TOKEN', '')
    repo = os.environ.get('GITHUB_REPOSITORY', '')
    sha = os.environ.get('GITHUB_SHA', '')
    
    if not token or not repo or not sha:
        print("Missing GITHUB env vars for posting comment")
        sys.exit(0)
        
    url = f"https://api.github.com/repos/{repo}/commits/{sha}/comments"
    data = json.dumps({'body': f"### ❌ Android Build Error Log:\n```\n{tail}\n```"}).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers={
        'Authorization': f'token {token}',
        'Content-Type': 'application/json',
        'User-Agent': 'GitHub-Actions-Diagnostics',
    })
    with urllib.request.urlopen(req) as resp:
        print("Posted error comment successfully!")
except Exception as e:
    print("Failed to post comment:", e)
