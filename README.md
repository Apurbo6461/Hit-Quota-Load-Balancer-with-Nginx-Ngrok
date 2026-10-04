Here is the formatted Markdown text optimized directly for your `README.md` file on GitHub, including clean syntax highlighting and proper ASCII diagrams:

```markdown
# Hit-Quota Load Balancer: Nginx + Ngrok

A custom hit-quota-based load balancer implementation using Nginx, Python, and Ngrok.

Unlike traditional round-robin or least-connection algorithms that continuously cycle traffic, this load balancer routes requests based on strict hit quotas per phase:

- **Phase 1 (Blue):** Serves the first 10 hits (Hits 1–10).
- **Phase 2 (Green):** Serves the next 5 hits (Hits 11–15).
- **Phase 3 (Red):** Serves the next 5 hits (Hits 16–20).
- **Reset:** After 20 hits, the cycle restarts automatically at Phase 1.

---

## 🏗️ Architecture & How It Works

```text
                                  +-----------------------+
                                  |   Hit Counter (9000)  |
                                  |   Python HTTP Service |
                                  +-----------^-----------+
                                              |
                                   1) Ask     | 2) Reply
                                 Which Phase? | Phase/Stats
                                              |
+----------+      +--------------+      +-----+------+      +----------------------+
|  Public  | ---> | Ngrok Tunnel | ---> |    Nginx   | ---> | Phase 1 (10 hits)    |
| Visitors |      |  (Port 80)   |      | Load Bal.  |      +----------------------+
+----------+      +--------------+      |  (Port 80)  | ---> | Phase 2 (5 hits)     |
                                        +------------+      +----------------------+
                                                            | Phase 3 (5 hits)     |
                                                            +----------------------+

```

1. **Public Access:** Visitors access the site via the public Ngrok HTTPS URL.
2. **Phase Query:** Nginx pauses incoming requests using the native `auth_request` module and queries the internal Python Hit Counter at `127.0.0.1:9000/hit`.
3. **Quota Calculation:** The Hit Counter Service tracks global requests, calculates current phase/hit counters, and responds with custom HTTP headers (`X-Phase`, `X-Hit`, `X-Phase-Hit`, `X-Phase-Quota`).
4. **Proxy & Response Modification:** Nginx proxies the request to the corresponding backend server (Phase 1, Phase 2, or Phase 3) and injects live hit counters into the rendered HTML using `sub_filter`.

```

### Steps to update your README on GitHub:

<Steps>
  <Step subtitle="Terminal" title="Edit your local README.md">
    Open or create the `README.md` file in your project directory using your code editor or terminal:
    ```bash
    nano README.md
    ```
    Paste the markdown code block above into the file and save it.
    
    *Verification:* Run `cat README.md` to confirm the content is updated.
  </Step>

  <Step subtitle="Terminal" title="Commit and push the README to GitHub">
    Stage, commit, and push your updated README to your repository:
    ```bash
    git add README.md
    git commit -m "Update README with architecture diagram and project details"
    git push origin main
    ```
    *Verification:* Refresh your repository page on GitHub to verify the formatted README displays correctly with diagram rendering.
  </Step>
</Steps>

<Elicitations message="What would you like to do next?">
  <Elicitation label="Add installation guide" query="Can you help me add an Installation & Usage section to the README?"/>
  <Elicitation label="Add Nginx config sample" query="Can you help me write an Nginx configuration snippet for the README?"/>
</Elicitations>

```
