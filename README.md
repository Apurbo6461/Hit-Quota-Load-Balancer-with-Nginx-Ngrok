Hit-Quota Load Balancer: Nginx + NgrokA custom hit-quota-based load balancer implementation using Nginx, Python, and Ngrok.   Unlike traditional round-robin or least-connection algorithms that continuously cycle traffic, this load balancer routes requests based on strict hit quotas per phase:   Phase 1 (Blue): Serves the first 10 hits (Hits 1–10).   Phase 2 (Green): Serves the next 5 hits (Hits 11–15).   Phase 3 (Red): Serves the next 5 hits (Hits 16–20).   After 20 hits, the cycle restarts automatically at Phase 1.   🏗️ Architecture & How It Works                                  +-----------------------+
                                  |   Hit Counter (9000)  |
                                  |   Python HTTP Service |
                                  +-----------^-----------+
                                              |
                                   1) Ask     | 2) Reply
                                   Which Phase? | Phase/Stats
                                              |
+----------+      +--------------+      +-----+------+      +----------------------+
|  Public  | ---> |  Ngrok Tunnel| ---> |    Nginx   | ---> | Phase 1 (10 hits)    |
| Visitors |      |  (Port 80)   |      | Load Bal.  |      +----------------------+
+----------+      +--------------+      |  (Port 80)  | ---> | Phase 2 (5 hits)     |
                                        +------------+      +----------------------+
                                                            | Phase 3 (5 hits)     |
                                                            +----------------------+
Visitors access the site via the public Ngrok HTTPS URL.   Nginx pauses incoming requests using the native auth_request module and queries the internal Python Hit Counter at 127.0.0.1:9000/hit.   Hit Counter Service tracks global requests, calculates current phase/hit counters, and responds with custom headers (X-Phase, X-Hit, X-Phase-Hit, X-Phase-Quota).   Nginx proxies the request to the corresponding backend server (Phase 1, Phase 2, or Phase 3) and injects live hit counters into the rendered HTML using sub_filter.   
