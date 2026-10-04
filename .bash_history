sudo apt update
sudo apt install -y niginx python3 curl
sudo apt install -y nginx python3 curl
sudo systemctl enable --now nginx
sudo mkdir -p /var/www/phase1 /var/www/phase2 /var/www/phase3
COLORS=("#1e88e5" "#43a047" "#e53935")
for i in 1 2 3; do  C=${COLORS[$((i-1))]}
 sudo tee /var/www/phase$i/index.html > /dev/null <<EOF<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<title>Phase $i</title>
<style>
body{margin:0;height:100vh;display:flex;align-items:center;
justify-content:center;font-family:Arial,sans-serif;
background:$C;color:#fff;text-align:center}
h1{font-size:7rem;margin:0}
p{font-size:1.4rem;margin:.4rem 0}
</style></head>
<body><div><h1>PHASE $i</h1>
<p>Served by web server $i (port 808$i)</p>
<p><b>Phase hit __PHIT__ of __PQ__ | Total hit __HIT__</b></p>
</div></body></html>
EOF
 done
/etc/nginx/conf.d/phase-backends.conf
server {
}
server {
}
server {
}
sudo mkdir -p /var/www/phase1 /var/www/phase2 /var/www/phase3
COLORS=("#1e88e5" "#43a047" "#e53935")
for i in 1 2 3; do   C=${COLORS[$((i-1))]}
  sudo tee /var/www/phase$i/index.html > /dev/null <<EOF<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8">
<title>Phase $i</title>
<style>
body{margin:0;height:100vh;display:flex;align-items:center;
justify-content:center;font-family:Arial,sans-serif;
background:$C;color:#fff;text-align:center}
h1{font-size:7rem;margin:0}
p{font-size:1.4rem;margin:.4rem 0}
</style></head>
<body><div><h1>PHASE $i</h1>
<p>Served by web server $i (port 808$i)</p>
<p><b>Phase hit __PHIT__ of __PQ__ | Total hit __HIT__</b></p>
</div></body></html>
EOF
 done
server {
}
server {
}
server {
}
sudo mkdir -p /opt/phase-counter
sudo tee /opt/phase-counter/counter.py > /dev/null <<'EOF'
#!/usr/bin/env python3
import json, os, threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
QUOTAS = [10, 5, 5] # hits accepted by Phase 1, Phase 2, Phase 3
HOST = os.environ.get("BIND", "127.0.0.1")
PORT = 9000
lock = threading.Lock()
total = 0 # hits handed out so far
def locate(n): # n = hits that happened BEFORE this one
 pos = n % sum(QUOTAS) # position inside the current cycle
 for i, quota in enumerate(QUOTAS):
 if pos < quota:
 return i + 1, pos + 1, quota # phase, hit in phase, quota
 pos -= quota
class Handler(BaseHTTPRequestHandler):
 def reply(self, code=200, body=b"", headers=None):
 self.send_response(code)
 for k, v in (headers or {}).items():
 self.send_header(k, v)
 self.send_header("Content-Length", str(len(body)))
 self.end_headers()
 if self.command != "HEAD":
 self.wfile.write(body)
 def do_GET(self):
 global total
 if self.path.startswith("/hit"):
 with lock:
 phase, ph, quota = locate(total)
 total += 1
 n = total
 self.reply(200, b"", {"X-Phase": "phase%d" % phase,
 "X-Hit": str(n), "X-Phase-Hit": str(ph),
 "X-Phase-Quota": str(quota)})
 elif self.path.startswith("/reset"):
 with lock:
 total = 0
 self.reply(200, b"counter reset\n")
 elif self.path.startswith("/status"):
 with lock:
 n = total
 phase, ph, quota = locate(n)
 info = {"hits_so_far": n, "next_hit": n + 1,
 "next_phase": phase, "next_phase_hit": ph,
 "quotas": QUOTAS}
 self.reply(200, (json.dumps(info) + "\n").encode())
 else:
 self.reply(404)
 do_HEAD = do_GET
 do_POST = do_GET
 def log_message(self, *args):
 pass
ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
EOF

sudo tee /etc/systemd/system/phase-counter.service > /dev/null <<'EOF'
[Unit]
Description=Phase hit counter
After=network.target
[Service]
ExecStart=/usr/bin/python3 /opt/phase-counter/counter.py
Restart=always
User=nobody
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable --now phase-counter
curl -s http://127.0.0.1:9000/status
curl -si http://127.0.0.1:9000/hit | grep -i "^x-"
