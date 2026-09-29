#!/usr/bin/env python3
"""Paying for a board, end to end, across two DEV ships and a test mint.

  pay.py <url-host> <jar-host> <~host> <url-payer> <jar-payer> <~payer> <mint-url> <cashu-venv>

The host prices a board at 100 sats a minute, through a test mint:
nutshell with its FakeWallet, which pays every invoice it issues by itself
(cashu-venv is the virtualenv nutshell is installed in; its wallet makes
the payer's ecash, in a directory of its own under /tmp). The payer pays
by Lightning and reads the board; the minute runs out and it meets the
paywall; it renews with an ecash token, and the same token again is
refused as spent. The host withdraws part of its wallet to Lightning, and
what is left must all be unspent at the mint; a withdrawal the mint
refuses leaves the wallet as it was. The host's furum reloads
under each payment (its fibers start again from their grubs), and each
must come through anyway. Exit 0 when every check passes, 1 when one
fails. Never point this at a real ship or a real mint.
"""
import base64, json, os, re, subprocess, sys, tempfile, time
import urllib.error, urllib.parse, urllib.request

uh, jh, sh, up, jp, sp, mint, venv = sys.argv[1:9]
mint = mint.rstrip('/')
t = int(time.time())
fails = 0
APP = '/apps/shell.shell/desks/furum.desk/desk/data/furum.furum_app'

def cookie(jar):
    return next(f'{p[5]}={p[6]}' for p in (l.rstrip('\n').split('\t') for l in open(jar))
                if len(p) == 7 and p[5].startswith('urbauth-'))

class Stay(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, *a): return None

def fetch(url, data=None, head=None, method=None):
    r = urllib.request.Request(url, data=data, headers=head or {}, method=method)
    try:
        with urllib.request.build_opener(Stay).open(r, timeout=90) as res:
            return res.status, res.read().decode(errors='replace'), res.headers
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode(errors='replace'), e.headers

class Ship:
    def __init__(s, url, jar, name):
        s.url, s.cookie, s.name = url.rstrip('/'), cookie(jar), name
    def req(s, meth, path, form=None, js=None):
        head = {'cookie': s.cookie}
        data = None
        if form is not None: data = urllib.parse.urlencode(form).encode()
        if js is not None:
            data, head['content-type'] = json.dumps(js).encode(), 'application/json'
        return fetch(f'{s.url}{path}', data, head, meth)
    def get(s, path): return s.req('GET', '/apps/furum' + path)[:2]
    def post(s, path, form=None): return s.req('POST', '/apps/furum' + path, form or {})
    def reload(s):
        s.req('POST', '/apps/grubbery/permits/reload', js={'app': APP})

H, P = Ship(uh, jh, sh), Ship(up, jp, sp)

def ok(what, good, why=''):
    global fails
    print(('  ok    ' if good else '  FAIL  ') + what + ('' if good else f': {why}'))
    fails += not good
    return good

def did(what, ship, path, form=None, code=303):
    got, body, _ = ship.post(path, form)
    ok(what, got == code, f'status {got}, not {code}: {body[:200]}')

def until(what, check, within=90, every=3):
    """poll check() until it answers truthy"""
    end = time.time() + within
    while True:
        got = check()
        if got: return ok(what, True)
        if time.time() > end: return ok(what, False, f'not within {within}s')
        time.sleep(every)

def mint_call(path, body=None):
    data = json.dumps(body).encode() if body is not None else None
    code, text, _ = fetch(f'{mint}{path}', data, {'content-type': 'application/json'})
    return json.loads(text)

board = f'pp{t}'
base = f'/b/{H.name}/{board}'
secret = f'members only {t}'

def reads():
    P.post('/admin/resub', {'host': H.name, 'name': board})
    code, body = P.get(base)
    return code == 200 and secret in body

def walled():
    P.post('/admin/resub', {'host': H.name, 'name': board})
    code, body = P.get(base)
    return code == 200 and 'payment required' in body and secret not in body

def wallet():
    code, body = H.get(f'{base}/mod/backup-proofs')
    return json.loads(body) if code == 200 else None

def balance():
    w = wallet()
    return None if w is None else sum(p['amount'] for p in w)

def notes():
    return H.get('/notifications')[1]

def pay_page(path):
    """a payment's page on the payer, followed to the board once it opens"""
    return P.get(path)

print(f'{H.name} hosts, {P.name} pays; board {board}; mint {mint}')
did('a board', H, '/create', {'name': board, 'title': f'Paid {t}'})
did('its post', H, f'{base}/submit', {'title': secret, 'body': 'x'})
did('its price: 100 sats a minute, through the test mint', H, f'{base}/mod/payment',
    {'enabled': 'on', 'price': '100', 'minutes': '1', 'mint-url': mint})
P.get(base)
until('the payer meets the paywall', walled, 60)

print('Lightning, with the host reloading under it')
subs = notes().count('New paid subscriber')
code, body, head = P.post(f'{base}/pay-lightning')
loc = head.get('location', '') if head else ''
ok('the payer asks for an invoice', code == 303 and '/payment/' in loc, f'{code} {loc} {body[:200]}')
H.reload()
path = loc.replace('/apps/furum', '')
until('its page shows the invoice', lambda: 'lnbc' in pay_page(path)[1], 90)
H.reload()
until('the mint is paid, and the payer reads the board', reads, 120)
until('the host is told of its new subscriber', lambda: notes().count('New paid subscriber') > subs, 30)
ok('the host holds the 100 sats', balance() == 100, f'balance {balance()}')

print('the minute runs out')
until('the payer meets the paywall again', walled, 200, 5)

print('ecash, with the host reloading under it')
wdir = tempfile.mkdtemp(prefix='furum-pay-wallet-')
env = dict(os.environ, CASHU_DIR=os.path.join(wdir, 'data'))
cashu = [os.path.join(venv, 'bin', 'cashu'), '-h', mint, '-y']
subprocess.run(cashu + ['invoice', '500'], env=env, cwd=wdir, capture_output=True, timeout=120)
out = subprocess.run(cashu + ['send', '100', '--legacy'], env=env, cwd=wdir,
                     capture_output=True, text=True, timeout=120).stdout
tok = re.search(r'cashuA[A-Za-z0-9_=-]+', out)
ok('the payer has a 100 sat token', bool(tok), out[-300:])
raw = tok.group(0)[len('cashuA'):]
proofs = [p for e in json.loads(base64.urlsafe_b64decode(raw + '=' * (-len(raw) % 4)))['token']
          for p in e['proofs']]
tokens = json.dumps({'inputs': proofs})
code, body, head = P.post(f'{base}/pay', {'mint': mint, 'tokens': tokens})
loc = head.get('location', '') if head else ''
ok('the payer sends it', code == 303 and '/payment/' in loc, f'{code} {body[:200]}')
H.reload()
until('the payer reads the board again', reads, 120)
fee = -(-len(proofs) * 100 // 1000)
ok(f'the host holds 100 more, less the mint fee ({fee})', balance() == 200 - fee, f'balance {balance()}')

print('the same token again')
code, body, head = P.post(f'{base}/pay', {'mint': mint, 'tokens': tokens})
path = (head.get('location', '') if head else '').replace('/apps/furum', '')
until('is refused as spent', lambda: 'failed' in pay_page(path)[1], 60)
ok('and the wallet is as it was', balance() == 200 - fee, f'balance {balance()}')

print('a withdrawal the mint refuses')
before = balance()
failed = notes().count('A withdrawal failed')
own = mint_call('/v1/mint/quote/bolt11', {'amount': 50, 'unit': 'sat'})['request']
time.sleep(5)  # the fake wallet pays the mint's own invoices by itself; paid, it can't be melted
did('the host melts to an invoice the mint has paid already', H, f'{base}/mod/melt',
    {'mint': mint, 'invoice': own})
until('the host is told it failed', lambda: notes().count('A withdrawal failed') > failed, 90)
ok('and the wallet is as it was', balance() == before, f'{before} to {balance()}')

print('a withdrawal, with the host reloading under it')
invoice = subprocess.run([os.path.join(venv, 'bin', 'python'), '-c',
    'import hashlib, os, datetime\n'
    'from bolt11 import Bolt11, Tags, TagChar, MilliSatoshi, encode\n'
    't = Tags(); t.add(TagChar.description, "furum test"); t.add(TagChar.expire_time, 3600)\n'
    's = os.urandom(32).hex(); t.add(TagChar.payment_secret, s)\n'
    't.add(TagChar.payment_hash, hashlib.sha256(s.encode()).hexdigest())\n'
    'b = Bolt11(currency="bc", amount_msat=MilliSatoshi(50000), date=int(datetime.datetime.now().timestamp()), tags=t)\n'
    'print(encode(b, os.urandom(32).hex()))'], capture_output=True, text=True).stdout.strip()
paid = notes().count('A withdrawal was paid')
did('the host melts to an invoice for 50 on another node', H, f'{base}/mod/melt', {'mint': mint, 'invoice': invoice})
H.reload()
until('the host is told the withdrawal was paid', lambda: notes().count('A withdrawal was paid') > paid, 120)
after = balance()
ok(f'its wallet went down by 50 and some fees ({before} to {after})',
   after is not None and before - 60 <= after <= before - 50, f'{before} to {after}')
w = wallet() or []
ys = subprocess.run([os.path.join(venv, 'bin', 'python'), '-c',
    'import sys,json\nfrom cashu.core.crypto.b_dhke import hash_to_curve\n'
    'print(json.dumps([hash_to_curve(s.encode()).format().hex() for s in json.load(sys.stdin)]))'],
    input=json.dumps([p['secret'] for p in w]), capture_output=True, text=True).stdout
states = mint_call('/v1/checkstate', {'Ys': json.loads(ys)})['states'] if w else []
ok(f'every proof left ({len(w)}) is unspent at the mint',
   len(states) == len(w) and all(s['state'] == 'UNSPENT' for s in states),
   json.dumps([s['state'] for s in states]))

print('the host deletes the board')
did(f'{board} goes', H, f'{base}/mod/delete')
code = H.req('GET', f'/grubbery/ball{APP}/wallets/{board}?info=1')[0]
ok('its wallet stays', code == 200, f'status {code}')
print('0 failed' if not fails else f'{fails} FAILED')
sys.exit(1 if fails else 0)
