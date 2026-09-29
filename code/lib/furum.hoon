::  lib/furum.hoon: rendering and parsing helpers for %furum
::
/<  *   /lib/furum-types.hoon
/<  ca  /lib/cashu.hoon
|%
++  version  '0.5.2'
::
::  favicon SVG: digamma (Ϝ) on red background
::
++  furum-favicon-svg
  ^-  cord
  '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 32 32"><rect width="32" height="32" rx="6" fill="#cc2020"/><text x="16" y="24" font-family="serif" font-size="26" font-weight="bold" fill="#fff" text-anchor="middle">&#x03DC;</text></svg>'
::
::  icon image as base64 JPEG
::
++  furum-icon-b64
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
  '''
  * { box-sizing: border-box; }
  html, body { max-width: 100%; overflow-x: hidden; }
  body { font-family: Verdana, Geneva, sans-serif; font-size: 16px;
         color: #1a1a2e; background: #f0eee8; margin: 0; padding: 0;
         line-height: 1.55; }
  #hd { background: #cc2020; padding: 8px 16px; line-height: 32px; }
  #hd a { color: #fff; text-decoration: none; font-weight: bold;
           font-size: 18px; }
  #hd .nav { font-weight: normal; font-size: 16px; }
  #hd .nav a { color: #ffdede; font-weight: normal; font-size: 16px; }
  .ct { padding: 16px; max-width: 960px; overflow-wrap: break-word;
         word-wrap: break-word; }
  a { color: #8b1a1a; }
  .ti a { text-decoration: none; font-size: 18px; color: #1a1a2e; }
  .ti a:visited { color: #6a6a7a; }
  .host { font-size: 14px; color: #5a7a8a; overflow-wrap: break-word;
           word-break: break-all; }
  .me { color: #5a7a8a; font-size: 14px; padding-left: 5px; }
  .me a { color: #5a7a8a; }
  .cm { border-left: 2px solid #d0ccc4; padding-left: 12px;
         margin: 10px 0 10px 12px; }
  .cm-meta { color: #5a7a8a; font-size: 14px; margin-bottom: 5px; }
  .cm-meta a { color: #5a7a8a; }
  .va { color: #8a8a9a; cursor: pointer; border: none;
         background: none; padding: 0; font-size: 18px; }
  .va:hover { color: #cc2020; }
  .rw { padding: 5px 0; display: flex; align-items: baseline; }
  .rk { min-width: 24px; text-align: right; margin-right: 6px;
         color: #5a7a8a; font-size: 15px; flex-shrink: 0; }
  .rw > div { min-width: 0; flex: 1; }
  .score { display: inline; }
  textarea { width: 100%; max-width: 540px; height: 160px; font-family: monospace;
              font-size: 16px; }
  input[type=text], input[type=url] { width: 100%; max-width: 440px;
                                        font-size: 16px; padding: 5px; }
  .btn { margin-top: 10px; padding: 8px 24px; cursor: pointer;
          background: #cc2020; color: #fff; border: none; font-size: 16px; }
  .btn:hover { background: #a01818; }
  .post-body { padding: 12px 0; max-width: 100%; white-space: pre-wrap;
                font-size: 16px; line-height: 1.6; overflow-wrap: break-word;
                word-wrap: break-word; }
  table.mod { border-collapse: collapse; font-size: 16px; }
  table.mod td, table.mod th { padding: 8px 16px; text-align: left;
                                 border-bottom: 1px solid #d0ccc4; }
  .err { color: #cc2020; padding: 20px; font-size: 16px; }
  .sort { font-size: 14px; color: #5a7a8a; margin-bottom: 10px; }
  .sort a { color: #8b1a1a; text-decoration: none; }
  .sort a:hover { text-decoration: underline; }
  .sort strong { color: #1a1a2e; }
  .tag { font-size: 14px; color: #cc2020; margin-left: 2px; }
  .img-preview { margin: 4px 0 4px 0; font-size: 14px; }
  .img-preview summary { cursor: pointer; color: #5a7a8a; }
  .img-preview summary:hover { color: #8b1a1a; }
  .img-preview img { max-width: 100%; max-height: 512px; margin-top: 6px;
                      display: block; }
  .dark-toggle { float: right; font-size: 15px; }
  .dark-toggle button { background: none; border: none; cursor: pointer;
                         font-size: 15px; padding: 0; color: #ffdede; }
  body.dark { background: #0a0a14; color: #b8b8c8; }
  body.dark #hd { background: #1a0808; border-bottom: 1px solid #cc2020; }
  body.dark #hd a { color: #cc2020; }
  body.dark #hd .nav a { color: #8a6a6a; }
  body.dark #hd .dark-toggle button { color: #8a6a6a; }
  body.dark a { color: #5a8a9a; }
  body.dark .ti a { color: #d0d0dd; }
  body.dark .ti a:visited { color: #555568; }
  body.dark .host, body.dark .me, body.dark .cm-meta { color: #4a6a7a; }
  body.dark .me a, body.dark .cm-meta a { color: #4a6a7a; }
  body.dark .cm { border-left-color: #1e2838; }
  body.dark .va { color: #4a4a5a; }
  body.dark .va:hover { color: #cc2020; }
  body.dark .rk { color: #4a4a5a; }
  body.dark textarea, body.dark input[type=text], body.dark input[type=url],
  body.dark input[type=number], body.dark select { background: #141428; color: #b8b8c8; border: 1px solid #2a2a40; }
  body.dark input[type=checkbox] { accent-color: #cc2020; }
  body.dark .btn { background: #cc2020; color: #fff; border: none; }
  body.dark .btn:hover { background: #a01818; }
  body.dark table.mod td, body.dark table.mod th { border-bottom-color: #1e2838; }
  body.dark .err { color: #cc2020; }
  body.dark .sort { color: #4a6a7a; }
  body.dark .sort a { color: #5a8a9a; }
  body.dark .sort strong { color: #b8b8c8; }
  body.dark .pinned { background: #14140a; border-left-color: #cc2020; }
  body.dark .img-preview summary { color: #4a6a7a; }
  body.dark .img-preview summary:hover { color: #5a8a9a; }
  body.dark hr { border-color: #1e2838; }
  .pinned { background: #f5f0e0; border-left: 3px solid #cc2020; padding-left: 8px; }
  .pin-tag { font-size: 12px; color: #cc2020; font-weight: bold; text-transform: uppercase;
             margin-right: 8px; white-space: nowrap; }
  .upload-section { margin: 8px 0; }
  .upload-section input[type=file] { font-size: 14px; }
  .upload-btn { padding: 6px 16px; cursor: pointer; background: #cc2020;
                color: #fff; border: none; font-size: 14px; margin-left: 8px; }
  .upload-btn:hover { background: #a01818; }
  .upload-btn:disabled { background: #999; cursor: default; }
  .upload-status { font-size: 14px; color: #5a7a8a; margin-left: 8px; }
  .upload-err { font-size: 14px; color: #cc2020; margin-left: 8px; }
  .new-tag { font-size: 11px; color: #fff; background: #cc2020; padding: 1px 6px;
             border-radius: 3px; margin-left: 6px; font-weight: bold;
             text-transform: uppercase; vertical-align: middle; }
  .new-dot { display: inline-block; width: 8px; height: 8px; background: #cc2020;
             border-radius: 50%; margin-right: 4px; vertical-align: middle; }
  .cm-new { background: #fdf5e6; border-left-color: #cc8020; }
  body.dark .cm-new { background: #1a1808; border-left-color: #cc8020; }
  .board-layout { display: flex; gap: 24px; }
  .board-main { flex: 1; min-width: 0; }
  .board-sidebar { width: 280px; flex-shrink: 0; padding: 12px 16px;
                   background: #f6f0e8; border: 1px solid #ddd; border-radius: 4px;
                   font-size: 14px; line-height: 1.5; white-space: pre-wrap;
                   word-wrap: break-word; align-self: flex-start; }
  .board-sidebar h4 { margin: 0 0 8px 0; font-size: 14px; color: #828282; text-transform: uppercase; }
  .board-sidebar a { color: #cc2020; }
  body.dark .board-sidebar { background: #1a1e28; border-color: #2a3040; }
  body.dark .board-sidebar a { color: #f08080; }
  .mobile-sidebar { display: none; margin-bottom: 12px; font-size: 14px; }
  .mobile-sidebar summary { cursor: pointer; color: #828282; font-size: 13px; }
  .mobile-sidebar a { color: #cc2020; }
  body.dark .mobile-sidebar a { color: #f08080; }
  .paywall-status { font-size: 18px; font-weight: bold; color: #cc2020; }
  .paywall-info { background: #ffeeba; padding: 12px; border-radius: 6px; margin: 12px 0; font-size: 15px; }
  body.dark .paywall-info { background: #4a3c00; color: #ffeeba; }
  .tab-bar { display: flex; gap: 0; margin: 16px 0 0 0; border-bottom: 2px solid #ddd; }
  .tab-btn { padding: 8px 20px; border: 2px solid #ddd; border-bottom: none; background: #f5f5f5; cursor: pointer; font-size: 14px; font-weight: bold; border-radius: 6px 6px 0 0; margin-bottom: -2px; color: #666; }
  .tab-btn.active { background: #fff; border-bottom: 2px solid #fff; color: #333; }
  body.dark .tab-bar { border-bottom-color: #444; }
  body.dark .tab-btn { background: #2a2a2a; border-color: #444; color: #888; }
  body.dark .tab-btn.active { background: #1a1a1a; border-bottom-color: #1a1a1a; color: #ddd; }
  .pay-tab { padding: 16px 0; }
  .payment-form { margin-top: 0; }
  .payment-form label { font-weight: bold; font-size: 14px; }
  .payment-form select, .payment-form input[type="text"], .payment-form textarea {
    width: 100%; max-width: 500px; padding: 6px; font-size: 14px; }
  #token-summary { font-size: 13px; color: #666; margin-top: 4px; }
  #qr-scan-btn { margin-top: 8px; cursor: pointer; }
  #qr-overlay { display:none; position:fixed; top:0; left:0; width:100%; height:100%;
    background:rgba(0,0,0,0.9); z-index:9999; flex-direction:column;
    align-items:center; justify-content:center; }
  #qr-overlay.active { display:flex; }
  #qr-video { max-width:90%; max-height:60vh; border:3px solid #fff; border-radius:8px; }
  #qr-status { color:#fff; margin-top:12px; font-size:16px; }
  #qr-close-btn { margin-top:12px; padding:8px 24px; font-size:16px; cursor:pointer;
    background:#fff; border:1px solid #ccc; border-radius:4px; }
  .wallet-entry { background: #f0f9ff; border: 1px solid #bde; padding: 12px; border-radius: 6px; margin: 8px 0; }
  body.dark .wallet-entry { background: #1a2a3a; border-color: #345; }
  .wallet-entry p { margin: 4px 0; }
  .wallet-entry textarea { width: 100%; max-width: 500px; padding: 6px; font-size: 14px; }
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
  '''
  (function(){
    var btn=document.getElementById("push-toggle");
    if(!btn||!("PushManager" in window)||!("serviceWorker" in navigator))return;
    btn.style.display="inline";
    var sub=null;
    var swReady=navigator.serviceWorker.ready;
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
        var id=sub.endpoint.split("/").pop();
        fetch("/apps/furum/~web-pusher/unsubscribe",{
          method:"POST",credentials:"include",
          headers:{"Content-Type":"application/json"},
          body:JSON.stringify({id:"b-"+id})
        }).then(function(){return sub.unsubscribe()}).then(function(){
          sub=null;updateBtn(false);btn.disabled=false;
        }).catch(function(){btn.disabled=false;});
      } else {
        swReady.then(function(reg){
          return fetch("/apps/furum/~web-pusher/vapid-key",{credentials:"include"})
          .then(function(r){return r.text()})
          .then(function(key){
            var raw=atob(key.replace(/-/g,"+").replace(/_/g,"/"));
            var arr=new Uint8Array(raw.length);
            for(var i=0;i<raw.length;i++)arr[i]=raw.charCodeAt(i);
            return reg.pushManager.subscribe({userVisibleOnly:true,applicationServerKey:arr});
          });
        }).then(function(s){
          sub=s;
          var k=sub.toJSON();
          var id="b-"+k.endpoint.split("/").pop();
          return fetch("/apps/furum/~web-pusher/subscribe",{
            method:"POST",credentials:"include",
            headers:{"Content-Type":"application/json"},
            body:JSON.stringify({id:id,endpoint:k.endpoint,p256dh:k.keys.p256dh,auth:k.keys.auth})
          });
        }).then(function(){
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
::  page shell: wrap content in full HTML page
::
++  page-shell
  |=  [title=@t content=marl board-ctx=(unit [href=tape label=tape]) public=? dark=?]
  ^-  manx
  =/  style-node=manx
    [[%style ~] [[[%$ [%$ (trip furum-css)]~] ~] ~]]
  =/  sw-script=tape  (trip 'if("serviceWorker" in navigator)navigator.serviceWorker.register("/apps/furum/sw",{scope:"/apps/furum"});')
  =/  sw-node=manx
    [[%script ~] [[[%$ [%$ sw-script] ~] ~] ~]]
  =/  notif-count-js=tape
    (trip 'fetch("/apps/furum/notif-count",{credentials:"include"}).then(function(r){return r.json()}).then(function(d){var el=document.getElementById("notif-link");if(el&&d.count>0)el.textContent=d.count+" new"}).catch(function(){})')
  =/  notif-count-node=manx
    ?.  public  [[%script ~] [[[%$ [%$ notif-count-js] ~] ~] ~]]
    ;span;
  =/  body-attrs=mart
    ?:(dark ~[['class' "dark"]] ~)
  =/  toggle-label=tape
    ?:(dark "light" "dark")
  =/  nav-link=manx
    ?~  board-ctx
      ;a/"/apps/furum/create": new board
    ;a(href href.u.board-ctx): {label.u.board-ctx}
  =/  right-section=manx
    ?:  public
      ;span.dark-toggle
        ;a(href "/apps/furum/about", style "color: #ffdede; text-decoration: none; margin-right: 16px"): I Have Urbit
        ;a(href "https://urbit.org/overview/running-urbit", style "color: #ffdede; text-decoration: none", target "_blank", rel "noopener noreferrer"): Get on Urbit
      ==
    ;span.dark-toggle
      ;a#notif-link(href "/apps/furum/notifications", style "margin-right: 12px"): notifications
      ;a(href "/apps/furum/admin", style "margin-right: 12px"): admin
      ;a(href "/apps/furum/guide", style "margin-right: 12px"): guide
      ;form(method "post", action "/apps/furum/dark-mode", style "display:inline")
        ;button(type "submit"): {toggle-label}
      ==
    ==
  =/  hd-node=manx
    ;div#hd
      ;+  right-section
      ;+  ?:  public
            ;span(style "color: #fff; font-weight: bold; font-size: 18px"): furum
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
    ;div(style "text-align: center; padding: 16px; font-size: 12px; color: #8a8a9a")
      ;+  ;/("furum v{(trip version)}")
    ==
  =/  body-children=marl  ~[hd-node ct-node ft-node notif-count-node]
  =/  body-node=manx  [[%body body-attrs] body-children]
  ;html
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;meta(name "apple-mobile-web-app-capable", content "yes");
      ;meta(name "apple-mobile-web-app-status-bar-style", content "black-translucent");
      ;meta(name "theme-color", content ?:(dark "#1a0808" "#cc2020"));
      ;link(rel "manifest", href "/apps/furum/manifest");
      ;link(rel "apple-touch-icon", href "/apps/furum/icon");
      ;link(rel "icon", type "image/svg+xml", href "/apps/furum/favicon");
      ;title: {(trip title)}
      ;+  style-node
      ;+  sw-node
    ==
    ;+  body-node
  ==
::
::  HOME PAGE: board directory
::
++  render-feed
  |=  [feed=(list [host=@p board-name=board-name =post]) our=@p now=@da dark=? page=@ud board-seen=(map [@p board-name] @da)]
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
  :*  'furum'  [nav (weld post-rows ~[pag-nav])]  ~  %.n  dark  ==
::
++  render-home
  |=  [entries=(list directory-entry) view=?(%all %curated %tag) active-tag=(unit @tas) all-tags=(set @tas) is-registry=? dark=? boards-with-new=(set [@p board-name])]
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
  :*  'furum'  [nav board-rows]  ~  %.n  dark  ==
::
::  BOARD PAGE: list of posts
::
++  render-board
  |=  $:  host=@p  =board-info  posts=(list post)  our=@p  now=@da
          is-mod=?  authed=?  dark=?  sort=?(%hot %new %top)
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
  [(crip "furum - {(trip title.board-info)}") [header mobile-sidebar board-body ~] `[board-path (trip title.board-info)] !authed dark]
::
::  POST DETAIL PAGE: post with comments
::
++  render-post-page
  |=  [host=@p =board-info =post comments=(map comment-id comment) our=@p now=@da is-mod=? authed=? dark=? pinned=(set post-id) post-last-seen=(unit @da)]
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
  [(crip "furum - {(trip title.post)}") post-content `[board-path (trip title.board-info)] !authed dark]
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
  |=  [host=@p name=board-name dark=?]
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
    dark
  ==
::
::  SHARE TARGET PAGE: receive content from OS share sheet
::
++  render-share
  |=  [all-boards=(list [@p board-name]) share-title=@t share-url=@t share-text=@t dark=?]
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
    dark
  ==
::
::  EDIT POST FORM
::
++  render-edit-post
  |=  [host=@p name=board-name =post dark=?]
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
  [%'furum - edit post' content `[board-path (trip name)] %.n dark]
::
::  CREATE BOARD FORM
::
++  render-create
  |=  dark=?
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
    dark
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
  |=  [host=@p =board-info pay=payment-config expired=(unit @da) dark=? pending=?]
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
  [(crip "furum - {(trip name.board-info)} - payment required") paywall-content `[board-path (trip title.board-info)] %.n dark]
::
++  render-lightning-invoice
  |=  [host=@p =board-info pay=payment-config bolt11=(unit @t) dark=?]
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
      ;p(style "margin-top: 16px; color: #666"): Waiting for payment... This page will refresh automatically.
      ;+  refresh-node
    ==
  =/  content=marl
    :~  invoice-content
    ==
  %-  page-shell
  [(crip "furum - {(trip name.board-info)} - lightning payment") content `[board-path (trip title.board-info)] %.n dark]
::
++  render-mod
  |=  [host=@p =board-info roles=(map @p role) is-host=? dark=? sidebar=@t payment=(unit payment-config) wallet=(map @t (list cashu-proof)) pending-melt=? saved=@t paid=(map @p @da) now=@da prune=(unit prune-config)]
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
        ;input.btn(type "submit", value "delete board", style "background: #c00; color: #fff");
      ==
    ==
  =/  paid-list=(list [@p @da])
    %+  sort  ~(tap by paid)
    |=  [[a=@p da=@da] [b=@p db=@da]]
    (gth da db)
  =/  paid-section=manx
    ?.  is-host  ;span;
    ?~  payment  ;span;
    ?:  =(0 ~(wyt by paid))  ;span;
    ;div
      ;hr;
      ;h4: Paid Subscribers
      ;table(style "width: 100%; border-collapse: collapse")
        ;tr(style "text-align: left")
          ;th: Ship
          ;th: Paid Until
          ;th: Status
        ==
        ;*  %+  turn  paid-list
            |=  [who=@p until=@da]
            ;tr(style "border-top: 1px solid #ddd; padding: 4px 0")
              ;td: {(scow %p who)}
              ;td: {(scow %da until)}
              ;td: {?:((gth until now) "active" "expired")}
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
  [(crip "furum - mod {(trip name.board-info)}") mod-content `[board-path (trip title.board-info)] %.n dark]
::
::  NOTIFICATIONS PAGE
::
++  render-notifications
  |=  [notifs=(list notification) now=@da dark=?]
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
    =/  read-style=tape  ?:(read.n "color: #8a8a9a" "")
    ?~  url.n
      ;div(style "padding: 8px 0; border-bottom: 1px solid #d0ccc4; {read-style}")
        ;strong: {(trip title.n)}
        ;p.me: {(trip body.n)}
        ;span.me: {time-text}
      ==
    ;div(style "padding: 8px 0; border-bottom: 1px solid #d0ccc4; {read-style}")
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
  :*  'furum - notifications'  notif-content  ~  %.n  dark  ==
::
::  ADMIN PAGE
::
++  render-admin
  |=  $:  our=@p  dark=?
          boards-list=(list [board-name board])
          is-registry=?
          entries=(list directory-entry)
          admins=(set @p)
          subs-list=(list [@p board-name])
          cache-list=(list [@p board-name cached-board])
          msg=@t
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
    ;div(style "padding: 6px 0; border-bottom: 1px solid #d0ccc4")
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
    ;div(style "padding: 6px 0; border-bottom: 1px solid #d0ccc4")
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
      fetch("/apps/furum/~web-pusher/prefs",{credentials:"include"})
      .then(function(r){return r.json()})
      .then(function(tags){
        boxes.forEach(function(cb){
          if(tags.indexOf(cb.value)!==-1)cb.checked=true;
        });
      }).catch(function(){});
      document.getElementById("notif-save").addEventListener("click",function(){
        var tags=[];
        boxes.forEach(function(cb){if(cb.checked)tags.push(cb.value)});
        fetch("/apps/furum/~web-pusher/prefs",{
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
      ;span(id "notif-status", style "margin-left: 12px; color: #5a7a8a");
      notif-script
    ==
  ::  -- assemble page --
  =/  admin-content=marl
    ;:  welp
      :~  ;h3: Admin
          ;p.me: Computer-level administration for your furum instance.
          status-banner
      ==
      boards-section
      notif-section
      subs-section
      registry-section
    ==
  %-  page-shell
  :*  'furum - admin'  admin-content  ~  %.n  dark  ==
::
::  ERROR PAGE
::
++  render-error
  |=  [msg=tape dark=?]
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
    dark
  ==
::
::  LOADING PAGE: auto-refreshes to target URL
::
++  render-loading
  |=  [url=tape dark=?]
  ^-  manx
  =/  refresh=tape  "3;url={url}"
  =/  style-node=manx
    [[%style ~] [[[%$ [%$ (trip furum-css)]~] ~] ~]]
  ;html
    ;head
      ;meta(charset "utf-8");
      ;meta(name "viewport", content "width=device-width, initial-scale=1");
      ;meta(http-equiv "refresh", content refresh);
      ;title: furum - loading
      ;+  style-node
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
  |=  dark=?
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
        ;p: Click the "dark" / "light" toggle in the top-right corner of any page to switch between themes. Your preference is saved.
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
    dark
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
    %.n
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
