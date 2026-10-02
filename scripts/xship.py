#!/usr/bin/env python3
"""Two DEV ships run furum at each other: follow, post, comment, vote, get
notified, and find each other's boards in the directory, both ways.

  xship.py <url-a> <jar-a> <~ship-a> <url-b> <jar-b> <~ship-b>

Ship A keeps the directory for the run (both ships' registry pref is set to
A; set it back on the admin page after). Each ship makes a board of its
own, the other opens it, and everything a host and a reader can do to each
other is checked from both sides. The boards are deleted at the end. Exit
0 when every check passes, 1 when one fails. The jars come from
hoon-test-kit/ship-cookie.sh. Never point this at a real ship.
"""
import re, sys, time, urllib.error, urllib.parse, urllib.request

ua, ja, sa, ub, jb, sb = sys.argv[1:7]
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
        r = urllib.request.Request(f'{s.url}/apps/furum{path}', data=data, method=meth,
                                   headers={'cookie': s.cookie})
        try:
            with urllib.request.build_opener(Stay).open(r, timeout=90) as res:
                return res.status, res.read().decode(errors='replace')
        except urllib.error.HTTPError as e:
            return e.code, e.read().decode(errors='replace')
    def get(s, path): return s.req('GET', path)
    def post(s, path, form=None): return s.req('POST', path, form or {})

A, B = Ship(ua, ja, sa), Ship(ub, jb, sb)

def ok(what, good, why=''):
    global fails
    print(('  ok    ' if good else '  FAIL  ') + what + ('' if good else f': {why}'))
    fails += not good

def did(what, ship, path, form=None, code=303):
    got, body = ship.post(path, form)
    ok(what, got == code, f'status {got}, not {code}')

def shows(what, ship, path, *has, within=30, lacks=()):
    """poll until the page shows every string (and none of lacks)"""
    end = time.time() + within
    while True:
        code, body = ship.get(path)
        miss = [h for h in has if h not in body] + [h for h in lacks if h in body]
        if code == 200 and not miss:
            return ok(what, True)
        if time.time() > end:
            return ok(what, False, f'status {code}, missing or present: {miss}')
        time.sleep(1)

ba, bb = f'xa{t}', f'xb{t}'
pa, pb = f'/b/{A.name}/{ba}', f'/b/{B.name}/{bb}'
print(f'{A.name} at {A.url} and {B.name} at {B.url}; boards {ba} and {bb}')

print('the directory is kept by', A.name)
did(f'{A.name} keeps it', A, '/admin/registry-ship', {'who': A.name})
did(f'{B.name} reads it from {A.name}', B, '/admin/registry-ship', {'who': A.name})

print('each ship hosts a board')
did(f'{A.name} makes {ba}', A, '/create', {'name': ba, 'title': f'Board A {t}', 'description': 'a'})
did(f'{B.name} makes {bb}', B, '/create', {'name': bb, 'title': f'Board B {t}', 'description': 'b'})
did(f'{A.name} posts on its own board', A, f'{pa}/submit', {'title': f'A hosts {t}', 'body': 'x'})
did(f'{B.name} posts on its own board', B, f'{pb}/submit', {'title': f'B hosts {t}', 'body': 'x'})

print('both boards are in both directories')
shows(f'{A.name} lists both', A, '?view=directory', f'Board A {t}', f'Board B {t}')
shows(f'{B.name} lists both', B, '?view=directory', f'Board A {t}', f'Board B {t}')

for H, R, board, other in [(A, B, pa, ba), (B, A, pb, bb)]:
    print(f'{R.name} reads {H.name}\'s board')
    shows(f'{R.name} has a copy', R, board, f'hosts {t}', within=45)
    did(f'{R.name} follows it', R, f'{board}/follow')
    shows(f'{R.name}\'s feed has it', R, '', f'hosts {t}')

    print(f'{R.name} writes to {H.name}\'s board')
    did(f'{R.name} posts', R, f'{board}/submit', {'title': f'{R.name} was here {t}', 'body': 'y'})
    shows(f'{H.name} has the post', H, board, f'{R.name} was here {t}')
    shows(f'{R.name}\'s copy has it at once', R, board, f'{R.name} was here {t}', within=1)
    shows(f'{H.name} is told', H, '/notifications', f'{R.name} posted')
    did(f'{R.name} comments too soon', R, f'{board}/0/comment', {'body': f'too soon {t}'})
    shows(f'{R.name} is told it was refused', R, '/notifications', 'too fast')
    did(f'{H.name} makes {R.name} a moderator', H, f'{board}/mod/role', {'who': R.name, 'role': 'mod'})
    did(f'{R.name} comments on {H.name}\'s post', R, f'{board}/0/comment', {'body': f'comment from {R.name} {t}'})
    shows(f'{H.name} has the comment', H, f'{board}/0', f'comment from {R.name} {t}')
    shows(f'{H.name} is told of it', H, '/notifications', f'{R.name} commented on')
    did(f'{H.name} replies', H, f'{board}/0/comment', {'body': f'reply from {H.name} {t}', 'parent': '0'})
    shows(f'{R.name} is told of the reply', R, '/notifications', f'{H.name} replied to your comment')
    shows(f'{R.name}\'s copy has the reply', R, f'{board}/0', f'reply from {H.name} {t}')
    did(f'{R.name} upvotes {H.name}\'s post', R, f'{board}/vote', {'target': 'post-0', 'dir': 'up'})
    shows(f'{H.name} counts it', H, board, f'1 points by {H.name}')
    did(f'{R.name} sets the sidebar as a moderator', R, f'{board}/sidebar', {'sidebar': f'rules by {R.name} {t}'})
    shows(f'{H.name}\'s board has the sidebar', H, board, f'rules by {R.name} {t}')
    did(f'{R.name} may not delete {H.name}\'s board', R, f'{board}/mod/delete', code=403)
    shows(f'{R.name}\'s notes all show as unread', R, '/notif-count', '"count":')
    did(f'{R.name} marks them read', R, '/notifications/read')
    shows(f'{R.name} has none unread', R, '/notif-count', '"count":0')

print('the hosts delete their boards')
did(f'{A.name} deletes {ba}', A, f'{pa}/mod/delete')
did(f'{B.name} deletes {bb}', B, f'{pb}/mod/delete')
shows(f'{A.name}\'s directory lets both go', A, '?view=directory', lacks=(f'Board A {t}', f'Board B {t}'))
# the registry is now as it was before the run: B's copy must still hold
# what A lists (grubbery loses a copy written identical to content it has
# already taken from another ship; furum keeps its copy in its own form)
listed = lambda ship: set(re.findall(r'href="(/apps/furum/b/~[a-z-]+/[a-z0-9-]+)"', ship.get('?view=directory')[1]))
end = time.time() + 30
while listed(B) != listed(A) and time.time() < end: time.sleep(1)
ok(f'{B.name}\'s directory is {A.name}\'s again ({len(listed(A))} boards)', listed(B) == listed(A),
   f'{A.name} lists {len(listed(A))}, {B.name} {len(listed(B))}')
print('0 failed' if not fails else f'{fails} FAILED')
sys.exit(1 if fails else 0)
