#!/usr/bin/env python3
"""Check shell/PowerShell localization deltas conservatively without executing checks."""
import argparse, pathlib, re, subprocess, sys

def git(*args):
    p=subprocess.run(["git",*args],text=True,capture_output=True,check=False)
    if p.returncode: raise RuntimeError(p.stderr.strip())
    return p.stdout

def lines(repo_path, ref):
    p=subprocess.run(["git","show",f"{ref}:{repo_path}"],capture_output=True)
    return p.stdout.decode("utf-8",errors="replace") if p.returncode==0 else None

def check():
    ap=argparse.ArgumentParser()
    ap.add_argument("--base",default="origin/master")
    args=ap.parse_args()
    names=git("diff","--name-only","--diff-filter=ACMR",args.base,"HEAD").splitlines()
    scripts=[n for n in names if n.endswith((".sh",".ps1"))]
    warnings=0
    for path in scripts:
        base=lines(path,args.base)
        new=pathlib.Path(path).read_text("utf-8")
        if base is None: continue
        old_lines=base.splitlines();new_lines=new.splitlines()
        import difflib
        for line in difflib.unified_diff(old_lines,new_lines,n=0):
            if line.startswith(("---","+++","@@")) or not line.startswith(("+","-")): continue
            content=line[1:].strip()
            if not content or content.startswith("#"):continue
            # Every changed executable line is flagged for human review.
            print(f"REVIEW {path}: {line[:180]}")
            warnings+=1
    print(f"Checked {len(scripts)} changed scripts; executable-line changes for review: {warnings}")
    return 1 if warnings else 0

if __name__=="__main__":
    sys.exit(check())
