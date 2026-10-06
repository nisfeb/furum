::  lib/furum.hoon: rendering and parsing helpers for %furum
::
/<  *   /lib/furum-types.hoon
/<  ca  /lib/cashu.hoon
/<  th  /lib/furum-theme.hoon
|%
::  the release, as in code/version.json; the page footer shows it
++  version  '7'
::
::  the app icon (nex/furum/icon.svg) as a 512 px PNG, base64
::
++  furum-icon-png
  ^-  cord
  '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'
::
::  CSS as a cord (no interpolation issues with braces)
::
::  the service worker: installs the page as an app and shows pushes
::
++  furum-sw-js
  ^-  cord
  '''
  self.addEventListener("install",function(e){self.skipWaiting()});
  self.addEventListener("activate",function(e){e.waitUntil(self.clients.claim())});
  self.addEventListener("push",function(e){
    var d={title:"Notification",body:""};
    try{d=e.data.json()}catch(x){}
    var t=d.tag||"";
    e.waitUntil(
      (t?self.registration.getNotifications({tag:t}):Promise.resolve([]))
      .then(function(all){
        var c=1;
        if(all.length>0&&all[0].data&&all[0].data.count)c=all[0].data.count+1;
        var body=d.body||"";
        if(c>1)body=c+" new";
        return self.registration.showNotification(d.title,{
          body:body,icon:d.icon||"",tag:t,renotify:true,
          data:{url:d.url||"",count:c}
        })
      })
    )
  });
  self.addEventListener("notificationclick",function(e){
    e.notification.close();
    if(e.notification.data&&e.notification.data.url)
      e.waitUntil(clients.openWindow(e.notification.data.url))
  });
  '''
::
++  furum-css
  ^-  @t
  ::  every colour is a role (a CSS variable); lib/furum-theme sets them
  ::  from the theme in use, light or dark
  '''
  * { box-sizing: border-box; }
  html, body { max-width: 100%; overflow-x: hidden; }
  body { font-family: Verdana, Geneva, sans-serif; font-size: 16px;
         color: var(--text); background: var(--bg); margin: 0; padding: 0;
         line-height: 1.55; }
  #hd { background: var(--hd); border-bottom: 1px solid var(--primary);
        padding: 8px 16px; line-height: 32px; }
  #hd a { color: var(--hd-text); text-decoration: none; font-weight: bold;
           font-size: 18px; }
  #hd .nav { font-weight: normal; font-size: 16px; }
  #hd .nav a, #hd .dark-toggle a { color: var(--hd-nav); font-weight: normal; font-size: 16px; }
  .ct { padding: 16px; max-width: 960px; overflow-wrap: break-word;
         word-wrap: break-word; }
  a { color: var(--link); }
  hr { border: 0; border-top: 1px solid var(--line); }
  .ti a { text-decoration: none; font-size: 18px; color: var(--title); }
  .ti a:visited { color: var(--visited); }
  .host { font-size: 14px; color: var(--muted); overflow-wrap: break-word;
           word-break: break-all; }
  .me { color: var(--muted); font-size: 14px; padding-left: 5px; }
  .me a { color: var(--muted); }
  .cm { border-left: 2px solid var(--line); padding-left: 12px;
         margin: 10px 0 10px 12px; }
  .cm-meta { color: var(--muted); font-size: 14px; margin-bottom: 5px; }
  .cm-meta a { color: var(--muted); }
  .va { color: var(--faint); cursor: pointer; border: none;
         background: none; padding: 0; font-size: 18px; }
  .va:hover { color: var(--primary); }
  .rw { padding: 5px 0; display: flex; align-items: baseline; }
  .rk { min-width: 24px; text-align: right; margin-right: 6px;
         color: var(--muted); font-size: 15px; flex-shrink: 0; }
  .rw > div { min-width: 0; flex: 1; }
  .score { display: inline; }
  textarea, input[type=text], input[type=url], input[type=number], select {
    background: var(--input); color: var(--text); border: 1px solid var(--line-strong); }
  textarea { width: 100%; max-width: 540px; height: 160px; font-family: monospace;
              font-size: 16px; }
  input[type=text], input[type=url] { width: 100%; max-width: 440px;
                                        font-size: 16px; padding: 5px; }
  input[type=checkbox], input[type=radio] { accent-color: var(--primary); }
  .btn { margin-top: 10px; padding: 8px 24px; cursor: pointer;
          background: var(--primary); color: var(--on-primary); border: none; font-size: 16px; }
  .btn:hover { background: var(--primary-hover); }
  .post-body { padding: 12px 0; max-width: 100%; white-space: pre-wrap;
                font-size: 16px; line-height: 1.6; overflow-wrap: break-word;
                word-wrap: break-word; }
  table.mod { border-collapse: collapse; font-size: 16px; }
  table.mod td, table.mod th { padding: 8px 16px; text-align: left;
                                 border-bottom: 1px solid var(--line); }
  .err { color: var(--primary); padding: 20px; font-size: 16px; }
  .sort { font-size: 14px; color: var(--muted); margin-bottom: 10px; }
  .sort a { color: var(--link); text-decoration: none; }
  .sort a:hover { text-decoration: underline; }
  .sort strong { color: var(--text); }
  .tag { font-size: 14px; color: var(--primary); margin-left: 2px; }
  .img-preview { margin: 4px 0 4px 0; font-size: 14px; }
  .img-preview summary { cursor: pointer; color: var(--muted); }
  .img-preview summary:hover { color: var(--link); }
  .img-preview img { max-width: 100%; max-height: 512px; margin-top: 6px;
                      display: block; }
  .dark-toggle { float: right; font-size: 15px; }
  .dark-toggle button { background: none; border: none; cursor: pointer;
                         font-size: 15px; padding: 0; color: var(--hd-nav); }
  .pinned { background: var(--pin); border-left: 3px solid var(--primary); padding-left: 8px; }
  .pin-tag { font-size: 12px; color: var(--primary); font-weight: bold; text-transform: uppercase;
             margin-right: 8px; white-space: nowrap; }
  .upload-section { margin: 8px 0; }
  .upload-section input[type=file] { font-size: 14px; }
  .upload-btn { padding: 6px 16px; cursor: pointer; background: var(--primary);
                color: var(--on-primary); border: none; font-size: 14px; margin-left: 8px; }
  .upload-btn:hover { background: var(--primary-hover); }
  .upload-btn:disabled { background: var(--faint); cursor: default; }
  .upload-status { font-size: 14px; color: var(--muted); margin-left: 8px; }
  .upload-err { font-size: 14px; color: var(--primary); margin-left: 8px; }
  .new-tag { font-size: 11px; color: var(--on-primary); background: var(--primary); padding: 1px 6px;
             border-radius: 3px; margin-left: 6px; font-weight: bold;
             text-transform: uppercase; vertical-align: middle; }
  .new-dot { display: inline-block; width: 8px; height: 8px; background: var(--primary);
             border-radius: 50%; margin-right: 4px; vertical-align: middle; }
  .cm-new { background: var(--note); border-left-color: var(--tertiary); }
  .board-layout { display: flex; gap: 24px; }
  .board-main { flex: 1; min-width: 0; }
  .board-sidebar { width: 280px; flex-shrink: 0; padding: 12px 16px;
                   background: var(--surface); color: var(--on-surface);
                   border: 1px solid var(--line-strong); border-radius: 4px;
                   font-size: 14px; line-height: 1.5; white-space: pre-wrap;
                   word-wrap: break-word; align-self: flex-start; }
  .board-sidebar h4 { margin: 0 0 8px 0; font-size: 14px; color: var(--muted); text-transform: uppercase; }
  .board-sidebar a { color: var(--side-link); }
  .mobile-sidebar { display: none; margin-bottom: 12px; font-size: 14px; }
  .mobile-sidebar summary { cursor: pointer; color: var(--muted); font-size: 13px; }
  .mobile-sidebar a { color: var(--side-link); }
  .paywall-status { font-size: 18px; font-weight: bold; color: var(--primary); }
  .paywall-info { background: var(--note); color: var(--on-note); padding: 12px; border-radius: 6px; margin: 12px 0; font-size: 15px; }
  .tab-bar { display: flex; gap: 0; margin: 16px 0 0 0; border-bottom: 2px solid var(--line-strong); }
  .tab-btn { padding: 8px 20px; border: 2px solid var(--line-strong); border-bottom: none; background: var(--tab); cursor: pointer; font-size: 14px; font-weight: bold; border-radius: 6px 6px 0 0; margin-bottom: -2px; color: var(--muted); }
  .tab-btn.active { background: var(--tab-on); border-bottom: 2px solid var(--tab-on); color: var(--text); }
  .pay-tab { padding: 16px 0; }
  .payment-form { margin-top: 0; }
  .payment-form label { font-weight: bold; font-size: 14px; }
  .payment-form select, .payment-form input[type="text"], .payment-form textarea {
    width: 100%; max-width: 500px; padding: 6px; font-size: 14px; }
  #token-summary { font-size: 13px; color: var(--muted); margin-top: 4px; }
  #qr-scan-btn { margin-top: 8px; cursor: pointer; }
  #qr-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%;
    background:rgba(0,0,0,0.9); z-index:9999; flex-direction:column;
    align-items:center; justify-content:center; }
  #qr-overlay.active { display:flex; }
  #qr-video { max-width:90%; max-height:60vh; border:3px solid #fff; border-radius:8px; }
  #qr-status { color:#fff; margin-top:12px; font-size:16px; }
  #qr-close-btn { margin-top:12px; padding:8px 24px; font-size:16px; cursor:pointer;
    background:#fff; border:1px solid #ccc; border-radius:4px; }
  .wallet-entry { background: var(--wallet); border: 1px solid var(--line-strong); padding: 12px; border-radius: 6px; margin: 8px 0; }
  .wallet-entry p { margin: 4px 0; }
  .wallet-entry textarea { width: 100%; max-width: 500px; padding: 6px; font-size: 14px; }
  .muted { color: var(--muted); }
  .faint { color: var(--faint); }
  .row-line { border-bottom: 1px solid var(--line); }
  .swatch { display: inline-block; width: 14px; height: 14px; border-radius: 3px;
            border: 1px solid var(--line-strong); vertical-align: middle; margin-right: 4px; }
  @media (max-width: 768px) {
    .ct { padding: 8px; }
    .board-layout { flex-direction: column; }
    .board-sidebar { display: none; }
    .mobile-sidebar { display: block; }
  }
  '''
::
::  inline JS for web push notification subscription management
::
++  push-js
  ^-  @t
  ::  the browser's subscription goes to grubbery's push service, which
  ::  answers a sub_id that unsubscribing needs; the page keeps it
  '''
  (function(){
    var btn=document.getElementById("push-toggle");
    if(!btn||!("PushManager" in window)||!("serviceWorker" in navigator))return;
    btn.style.display="inline";
    var sub=null;
    var swReady=navigator.serviceWorker.ready;
    var post=function(u,b){return fetch(u,{method:"POST",credentials:"include",headers:{"Content-Type":"application/json"},body:JSON.stringify(b)})};
    function updateBtn(on){
      btn.textContent=on?"notifications: on":"notifications: off";
      btn.title=on?"Click to disable notifications":"Click to enable notifications";
    }
    swReady.then(function(reg){
      return reg.pushManager.getSubscription();
    }).then(function(s){
      sub=s;
      updateBtn(!!sub);
    }).catch(function(){
      updateBtn(false);
    });
    btn.onclick=function(){
      btn.disabled=true;
      if(sub){
        var id=null;try{id=localStorage.getItem("furum-push-sub")}catch(e){}
        (id?post("/grubbery/push/unsubscribe",{sub_id:id}):Promise.resolve())
        .then(function(){return sub.unsubscribe()}).then(function(){
          try{localStorage.removeItem("furum-push-sub")}catch(e){}
          sub=null;updateBtn(false);btn.disabled=false;
        }).catch(function(){btn.disabled=false;});
      } else {
        swReady.then(function(reg){
          return fetch("/grubbery/push/vapid-key",{credentials:"include"})
          .then(function(r){if(!r.ok)throw new Error("push is not set up on this ship");return r.text()})
          .then(function(key){
            var raw=atob(key.replace(/-/g,"+").replace(/_/g,"/"));
            var arr=new Uint8Array(raw.length);
            for(var i=0;i<raw.length;i++)arr[i]=raw.charCodeAt(i);
            return reg.pushManager.subscribe({userVisibleOnly:true,applicationServerKey:arr});
          });
        }).then(function(s){
          sub=s;
          var k=sub.toJSON();
          return post("/grubbery/push/subscribe",{endpoint:k.endpoint,p256dh:k.keys.p256dh,auth:k.keys.auth});
        }).then(function(r){return r.json()}).then(function(d){
          try{if(d.sub_id)localStorage.setItem("furum-push-sub",d.sub_id)}catch(e){}
          updateBtn(true);btn.disabled=false;
        }).catch(function(e){
          btn.disabled=false;
          alert("Could not enable notifications: "+e.message);
        });
      }
    };
  })();
  '''
::
::  inline JS for S3 image upload (works on submit form and comment forms)
::
++  upload-js
  ^-  @t
  '''
  (function(){
    async function doUpload(fileInput,btn,statusEl,target){
      var file=fileInput.files[0];
      if(!file){statusEl.textContent='select a file first';statusEl.className='upload-err';return;}
      btn.disabled=true;statusEl.textContent='loading config...';statusEl.className='upload-status';
      try{
        var res=await fetch('/apps/furum/s3-config',{credentials:'include'});
        if(!res.ok)throw new Error('could not load storage config');
        var cfg=await res.json();
        if(!cfg.accessKeyId||!cfg.bucket)throw new Error('S3 not configured. Set up storage in System Preferences.');
        var ts=Date.now();
        var safe=file.name.replace(/[^a-zA-Z0-9._-]/g,'_');
        var key='furum/'+ts+'-'+safe;
        var ct=file.type||'application/octet-stream';
        var endpoint=cfg.endpoint||('https://s3.'+(cfg.region||'us-east-1')+'.amazonaws.com');
        if(endpoint&&!/^https?:\/\//.test(endpoint))endpoint='https://'+endpoint;
        statusEl.textContent='uploading...';
        var purl=await presign(endpoint,cfg.bucket,key,cfg.region||'us-east-1',cfg.accessKeyId,cfg.secretAccessKey,ct);
        var xhr=new XMLHttpRequest();
        xhr.open('PUT',purl);
        xhr.setRequestHeader('Content-Type',ct);
        xhr.setRequestHeader('Cache-Control','public, max-age=3600');
        xhr.setRequestHeader('x-amz-acl','public-read');
        xhr.upload.onprogress=function(e){if(e.lengthComputable)statusEl.textContent=Math.round(e.loaded/e.total*100)+'%';};
        xhr.onload=function(){
          if(xhr.status>=200&&xhr.status<300){
            var finalUrl=cfg.publicUrlBase?(cfg.publicUrlBase+'/'+key):(endpoint+'/'+cfg.bucket+'/'+key);
            if(target.tagName==='INPUT'){target.value=finalUrl;}
            else{var v=target.value;target.value=v+(v&&!v.endsWith('\n')?'\n':'')+finalUrl;}
            statusEl.textContent='uploaded!';statusEl.className='upload-status';
            btn.disabled=false;
          }else{statusEl.textContent='upload failed: '+xhr.status;statusEl.className='upload-err';btn.disabled=false;}
        };
        xhr.onerror=function(){statusEl.textContent='network error';statusEl.className='upload-err';btn.disabled=false;};
        xhr.send(file);
      }catch(e){statusEl.textContent=e.message;statusEl.className='upload-err';btn.disabled=false;}
    }
    document.querySelectorAll('.upload-section').forEach(function(sec){
      var btn=sec.querySelector('.upload-btn');
      var fi=sec.querySelector('input[type=file]');
      var st=sec.querySelector('.upload-status');
      var mode=sec.dataset.mode;
      if(!btn||!fi)return;
      btn.addEventListener('click',function(){
        var form=sec.closest('form');
        var target=mode==='url'?form.querySelector('input[name=url]'):form.querySelector('textarea[name=body]');
        if(target)doUpload(fi,btn,st,target);
      });
    });
    async function presign(endpoint,bucket,key,region,akid,secret,ct){
      var u=new URL(endpoint+'/'+bucket+'/'+key);
      var now=new Date();
      var ds=now.toISOString().replace(/[-:]/g,'').replace(/\.\d+/,'');
      var dd=ds.slice(0,8);
      var scope=dd+'/'+region+'/s3/aws4_request';
      var sh='cache-control;content-type;host;x-amz-acl';
      u.searchParams.set('X-Amz-Algorithm','AWS4-HMAC-SHA256');
      u.searchParams.set('X-Amz-Credential',akid+'/'+scope);
      u.searchParams.set('X-Amz-Date',ds);
      u.searchParams.set('X-Amz-Expires','3600');
      u.searchParams.set('X-Amz-SignedHeaders',sh);
      var sp=[...u.searchParams.entries()].sort(function(a,b){return a[0]<b[0]?-1:a[0]>b[0]?1:0;});
      var cqs=sp.map(function(p){return ue(p[0])+'='+ue(p[1]);}).join('&');
      var ch='cache-control:public, max-age=3600\ncontent-type:'+ct+'\nhost:'+u.host+'\nx-amz-acl:public-read\n';
      var cr=['PUT',u.pathname,cqs,ch,sh,'UNSIGNED-PAYLOAD'].join('\n');
      var sts=['AWS4-HMAC-SHA256',ds,scope,await sha(cr)].join('\n');
      var sk=await sigkey(secret,dd,region,'s3');
      var sig=await hmh(sk,sts);
      u.searchParams.set('X-Amz-Signature',sig);
      return u.toString();
    }
    function ue(s){return encodeURIComponent(s).replace(/[!'()*]/g,function(c){return '%'+c.charCodeAt(0).toString(16).toUpperCase();});}
    async function hm(k,d){var ck=await crypto.subtle.importKey('raw',k instanceof ArrayBuffer?k:new TextEncoder().encode(k),{name:'HMAC',hash:'SHA-256'},false,['sign']);return crypto.subtle.sign('HMAC',ck,new TextEncoder().encode(d));}
    async function hmh(k,d){var s=await hm(k,d);return Array.from(new Uint8Array(s)).map(function(b){return b.toString(16).padStart(2,'0');}).join('');}
    async function sha(d){var h=await crypto.subtle.digest('SHA-256',new TextEncoder().encode(d));return Array.from(new Uint8Array(h)).map(function(b){return b.toString(16).padStart(2,'0');}).join('');}
    async function sigkey(k,ds,r,s){var a=await hm('AWS4'+k,ds);a=await hm(a,r);a=await hm(a,s);return hm(a,'aws4_request');}
  })();
  '''
::
::  URL parsing: split URL into path segments and query params
::
++  parse-request-url
  |=  url=@t
  ^-  [pax=(list @t) args=(map @t @t)]
  =/  ut=tape  (trip url)
  ::  split on ?
  =/  qidx  (find "?" ut)
  =/  path-tape=tape  ?~(qidx ut (scag u.qidx ut))
  =/  query-tape=tape  ?~(qidx ~ (slag +(u.qidx) ut))
  ::  split path on / and drop empties
  =/  segs=(list tape)  (split-on path-tape '/')
  =/  pax=(list @t)
    (skip (turn segs crip) |=(a=@t =(a '')))
  ::  parse query string
  =/  args=(map @t @t)  (parse-query query-tape)
  [pax args]
::
::  split a tape on a character
::
++  split-on
  |=  [t=tape c=@tD]
  ^-  (list tape)
  ?:  =(~ t)  ["" ~]
  =/  idx  (find [c ~] t)
  ?~  idx  [t ~]
  [(scag u.idx t) $(t (slag +(u.idx) t))]
::
::  parse query string "key=val&key2=val2" into map
::
++  parse-query
  |=  qs=tape
  ^-  (map @t @t)
  ?~  qs  *(map @t @t)
  =/  pairs=(list tape)  (split-on qs '&')
  %+  roll  pairs
  |=  [pair=tape acc=(map @t @t)]
  =/  kv=(list tape)  (split-on pair '=')
  ?~  kv  acc
  ?~  t.kv  (~(put by acc) (crip (urld i.kv)) '')
  (~(put by acc) (crip (urld i.kv)) (crip (urld i.t.kv)))
::
::  parse form-urlencoded POST body
::
++  parse-form
  |=  bod=(unit octs)
  ^-  (map @t @t)
  ?~  bod  *(map @t @t)
  (parse-query (trip (cut 3 [0 p.u.bod] q.u.bod)))
::
::  URL decode a tape
::
++  urld
  |=  t=tape
  ^-  tape
  ?~  t  ~
  ?:  =('+' i.t)
    [' ' $(t t.t)]
  ?.  =('%' i.t)
    [i.t $(t t.t)]
  ?~  t.t  ~
  ?~  t.t.t  ~
  =/  hi  (hex-char i.t.t)
  =/  lo  (hex-char i.t.t.t)
  ?~  hi  [i.t $(t t.t)]
  ?~  lo  [i.t $(t t.t)]
  [`@tD`(add (mul u.hi 16) u.lo) $(t t.t.t.t)]
::
++  urle
  |=  t=tape
  ^-  tape
  ?~  t  ~
  =/  c=@tD  i.t
  ?:  ?|  &((gte c 'a') (lte c 'z'))
          &((gte c 'A') (lte c 'Z'))
          &((gte c '0') (lte c '9'))
          =(c '-')  =(c '_')  =(c '.')  =(c '~')
      ==
    [c $(t t.t)]
  =/  hi=@tD  (to-hex-char (div c 16))
  =/  lo=@tD  (to-hex-char (mod c 16))
  ['%' hi lo $(t t.t)]
::
++  to-hex-char
  |=  n=@
  ^-  @tD
  ?:((lth n 10) (add '0' n) (add 'A' (sub n 10)))
::
++  hex-char
  |=  c=@tD
  ^-  (unit @)
  ?:  &((gte c '0') (lte c '9'))  `(sub c '0')
  ?:  &((gte c 'a') (lte c 'f'))  `(add 10 (sub c 'a'))
  ?:  &((gte c 'A') (lte c 'F'))  `(add 10 (sub c 'A'))
  ~
::
::  format number with commas: 10000 -> "10,000"
::
++  commafy
  |=  n=@ud
  ^-  tape
  =/  raw=tape  (skip (a-co:co n) |=(c=@ =(c '.')))
  =/  len=@ud  (lent raw)
  ?:  (lte len 3)  raw
  =/  idx=@ud  0
  =/  out=tape  ~
  |-
  ?:  =(idx len)  out
  =/  pos=@ud  (sub len (add idx 1))
  =/  ch=@  (snag idx raw)
  =/  need-comma=?  &((gth pos 0) =(0 (mod pos 3)))
  ?:  need-comma
    $(idx +(idx), out (weld out [ch ',' ~]))
  $(idx +(idx), out (snoc out ch))
::
::  time ago display
::
++  time-ago
  |=  [now=@da then=@da]
  ^-  tape
  ?:  (lte now then)  "just now"
  =/  diff=@dr  (sub now then)
  =/  parts=tarp  (yell diff)
  ?:  (gth d.parts 0)
    "{(a-co:co d.parts)}d ago"
  ?:  (gth h.parts 0)
    "{(a-co:co h.parts)}h ago"
  ?:  (gth m.parts 0)
    "{(a-co:co m.parts)}m ago"
  "{(a-co:co s.parts)}s ago"
::
::  sort posts by creation time (newest first)
::
++  sort-posts-by-new
  |=  posts=(list post)
  ^-  (list post)
  %+  sort  posts
  |=  [a=post b=post]
  (gth created.a created.b)
::
::  sort posts by net votes descending, tiebreak newest
::
++  sort-posts-by-top
  |=  posts=(list post)
  ^-  (list post)
  %+  sort  posts
  |=  [a=post b=post]
  =/  va=@ud
    =/  up  ~(wyt in up-votes.a)
    =/  dn  ~(wyt in down-votes.a)
    ?:((gte up dn) (sub up dn) 0)
  =/  vb=@ud
    =/  up  ~(wyt in up-votes.b)
    =/  dn  ~(wyt in down-votes.b)
    ?:((gte up dn) (sub up dn) 0)
  ?:  =(va vb)
    (gth created.a created.b)
  (gth va vb)
::
::  sort posts by HN-style hot score descending: net votes over
::  (hours + 2)^2, each post scored once and compared by cross-
::  multiplying, exactly; newer first at an equal score. Scoring in @rs
::  on every comparison took 46 s to sort a 700-post board, and without
::  the tie-break +sort (a quicksort) went quadratic on a board of
::  unvoted posts, which all score 0: 4 s at 2,450 posts.
::
++  sort-posts-by-hot
  |=  [now=@da posts=(list post)]
  ^-  (list post)
  =/  keyed=(list [n=@ud d=@ud p=post])
    %+  turn  posts
    |=  p=post
    =/  up=@ud  ~(wyt in up-votes.p)
    =/  dn=@ud  ~(wyt in down-votes.p)
    =/  h=@ud  (add 2 (div ?:((gth now created.p) (sub now created.p) 0) ~h1))
    [?:((gte up dn) (sub up dn) 0) (mul h h) p]
  %+  turn
    %+  sort  keyed
    |=  [a=[n=@ud d=@ud p=post] b=[n=@ud d=@ud p=post]]
    =/  l=@ud  (mul n.a d.b)
    =/  r=@ud  (mul n.b d.a)
    ?.  =(l r)  (gth l r)
    (gth created.p.a created.p.b)
  |=([* * p=post] p)
::
::  dispatch to sort function by mode
::
++  sort-posts-dispatch
  |=  [mode=?(%hot %new %top) now=@da posts=(list post)]
  ^-  (list post)
  ?-  mode
    %hot  (sort-posts-by-hot now posts)
    %new  (sort-posts-by-new posts)
    %top  (sort-posts-by-top posts)
  ==
::
::  parse sort param from query string
::
++  parse-sort
  |=  args=(map @t @t)
  ^-  ?(%hot %new %top)
  =/  raw=@t  (~(gut by args) 'sort' 'hot')
  ?+  raw  %hot
    %'hot'  %hot
    %'new'  %new
    %'top'  %top
  ==
::
::  a url is safe to link if it is http(s) or a same-origin furum path;
::  guards against javascript: and other script-bearing hrefs
::
++  safe-url
  |=  url=@t
  ^-  ?
  =/  lu=tape  (cass (trip url))
  ?|  =((scag 7 lu) "http://")
      =((scag 8 lu) "https://")
      =((scag 12 lu) "/apps/furum/")
  ==
::
++  safe-href
  |=  url=@t
  ^-  tape
  ?:((safe-url url) (trip url) "#")
::
::  +valid-board-name: [a-z0-9-]+, the url-safe names the create form allows
::
++  valid-board-name
  |=  name=@t
  ^-  ?
  =/  n=tape  (trip name)
  ?&  !=(~ n)
      (lte (lent n) 64)
      %+  levy  n
      |=  c=@tD
      ?|  &((gte c 'a') (lte c 'z'))
          &((gte c '0') (lte c '9'))
          =(c '-')
      ==
  ==
::
++  is-image-url
  |=  url=@t
  ^-  ?
  =/  u=tape  (cass (trip url))
  ::  only allow http/https URLs (scheme must be a prefix, not anywhere)
  ?.  |(=((scag 7 u) "http://") =((scag 8 u) "https://"))
    %.n
  =/  exts=(list tape)
    ~[".jpg" ".jpeg" ".png" ".gif" ".webp" ".svg" ".bmp"]
  |-
  ?~  exts  %.n
  ?^  (find i.exts u)  %.y
  $(exts t.exts)
::
::  render image preview toggle for image URLs
::
++  image-preview
  |=  url=tape
  ^-  manx
  ;details.img-preview
    ;summary: show image
    ;img(src url, alt "image", loading "lazy");
  ==
::
::  extract image URLs from text body
::
++  extract-image-urls
  |=  text=@t
  ^-  (list tape)
  =/  txt=tape  (trip text)
  =/  acc=(list tape)  ~
  |-
  =/  https-idx  (find "https://" txt)
  =/  http-idx   (find "http://" txt)
  =/  url-idx=(unit @)
    ?~  https-idx  http-idx
    ?~  http-idx   https-idx
    `(min u.https-idx u.http-idx)
  ?~  url-idx  (flop acc)
  =/  from=tape  (slag u.url-idx txt)
  =/  [url=tape rest=tape]  (extract-url from)
  ?:  (is-image-url (crip url))
    $(txt rest, acc [url acc])
  $(txt rest)
::
::  linkify: convert URLs in text to clickable links
::  splits a tape into marl of text nodes and anchor elements
::
++  extract-url
  |=  text=tape
  ^-  [url=tape rest=tape]
  =/  url=tape  ~
  |-
  ?~  text  [(flop url) ~]
  ?:  ?|  =(i.text ' ')
          =(i.text '\0a')
          =(i.text '\09')
          =(i.text '<')
          =(i.text '>')
      ==
    [(flop url) text]
  $(text t.text, url [i.text url])
::
++  linkify
  |=  text=tape
  ^-  marl
  =/  txt=tape  text
  ::  find first URL
  =/  https-idx  (find "https://" txt)
  =/  http-idx   (find "http://" txt)
  =/  url-idx=(unit @)
    ?~  https-idx  http-idx
    ?~  http-idx   https-idx
    `(min u.https-idx u.http-idx)
  ?~  url-idx
    ::  no URLs, return as text node
    ?~  txt  ~
    ~[;/(txt)]
  ::  split: text before URL, then URL, then rest
  =/  before=tape  (scag u.url-idx txt)
  =/  from=tape  (slag u.url-idx txt)
  =/  [url=tape rest=tape]  (extract-url from)
  =/  link=manx  ;a(href url, target "_blank", rel "noopener noreferrer"): {url}
  =/  prefix=marl  ?~(before ~ ~[;/(before)])
  (weld prefix [link (linkify rest)])
::
::  render text with linkified URLs as a div
::
++  linkify-div
  |=  [cls=tape text=tape]
  ^-  manx
  =/  kids=marl  (linkify text)
  [[%div ~[[%class cls]]] kids]
::
::  pagination constants and helpers
::
++  per-page  30
::
++  parse-page
  |=  args=(map @t @t)
  ^-  @ud
  =/  raw=@t  (~(gut by args) 'page' '1')
  =/  n=(unit @ud)  ((slat %ud) raw)
  ?~(n 1 ?:((lth u.n 1) 1 u.n))
::
++  paginate
  |*  [page=@ud lst=(list)]
  =/  total=@ud  (lent lst)
  =/  skip=@ud  (mul (dec page) per-page)
  =/  sliced  (scag per-page (slag skip lst))
  [total sliced]
::
++  render-pagination
  |=  [base-url=tape page=@ud total=@ud]
  ^-  manx
  ?:  =(total 0)  ;span;
  =/  total-pages=@ud
    (add (div total per-page) ?:((gth (mod total per-page) 0) 1 0))
  ?:  (lte total-pages 1)  ;span;
  =/  has-prev=?  (gth page 1)
  =/  has-next=?  (lth page total-pages)
  =/  prev-node=manx
    ?.  has-prev  ;span;
    ;a(href "{base-url}page={(a-co:co (dec page))}"): ← prev
  =/  next-node=manx
    ?.  has-next  ;span;
    ;a(href "{base-url}page={(a-co:co (add page 1))}"): next →
  =/  info-node=manx
    ;span.me: page {(a-co:co page)} of {(a-co:co total-pages)}
  ;div.sort
    ;+  prev-node
    ;+  ?:  ?&(has-prev has-next)
          ;span: {" | "}
        ;span;
    ;+  next-node
    ;+  ;/("  ")
    ;+  info-node
  ==
::
::  flatten comments into depth-ordered list for rendering
::  returns (list [depth=@ud =comment])
::
++  flatten-comments
  |=  comments=(map comment-id comment)
  ^-  (list [@ud comment])
  =/  clist=(list comment)  ~(val by comments)
  ::  group by parent
  =/  by-parent=(map (unit comment-id) (list comment))
    %+  roll  clist
    |=  [c=comment acc=(map (unit comment-id) (list comment))]
    =/  existing  (~(gut by acc) parent.c ~)
    (~(put by acc) parent.c [c existing])
  ::  walk tree depth-first
  (walk-children 0 ~ by-parent)
::
++  walk-children
  |=  [depth=@ud parent=(unit comment-id) by-parent=(map (unit comment-id) (list comment))]
  ^-  (list [@ud comment])
  =/  kids=(list comment)  (~(gut by by-parent) parent ~)
  =/  sorted=(list comment)
    %+  sort  kids
    |=  [a=comment b=comment]
    (lth created.a created.b)
  %-  zing
  %+  turn  sorted
  |=  c=comment
  [[depth c] (walk-children +(depth) `id.c by-parent)]
::
::  convert manx to octs for HTTP response
::
++  manx-to-octs
  |=  =manx
  ^-  octs
  =/  html=@t  (crip (en-xml:html manx))
  [(met 3 html) html]
::
::  +theme-head: what every page's head needs to draw in its theme: the
::  browser bar's colour (the header's, per light or dark), the theme's
::  colours, and the stylesheet that draws with them
::
++  theme-head
  |=  =look:th
  ^-  marl
  %+  weld
    %+  turn  bars.look
    |=  [media=@t hex=@t]
    ^-  manx
    ?:  =('' media)  ;meta(name "theme-color", content (trip hex));
    ;meta(name "theme-color", content (trip hex), media (trip media));
  ^-  marl
  :~  [[%style ~] [[[%$ [%$ (trip style.look)]~] ~] ~]]
      [[%style ~] [[[%$ [%$ (trip furum-css)]~] ~] ~]]
  ==
::
::  page shell: wrap content in full HTML page
::
++  page-shell
  |=  [title=@t content=marl board-ctx=(unit [href=tape label=tape]) public=? =look:th]
  ^-  manx
  =/  sw-script=tape  (trip 'if("serviceWorker" in navigator)navigator.serviceWorker.register("/apps/furum/sw",{scope:"/apps/furum"});')
  =/  sw-node=manx
    [[%script ~] [[[%$ [%$ sw-script] ~] ~] ~]]
  =/  notif-count-js=tape
    (trip 'fetch("/apps/furum/notif-count",{credentials:"include"}).then(function(r){return r.json()}).then(function(d){var el=document.getElementById("notif-link");if(el&&d.count>0)el.textContent=d.count+" new"}).catch(function(){})')
  =/  notif-count-node=manx
    ?.  public  [[%script ~] [[[%$ [%$ notif-count-js] ~] ~] ~]]
    ;span;
  =/  nav-link=manx
    ?~  board-ctx
      ;a/"/apps/furum/create": new board
    ;a(href href.u.board-ctx): {label.u.board-ctx}
  =/  right-section=manx
    ?:  public
      ;span.dark-toggle
        ;a(href "/apps/furum/about", style "text-decoration: none; margin-right: 16px"): I Have Urbit
        ;a(href "https://urbit.org/overview/running-urbit", style "text-decoration: none", target "_blank", rel "noopener noreferrer"): Get on Urbit
      ==
    ;span.dark-toggle
      ;a#notif-link(href "/apps/furum/notifications", style "margin-right: 12px"): notifications
      ;a(href "/apps/furum/admin", style "margin-right: 12px"): admin
      ;a(href "/apps/furum/guide", style "margin-right: 12px"): guide
      ;a(href "/apps/furum/theme"): theme
    ==
  =/  hd-node=manx
    ;div#hd
      ;+  right-section
      ;+  ?:  public
            ;span(style "color: var(--hd-text); font-weight: bold; font-size: 18px"): furum
          ;a/"/apps/furum": furum
      ;+  ?.  public
            ;span.nav
              ;+  ;/("  |  ")
              ;+  nav-link
            ==
          ;span;
    ==
  =/  ct-node=manx
    ;div.ct
      ;*  content
    ==
  =/  ft-node=manx
    ;div.faint(style "text-align: center; padding: 16px; font-size: 12px")
      ;+  ;/("furum v{(trip version)}")
    ==
  =/  body-children=marl  ~[hd-node ct-node ft-node notif-count-node]
  =/  body-node=manx  [[%body ~] body-children]
  ;html
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;meta(name "apple-mobile-web-app-capable", content "yes");
      ;meta(name "apple-mobile-web-app-status-bar-style", content "black-translucent");
      ;link(rel "manifest", href "/apps/furum/manifest");
      ;link(rel "apple-touch-icon", href "/apps/furum/icon");
      ;link(rel "icon", type "image/svg+xml", href "/apps/furum/favicon");
      ;title: {(trip title)}
      ;*  (theme-head look)
      ;+  sw-node
    ==
    ;+  body-node
  ==
::
::  HOME PAGE: board directory
::
++  render-feed
  |=  [feed=(list [host=@p board-name=board-name =post]) our=@p now=@da =look:th page=@ud board-seen=(map [@p board-name] @da)]
  ^-  manx
  =/  sorted=(list [host=@p board-name=board-name =post])
    %+  sort  feed
    |=  [a=[host=@p board-name=board-name =post] b=[host=@p board-name=board-name =post]]
    (gth created.post.a created.post.b)
  =/  [total=@ud paged=(list [host=@p board-name=board-name =post])]
    (paginate page sorted)
  =/  nav=manx
    ;div
      ;h3: Feed
      ;p
        ;strong: feed
        ;+  ;/(" | ")
        ;a(href "/apps/furum?view=directory"): directory
      ==
      ;p.me: Posts from boards you follow.
    ==
  =/  post-rows=marl
    =/  rem  paged
    =/  idx=@ud  +((mul (dec page) per-page))
    =/  acc=marl  ~
    |-
    ?~  rem
      ?~  acc
        :~  ;p.me: No posts yet. Follow some boards to see their posts here.
        ==
      (flop acc)
    =/  rank=@ud  idx
    =/  item  i.rem
    =/  row=manx
    ^-  manx
    =/  board-path=tape
      "/apps/furum/b/{(scow %p host.item)}/{(trip board-name.item)}"
    =/  post-href=tape  "{board-path}/{(a-co:co id.post.item)}"
    =/  title-href=tape
      ?^  url.post.item  (safe-href u.url.post.item)
      post-href
    =/  title-link=manx
      ?^  url.post.item
        ;a(href title-href, target "_blank", rel "noopener noreferrer"): {(trip title.post.item)}
      ;a(href title-href): {(trip title.post.item)}
    =/  points=@ud
      =/  up  ~(wyt in up-votes.post.item)
      =/  dn  ~(wyt in down-votes.post.item)
      ?:((gte up dn) (sub up dn) 0)
    =/  url-host=manx
      ?~  url.post.item  ;span;
      ;span.host: ({(trip u.url.post.item)})
    =/  img-prev=manx
      ?.  ?&(?=(^ url.post.item) (is-image-url u.url.post.item))
        ;span;
      (image-preview (trip u.url.post.item))
    =/  bls  (~(get by board-seen) [host.item board-name.item])
    =/  is-new=?
      ?~  bls  %.n
      (gth created.post.item u.bls)
    =/  new-tag=manx
      ?.  is-new  ;span;
      ;span.new-tag: new
    ;div.rw
      ;span.rk: {(a-co:co rank)}.
      ;div
        ;span.ti
          ;+  title-link
          ;+  new-tag
        ==
        ;+  url-host
        ;+  img-prev
        ;div.me
          ;+  ;/("{(commafy points)} pts by {(scow %p author.post.item)} {(time-ago now created.post.item)} to ")
          ;a(href board-path): {(trip board-name.item)}
          ;+  ;/(" | ")
          ;a(href post-href): {(commafy comment-count.post.item)} comments
        ==
      ==
    ==
    $(rem t.rem, idx +(idx), acc [row acc])
  =/  pag-nav=manx  (render-pagination "/apps/furum?" page total)
  %-  page-shell
  :*  'furum'  [nav (weld post-rows ~[pag-nav])]  ~  %.n  look  ==
::
++  render-home
  |=  [entries=(list directory-entry) view=?(%all %curated %tag) active-tag=(unit @tas) all-tags=(set @tas) is-registry=? =look:th boards-with-new=(set [@p board-name]) note=tape]
  ^-  manx
  =/  tag-list=(list @tas)
    %+  sort  ~(tap in all-tags)
    |=  [a=@tas b=@tas]
    (aor a b)
  =/  tag-links=marl
    %+  turn  tag-list
    |=  tag=@tas
    ^-  manx
    ;span
      ;+  ;/(" ")
      ;a(href "/apps/furum/tag/{(trip tag)}"): #{(trip tag)}
    ==
  =/  view-label=tape
    ?-  view
      %all      "All Boards"
      %curated  "Curated Boards"
      %tag      ?~(active-tag "Tagged" "#{(trip u.active-tag)}")
    ==
  =/  nav=manx
    ;div
      ;h3: Board Directory
      ;p
        ;a(href "/apps/furum"): feed
        ;+  ;/(" | ")
        ;a(href "/apps/furum?view=directory"): all
        ;+  ;/(" | ")
        ;a(href "/apps/furum/curated"): curated
        ;*  tag-links
        ;+  ?:  is-registry
              ;span
                ;+  ;/(" | ")
                ;a(href "/apps/furum/registry"): admin
              ==
            ;span;
      ==
      ;p.me: Showing: {view-label}
      ::  why this ship's copy of the directory is out of date, if it is
      ;+  ?~  note  ;span;
          ;p.me(style "color: var(--error)"): {note}
    ==
  =/  board-rows=marl
    ?~  entries
      :~  ;p.me: No boards in this view.
      ==
    %+  turn  entries
    |=  entry=directory-entry
    ^-  manx
    =/  href=tape
      "/apps/furum/b/{(scow %p host.entry)}/{(trip name.entry)}"
    =/  tag-text=tape
      %+  roll  ~(tap in tags.entry)
      |=  [tag=@tas acc=tape]
      ?:(=(acc "") "#{(trip tag)}" "{acc} #{(trip tag)}")
    =/  tag-node=manx
      ?.  =(tag-text "")
        ;span.me: {" "}{tag-text}
      ;span;
    =/  curated-node=manx
      ?:  curated.entry
        ;span.me: {" "}[curated]
      ;span;
    =/  new-dot=manx
      ?.  (~(has in boards-with-new) [host.entry name.entry])
        ;span;
      ;span.new-dot;
    ;div.rw
      ;div
        ;span.ti
          ;+  new-dot
          ;a(href href): {(trip title.entry)}
        ==
        ;span.host: {" "}({(scow %p host.entry)})
        ;+  tag-node
        ;+  curated-node
        ;div.me: {(trip description.entry)}
      ==
    ==
  %-  page-shell
  :*  'furum'  [nav board-rows]  ~  %.n  look  ==
::
::  BOARD PAGE: list of posts
::
++  render-board
  |=  $:  host=@p  =board-info  posts=(list post)  our=@p  now=@da
          is-mod=?  authed=?  =look:th  sort=?(%hot %new %top)
          is-followed=?  page=@ud  pin-set=(set post-id)
          board-last-seen=(unit @da)  sidebar=@t
      ==
  ^-  manx
  =/  pinned-posts=(list post)
    (sort-posts-by-new (skim posts |=(p=post (~(has in pin-set) id.p))))
  =/  unpinned=(list post)
    (skim posts |=(p=post !(~(has in pin-set) id.p)))
  =/  sorted  (sort-posts-dispatch sort now unpinned)
  =/  [total=@ud paged=(list post)]  (paginate page sorted)
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name.board-info)}"
  =/  mod-link=manx
    ?.  ?|(=(host our) is-mod)  ;span;
    ;span
      ;+  ;/("  |  ")
      ;a(href "{board-path}/mod"): moderate
    ==
  =/  follow-btn=manx
    ?.  authed  ;span;
    ?:  is-followed
      ;form(method "post", action "{board-path}/unfollow", style "display:inline")
        ;+  ;/("  |  ")
        ;button.va(type "submit"): unfollow
      ==
    ;form(method "post", action "{board-path}/follow", style "display:inline")
      ;+  ;/("  |  ")
      ;button.va(type "submit"): follow
    ==
  =/  nav-section=manx
    ?.  authed  ;p;
    ;p
      ;a(href "{board-path}/submit"): submit post
      ;+  mod-link
      ;+  follow-btn
    ==
  =/  sort-hot=manx
    ?:  =(sort %hot)
      ;strong: hot
    ;a(href "{board-path}?sort=hot"): hot
  =/  sort-new=manx
    ?:  =(sort %new)
      ;strong: new
    ;a(href "{board-path}?sort=new"): new
  =/  sort-top=manx
    ?:  =(sort %top)
      ;strong: top
    ;a(href "{board-path}?sort=top"): top
  =/  sort-bar=manx
    ;div.sort
      ;span: sort:
      ;+  sort-hot
      ;+  ;/(" | ")
      ;+  sort-new
      ;+  ;/(" | ")
      ;+  sort-top
    ==
  =/  header=manx
    ;div
      ;h3: {(trip title.board-info)}
      ;p.me: {(trip description.board-info)}
      ;+  nav-section
      ;+  sort-bar
    ==
  =/  pinned-rows=marl
    ?.  ?&(!=(~ pinned-posts) =(page 1))  ~
    %+  turn  pinned-posts
    |=  =post
    ^-  manx
    =/  post-href=tape  "{board-path}/{(a-co:co id.post)}"
    =/  title-href=tape
      ?^  url.post  (safe-href u.url.post)
      post-href
    =/  title-link=manx
      ?^  url.post
        ;a(href title-href, target "_blank", rel "noopener noreferrer"): {(trip title.post)}
      ;a(href title-href): {(trip title.post)}
    =/  unpin-btn=manx
      ?.  ?&(authed is-mod)  ;span;
      ;form(method "post", action "{post-href}/pin", style "display:inline")
        ;input(type "hidden", name "pinned", value "false");
        ;+  ;/(" | ")
        ;button.va(type "submit"): unpin
      ==
    ;div(class "rw pinned")
      ;span.pin-tag: pinned
      ;div
        ;span.ti
          ;+  title-link
        ==
        ;div.me
          ;a(href post-href): {(commafy comment-count.post)} comments
          ;+  unpin-btn
        ==
      ==
    ==
  =/  post-rows=marl
    ?~  paged
      ?.  ?=(~ pinned-posts)  ~
      :~  ;p.me: No posts yet.
      ==
    =/  offset=@ud  (mul (dec page) per-page)
    =/  ranked  (rank-list-offset paged offset)
    %+  turn  ranked
    |=  [rank=@ud =post]
    ^-  manx
    =/  points=@ud
      =/  up  ~(wyt in up-votes.post)
      =/  dn  ~(wyt in down-votes.post)
      ?:((gte up dn) (sub up dn) 0)
    =/  post-href=tape  "{board-path}/{(a-co:co id.post)}"
    =/  title-href=tape
      ?^  url.post  (safe-href u.url.post)
      post-href
    =/  title-link=manx
      ?^  url.post
        ;a(href title-href, target "_blank", rel "noopener noreferrer"): {(trip title.post)}
      ;a(href title-href): {(trip title.post)}
    =/  vote-btn=manx
      ?.  authed  ;span;
      ;form(method "post", action "{board-path}/vote", style "display:inline")
        ;input(type "hidden", name "target", value "post-{(a-co:co id.post)}");
        ;input(type "hidden", name "dir", value "up");
        ;button.va(type "submit"): ▲
      ==
    =/  url-host=manx
      ?~  url.post  ;span;
      ;span.host: ({(trip u.url.post)})
    =/  img-prev=manx
      ?.  ?&(?=(^ url.post) (is-image-url u.url.post))
        ;span;
      (image-preview (trip u.url.post))
    =/  del-btn=manx
      ?.  ?&(authed ?|(=(our author.post) is-mod))  ;span;
      ;form(method "post", action "{post-href}/delete", style "display:inline")
        ;+  ;/(" | ")
        ;button.va(type "submit"): delete
      ==
    =/  pin-btn=manx
      ?.  ?&(authed is-mod)  ;span;
      ;form(method "post", action "{post-href}/pin", style "display:inline")
        ;input(type "hidden", name "pinned", value "true");
        ;+  ;/(" | ")
        ;button.va(type "submit"): pin
      ==
    =/  new-tag=manx
      ?~  board-last-seen  ;span;
      ?.  (gth created.post u.board-last-seen)  ;span;
      ;span.new-tag: new
    ;div.rw
      ;span.rk: {(a-co:co rank)}.
      ;+  vote-btn
      ;div
        ;span.ti
          ;+  title-link
          ;+  new-tag
        ==
        ;+  url-host
        ;+  img-prev
        ;div.me
          ;+  ;/("{(commafy points)} points by {(scow %p author.post)} {(time-ago now created.post)} | ")
          ;a(href post-href): {(commafy comment-count.post)} comments
          ;+  del-btn
          ;+  pin-btn
        ==
      ==
    ==
  =/  pag-base=tape  "{board-path}?sort={(trip sort)}&"
  =/  pag-nav=manx  (render-pagination pag-base page total)
  =/  has-sidebar=?  !=('' sidebar)
  =/  sidebar-node=manx
    ?.  has-sidebar  ;span;
    ;aside.board-sidebar
      ;h4: Community Info
      ;*  (linkify (trip sidebar))
    ==
  =/  mobile-sidebar=manx
    ?.  has-sidebar  ;span;
    ;details.mobile-sidebar
      ;summary: community info
      ;*  (linkify (trip sidebar))
    ==
  =/  posts-section=manx
    ;div.board-main
      ;*  (weld pinned-rows (weld post-rows ~[pag-nav]))
    ==
  =/  board-body=manx
    ;div.board-layout
      ;+  posts-section
      ;+  sidebar-node
    ==
  %-  page-shell
  [(crip "furum - {(trip title.board-info)}") [header mobile-sidebar board-body ~] `[board-path (trip title.board-info)] !authed look]
::
::  POST DETAIL PAGE: post with comments
::
++  render-post-page
  |=  [host=@p =board-info =post comments=(map comment-id comment) our=@p now=@da is-mod=? authed=? =look:th pinned=(set post-id) post-last-seen=(unit @da)]
  ^-  manx
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name.board-info)}"
  =/  post-path=tape
    "{board-path}/{(a-co:co id.post)}"
  =/  points=@ud
    =/  up  ~(wyt in up-votes.post)
    =/  dn  ~(wyt in down-votes.post)
    ?:((gte up dn) (sub up dn) 0)
  =/  flat-comments  (flatten-comments comments)
  =/  comment-form=manx
    ?.  authed
      ;span;
    ;form(method "post", action "{post-path}/comment")
      ;textarea(name "body", placeholder "add a comment...");
      ;div.upload-section(data-mode "body")
        ;label: attach image:
        ;input(type "file", accept "image/*");
        ;button.upload-btn(type "button"): upload
        ;span.upload-status;
      ==
      ;input.btn(type "submit", value "add comment");
    ==
  =/  vote-btn=manx
    ?.  authed  ;span;
    ;form(method "post", action "{board-path}/vote", style "display:inline")
      ;input(type "hidden", name "target", value "post-{(a-co:co id.post)}");
      ;input(type "hidden", name "dir", value "up");
      ;button.va(type "submit"): ▲
    ==
  =/  url-link=manx
    ?~  url.post  ;span;
    ;a(href (safe-href u.url.post), target "_blank", rel "noopener noreferrer"): {(trip u.url.post)}
  =/  img-prev=manx
    ?.  ?&(?=(^ url.post) (is-image-url u.url.post))
      ;span;
    (image-preview (trip u.url.post))
  =/  edit-link=manx
    ?.  ?&(authed =(our author.post))  ;span;
    ;span
      ;+  ;/(" | ")
      ;a.me(href "{post-path}/edit"): edit
    ==
  =/  del-btn=manx
    ?.  ?&(authed ?|(=(our author.post) is-mod))  ;span;
    ;form(method "post", action "{post-path}/delete", style "display:inline")
      ;+  ;/(" | ")
      ;button.va(type "submit"): delete post
    ==
  =/  pin-btn=manx
    ?.  ?&(authed is-mod)  ;span;
    =/  is-pinned=?  (~(has in pinned) id.post)
    ;form(method "post", action "{post-path}/pin", style "display:inline")
      ;input(type "hidden", name "pinned", value ?:(is-pinned "false" "true"));
      ;+  ;/(" | ")
      ;button.va(type "submit"): {?:(is-pinned "unpin" "pin")}
    ==
  =/  pin-tag=manx
    ?.  (~(has in pinned) id.post)  ;span;
    ;span.pin-tag: pinned
  =/  body-section=manx
    ?~  body.post  ;span;
    (linkify-div "post-body" (trip u.body.post))
  =/  comment-list=marl
    (render-flat-comments flat-comments board-path id.post our is-mod authed now post-last-seen)
  =/  comment-div=manx
    ;div
      ;*  comment-list
    ==
  =/  post-detail=manx
    ;div
      ;+  pin-tag
      ;+  vote-btn
      ;span.ti: {" "}{(trip title.post)}
      ;+  url-link
      ;+  img-prev
      ;div.me
        ;+  ;/("{(commafy points)} points by {(scow %p author.post)} {(time-ago now created.post)}")
        ;+  edit-link
        ;+  del-btn
        ;+  pin-btn
      ==
      ;+  body-section
    ==
  =/  script-node=manx
    ?.  authed  ;span;
    [[%script ~] [[[%$ [%$ (trip upload-js)]~] ~] ~]]
  =/  post-content=marl
    :~  post-detail
        ;hr;
        comment-form
        ;hr;
        comment-div
        script-node
    ==
  %-  page-shell
  [(crip "furum - {(trip title.post)}") post-content `[board-path (trip title.board-info)] !authed look]
::
::  render a flat list of depth-tagged comments
::
++  render-flat-comments
  |=  [cmts=(list [@ud comment]) board-path=tape post-id=post-id our=@p is-mod=? authed=? now=@da post-last-seen=(unit @da)]
  ^-  marl
  %+  turn  cmts
  |=  [depth=@ud c=comment]
  ^-  manx
  =/  points=@ud
    =/  up  ~(wyt in up-votes.c)
    =/  dn  ~(wyt in down-votes.c)
    ?:((gte up dn) (sub up dn) 0)
  =/  indent=tape  (a-co:co (mul depth 20))
  =/  vote-btn=manx
    ?.  authed  ;span;
    ;form(method "post", action "{board-path}/vote", style "display:inline")
      ;input(type "hidden", name "target", value "comment-{(a-co:co post-id)}-{(a-co:co id.c)}");
      ;input(type "hidden", name "dir", value "up");
      ;button.va(type "submit"): ▲
    ==
  =/  del-btn=manx
    ?.  ?&(authed ?|(=(our author.c) is-mod))  ;span;
    ;form(method "post", action "{board-path}/{(a-co:co post-id)}/delete-comment", style "display:inline")
      ;input(type "hidden", name "comment-id", value "{(a-co:co id.c)}");
      ;+  ;/(" ")
      ;button.va(type "submit"): delete
    ==
  =/  reply-section=manx
    ?.  authed  ;span;
    ;details
      ;summary.me: reply
      ;form(method "post", action "{board-path}/{(a-co:co post-id)}/comment")
        ;input(type "hidden", name "parent", value "{(a-co:co id.c)}");
        ;textarea(name "body", rows "3", cols "60");
        ;div.upload-section(data-mode "body")
          ;label: attach image:
          ;input(type "file", accept "image/*");
          ;button.upload-btn(type "button"): upload
          ;span.upload-status;
        ==
        ;input.btn(type "submit", value "reply");
      ==
    ==
  =/  is-new-comment=?
    ?~  post-last-seen  %.n
    (gth created.c u.post-last-seen)
  ;div(style "margin-left: {indent}px")
    ;div(class ?:(is-new-comment "cm cm-new" "cm"))
      ;div.cm-meta
        ;+  vote-btn
        ;+  ;/(" {(scow %p author.c)} {(commafy points)} points {(time-ago now created.c)}")
        ;+  del-btn
      ==
      ;+  (linkify-div "" (trip body.c))
      ;*  (turn (extract-image-urls body.c) image-preview)
      ;+  reply-section
    ==
  ==
::
::  SUBMIT POST FORM
::
++  render-submit
  |=  [host=@p name=board-name =look:th]
  ^-  manx
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name)}"
  =/  script-node=manx
    [[%script ~] [[[%$ [%$ (trip upload-js)]~] ~] ~]]
  %-  page-shell
  :*  'furum - submit'
    ^-  marl
    :~
      ;h3: Submit to {(trip name)}
      ;form(method "post", action "{board-path}/submit")
        ;div
          ;label: title
          ;br;
          ;input(type "text", name "title", required "");
        ==
        ;br;
        ;div
          ;label: url (optional, for link posts)
          ;br;
          ;input(type "url", name "url");
        ==
        ;div.upload-section(data-mode "url")
          ;label: or upload an image:
          ;input(type "file", accept "image/*");
          ;button.upload-btn(type "button"): upload
          ;span.upload-status;
        ==
        ;br;
        ;div
          ;label: text (optional, for text posts)
          ;br;
          ;textarea(name "body");
        ==
        ;br;
        ;input.btn(type "submit", value "submit");
      ==
      script-node
    ==
    `[board-path (trip name)]
    %.n
    look
  ==
::
::  SHARE TARGET PAGE: receive content from OS share sheet
::
++  render-share
  |=  [all-boards=(list [@p board-name]) share-title=@t share-url=@t share-text=@t =look:th]
  ^-  manx
  =/  script-node=manx
    [[%script ~] [[[%$ [%$ (trip upload-js)]~] ~] ~]]
  ::  build JS to update form action when board selection changes
  =/  board-js=cord
    'document.getElementById("board-sel").addEventListener("change",function(){document.getElementById("share-form").action=this.value+"/submit";})'
  =/  board-script=manx
    [[%script ~] [[[%$ [%$ (trip board-js)]~] ~] ~]]
  ::  if share-text contains a URL and share-url is empty, use text as url
  =/  effective-url=@t
    ?:  !=('' share-url)  share-url
    ?:  ?|  =((find "https://" (trip share-text)) `0)
            =((find "http://" (trip share-text)) `0)
        ==
      share-text
    ''
  =/  effective-body=@t
    ?:  =(effective-url share-text)  ''
    share-text
  =/  board-options=marl
    ?~  all-boards
      :~  ;option(value "", disabled ""): no boards available
      ==
    %+  turn  all-boards
    |=  [host=@p name=board-name]
    ^-  manx
    =/  board-path=tape
      "/apps/furum/b/{(scow %p host)}/{(trip name)}"
    ;option(value board-path): {(trip name)} ({(scow %p host)})
  =/  first-action=tape
    ?~  all-boards  ""
    =/  [fh=@p fn=board-name]  i.all-boards
    "/apps/furum/b/{(scow %p fh)}/{(trip fn)}/submit"
  %-  page-shell
  :*  'furum - share'
    ^-  marl
    :~
      ;h3: Share to furum
      ;div
        ;label: board
        ;br;
        ;select#board-sel
          ;*  board-options
        ==
      ==
      ;br;
      ;form#share-form(method "post", action first-action)
        ;div
          ;label: title
          ;br;
          ;input(type "text", name "title", required "", value (trip share-title));
        ==
        ;br;
        ;div
          ;label: url (optional)
          ;br;
          ;input(type "url", name "url", value (trip effective-url));
        ==
        ;div.upload-section(data-mode "url")
          ;label: or upload an image:
          ;input(type "file", accept "image/*");
          ;button.upload-btn(type "button"): upload
          ;span.upload-status;
        ==
        ;br;
        ;div
          ;label: text (optional)
          ;br;
          ;textarea(name "body"): {(trip effective-body)}
        ==
        ;br;
        ;input.btn(type "submit", value "share");
      ==
      board-script
      script-node
    ==
    ~
    %.n
    look
  ==
::
::  EDIT POST FORM
::
++  render-edit-post
  |=  [host=@p name=board-name =post =look:th]
  ^-  manx
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name)}"
  =/  post-path=tape
    "{board-path}/{(a-co:co id.post)}"
  =/  url-display=manx
    ?~  url.post  ;span;
    ;div
      ;label: link
      ;br;
      ;span.me: {(trip u.url.post)}
    ==
  =/  edit-form=manx
    ;form(method "post", action "{post-path}/edit")
      ;div
        ;label: title
        ;br;
        ;input(type "text", name "title", required "", value "{(trip title.post)}");
      ==
      ;br;
      ;div
        ;label: text (optional)
        ;br;
        ;textarea(name "body"): {?~(body.post "" (trip u.body.post))}
      ==
      ;br;
      ;input.btn(type "submit", value "save");
    ==
  =/  content=marl
    :~  ;h3: Edit post
        url-display
        ;br;
        edit-form
    ==
  %-  page-shell
  [%'furum - edit post' content `[board-path (trip name)] %.n look]
::
::  CREATE BOARD FORM
::
++  render-create
  |=  =look:th
  ^-  manx
  %-  page-shell
  :*  'furum - create board'
    ^-  marl
    :~
      ;h3: Create a New Board
      ;form(method "post", action "/apps/furum/create")
        ;div
          ;label: name (url-safe, lowercase, no spaces)
          ;br;
          ;input(type "text", name "name", required "", pattern "[a-z0-9-]+", maxlength "64");
        ==
        ;br;
        ;div
          ;label: title
          ;br;
          ;input(type "text", name "title", required "");
        ==
        ;br;
        ;div
          ;label: description
          ;br;
          ;textarea(name "description");
        ==
        ;br;
        ;div
          ;label: default role for new users
          ;br;
          ;select(name "default-role")
            ;option(value "poster", selected ""): poster (can post and comment)
            ;option(value "reader"): reader (can only vote)
          ==
        ==
        ;br;
        ;input.btn(type "submit", value "create board");
      ==
    ==
    ~
    %.n
    look
  ==
::
::  MODERATION PANEL
::
++  known-mints
  ^-  (list [@t @t])
  :~  ['https://mint.minibits.cash/Bitcoin' 'Minibits (Bitcoin)']
      ['https://mint.chorus.community' 'Chorus Community']
      ['https://mint.cubabitcoin.org' 'Cuba Bitcoin']
  ==
::
::  +accepted-mints: the mints a paid board takes ecash from, as [url label].
::  the board's own mint if set, else the known public mints. a token from
::  any other mint is refused: a self-run mint can sign worthless tokens.
::
++  accepted-mints
  |=  pay=payment-config
  ^-  (list [@t @t])
  ?~  mint.pay  known-mints
  =/  url=@t  (crip (clean-mint-url:ca u.mint.pay))
  ~[[url url]]
::
++  mint-accepted
  |=  [pay=payment-config mint=@t]
  ^-  ?
  =/  url=@t  (crip (clean-mint-url:ca mint))
  (lien (accepted-mints pay) |=([u=@t *] =(u url)))
::
++  render-paywall
  |=  [host=@p =board-info pay=payment-config expired=(unit @da) =look:th pending=?]
  ^-  manx
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name.board-info)}"
  =/  price-text=tape  (commafy price.pay)
  =/  days=@ud  (div interval.pay ~d1)
  =/  days-text=tape  (commafy days)
  =/  paywall-refresh-js=tape  (trip 'setInterval(function(){location.reload()},3000)')
  =/  refresh-node=manx  [[%script ~] [[[%$ [%$ paywall-refresh-js] ~] ~] ~]]
  =/  has-lightning=?  ?=(^ mint.pay)
  =/  pending-section=manx
    ?.  pending  ;span;
    :-  [%div ~[['class' "paywall-info"]]]
    :~  ;p: Processing payment... This page will refresh automatically.
        refresh-node
    ==
  =/  status-msg=manx
    ?:  pending
      ;p.paywall-status: Payment submitted. Waiting for mint confirmation...
    ?~  expired
      ;p.paywall-status: This board requires payment to access.
    ;p.paywall-status: Your access has expired. Pay to renew.
  =/  mint-options=marl
    %+  turn  (accepted-mints pay)
    |=  [url=@t label=@t]
    ;option(value (trip url)): {(trip label)}
  =/  token-js=cord
    '''
    (function(){
      function b64url(s){return s.replace(/-/g,'+').replace(/_/g,'/').replace(/=+$/,'');}
      function decodeCBOR(buf){var d=new DataView(buf),p=0;function r(){var b=d.getUint8(p++),m=b>>5,a=b&31,v=a;if(a===24)v=d.getUint8(p++);else if(a===25){v=d.getUint16(p);p+=2;}else if(a===26){v=d.getUint32(p);p+=4;}if(m===0)return v;if(m===2){var u=new Uint8Array(buf,p,v);p+=v;return Array.from(u).map(function(x){return('0'+x.toString(16)).slice(-2)}).join('');}if(m===3){var t=new TextDecoder().decode(new Uint8Array(buf,p,v));p+=v;return t;}if(m===4){var ar=[];for(var i=0;i<v;i++)ar.push(r());return ar;}if(m===5){var o={};for(var i=0;i<v;i++){var k=r();o[k]=r();}return o;}return v;}return r();}
      var ta=document.getElementById('token-input');
      var mf=document.getElementById('mint-select');
      var sf=document.getElementById('token-summary');
      var hid=document.getElementById('tokens-hidden');
      var hm=document.getElementById('mint-hidden');
      hm.value=mf.value;
      ta.addEventListener('input',function(){
        var v=ta.value.trim();
        try{
          var proofs=[],mint='';
          if(v.startsWith('cashuA')){
            var j=JSON.parse(atob(b64url(v.slice(6))));
            if(j.token&&j.token[0]){mint=j.token[0].mint||'';proofs=j.token[0].proofs||[];}
          }else if(v.startsWith('cashuB')){
            var raw=atob(b64url(v.slice(6)));
            var buf=new ArrayBuffer(raw.length);
            var u8=new Uint8Array(buf);
            for(var i=0;i<raw.length;i++)u8[i]=raw.charCodeAt(i);
            var obj=decodeCBOR(buf);
            mint=obj.m||'';
            if(obj.t){obj.t.forEach(function(g){
              var kid=typeof g.i==='string'?g.i:'';
              if(g.p)g.p.forEach(function(pr){
                proofs.push({amount:pr.a,secret:pr.s,C:pr.c,id:kid});
              });
            });}
          }else{
            var j=JSON.parse(v);
            if(j.inputs)proofs=j.inputs;
            else if(Array.isArray(j))proofs=j;
            else if(j.token&&j.token[0]){mint=j.token[0].mint||'';proofs=j.token[0].proofs||[];}
          }
          var total=proofs.reduce(function(s,p){return s+(p.amount||0);},0);
          sf.textContent=total>0?'Total: '+total+' sats ('+proofs.length+' proofs)':'';
          hid.value=JSON.stringify({inputs:proofs});
          if(mint){
            mint=mint.replace(/\/+$/,'');
            mf.value=mint;
            hm.value=mint;
            if(mf.value!==mint)sf.textContent='This board does not accept tokens from '+mint;
          }
        }catch(e){sf.textContent='Could not parse token';hid.value='';}
      });
      mf.addEventListener('change',function(){hm.value=mf.value;});
    })();
    '''
  =/  qr-scan-js=cord
    '''
    (function(){
      var btn=document.getElementById('qr-scan-btn');
      if(!btn)return;
      var overlay=document.getElementById('qr-overlay');
      var video=document.getElementById('qr-video');
      var status=document.getElementById('qr-status');
      var closeBtn=document.getElementById('qr-close-btn');
      var scanning=false;
      var stream=null;
      var canvas=document.createElement('canvas');
      var ctx=canvas.getContext('2d',{willReadFrequently:true});
      var frames=0;
      var urDecoder=null;
      var bcurLoaded=null;
      var seenParts={};
      function loadLibs(){
        return new Promise(function(resolve,reject){
          if(typeof jsQR!=='undefined'&&bcurLoaded){resolve();return;}
          var pending=0;
          if(typeof jsQR==='undefined'){
            pending++;
            var s=document.createElement('script');
            s.src='https://cdn.jsdelivr.net/npm/jsqr@1.4.0/dist/jsQR.min.js';
            s.onload=function(){pending--;if(pending===0)resolve();};
            s.onerror=function(){reject('Failed to load QR scanner');};
            document.head.appendChild(s);
          }
          if(!bcurLoaded){
            pending++;
            import('https://esm.sh/@ngraveio/bc-ur').then(function(m){
              bcurLoaded=m;
              pending--;if(pending===0)resolve();
            }).catch(function(){
              bcurLoaded={unavailable:true};
              pending--;if(pending===0)resolve();
            });
          }
          if(pending===0)resolve();
        });
      }
      btn.addEventListener('click',function(){
        if(scanning)return stopScan();
        btn.textContent='Loading scanner...';
        btn.disabled=true;
        loadLibs().then(function(){
          btn.textContent='Scan QR Code';
          btn.disabled=false;
          startScan();
        }).catch(function(e){
          btn.textContent='Scan QR Code';
          btn.disabled=false;
          alert(e);
        });
      });
      closeBtn.addEventListener('click',stopScan);
      function startScan(){
        if(!navigator.mediaDevices||!navigator.mediaDevices.getUserMedia){
          alert('Camera access requires HTTPS. Please access your computer over HTTPS to use the QR scanner.');
          return;
        }
        frames=0;
        urDecoder=null;
        seenParts={};
        navigator.mediaDevices.getUserMedia({
          video:{facingMode:'environment'}
        }).then(function(s){
          stream=s;
          video.srcObject=s;
          scanning=true;
          overlay.classList.add('active');
          status.textContent='Point camera at Cashu QR code...';
          video.onloadedmetadata=function(){video.play().then(function(){requestAnimationFrame(tick);}).catch(function(){});};
        }).catch(function(e){
          alert('Camera access denied: '+e.message);
        });
      }
      function stopScan(){
        scanning=false;
        overlay.classList.remove('active');
        if(stream){
          stream.getTracks().forEach(function(t){t.stop();});
          stream=null;
        }
      }
      function handleResult(d){
        var ta=document.getElementById('token-input');
        ta.value=d;
        ta.dispatchEvent(new Event('input'));
        stopScan();
      }
      function tick(){
        if(!scanning)return;
        if(video.readyState===video.HAVE_ENOUGH_DATA){
          frames++;
          canvas.width=video.videoWidth;
          canvas.height=video.videoHeight;
          ctx.drawImage(video,0,0,canvas.width,canvas.height);
          var img=ctx.getImageData(0,0,canvas.width,canvas.height);
          var code=jsQR(img.data,canvas.width,canvas.height,{inversionAttempts:'dontInvert'});
          if(code&&code.data){
            var d=code.data.trim();
            if(d.startsWith('cashuA')||d.startsWith('cashuB')||d.startsWith('{')){
              handleResult(d);
              return;
            }
            if(d.toLowerCase().startsWith('ur:')&&bcurLoaded&&!bcurLoaded.unavailable){
              try{
                if(!urDecoder){
                  var D=bcurLoaded.URDecoder;
                  if(!D){status.textContent='URDecoder not found in module. Keys: '+Object.keys(bcurLoaded).join(',');return;}
                  urDecoder=new D();
                }
                if(urDecoder){
                  var part=d.toLowerCase();
                  if(!seenParts[part]){
                    seenParts[part]=true;
                    urDecoder.receivePart(part);
                  }
                  var pct=Math.round(urDecoder.estimatedPercentComplete()*100);
                  var exp=urDecoder.expectedPartCount?urDecoder.expectedPartCount():0;
                  var rcv=Object.keys(seenParts).length;
                  status.textContent='UR frames: '+rcv+'/'+exp+' ('+pct+'%) complete='+urDecoder.isComplete();
                  if(urDecoder.isComplete()){
                    if(urDecoder.isSuccess()){
                      var ur=urDecoder.resultUR();
                      var cbor=ur.cbor;
                      var arr=cbor instanceof Uint8Array?cbor:new Uint8Array(cbor);
                      var payload=arr;
                      if(arr.length>0&&(arr[0]>>5)===2){
                        var add=arr[0]&0x1f,off=1,len=add;
                        if(add===24){len=arr[1];off=2;}
                        else if(add===25){len=(arr[1]<<8)|arr[2];off=3;}
                        else if(add===26){len=(arr[1]<<24)|(arr[2]<<16)|(arr[3]<<8)|arr[4];off=5;}
                        payload=arr.slice(off,off+len);
                      }
                      var txt='';
                      try{txt=new TextDecoder().decode(payload);}catch(e){}
                      status.textContent='UR decoded: '+payload.length+'b, starts: '+txt.substring(0,20);
                      if(txt.startsWith('cashuA')||txt.startsWith('cashuB')||txt.startsWith('{')){
                        handleResult(txt);
                      }else{
                        var raw='';
                        for(var bi=0;bi<payload.length;bi++)raw+=String.fromCharCode(payload[bi]);
                        var b64=btoa(raw).replace(/\+/g,'-').replace(/\//g,'_').replace(/=+$/,'');
                        handleResult('cashuB'+b64);
                      }
                    }else{
                      status.textContent='UR decode error: '+urDecoder.resultError()+'. Retrying...';
                      urDecoder=null;
                    }
                  }
                }
              }catch(e){
                status.textContent='UR error: '+e.message+' | '+e.stack;
              }
            }else if(d.toLowerCase().startsWith('ur:')){
              status.textContent='UR QR detected but decoder unavailable. Paste token manually.';
            }
          }else{
            if(frames%30===0)status.textContent='Scanning... ('+frames+' frames)';
          }
        }
        requestAnimationFrame(tick);
      }
    })();
    '''
  =/  qr-scan-script=manx  [[%script ~] [[;/((trip qr-scan-js))] ~]]
  =/  qr-overlay=manx
    ;div(id "qr-overlay")
      ;video(id "qr-video", playsinline "true", autoplay "true");
      ;p(id "qr-status"): Point camera at Cashu QR code...
      ;button(type "button", id "qr-close-btn"): Close
    ==
  =/  tab-js=@t
    '''
    function showTab(id){
      document.querySelectorAll('.pay-tab').forEach(function(el){el.style.display='none'});
      document.querySelectorAll('.tab-btn').forEach(function(el){el.classList.remove('active')});
      document.getElementById(id).style.display='block';
      document.querySelector('[data-tab="'+id+'"]').classList.add('active');
    }
    '''
  =/  tab-script=manx  [[%script ~] [[[%$ [%$ (trip tab-js)] ~] ~] ~]]
  =/  ln-tab=manx
    ?.  has-lightning  ;span;
    ;div.pay-tab(id "tab-lightning")
      ;form(method "post", action "{board-path}/pay-lightning")
        ;p: Pay instantly from any Lightning wallet.
        ;input.btn(type "submit", value "Generate Lightning Invoice");
      ==
    ==
  =/  ecash-tab=manx
    ;div.pay-tab(id "tab-ecash", style ?:(has-lightning "display:none" ""))
      ;form.payment-form(method "post", action "{board-path}/pay")
        ;input(type "hidden", name "tokens", id "tokens-hidden", value "");
        ;input(type "hidden", name "mint", id "mint-hidden", value "");
        ;div
          ;label: Select Mint
          ;br;
          ;select(name "mint-select", id "mint-select")
            ;*  mint-options
          ==
        ==
        ;br;
        ;div
          ;label: Paste Cashu Token (cashuA.../cashuB... or raw JSON)
          ;br;
          ;textarea(id "token-input", rows "6", cols "60", placeholder "cashuAeyJ0b2tlbi...");
        ==
        ;p(id "token-summary");
        ;button.btn(type "button", id "qr-scan-btn"): Scan QR Code
        ;br;
        ;br;
        ;input.btn(type "submit", value "Submit Payment");
      ==
    ==
  =/  tab-bar=manx
    ?.  has-lightning
      ;span;
    ;div.tab-bar
      ;button.tab-btn.active(type "button", data-tab "tab-lightning", onclick "showTab('tab-lightning')"): Lightning
      ;button.tab-btn(type "button", data-tab "tab-ecash", onclick "showTab('tab-ecash')"): Cashu Token
    ==
  =/  paywall-content=marl
    :~  ;h3: {(trip title.board-info)}
        ;p.me: {(trip description.board-info)}
        ;hr;
        pending-section
        status-msg
        ;div.paywall-info
          ;p: Price: {price-text} sats for {days-text} days of access
        ==
        tab-bar
        ln-tab
        ecash-tab
        tab-script
        ;script: {(trip token-js)}
        qr-overlay
        qr-scan-script
    ==
  %-  page-shell
  [(crip "furum - {(trip name.board-info)} - payment required") paywall-content `[board-path (trip title.board-info)] %.n look]
::
++  render-lightning-invoice
  |=  [host=@p =board-info pay=payment-config bolt11=(unit @t) =look:th]
  ^-  manx
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name.board-info)}"
  =/  price-text=tape  (commafy price.pay)
  =/  days=@ud  (div interval.pay ~d1)
  =/  days-text=tape  (commafy days)
  =/  refresh-js=tape  (trip 'setInterval(function(){location.reload()},4000)')
  =/  refresh-node=manx  [[%script ~] [[[%$ [%$ refresh-js] ~] ~] ~]]
  =/  copy-js=tape  "navigator.clipboard.writeText(document.getElementById('bolt11-text').value)"
  =/  invoice-content=manx
    ?~  bolt11
      ;div.paywall
        ;h3: Lightning Payment
        ;div.paywall-info
          ;p: Pay {price-text} sats for {days-text} days of access
        ==
        ;p: Generating invoice...
        ;+  refresh-node
      ==
    ;div.paywall
      ;h3: Lightning Payment
      ;div.paywall-info
        ;p: Pay {price-text} sats for {days-text} days of access
      ==
      ;div(style "text-align: center; margin: 16px 0")
        ;img(src "https://api.qrserver.com/v1/create-qr-code/?size=280x280&data={(urle (trip u.bolt11))}", alt "Lightning Invoice QR Code", style "max-width: 280px");
      ==
      ;div(style "margin: 12px 0")
        ;label: Lightning Invoice
        ;br;
        ;textarea(rows "4", cols "60", id "bolt11-text", style "font-size: 11px; word-break: break-all"): {(trip u.bolt11)}
      ==
      ;button.btn(type "button", onclick "{copy-js}"): Copy Invoice
      ;p(style "margin-top: 16px; color: var(--muted)"): Waiting for payment... This page will refresh automatically.
      ;+  refresh-node
    ==
  =/  content=marl
    :~  invoice-content
    ==
  %-  page-shell
  [(crip "furum - {(trip name.board-info)} - lightning payment") content `[board-path (trip title.board-info)] %.n look]
::
++  render-mod
  |=  [host=@p =board-info roles=(map @p role) is-host=? =look:th sidebar=@t payment=(unit payment-config) wallet=(map @t (list cashu-proof)) pending-melt=? saved=@t paid=(map @p @da) now=@da prune=(unit prune-config)]
  ^-  manx
  =/  board-path=tape
    "/apps/furum/b/{(scow %p host)}/{(trip name.board-info)}"
  =/  role-section=manx
    ?.  (gth ~(wyt by roles) 0)
      ;p.me: No explicit roles set. Everyone gets the default role.
    ;table.mod
      ;thead
        ;tr
          ;th: Ship
          ;th: Role
          ;th: Action
        ==
      ==
      ;tbody
        ;*
        %+  turn  ~(tap by roles)
        |=  [who=@p =role]
        ;tr
          ;td: {(scow %p who)}
          ;td: {(trip (role-to-text role))}
          ;td
            ;form(method "post", action "{board-path}/mod/remove-role", style "display:inline")
              ;input(type "hidden", name "who", value "{(scow %p who)}");
              ;input.btn(type "submit", value "remove");
            ==
          ==
        ==
      ==
    ==
  =/  info-section=manx
    ?.  is-host  ;span;
    ;div
      ;h4: Board Info
      ;form(method "post", action "{board-path}/mod/edit-info")
        ;div
          ;label: Title
          ;br;
          ;input(type "text", name "title", value (trip title.board-info), required "", style "width: 100%; max-width: 440px; font-size: 16px; padding: 5px");
        ==
        ;br;
        ;div
          ;label: Description
          ;br;
          ;textarea(name "description", rows "3", cols "60"): {(trip description.board-info)}
        ==
        ;br;
        ;input.btn(type "submit", value "Save Info");
      ==
      ;hr;
    ==
  =/  pub-status=tape  ?:(public.board-info "This board is currently public." "This board is currently private.")
  =/  pub-label=tape  ?:(public.board-info "make private" "make public")
  =/  pub-section=manx
    ?.  is-host  ;span;
    ;div
      ;h4: Public Access
      ;p.me: Public boards can be read without authentication.
      ;form(method "post", action "{board-path}/mod/public")
        ;p: {pub-status}
        ;input.btn(type "submit", value pub-label);
      ==
      ;hr;
    ==
  =/  role-form=manx
    ;form(method "post", action "{board-path}/mod/role")
      ;div
        ;label: computer (@p)
        ;br;
        ;input(type "text", name "who", required "", placeholder "~sampel-palnet");
      ==
      ;br;
      ;div
        ;label: role
        ;br;
        ;select(name "role")
          ;option(value "reader"): reader
          ;option(value "poster"): poster
          ;option(value "mod"): moderator
        ==
      ==
      ;br;
      ;input.btn(type "submit", value "set role");
    ==
  =/  sidebar-section=manx
    ;div
      ;h4: Community Sidebar
      ;p.me: This text appears in the sidebar on the board page. URLs will be linked automatically. Leave empty to hide.
      ;form(method "post", action "{board-path}/sidebar")
        ;textarea(name "sidebar", rows "6", cols "60"): {(trip sidebar)}
        ;br;
        ;input.btn(type "submit", value "save sidebar");
      ==
      ;hr;
    ==
  =/  prune-enabled=?  ?=(^ prune)
  =/  prune-score=tape  ?~(prune "2" (a-co:co min-score.u.prune))
  =/  prune-days=tape  ?~(prune "7" (a-co:co (div after.u.prune ~d1)))
  =/  prune-checkbox=manx
    ?:  prune-enabled
      ;input(type "checkbox", name "prune-enabled", value "on", checked "checked");
    ;input(type "checkbox", name "prune-enabled", value "on");
  =/  prune-section=manx
    ?.  is-host  ;span;
    ;div
      ;h4: Auto-Prune
      ;p.me: Automatically delete posts below a minimum score after a set number of days. Pinned posts are never pruned.
      ;form(method "post", action "{board-path}/mod/prune")
        ;div(style "margin: 8px 0")
          ;label
            ;+  prune-checkbox
            ;+  ;/(" Enable auto-prune")
          ==
        ==
        ;div(style "margin: 8px 0")
          ;label: Minimum score (posts below this get pruned)
          ;br;
          ;input(type "number", name "min-score", value prune-score, min "0", style "width: 80px");
        ==
        ;div(style "margin: 8px 0")
          ;label: After days
          ;br;
          ;input(type "number", name "after-days", value prune-days, min "1", style "width: 80px");
        ==
        ;input.btn(type "submit", value "save prune settings");
      ==
      ;hr;
    ==
  =/  pay-enabled=?  ?=(^ payment)
  =/  pay-price=tape  (skip ?~(payment "0" (a-co:co price.u.payment)) |=(c=@ =(c '.')))
  =/  pay-days=tape  (skip ?~(payment "30" (a-co:co (div interval.u.payment ~d1))) |=(c=@ =(c '.')))
  =/  pay-mint=tape  ?~(payment "" ?~(mint.u.payment "" (trip u.mint.u.payment)))
  =/  pay-checkbox=manx
    ?:  pay-enabled
      ;input(type "checkbox", name "enabled", value "on", checked "checked");
    ;input(type "checkbox", name "enabled", value "on");
  =/  saved-msg=tape
    ?:  =('payment' saved)  "Payment config saved."
    ?:  =('registered' saved)  "Board registered in directory."
    "Settings saved."
  =/  saved-banner=manx
    ?:  =('' saved)  ;span;
    :-  [%div ~[['class' "paywall-info"]]]
    :~  ;/(saved-msg)
    ==
  =/  payment-section=manx
    ?.  is-host  ;span;
    ;div
      ;h4: Paid Access
      ;p.me: Enable paid access to require ecash tokens for board access. Paid boards cannot be public.
      ;form(method "post", action "{board-path}/mod/payment")
        ;div
          ;label
            ;+  pay-checkbox
            ;+  ;/(" Enable paid access")
          ==
        ==
        ;br;
        ;div
          ;label: Price (sats)
          ;br;
          ;input(type "number", name "price", min "1", value pay-price);
        ==
        ;br;
        ;div
          ;label: Access duration (days)
          ;br;
          ;input(type "number", name "interval", min "1", value pay-days);
        ==
        ;br;
        ;div
          ;label: Mint URL (enables Lightning; ecash is then only accepted from this mint, otherwise from the known public mints)
          ;br;
          ;input(type "text", name "mint-url", value pay-mint, placeholder "https://mint.example.com", style "width: 400px");
        ==
        ;br;
        ;input.btn(type "submit", value "save payment config");
      ==
      ;hr;
    ==
  =/  wallet-entries=(list [@t @ud @ud])
    %+  murn  ~(tap by wallet)
    |=  [mint=@t proofs=(list cashu-proof)]
    =/  total=@ud  (roll proofs |=([p=cashu-proof acc=@ud] (add acc amount.p)))
    ?:  =(0 total)  ~
    `[mint total (lent proofs)]
  =/  melt-pending-banner=manx
    ?.  pending-melt  ;span;
    :-  [%div ~[['class' "paywall-info"]]]
    :~  ;p: Processing withdrawal... This page will refresh automatically.
        [[%script ~] [[[%$ [%$ (trip 'setInterval(function(){location.reload()},3000)')] ~] ~] ~]]
    ==
  =/  wallet-section=manx
    ?.  is-host  ;span;
    ?:  =(0 (lent wallet-entries))
      ;div
        ;h4: Wallet
        ;+  melt-pending-banner
        ;p.me: No ecash tokens stored. Tokens will appear here when users pay for board access.
        ;hr;
      ==
    ;div
      ;h4: Wallet
      ;+  melt-pending-banner
      ;p.me: Ecash tokens received from board payments. Withdraw to Lightning below.
      ;a.btn(href "{board-path}/mod/backup-proofs", style "margin-bottom: 12px; display: inline-block"): backup proofs
      ;*
      %+  turn  wallet-entries
      |=  [mint=@t total=@ud count=@ud]
      ^-  manx
      ;div.wallet-entry
        ;p: Mint: {(trip mint)}
        ;p: Balance: {(commafy total)} sats ({(commafy count)} proofs)
        ;form(method "post", action "{board-path}/mod/melt")
          ;input(type "hidden", name "mint", value (trip mint));
          ;div
            ;label: Lightning Invoice (bolt11)
            ;br;
            ;textarea(name "invoice", rows "3", cols "60", placeholder "lnbc...");
          ==
          ;br;
          ;input.btn(type "submit", value "withdraw to lightning");
        ==
      ==
      ;hr;
    ==
  =/  register-section=manx
    ?.  is-host  ;span;
    ;div
      ;hr;
      ;h4: Directory Registration
      ;p.me: Register or re-register this board in the network directory so others can discover it.
      ;form(method "post", action "{board-path}/mod/register")
        ;input.btn(type "submit", value "Register in Directory");
      ==
    ==
  =/  delete-section=manx
    ?.  is-host  ;span;
    ;div
      ;hr;
      ;h4: Delete Board
      ;p.me: Permanently delete this board and unregister it. This cannot be undone.
      ;form(method "post", action "{board-path}/mod/delete", onsubmit "return confirm('Are you sure you want to delete this board? This cannot be undone.')")
        ;input.btn(type "submit", value "delete board", style "background: var(--error); color: var(--on-error)");
      ==
    ==
  =/  paid-list=(list [@p @da])
    %+  sort  ~(tap by paid)
    |=  [[a=@p da=@da] [b=@p db=@da]]
    (gth da db)
  =/  paid-section=manx
    ?.  is-host  ;span;
    ?~  payment  ;span;
    ;div
      ;hr;
      ;h4: Members
      ;p.me: Members and moderators read this board; nobody else can.
      ;form(method "post", action "{board-path}/mod/grant")
        ;input(type "text", name "who", placeholder "~sampel-palnet", required "");
        ;input(type "number", name "days", value "30", min "1", style "width: 5em");
        ;+  ;/(" days ")
        ;input.btn(type "submit", value "give access");
      ==
      ;table(style "width: 100%; border-collapse: collapse")
        ;tr(style "text-align: left")
          ;th: Ship
          ;th: Paid Until
          ;th: Status
          ;th;
        ==
        ;*  %+  turn  paid-list
            |=  [who=@p until=@da]
            ;tr(style "border-top: 1px solid var(--line); padding: 4px 0")
              ;td: {(scow %p who)}
              ;td: {(scow %da until)}
              ;td: {?:((gth until now) "active" "expired")}
              ;td
                ;form(method "post", action "{board-path}/mod/revoke", style "display:inline")
                  ;input(type "hidden", name "who", value (scow %p who));
                  ;button.va(type "submit"): revoke
                ==
              ==
            ==
      ==
    ==
  =/  mod-content=marl
    :~  ;h3: Moderate {(trip title.board-info)}
        ;p.me: Default role: {(trip (role-to-text default-role.board-info))}
        saved-banner
        info-section
        pub-section
        payment-section
        wallet-section
        paid-section
        sidebar-section
        prune-section
        ;h4: Set User Role
        role-form
        ;hr;
        ;h4: Current Roles
        role-section
        register-section
        delete-section
    ==
  %-  page-shell
  [(crip "furum - mod {(trip name.board-info)}") mod-content `[board-path (trip title.board-info)] %.n look]
::
::  NOTIFICATIONS PAGE
::
++  render-notifications
  |=  [notifs=(list notification) now=@da =look:th]
  ^-  manx
  =/  unread=@ud
    %+  roll  notifs
    |=  [n=notification acc=@ud]
    ?:(read.n acc +(acc))
  =/  mark-btn=manx
    ?.  (gth unread 0)  ;span;
    ;form(method "post", action "/apps/furum/notifications/read")
      ;input.btn(type "submit", value "Mark all read");
    ==
  =/  notif-rows=marl
    ?~  notifs
      :~  ;p.me: No notifications yet. You'll see them here when someone comments on your posts or replies to your comments.
      ==
    %+  turn  notifs
    |=  n=notification
    ^-  manx
    =/  time-text=tape  (time-ago now time.n)
    =/  read-style=tape  ?:(read.n "color: var(--faint)" "")
    ?~  url.n
      ;div(style "padding: 8px 0; border-bottom: 1px solid var(--line); {read-style}")
        ;strong: {(trip title.n)}
        ;p.me: {(trip body.n)}
        ;span.me: {time-text}
      ==
    ;div(style "padding: 8px 0; border-bottom: 1px solid var(--line); {read-style}")
      ;strong
        ;a(href (safe-href u.url.n)): {(trip title.n)}
      ==
      ;p.me: {(trip body.n)}
      ;span.me: {time-text}
    ==
  =/  notif-content=marl
    %+  welp
    :~  ;h3: Notifications
        ;p.me: {?:((gth unread 0) "{(a-co:co unread)} unread" "All caught up.")}
        mark-btn
    ==
    notif-rows
  %-  page-shell
  :*  'furum - notifications'  notif-content  ~  %.n  look  ==
::
::  ADMIN PAGE
::
++  render-admin
  |=  $:  our=@p  =look:th
          boards-list=(list [board-name board])
          is-registry=?
          entries=(list directory-entry)
          admins=(set @p)
          subs-list=(list [@p board-name])
          cache-list=(list [@p board-name cached-board])
          msg=@t
          registry=@p
      ==
  ^-  manx
  =/  status-banner=manx
    ?:  =('' msg)  ;span;
    ?:  =('resubscribed' msg)
      ;div.paywall-info
        ;p: Re-subscribed to remote board.
      ==
    ;span;
  ::  -- boards overview --
  =/  board-rows=marl
    ?~  boards-list
      :~  ;p.me: No boards hosted on this computer.
      ==
    %+  turn  boards-list
    |=  [name=board-name brd=board]
    ^-  manx
    =/  post-count=@ud  ~(wyt by posts.brd)
    =/  comment-count=@ud
      %+  roll  ~(val by comments.brd)
      |=  [cm=(map comment-id comment) acc=@ud]
      (add acc ~(wyt by cm))
    =/  role-count=@ud  ~(wyt by roles.brd)
    =/  paid-text=tape
      ?~  payment.brd  "free"
      "paid ({(commafy price.u.payment.brd)} sats)"
    ;div(style "padding: 6px 0; border-bottom: 1px solid var(--line)")
      ;strong
        ;a(href "/apps/furum/b/{(scow %p our)}/{(trip name)}"): {(trip name)}
      ==
      ;span.me: {" "}{(commafy post-count)} posts, {(commafy comment-count)} comments, {(commafy role-count)} roles, {paid-text}
    ==
  =/  boards-section=marl
    %+  welp
      :~  ;hr;
          ;h3: Hosted Boards
      ==
    board-rows
  ::  -- subscriptions overview --
  =/  sub-rows=marl
    ?~  cache-list
      :~  ;p.me: Not subscribed to any remote boards.
      ==
    %+  turn  cache-list
    |=  [host=@p name=board-name cb=cached-board]
    ^-  manx
    =/  post-count=@ud  ~(wyt by posts.cb)
    =/  paid-text=tape
      ?~  paid-until.cb  ""
      " | paid until {(trip (scot %da u.paid-until.cb))}"
    ;div(style "padding: 6px 0; border-bottom: 1px solid var(--line)")
      ;strong
        ;a(href "/apps/furum/b/{(scow %p host)}/{(trip name)}"): {(scow %p host)}/{(trip name)}
      ==
      ;span.me: {" "}{(commafy post-count)} cached posts{paid-text}
      ;form(method "post", action "/apps/furum/admin/resub", style "display:inline; margin-left: 8px")
        ;input(type "hidden", name "host", value (scow %p host));
        ;input(type "hidden", name "name", value (trip name));
        ;button.va(type "submit"): resub
      ==
    ==
  =/  subs-section=marl
    %+  welp
      :~  ;hr;
          ;h3: Remote Subscriptions
          ;p.me: Boards you follow on other computers.
      ==
    sub-rows
  ::  -- registry section (conditional) --
  =/  registry-section=marl
    ?.  is-registry  ~
    =/  admin-list=(list @p)  ~(tap in admins)
    =/  admin-rows=marl
      %+  turn  admin-list
      |=  who=@p
      ^-  manx
      ;tr
        ;td: {(scow %p who)}
        ;td
          ;form(method "post", action "/apps/furum/registry/remove-admin", style "display:inline")
            ;input(type "hidden", name "who", value "{(scow %p who)}");
            ;input.btn(type "submit", value "remove");
          ==
        ==
      ==
    =/  admin-table=manx
      ?.  (gth (lent admin-list) 0)
        ;p.me: No delegates added yet.
      ;table.mod
        ;thead
          ;tr
            ;th: Delegate
            ;th: Action
          ==
        ==
        ;tbody
          ;*  admin-rows
        ==
      ==
    =/  entry-rows=marl
      ?~  entries
        :~  ;p.me: No boards registered.
        ==
      %+  turn  entries
      |=  entry=directory-entry
      ^-  manx
      =/  tag-text=tape
        %+  roll  ~(tap in tags.entry)
        |=  [tag=@tas acc=tape]
        ?:(=(acc "") (trip tag) "{acc}, {(trip tag)}")
      =/  name-text=tape  (trip name.entry)
      ;div.rw
        ;div(style "width: 100%")
          ;span.ti: {(trip title.entry)}
          ;span.host: {" "}({(scow %p host.entry)})
          ;span.me: {" "}curated: {?:(curated.entry "yes" "no")} | tags: {?:(=(tag-text "") "none" tag-text)}
          ;div(style "margin-top: 4px")
            ;form(method "post", action "/apps/furum/registry/curate", style "display:inline")
              ;input(type "hidden", name "name", value name-text);
              ;input(type "hidden", name "curated", value ?:(curated.entry "false" "true"));
              ;input.btn(type "submit", value ?:(curated.entry "uncurate" "curate"));
            ==
            ;form(method "post", action "/apps/furum/registry/tag", style "display:inline; margin-left: 8px")
              ;input(type "hidden", name "name", value name-text);
              ;input(type "text", name "tag", placeholder "add tag", style "width: 100px");
              ;input.btn(type "submit", value "tag");
            ==
            ;+  ?.  (gth ~(wyt in tags.entry) 0)
                  ;span;
                ;span(style "margin-left: 8px")
                  ;*
                  %+  turn  ~(tap in tags.entry)
                  |=  tag=@tas
                  ^-  manx
                  ;form(method "post", action "/apps/furum/registry/untag", style "display:inline; margin-left: 4px")
                    ;input(type "hidden", name "name", value name-text);
                    ;input(type "hidden", name "tag", value (trip tag));
                    ;input.btn(type "submit", value "x {(trip tag)}");
                  ==
                ==
          ==
        ==
      ==
    %+  welp
    :~
      ;hr;
      ;h3: Registry Admin
      ;p.me: Manage board curation, tags, and delegate admins.
      ;h4: Delegate Admins
      ;p.me: These computers can curate and tag boards.
      ;form(method "post", action "/apps/furum/registry/add-admin")
        ;div
          ;label: computer (@p)
          ;br;
          ;input(type "text", name "who", required "", placeholder "~sampel-palnet");
        ==
        ;br;
        ;input.btn(type "submit", value "add delegate");
      ==
      admin-table
      ;hr;
      ;h4: Registered Boards
      ;form(method "post", action "/apps/furum/admin/refresh-registry", style "margin-bottom: 12px")
        ;input.btn(type "submit", value "Refresh All Subscribers");
        ;span.me: {" "}Kicks all directory subscribers so they re-sync.
      ==
    ==
    entry-rows
  ::  -- notifications section --
  =/  notif-js=@t
    '''
    (function(){
      var boxes=document.querySelectorAll(".notif-pref");
      if(!boxes.length)return;
      fetch("/apps/furum/push-prefs",{credentials:"include"})
      .then(function(r){return r.json()})
      .then(function(tags){
        boxes.forEach(function(cb){
          if(tags.indexOf(cb.value)!==-1)cb.checked=true;
        });
      }).catch(function(){});
      document.getElementById("notif-save").addEventListener("click",function(){
        var tags=[];
        boxes.forEach(function(cb){if(cb.checked)tags.push(cb.value)});
        fetch("/apps/furum/push-prefs",{
          method:"POST",credentials:"include",
          headers:{"Content-Type":"application/json"},
          body:JSON.stringify({tags:tags})
        }).then(function(){
          document.getElementById("notif-status").textContent="Saved!";
          setTimeout(function(){document.getElementById("notif-status").textContent=""},2000);
        });
      });
    })();
    '''
  =/  notif-script=manx  [[%script ~] [[[%$ [%$ (weld (trip push-js) (trip notif-js))] ~] ~] ~]]
  =/  notif-section=marl
    :~
      ;hr;
      ;h3: Notification Preferences
      ;h4: Push Notifications
      ;p.me: Enable browser push notifications to get alerts even when furum isn't open.
      ;button#push-toggle.btn(type "button", style "display:none"): Enable Push Notifications
      ;br;
      ;br;
      ;h4: Notification Types
      ;p.me: Choose which events you want to be notified about.
      ;div(style "margin: 12px 0")
        ;div(style "padding: 4px 0")
          ;label
            ;input.notif-pref(type "checkbox", value "comments");
            ;+  ;/(" Comments on my posts and replies to my comments")
          ==
        ==
        ;div(style "padding: 4px 0")
          ;label
            ;input.notif-pref(type "checkbox", value "new-posts");
            ;+  ;/(" New posts on boards I host")
          ==
        ==
        ;div(style "padding: 4px 0")
          ;label
            ;input.notif-pref(type "checkbox", value "payments");
            ;+  ;/(" New paid subscribers")
          ==
        ==
      ==
      ;button.btn(type "button", id "notif-save"): Save Preferences
      ;span(id "notif-status", style "margin-left: 12px; color: var(--muted)");
      notif-script
    ==
  ::  -- the directory this ship reads --
  =/  directory-section=marl
    :~  ;hr;
        ;h3: Board directory
        ;p.me: The home page lists the boards registered with {(scow %p registry)}.
        ;form(method "post", action "/apps/furum/admin/registry-ship")
          ;input(type "text", name "who", value "{(scow %p registry)}", required "");
          ;input.btn(type "submit", value "read the directory from this ship");
        ==
    ==
  ::  -- assemble page --
  =/  admin-content=marl
    ;:  welp
      :~  ;h3: Admin
          ;p.me: Computer-level administration for your furum instance.
          status-banner
      ==
      directory-section
      boards-section
      notif-section
      subs-section
      registry-section
    ==
  %-  page-shell
  :*  'furum - admin'  admin-content  ~  %.n  look  ==
::
::  ERROR PAGE
::
::  THEME PAGE: light or dark, talon's theme settings or furum's own
::  (saved themes of five colours, and an accent), with an editor
::
++  render-theme
  |=  $:  =look:th
          mode=mode:th
          talon=?
          talon-has=(unit [themes:th accent:th])
          own=themes:th
          accent=accent:th
          profile=(unit @ux)
          edit=(unit theme:th)
          msg=@t
      ==
  ^-  manx
  =/  swatches
    |=  t=theme:th
    ^-  marl
    %+  turn  ~[primary.t secondary.t tertiary.t background.t surface.t]
    |=(h=@t ;span.swatch(style "background: {(trip h)}");)
  =/  radio
    |=  [name=tape value=tape label=tape on=?]
    ^-  manx
    ?:  on
      ;label(style "margin-right: 16px")
        ;input(type "radio", name name, value value, checked "", onchange "this.form.submit()");
        ;+  ;/(" {label}")
      ==
    ;label(style "margin-right: 16px")
      ;input(type "radio", name name, value value, onchange "this.form.submit()");
      ;+  ;/(" {label}")
    ==
  =/  accent-text
    |=  a=accent:th
    ^-  tape
    ?.  =(`& on.a)  "off"
    ?-  how.a
      %brand    "the brand colour"
      %profile  "your %contacts profile colour"
      %custom   (trip (fall hex.a 'none'))
    ==
  =/  banner=manx
    ?:  =('' msg)  ;span;
    ;div.paywall-info
      ;p: {(trip msg)}
    ==
  =/  mode-section=manx
    ;div
      ;h4: Appearance
      ;form(method "post", action "/apps/furum/theme/mode")
        ;+  (radio "mode" "system" "System" =(%system mode))
        ;+  (radio "mode" "light" "Light" =(%light mode))
        ;+  (radio "mode" "dark" "Dark" =(%dark mode))
        ;noscript
          ;input.btn(type "submit", value "save");
        ==
      ==
      ;p.me: A theme you make brings its own light or dark; this is for the built-in one.
    ==
  =/  talon-section=manx
    ;div
      ;h4: Talon
      ;form(method "post", action "/apps/furum/theme/talon")
        ;label
          ;+  ?:  talon
                ;input(type "checkbox", name "on", checked "", onchange "this.form.submit()");
              ;input(type "checkbox", name "on", onchange "this.form.submit()");
          ;+  ;/(" Use talon's theme settings")
        ==
        ;input(type "hidden", name "sent", value "yes");
        ;noscript
          ;input.btn(type "submit", value "save");
        ==
      ==
      ;+  ?~  talon-has
            ;p.me: Talon keeps no theme settings on this computer yet (it keeps them in %settings), so furum uses its own below.
          =/  ts=themes:th  -.u.talon-has
          =/  in-use=tape
            ?~  a=(active:th ts)  "the built-in theme"
            "\"{(trip name.u.a)}\""
          ;p.me: Talon's settings here: {(a-co:co (lent list.ts))} saved themes, using {in-use}; accent {(accent-text +.u.talon-has)}. Change them in talon.
    ==
  =/  own-section=marl
    ?:  &(talon ?=(^ talon-has))
      :~  ;p.me: Furum's own themes and accent below are kept, for when talon's settings are off.
      ==
    =/  choices=marl
      :-  ;div
            ;+  (radio "id" "" "Built-in" ?=(~ active.own))
          ==
      %+  turn  list.own
      |=  t=theme:th
      ^-  manx
      ;div(style "margin: 4px 0")
        ;+  (radio "id" (trip id.t) (trip name.t) =(`id.t active.own))
        ;*  (swatches t)
        ;a(href "/apps/furum/theme?edit={(trip id.t)}", style "margin-left: 12px"): edit
      ==
    =/  hex-value=tape  (trip (fall hex.accent '#cc2020'))
    :~  ;h4: Themes
        ;form(method "post", action "/apps/furum/theme/use")
          ;*  choices
          ;noscript
            ;input.btn(type "submit", value "use");
          ==
        ==
        ;a.btn(href "/apps/furum/theme?edit=new", style "display: inline-block; text-decoration: none"): new theme
        ;h4: Accent
        ;p.me: Repaints the primary colour: the header, buttons and tags.
        ;form(method "post", action "/apps/furum/theme/accent")
          ;div
            ;+  (radio "how" "off" "Off" !=(`& on.accent))
            ;+  (radio "how" "profile" "Profile colour" &(=(`& on.accent) ?=(%profile how.accent)))
            ;+  (radio "how" "custom" "Custom" &(=(`& on.accent) ?=(%custom how.accent)))
          ==
          ;p.me
            ;+  ?~  profile  ;/("Your %contacts profile has no colour.")
                ;span
                  ;span.swatch(style "background: {(trip (hexa:th u.profile))}");
                  ;+  ;/("Your %contacts profile colour.")
                ==
          ==
          ;div
            ;input(type "color", name "hex", value hex-value);
            ;input.btn(type "submit", value "use this colour", style "margin-left: 8px");
          ==
        ==
    ==
  =/  editor=manx
    ?~  edit  ;span;
    =*  t  u.edit
    =/  pick
      |=  [name=tape label=tape value=@t]
      ^-  manx
      ;div(style "margin: 4px 0")
        ;input.pick(type "color", name name, value (trip value));
        ;+  ;/(" {label}")
      ==
    ;div(style "background: var(--surface); color: var(--on-surface); border: 1px solid var(--line-strong); padding: 12px; border-radius: 6px; margin: 12px 0")
      ;h4: {?:(=('' name.t) "New theme" "Edit {(trip name.t)}")}
      ;form(method "post", action "/apps/furum/theme/save")
        ;input(type "hidden", name "id", value (trip id.t));
        ;div
          ;input(type "text", name "name", value (trip name.t), placeholder "theme name", required "");
        ==
        ;div(style "margin: 8px 0")
          ;+  ?:  dark.t
                ;label(style "margin-right: 16px")
                  ;input(type "radio", name "dark", value "light");
                  ;+  ;/(" Light")
                ==
              ;label(style "margin-right: 16px")
                ;input(type "radio", name "dark", value "light", checked "");
                ;+  ;/(" Light")
              ==
          ;+  ?:  dark.t
                ;label
                  ;input(type "radio", name "dark", value "dark", checked "");
                  ;+  ;/(" Dark")
                ==
              ;label
                ;input(type "radio", name "dark", value "dark");
                ;+  ;/(" Dark")
              ==
        ==
        ;+  (pick "primary" "Primary" primary.t)
        ;+  (pick "secondary" "Secondary (links)" secondary.t)
        ;+  (pick "tertiary" "Tertiary" tertiary.t)
        ;+  (pick "background" "Background" background.t)
        ;+  (pick "surface" "Surface" surface.t)
        ;div#preview(style "margin: 12px 0; padding: 12px; border-radius: 8px")
          ;strong: Preview
          ;div#pv-surface(style "margin: 8px 0; padding: 8px; border-radius: 6px"): A post on a surface.
          ;span#pv-primary(style "padding: 4px 12px; border-radius: 4px"): Primary
          ;a#pv-link(href "#", style "margin-left: 12px"): a link
          ;span#pv-tertiary(style "margin-left: 12px"): tertiary
        ==
        ;input.btn(type "submit", value "save and use");
        ;a(href "/apps/furum/theme", style "margin-left: 12px"): cancel
      ==
      ;+  ?:  =('' name.t)  ;span;
          ;form(method "post", action "/apps/furum/theme/delete")
            ;input(type "hidden", name "id", value (trip id.t));
            ;input.btn(type "submit", value "delete this theme", style "background: var(--error); color: var(--on-error)");
          ==
      ;script: {(trip theme-preview-js)}
    ==
  %-  page-shell
  :*  'furum - theme'
      ;:  welp
        :~  ;h3: Theme
            banner
            mode-section
            ;hr;
            talon-section
            ;hr;
        ==
        own-section
        ~[editor]
      ==
      ~
      %.n
      look
  ==
::
::  the editor's preview: the picked colours, with ink or paper text on
::  each by luminance, as the theme will draw them
::
++  theme-preview-js
  ^-  @t
  '''
  (function(){
    function lin(c){c=c/255;return c<=0.04045?c/12.92:Math.pow((c+0.055)/1.055,2.4);}
    function lum(h){var n=parseInt(h.slice(1),16);return 0.2126*lin(n>>16&255)+0.7152*lin(n>>8&255)+0.0722*lin(n&255);}
    function on(h){return lum(h)>0.4?"#1c1917":"#fafaf9";}
    function v(n){return document.querySelector('input[name="'+n+'"]').value;}
    function paint(){
      var p=document.getElementById("preview");if(!p)return;
      p.style.background=v("background");p.style.color=on(v("background"));
      var s=document.getElementById("pv-surface");s.style.background=v("surface");s.style.color=on(v("surface"));
      var b=document.getElementById("pv-primary");b.style.background=v("primary");b.style.color=on(v("primary"));
      document.getElementById("pv-link").style.color=v("secondary");
      document.getElementById("pv-tertiary").style.color=v("tertiary");
    }
    document.querySelectorAll("input.pick").forEach(function(i){i.addEventListener("input",paint);});
    paint();
  })();
  '''

::
++  render-error
  |=  [msg=tape =look:th]
  ^-  manx
  %-  page-shell
  :*  'furum - error'
    :~  ;div.err
          ;h3: Error
          ;p: {msg}
          ;p
            ;a/"/apps/furum": back to home
          ==
        ==
    ==
    ~
    %.n
    look
  ==
::
::  LOADING PAGE: auto-refreshes to target URL
::
++  render-loading
  |=  [url=tape =look:th]
  ^-  manx
  =/  refresh=tape  "3;url={url}"
  ;html
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;meta(http-equiv "refresh", content refresh);
      ;title: furum - loading
      ;*  (theme-head look)
    ==
    ;body
      ;div.ct
        ;p.me: Loading board data...
        ;p.me
          ;a(href url): Retry
          ;+  ;/(" | ")
          ;a(href "/apps/furum"): Home
        ==
      ==
    ==
  ==
::
::  GUIDE PAGE (authenticated)
::
++  render-guide
  |=  =look:th
  ^-  manx
  %-  page-shell
  :*  'furum - guide'
    ^-  marl
    :~
      ;div
        ;h3: furum guide
        ;p.me: Everything you need to know to use furum, the decentralized forum on Urbit.
        ;hr;
        ;h3: What is furum?
        ;p
          ;+  ;/("furum is a forum that runs on ")
          ;a(href "https://urbit.org", target "_blank", rel "noopener noreferrer"): Urbit
          ;+  ;/(", a peer-to-peer computing network. Every board is hosted on someone's personal server — no corporation in the middle. Think Reddit or Hacker News, but decentralized and uncensorable.")
        ==
        ;p: Boards sync directly between Urbit computers. When you follow a board hosted by someone else, your computer subscribes to theirs and receives updates in real time. Your computer stores its own copy of the data, so you can browse even when the host is offline.
        ;hr;
        ;h3: Getting around
        ;h4: Feed
        ;p: Your home page shows two views — feed and directory. The feed shows recent posts from boards you follow, all in one stream. This is your main timeline.
        ;h4: Directory
        ;p: The directory lists all boards registered on the network. You can browse by tag or search for boards you're interested in. Curated boards are highlighted at the top.
        ;h4: Dark mode
        ;p: The "theme" link in the top-right corner of any page picks light, dark or your device's setting, and your own themes: five colours you choose, and an accent. If you use talon, furum follows the theme you picked there (turn that off on the same page).
        ;hr;
        ;h3: Boards
        ;h4: Following a board
        ;p: When you visit a board in the directory and click into it, your computer subscribes to that board's host. The board will then appear in your feed. You can unfollow from the board page.
        ;h4: Creating a board
        ;p
          ;+  ;/("Click ")
          ;strong: new board
          ;+  ;/(" in the top-right navigation to create a board. You'll choose a name (lowercase, no spaces — use hyphens), a display title, a description, and a default role for new visitors.")
        ==
        ;p: The default role determines what people can do when they first arrive:
        ;ul
          ;li
            ;strong: reader
            ;+  ;/(" — can view and vote, but not post")
          ==
          ;li
            ;strong: poster
            ;+  ;/(" — can view, vote, and submit posts (the most common default)")
          ==
          ;li
            ;strong: mod
            ;+  ;/(" — full moderator access (use sparingly)")
          ==
        ==
        ;h4: Public boards
        ;p: Boards can be set to public on the mod page. Public boards are viewable by anyone on the web — even people without Urbit. This is useful for making your community discoverable. Non-public boards require an Urbit computer and authentication to view.
        ;hr;
        ;h3: Posts and comments
        ;h4: Submitting a post
        ;p: From a board page, click "submit" to create a new post. Posts can be:
        ;ul
          ;li
            ;strong: Link posts
            ;+  ;/(" — a URL with an optional body. The title links to the URL.")
          ==
          ;li
            ;strong: Text posts
            ;+  ;/(" — a title and body with no external link. Good for discussions and questions.")
          ==
        ==
        ;p: If you paste an image URL, a preview thumbnail will appear on the board.
        ;h4: Commenting
        ;p: Click into any post to see comments and add your own. Comments support threading — click "reply" on any comment to respond directly to it. Nested comments are indented to show the conversation tree.
        ;h4: Voting
        ;p: Use the up/down arrows to vote on posts and comments. Votes are tied to your Urbit identity, so each computer gets one vote per item. You can change or remove your vote at any time.
        ;hr;
        ;h3: Moderation
        ;p: Board owners and moderators can manage their board from the mod page, accessible via the "mod" link on the board.
        ;h4: Roles
        ;p: Set roles for individual computers. Mods can delete posts and comments, pin posts, and manage the board. Posters can submit posts and comments. Readers can only view and vote.
        ;h4: Pinned posts
        ;p: Mods can pin posts so they always appear at the top of the board, regardless of sort order. Useful for rules, announcements, or FAQs.
        ;h4: Sidebar
        ;p: The mod page has a sidebar editor. The sidebar appears on the right side of the board and is a good place for rules, links, or a community description.
        ;h4: Board settings
        ;p: From the mod page you can edit the board title and description, toggle public visibility, and set the default role for new visitors.
        ;h4: Auto-prune
        ;p: Board hosts can enable automatic pruning to keep boards clean. Set a minimum score and a time window — posts older than the window with fewer upvotes than the minimum are automatically deleted. Pinned posts are never pruned. The system checks every 6 hours.
        ;p: Example: set minimum score to 2 and after to 7 days. Any post older than a week with fewer than 2 net upvotes gets automatically removed. Active discussions survive; dead posts disappear.
        ;h4: Registry
        ;p: Boards can be registered in the network directory so other users can discover them. From the mod page, click "Register in Directory" to register or re-register your board.
        ;hr;
        ;h3: Sorting
        ;p: Board posts can be sorted three ways using the toggle links at the top of the post list:
        ;ul
          ;li
            ;strong: hot
            ;+  ;/(" — a time-decay algorithm that rewards both recency and votes (the default)")
          ==
          ;li
            ;strong: new
            ;+  ;/(" — newest posts first, regardless of votes")
          ==
          ;li
            ;strong: top
            ;+  ;/(" — highest net votes first, all time")
          ==
        ==
        ;hr;
        ;h3: Paid boards
        ;p: Board owners can charge for access using Cashu ecash tokens or Lightning payments.
        ;h4: How it works
        ;p: On the mod page, enable payments by setting a price (in satoshis) and an access duration (e.g. 30 days). When a visitor arrives at a paid board, they see a paywall with payment options.
        ;h4: Paying with Lightning
        ;p: If the board owner has configured a Cashu mint URL, visitors can pay with Lightning. Click "Pay with Lightning," and the board generates a Lightning invoice. Pay from any Lightning wallet (Phoenix, Zeus, Wallet of Satoshi, etc.) and access is granted automatically once the payment confirms.
        ;h4: Paying with Cashu tokens
        ;p: Visitors can also paste Cashu ecash tokens directly. Get tokens from any Cashu wallet, paste them into the payment form, and submit.
        ;h4: Access duration
        ;p: Paid access lasts for the duration set by the board owner. When your access expires, you'll see the paywall again and can pay to renew. If you pay before expiry, the new time is added to your remaining time. Expired subscribers can still view their previously accessed content in read-only mode via a link on the paywall.
        ;h4: For board owners
        ;p: The mod page shows your token wallet balance and a list of paid subscribers with their expiry dates. You can withdraw tokens to a Lightning wallet using the "melt to Lightning" feature — paste a Lightning invoice and the mint will pay it using your collected tokens.
        ;hr;
        ;h3: Notifications
        ;p: furum has a notification panel and optional push notifications. Click "notifications" in the header to see all your recent activity — comments on your posts, replies to your comments, new posts on boards you host, and new paid subscribers. Each notification links directly to the relevant post.
        ;h4: Push notifications
        ;p: Enable push notifications from the admin page under Notification Preferences. Your browser will ask for permission. Once enabled, you'll receive push alerts even when furum isn't open. You can choose which categories of events trigger push notifications.
        ;p: Push notifications require HTTPS. They work in both the browser and the installed PWA.
        ;hr;
        ;h3: Admin page
        ;p: Click "admin" in the header to access computer-level administration. The admin page includes:
        ;ul
          ;li: Hosted Boards — overview of all boards you host with post and comment counts
          ;li: Notification Preferences — enable push notifications and choose which events trigger them
          ;li: Remote Subscriptions — see boards you follow with a resub button to fix stale connections
          ;li: Registry Admin — manage the network directory (registry host only)
        ==
        ;hr;
        ;h3: Data and backups
        ;p: All of your data lives on your Urbit computer, in grubbery's ball: each board you host is a folder under furum's app, and grubbery keeps the history of every change to it.
        ;h4: What is stored
        ;ul
          ;li
            ;strong: Boards you host
            ;+  ;/(" — posts, comments, votes, roles, pinned posts, sidebar and auto-prune settings, one folder per board")
          ==
          ;li
            ;strong: Your settings
            ;+  ;/(" — the boards you follow, dark mode, and which posts you have read")
          ==
        ==
        ;h4: Making a copy
        ;p: Download every board you host as one tar file:
        ;a(href "/grubbery/ball/apps/shell.shell/desks/furum.desk/desk/data/furum.furum_app/boards?download=tar"): download your boards
        ;p: Keep pier-level snapshots as a second layer of protection (e.g. GroundSeg daily snapshots).
        ;hr;
        ;h3: Tips
        ;ul
          ;li: You can install furum as a home-screen app on mobile (PWA). Use your browser's "Add to Home Screen" option.
          ;li: furum supports image uploads if your computer has S3 storage configured (via the Storage app). Otherwise, paste image URLs directly.
          ;li: Board names are permanent — pick a good one. Titles and descriptions can be changed later.
          ;li: Your Urbit identity (@p) is your username everywhere. No separate accounts needed.
          ;li: If a board host computer is offline, you can still browse your cached copy. Updates will sync when the host comes back.
        ==
      ==
    ==
    ~
    %.n
    look
  ==
::
::  ABOUT PAGE (public)
::
++  render-about
  |=  host=@p
  ^-  manx
  =/  host-p=tape  (scow %p host)
  %-  page-shell
  :*  'furum - about'
    ^-  marl
    :~
      ;div
        ;h3: What is furum?
        ;p
          ;+  ;/("furum is a decentralized forum that runs on ")
          ;a(href "https://urbit.org", target "_blank", rel "noopener noreferrer"): Urbit
          ;+  ;/(", a peer-to-peer computing network. Think Reddit or Hacker News, but every board is hosted on someone's personal server — no corporation in the middle.")
        ==
        ;h4: Why is this different?
        ;ul
          ;li: Self-hosted — every board lives on its owner's Urbit computer. Your content, your server, your rules.
          ;li: Uncensorable — no central authority can take down a board or ban a user from the network.
          ;li: Peer-to-peer — boards sync directly between computers. No cloud infrastructure required.
          ;li: Open source — furum is free software anyone can modify and redistribute.
        ==
        ;hr;
        ;h3: Install furum
        ;p: If you already have an Urbit computer running, you can install furum and start participating.
        ;h4: From your computer's dojo
        ;p: If you can reach this page, the host computer is distributing furum. Run this in your dojo:
        ;pre: |install {host-p} %furum
        ;p: That's it. Once installed, visit /apps/furum on your computer.
        ;h4: Self-hosted computer (Port, native, or CLI)
        ;ol
          ;li
            ;+  ;/("Make sure your computer is running and you can access the dojo (the command line in ")
            ;a(href "https://port.urbit.org", target "_blank", rel "noopener noreferrer"): Port
            ;+  ;/(", or your terminal).")
          ==
          ;li
            ;+  ;/("Run ")
            ;code: |install {host-p} %furum
          ==
          ;li: Visit your computer's URL at /apps/furum
        ==
        ;h4: Tlon hosted computer (tlon.network)
        ;ol
          ;li
            ;+  ;/("Log in to your computer at ")
            ;a(href "https://tlon.network", target "_blank", rel "noopener noreferrer"): tlon.network
          ==
          ;li: Open the Landscape app browser and search for furum, or use the dojo
          ;li
            ;+  ;/("In the dojo, run ")
            ;code: |install {host-p} %furum
          ==
          ;li: furum will appear in your app list
        ==
        ;hr;
        ;h4: Don't have Urbit yet?
        ;p
          ;+  ;/("Urbit is a personal server you own and control. Get started at ")
          ;a(href "https://urbit.org/overview/running-urbit", target "_blank", rel "noopener noreferrer"): urbit.org
          ;+  ;/(".")
        ==
      ==
    ==
    ~
    %.y
    ::  anyone's: the built-in look, as their device is set
    (draw:th %system ~ ~)
  ==
::
::  helper: role to text
::
++  role-to-text
  |=  =role
  ^-  @t
  ?-  role
    %mod     'moderator'
    %poster  'poster'
    %reader  'reader'
  ==
::
++  rank-list-offset
  |=  [posts=(list post) offset=@ud]
  ^-  (list [@ud post])
  =/  idx=@ud  +(offset)
  |-
  ?~  posts  ~
  [[idx i.posts] $(posts t.posts, idx +(idx))]
::
::  +parse-id: a post or comment id from a form, in plain digits.
::  dem:ag would refuse anything past 999 unless written "1.000".
::
++  parse-id
  |=  t=@t
  ^-  (unit @ud)
  (rush t dum:ag)
::
::  helper: parse vote target from form value
::  format: "post-{id}" or "comment-{post-id}-{comment-id}"
::
++  parse-vote-target
  |=  val=@t
  ^-  (unit vote-target)
  =/  t=tape  (trip val)
  ?:  =("post-" (scag 5 t))
    =/  id  (parse-id (crip (slag 5 t)))
    ?~  id  ~
    `[%post u.id]
  ?:  =("comment-" (scag 8 t))
    =/  rest=tape  (slag 8 t)
    =/  parts=(list tape)  (split-on rest '-')
    ?~  parts  ~
    ?~  t.parts  ~
    =/  post-id  (parse-id (crip i.parts))
    =/  cmt-id  (parse-id (crip i.t.parts))
    ?~  post-id  ~
    ?~  cmt-id  ~
    `[%comment u.post-id u.cmt-id]
  ~
--
