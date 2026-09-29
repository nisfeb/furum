#!/usr/bin/env python3
"""Who may read a paid board, checked across two DEV ships.

  access.py <url-host> <jar-host> <~host> <url-reader> <jar-reader> <~reader>

The host makes a free board and a paid one, each with a post; the reader
opens both. The reader reads the free one, and the paid one shows its
paywall, never its post: the host's weir refuses it the content. Then
the host gives the reader access (it reads), takes it away (the paywall
again), makes it a moderator (it reads), and gives it a one-minute trial
that runs out while the script waits: the host's sweeper takes it out of
the board's group, and the reader loses the post. The boards are deleted
at the end. Exit 0 when every check passes, 1 when one fails. Never
point this at a real ship.
"""
import sys, time, urllib.error, urllib.parse, urllib.request

uh, jh, sh, ur, jr, sr = sys.argv[1:7]
t = int(time.time())
fails = 0

def cookie(jar):
    return next(f'{p[5]}={p[6]}' for p in (l.rstrip('\n').split('\t') for l in open(jar))
                if len(p) == 7 and p[5].startswith('urbauth-'))

class Stay(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *a): return None

class Ship:
    def __init__(s, url, jar, name):
        s.url, s.cookie, s.name = url.rstrip('/'), cookie(jar), name
    def req(s, meth, path, form=None):
        data = urllib.parse.urlencode(form).encode() if form is not None else None
        r = urllib.request.Request(f'{s.url}{path}', data=data, method=meth,
                                   headers={'cookie': s.cookie})
        try:
            with urllib.request.build_opener(Stay).open(r, timeout=90) as res:
                return res.status, res.read().decode(errors='replace')
        except urllib.error.HTTPError as e:
            return e.code, e.read().decode(errors='replace')
    def get(s, path): return s.req('GET', '/apps/furum' + path)
    def post(s, path, form=None): return s.req('POST', '/apps/furum' + path, form or {})
    def raw(s, path): return s.req('GET', path)

H, R = Ship(uh, jh, sh), Ship(ur, jr, sr)
APP = '/grubbery/ball/apps/shell.shell/desks/furum.desk/desk/data/furum.furum_app'

def ok(what, good, why=''):
    global fails
    print(('  ok    ' if good else '  FAIL  ') + what + ('' if good else f': {why}'))
    fails += not good

def did(what, ship, path, form=None, code=303):
    got, _ = ship.post(path, form)
    ok(what, got == code, f'status {got}, not {code}')

def sync(board):
    """the reader asks its follower to look again now, as the admin page's resub does"""
    R.post('/admin/resub', {'host': H.name, 'name': board})

def reads(what, board, secret, yes, within=45):
    """poll the reader's page for the board's post (yes) or its paywall (no)"""
    end = time.time() + within
    while True:
        sync(board)
        time.sleep(3)
        code, body = R.get(f'/b/{H.name}/{board}')
        seen = secret in body
        wall = 'payment required' in body
        if code == 200 and (seen if yes else (wall and not seen)):
            return ok(what, True)
        if time.time() > end:
            return ok(what, False, f'status {code}, post {"shown" if seen else "not shown"}, paywall {wall}')

free, paid = f'af{t}', f'ap{t}'
print(f'{H.name} hosts, {R.name} reads; boards {free} and {paid}')
did('a free board', H, '/create', {'name': free, 'title': f'Free {t}'})
did('its post', H, f'/b/{H.name}/{free}/submit', {'title': f'open to all {t}', 'body': 'x'})
did('a paid board', H, '/create', {'name': paid, 'title': f'Paid {t}'})
did('its post', H, f'/b/{H.name}/{paid}/submit', {'title': f'members only {t}', 'body': 'x'})
did('its price', H, f'/b/{H.name}/{paid}/mod/payment', {'enabled': 'on', 'price': '100', 'interval': '30'})
did('a paid board is never public', H, f'/b/{H.name}/{paid}/mod/public', code=400)

print('the weir')
code, body = H.raw('/grubbery/ball/sys/ames/usergroups/public.grp/how.weir?raw=1')
ok('the public may read the free board', f'boards/{free}/content' in body, body[:200])
ok('the public may read the paid board\'s card', f'boards/{paid}/pub' in body, body[:200])
ok('the public may not read the paid board\'s content', f'boards/{paid}/content' not in body)
code, body = H.raw(f'/grubbery/ball/sys/ames/usergroups/furum-{paid}.grp/how.weir?raw=1')
ok('its group may', f'boards/{paid}/content' in body, f'status {code}')

print(f'{R.name}, a stranger')
R.get(f'/b/{H.name}/{free}'); R.get(f'/b/{H.name}/{paid}')
reads('reads the free board', free, f'open to all {t}', True)
reads('meets the paid board\'s paywall', paid, f'members only {t}', False)
code, body = R.raw(f'{APP}/cache/{H.name}/{paid}?info=1')
ok('holds none of its content', '"content"' not in body, body[:200])

print(f'{R.name}, a member')
did('the host gives access', H, f'/b/{H.name}/{paid}/mod/grant', {'who': R.name, 'days': '1'})
code, body = H.raw(f'/grubbery/ball/sys/ames/usergroups/furum-{paid}.grp/who.ships?raw=1')
ok('the group holds the member', R.name in body, body[:100])
reads('reads the paid board', paid, f'members only {t}', True)
did('the host takes it away', H, f'/b/{H.name}/{paid}/mod/revoke', {'who': R.name})
reads('meets the paywall again', paid, f'members only {t}', False)

print(f'{R.name}, a moderator')
did('the host makes it a moderator', H, f'/b/{H.name}/{paid}/mod/role', {'who': R.name, 'role': 'mod'})
reads('reads as a moderator', paid, f'members only {t}', True)
did('and not any more', H, f'/b/{H.name}/{paid}/mod/remove-role', {'who': R.name})
reads('meets the paywall', paid, f'members only {t}', False)

print(f'{R.name}, a one-minute trial')
did('the host gives a minute', H, f'/b/{H.name}/{paid}/mod/grant', {'who': R.name, 'minutes': '1'})
reads('reads during it', paid, f'members only {t}', True)
start = time.time()
while R.name in H.raw(f'/grubbery/ball/sys/ames/usergroups/furum-{paid}.grp/who.ships?raw=1')[1]:
    if time.time() - start > 180: break
    time.sleep(3)
ok(f'the sweep drops it when the minute is up (after {int(time.time() - start)}s)',
   time.time() - start < 180)
reads('meets the paywall after', paid, f'members only {t}', False)

print('the host deletes both boards')
did(f'{free} goes', H, f'/b/{H.name}/{free}/mod/delete')
did(f'{paid} goes', H, f'/b/{H.name}/{paid}/mod/delete')
code, body = H.raw('/grubbery/ball/sys/ames/usergroups/public.grp/how.weir?raw=1')
ok('the public grant forgets them', f'boards/{free}' not in body and f'boards/{paid}' not in body)
code, _ = H.raw(f'/grubbery/ball/sys/ames/usergroups/furum-{paid}.grp?info=1')
ok('the group is gone', code == 404, f'status {code}')
print('0 failed' if not fails else f'{fails} FAILED')
sys.exit(1 if fails else 0)
