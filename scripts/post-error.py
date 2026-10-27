import sys
import os
import json
import urllib.request

log_file = sys.argv[1] if len(sys.argv) > 1 else 'build.log'
if not os.path.exists(log_file):
    print("Log file not found:", log_file)
    sys.exit(0)

try:
    with open(log_file, 'r', encoding='utf-8', errors='replace') as f:
        lines = f.read().splitlines()

    print(f"Total log lines: {len(lines)}")
    
    # 1. Filter lines with explicit error keywords
    keywords = ['error:', 'exception:', 'target of uri', 'what went wrong', 'fatal:', 'failed to', 'undefined class', 'compilation failed']
    matched_lines = []
    for i, line in enumerate(lines):
        lower = line.lower()
        if any(k in lower for k in keywords):
            # grab context
            start = max(0, i - 2)
            end = min(len(lines), i + 3)
            matched_lines.append(f"--- Around line {i} ---")
            matched_lines.extend(lines[start:end])
            if len(matched_lines) > 50:
                break
    
    # 2. Grab 60 lines right before "FAILURE: Build failed"
    fail_idx = -1
    for i, line in enumerate(lines):
        if 'FAILURE: Build failed' in line or '* What went wrong:' in line:
            fail_idx = i
            break
            
    if fail_idx != -1:
        start = max(0, fail_idx - 60)
        end = min(len(lines), fail_idx + 10)
        focus = '\n'.join(lines[start:end])
    else:
        focus = '\n'.join(lines[-80:])
        
    body = (
        "### ❌ Matched Error Keywords:\n```\n" + '\n'.join(matched_lines[:40]) + "\n```\n\n"
        "### ❌ Pre-Failure Log Focus:\n```\n" + focus + "\n```"
    )
    
    token = os.environ.get('GITHUB_TOKEN', '')
    repo = os.environ.get('GITHUB_REPOSITORY', '')
    sha = os.environ.get('GITHUB_SHA', '')
    
    if not token or not repo or not sha:
        print("Missing GITHUB env vars for posting comment")
        sys.exit(0)
        
    url = f"https://api.github.com/repos/{repo}/commits/{sha}/comments"
    data = json.dumps({'body': body}).encode('utf-8')
    req = urllib.request.Request(url, data=data, headers={
        'Authorization': f'token {token}',
        'Content-Type': 'application/json',
        'User-Agent': 'GitHub-Actions-Diagnostics',
    })
    with urllib.request.urlopen(req) as resp:
        print("Posted error comment successfully!")
except Exception as e:
    print("Failed to post comment:", e)
