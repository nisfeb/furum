#!/usr/bin/env python3
"""The quiet gate's last three steps (docs/logging.md), on a DEV ship.

  quiet-gate.py <url> <cookie-jar> <tmux-target> [road]

Reloads furum, then approves its weir without `road` (default
/sys/ames/registry) and reloads it, then approves the whole weir again,
reading the ship's console (a tmux pane) after each. Furum must say nothing
on the reload, exactly one line on the refusal (kept at /tr/fault), and
nothing more when the grant is whole again (the fault cleared). The first
step, an upgrade from the last release, is a deploy: run it before this.

A line is said for furum when it contains %furum, or is the kernel's
parked line for furum's app: a road whose refusal parks a fiber (timers,
the bowl) is the kernel's to say, and the parked grub's bang its record.
The console is counted from a mark: what is on it when a step starts
doesn't count, screen included.

Never point this at a real ship: it changes furum's grant.
"""
import json, subprocess, sys, time, urllib.request

url, jar, pane = sys.argv[1].rstrip('/'), sys.argv[2], sys.argv[3]
road = sys.argv[4] if len(sys.argv) > 4 else '/sys/ames/registry'
APP = '/apps/shell.shell/desks/furum.desk/desk/data/furum.furum_app'
cookie = next(f'{p[5]}={p[6]}' for p in (l.rstrip('\n').split('\t') for l in open(jar))
              if len(p) == 7 and p[5].startswith('urbauth-'))

def call(path, body=None):
    r = urllib.request.Request(url + path, data=json.dumps(body).encode() if body is not None else None,
                               headers={'cookie': cookie, 'content-type': 'application/json'},
                               method='POST' if body is not None else 'GET')
    return urllib.request.urlopen(r, timeout=120).read()

def console():
    out = subprocess.run(['tmux', 'capture-pane', '-p', '-J', '-t', pane, '-S', '-'],
                         capture_output=True, text=True, check=True).stdout
    return [l for l in out.split('\n') if '%furum' in l or ('furum.furum_app is parked' in l)]

def mark():
    subprocess.run(['tmux', 'clear-history', '-t', pane], check=True)
    return len(console())

def faults():
    j = json.loads(call(f'/grubbery/ball{APP}/tr/fault?info=1'))
    return j.get('text', '') != '[1 0]'

def grant(refuse=()):
    asks = json.loads(call('/apps/grubbery/asks.json'))
    ask = next(v for v in (asks.values() if isinstance(asks, dict) else asks) if v.get('path') == APP)
    road_of = lambda x: x['road'] if isinstance(x, dict) else x
    g = {k: [road_of(x) for x in ask.get(k, []) if road_of(x) not in refuse] for k in ('poke', 'peek', 'make')}
    call('/apps/grubbery/permits', {'action': 'approve-weir', 'app': APP, 'granted': g})
    call('/apps/grubbery/permits/reload', {'app': APP})

def step(what, act, said, kept, wait=90):
    before = mark()
    act()
    time.sleep(wait)
    lines = console()[before:]
    # a fault the kernel said is kept as its bang, not at /tr/fault
    kernel = any('is parked' in l for l in lines)
    ok = len(lines) == said and (faults() or kernel) == kept
    print(f'  {"ok  " if ok else "FAIL"}  {what}: {len(lines)} line(s), fault {"kept" if faults() else "none"}')
    for l in lines:
        print(f'          {l.strip()[:160]}')
    return ok

print(f'quiet gate on {url} ({pane}), refusing {road}')
results = [
    step('a reload says nothing', lambda: call('/apps/grubbery/permits/reload', {'app': APP}), 0, False, 60),
    step(f'refusing {road} says one line, kept', lambda: grant({road}), 1, True),
    step('the whole grant again says nothing, and clears it', grant, 0, False),
]
print('passed' if all(results) else 'FAILED')
sys.exit(0 if all(results) else 1)
