#!/usr/bin/env python3
"""Every route furum serves on a DEV ship, as the owner and as a guest,
with the refusals each one promises.

  api-matrix.py <base-url> <cookie-jar> <~ship>

Makes a board of its own (m<time>), works it through every host action,
checks each page shows what the action did, and deletes it again. Exit 0
when every check passes, 1 when one fails. The jar comes from
hoon-test-kit/ship-cookie.sh. Never point this at a real ship.
"""
import sys, time, urllib.error, urllib.parse, urllib.request

url, jar, ship = sys.argv[1].rstrip('/'), sys.argv[2], sys.argv[3]
cookie = next(f'{p[5]}={p[6]}' for p in (l.rstrip('\n').split('\t') for l in open(jar))
              if len(p) == 7 and p[5].startswith('urbauth-'))
b = f'm{int(time.time())}'
board = f'/b/{ship}/{b}'
fails = 0

class Stay(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *a): return None

def req(meth, path, form=None, owner=True, site=None):
    head = {'cookie': cookie} if owner else {}
    if site: head['sec-fetch-site'] = site
    data = urllib.parse.urlencode(form).encode() if form is not None else None
    r = urllib.request.Request(f'{url}/apps/furum{path}', data=data, method=meth, headers=head)
    try:
        with urllib.request.build_opener(Stay).open(r, timeout=60) as res:
            return res.status, res.read().decode(errors='replace'), res.headers.get('location')
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode(errors='replace'), e.headers.get('location')

def check(what, meth, path, code, form=None, has=(), lacks=(), owner=True, site=None, to=None):
    global fails
    got, body, loc = req(meth, path, form, owner, site)
    bad = []
    if got != code: bad.append(f'status {got}, not {code}')
    bad += [f'no "{h}"' for h in has if h not in body]
    bad += [f'has "{h}"' for h in lacks if h in body]
    if to and not (loc or '').endswith(to): bad.append(f'went to {loc}, not {to}')
    print(('  ok    ' if not bad else '  FAIL  ') + what + ('' if not bad else ': ' + '; '.join(bad)))
    fails += bool(bad)

get = lambda what, path, code=200, **k: check(what, 'GET', path, code, **k)
post = lambda what, path, form, code=303, **k: check(what, 'POST', path, code, form, **k)

print(f'furum on {ship} at {url}, board {b}')
print('pages')
for p in ['', '?view=directory', '/curated', '/tag/x', '/guide', '/create', '/admin',
          '/notifications', '/share?title=t&url=https://x.example']:
    get(f'GET {p or "/"}', p)
get('notif-count is json', '/notif-count', has=['"count":'])
get('s3-config says not set up', '/s3-config', has=['{}'])
get('registry goes to admin', '/registry', 303, to='/apps/furum/admin')
get('no such page', '/x', 404)
get("no board by a bad name on another ship", '/b/~nec/Bad_Name', 404)
print('anyone')
for p in ['/manifest', '/sw', '/icon', '/favicon', '/about']:
    get(f'GET {p} without a login', p, owner=False)
get('a guest gets no owner page', '/guide', 403, owner=False)
print('refusals')
post('a form from another site', '/create', {'name': b}, 403, site='cross-site')
check('PUT is not a method here', 'PUT', '/create', 405)
post('a bad board name', '/create', {'name': 'Bad Name', 'title': 'x'}, 400, has=['a-z, 0-9'])
print('a board')
post('create', '/create', {'name': b, 'title': 'Matrix', 'description': 'made by api-matrix', 'default-role': 'poster'}, to=board)
post('create again', '/create', {'name': b, 'title': 'again'}, 409, has=['already host'])
get('the board', board, has=['Matrix'])
get('its submit page', f'{board}/submit')
get('its mod page', f'{board}/mod', has=['made by api-matrix'])
get('a missing board', f'/b/{ship}/nope{b}', 404)
print('posts')
post('a post with no title', f'{board}/submit', {'title': ''}, 400, has=['needs a title'])
post('post 0', f'{board}/submit', {'title': 'First post', 'url': 'https://example.com/a', 'body': 'body text'}, to=board)
post('post 1', f'{board}/submit', {'title': 'Second post', 'body': 'another'}, to=board)
get('both on the board', board, has=['First post', 'Second post'])
get('post 0 page', f'{board}/0', has=['First post', 'body text'])
get('post 0 edit page', f'{board}/0/edit')
post('edit post 0', f'{board}/0/edit', {'title': 'First post, edited', 'body': 'new body'}, to=f'{board}/0')
get('the edit shows', f'{board}/0', has=['First post, edited', 'new body'])
get('a missing post', f'{board}/999', 404)
get('a post id past 999 parses', f'{board}/1000', 404, has=['post not found'])
print('comments')
post('comment', f'{board}/0/comment', {'body': 'first comment'}, to=f'{board}/0')
post('reply', f'{board}/0/comment', {'body': 'a reply', 'parent': '0'}, to=f'{board}/0')
post('a reply to nothing', f'{board}/0/comment', {'body': 'x', 'parent': '7'}, 404)
post('a comment on nothing', f'{board}/9/comment', {'body': 'x'}, 404)
get('both on the post', f'{board}/0', has=['first comment', 'a reply'])
post('delete the reply', f'{board}/0/delete-comment', {'comment-id': '1'}, to=f'{board}/0')
get('the reply is gone', f'{board}/0', has=['first comment'], lacks=['a reply'])
print('votes and pins')
post('upvote post 1', f'{board}/vote', {'target': 'post-1', 'dir': 'up'})
post('downvote comment 0', f'{board}/vote', {'target': 'comment-0-0', 'dir': 'down'})
post('remove the vote', f'{board}/vote', {'target': 'post-1', 'dir': 'remove'})
post('a bad vote target', f'{board}/vote', {'target': 'nope'}, 400)
post('pin post 1', f'{board}/1/pin', {'pinned': 'true'}, to=board)
post('unpin post 1', f'{board}/1/pin', {'pinned': 'false'}, to=board)
print('moderation')
post('sidebar', f'{board}/sidebar', {'sidebar': 'rules of the matrix'}, to=f'{board}/mod')
get('the sidebar shows', board, has=['rules of the matrix'])
post('edit info', f'{board}/mod/edit-info', {'title': 'Matrix renamed', 'description': 'd2'}, to=f'{board}/mod')
get('the new title shows', board, has=['Matrix renamed'])
post('a role', f'{board}/mod/role', {'who': '~nec', 'role': 'mod'}, to=f'{board}/mod')
get('the role shows', f'{board}/mod', has=['~nec'])
post('remove the role', f'{board}/mod/remove-role', {'who': '~nec'}, to=f'{board}/mod')
post('a role for no ship', f'{board}/mod/role', {'who': 'nec', 'role': 'mod'}, 400)
post('auto-prune on', f'{board}/mod/prune', {'prune-enabled': 'on', 'min-score': '1', 'after-days': '30'}, to=f'{board}/mod')
post('auto-prune off', f'{board}/mod/prune', {}, to=f'{board}/mod')
print('members')
post('a price', f'{board}/mod/payment', {'enabled': 'on', 'price': '100', 'interval': '30'}, to=f'{board}/mod?saved=payment')
get('the mod page lists members', f'{board}/mod', has=['give access'])
post('give access', f'{board}/mod/grant', {'who': '~nec', 'days': '1'}, to=f'{board}/mod')
get('the member shows', f'{board}/mod', has=['~nec', 'active'])
post('take it away', f'{board}/mod/revoke', {'who': '~nec'}, to=f'{board}/mod')
post('access for no ship', f'{board}/mod/grant', {'who': 'nec'}, 400)
post('no price', f'{board}/mod/payment', {}, to=f'{board}/mod?saved=payment')
print('payments (scripts/pay.py pays for real)')
post('a host does not pay for its own board', f'{board}/pay', {}, 400)
post('nor asks itself for an invoice', f'{board}/pay-lightning', {}, 400)
get('the wallet backup is json, empty', f'{board}/mod/backup-proofs', has=['[]'])
get('and not a guest\'s', f'{board}/mod/backup-proofs', 403, owner=False)
post('nor withdraws from an empty wallet', f'{board}/mod/melt',
     {'mint': 'http://127.0.0.1:1', 'invoice': 'lnbc1'}, 400)
print('the directory')
post('register', f'{board}/mod/register', {}, to=f'{board}/mod?saved=registered')
print('public')
get('a private board, to a guest', board, 403, owner=False)
post('make it public', f'{board}/mod/public', {}, to=f'{board}/mod')
get('the public board, to a guest', board, owner=False, has=['Second post'])
get('a public post, to a guest', f'{board}/0', owner=False, has=['first comment'])
post('make it private', f'{board}/mod/public', {}, to=f'{board}/mod')
get('private again', board, 403, owner=False)
print('you')
post('follow', f'{board}/follow', {}, to=board)
post('follow twice', f'{board}/follow', {}, to=board)
get('the feed has it', '', has=['Second post'])
post('unfollow', f'{board}/unfollow', {}, to=board)
post('unfollow twice', f'{board}/unfollow', {}, to=board)
print('theme')
get('the theme page', '/theme', has=['Use talon', 'Appearance', 'new theme'])
post('the built-in theme', '/theme/use', {'id': ''}, to='/apps/furum/theme')
post('the device decides', '/theme/mode', {'mode': 'system'}, to='/apps/furum/theme')
get('a page follows the device', '/guide', has=['prefers-color-scheme: dark', 'color-scheme:light dark'])
post('dark', '/theme/mode', {'mode': 'dark'}, to='/apps/furum/theme')
get('dark, with no light', '/guide', has=['color-scheme:dark;', '--bg:#0a0a14;'], lacks=['prefers-color-scheme'])
post('the old toggle still flips it', '/dark-mode', {})
get('light', '/guide', has=['color-scheme:light;'])
post('a new theme', '/theme/save', {'id': f'theme-{b}', 'name': 'Dusk', 'dark': 'dark', 'primary': '#fbbf24',
     'secondary': '#a5b4fc', 'tertiary': '#34d399', 'background': '#0f0d1a', 'surface': '#1a1625'},
     to='/apps/furum/theme')
get('draws with it', '/guide', has=['--primary:#fbbf24;', 'color-scheme:dark;'])
get('and can edit it', f'/theme?edit=theme-{b}', has=['Edit Dusk', 'delete this theme'])
post('an accent', '/theme/accent', {'how': 'custom', 'hex': '#101541', 'set': 'use'}, to='/apps/furum/theme')
get('repaints the primary colour', '/guide', has=['--primary:#101541;'])
post('a colour that is not one', '/theme/save', {'id': 'x', 'name': 'X', 'dark': 'light', 'primary': 'red',
     'secondary': '#000000', 'tertiary': '#000000', 'background': '#000000', 'surface': '#000000'}, 400)
post('no such setting', '/theme/nope', {}, 400)
post('delete the theme', '/theme/delete', {'id': f'theme-{b}'}, to='/apps/furum/theme')
post('accent off', '/theme/accent', {'how': 'off'}, to='/apps/furum/theme')
post('back to the device', '/theme/mode', {'mode': 'system'}, to='/apps/furum/theme')
get('the built-in theme again', '/guide', has=['--primary:#cc2020;', 'prefers-color-scheme: dark'])
post('notifications read', '/notifications/read', {}, to='/apps/furum/notifications')
print('deleting')
post('delete post 1', f'{board}/1/delete', {}, to=board)
get('post 1 is gone', board, lacks=['Second post'])
post('delete the board', f'{board}/mod/delete', {}, to='/apps/furum')
get('the board is gone', board, 404)
print('0 failed' if not fails else f'{fails} FAILED')
sys.exit(1 if fails else 0)
