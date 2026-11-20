local M = {}

local server_job_id = nil
local server_port = nil
local server_dir = nil
local reload_pipe_path = nil

local function get_free_port(start_port)
  local port = start_port or 5500
  local check_script = [=[
import socket, sys
port = int(sys.argv[1])
while port < 6000:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    try:
        s.bind(('127.0.0.1', port))
        s.close()
        print(port)
        sys.exit(0)
    except OSError:
        port += 1
print(start_port)
]=]
  local res = vim.fn.system({ "python3", "-c", check_script, tostring(port) })
  local found = tonumber(vim.trim(res))
  return found or port
end

local function generate_python_server_script()
  return [=[
import os, sys, threading, urllib.parse
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

PORT = int(sys.argv[1])
DIRECTORY = sys.argv[2]
PIPE_PATH = sys.argv[3]

clients = []
clients_lock = threading.Lock()

RELOAD_SCRIPT = b'''
<script>
(function() {
  const evtSource = new EventSource("/__live_reload_events__");
  evtSource.onmessage = function(e) {
    if (e.data === "reload") {
      window.location.reload();
    }
  };
})();
</script>
'''

class LiveHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=DIRECTORY, **kwargs)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        if parsed.path == "/__live_reload_events__":
            self.send_response(200)
            self.send_header("Content-Type", "text/event-stream")
            self.send_header("Cache-Control", "no-cache")
            self.send_header("Connection", "keep-alive")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            with clients_lock:
                clients.append(self.wfile)
            try:
                while True:
                    self.wfile.write(b": keepalive\n\n")
                    self.wfile.flush()
                    threading.Event().wait(15)
            except Exception:
                with clients_lock:
                    if self.wfile in clients:
                        clients.remove(self.wfile)
            return

        path = self.translate_path(self.path)
        if os.path.isdir(path):
            index = os.path.join(path, "index.html")
            if os.path.exists(index):
                path = index

        if os.path.isfile(path) and path.endswith((".html", ".htm")):
            try:
                with open(path, "rb") as f:
                    content = f.read()
                lower = content.lower()
                idx = lower.rfind(b"</body>")
                if idx != -1:
                    content = content[:idx] + RELOAD_SCRIPT + content[idx:]
                else:
                    content = content + RELOAD_SCRIPT
                self.send_response(200)
                self.send_header("Content-Type", "text/html; charset=utf-8")
                self.send_header("Content-Length", str(len(content)))
                self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
                self.end_headers()
                self.wfile.write(content)
                return
            except Exception:
                pass

        super().do_GET()

    def end_headers(self):
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        super().end_headers()

    def log_message(self, format, *args):
        pass

def listen_pipe():
    while True:
        try:
            with open(PIPE_PATH, "r") as fifo:
                for line in fifo:
                    if "reload" in line:
                        with clients_lock:
                            dead = []
                            for w in clients:
                                try:
                                    w.write(b"data: reload\n\n")
                                    w.flush()
                                except Exception:
                                    dead.append(w)
                            for d in dead:
                                if d in clients:
                                    clients.remove(d)
        except Exception:
            break

t = threading.Thread(target=listen_pipe, daemon=True)
t.start()

ThreadingHTTPServer.allow_reuse_address = True
httpd = ThreadingHTTPServer(("127.0.0.1", PORT), LiveHandler)
httpd.serve_forever()
]=]
end

function M.start()
  if server_job_id then
    vim.notify("Live Server allaqachon ishlamoqda: http://127.0.0.1:" .. server_port, vim.log.levels.WARN)
    return
  end

  local current_file = vim.api.nvim_buf_get_name(0)
  if current_file == "" then
    vim.notify("Avval HTML faylni oching yoki saqlang!", vim.log.levels.ERROR)
    return
  end

  server_dir = vim.fs.dirname(current_file)
  local relative_path = vim.fs.basename(current_file)
  server_port = get_free_port(5500)

  reload_pipe_path = vim.fn.tempname() .. "_live_pipe"
  vim.fn.system({ "mkfifo", reload_pipe_path })

  local py_script = vim.fn.tempname() .. "_live_server.py"
  local f = io.open(py_script, "w")
  if f then
    f:write(generate_python_server_script())
    f:close()
  end

  server_job_id = vim.fn.jobstart({ "python3", py_script, tostring(server_port), server_dir, reload_pipe_path }, {
    on_exit = function()
      server_job_id = nil
      server_port = nil
      server_dir = nil
      pcall(vim.fn.delete, py_script)
      pcall(vim.fn.delete, reload_pipe_path)
    end,
  })

  if server_job_id <= 0 then
    server_job_id = nil
    vim.notify("Live Serverni ishga tushirib bo'lmadi!", vim.log.levels.ERROR)
    return
  end

  local url = string.format("http://127.0.0.1:%d/%s", server_port, relative_path)
  vim.notify("Live Server ishga tushdi: " .. url, vim.log.levels.INFO)

  -- Open browser
  vim.defer_fn(function()
    if vim.fn.executable("xdg-open") == 1 then
      vim.fn.jobstart({ "xdg-open", url }, { detach = true })
    end
  end, 300)
end

function M.stop()
  if not server_job_id then
    vim.notify("Live Server ishlamayapti.", vim.log.levels.INFO)
    return
  end
  vim.fn.jobstop(server_job_id)
  server_job_id = nil
  server_port = nil
  server_dir = nil
  vim.notify("Live Server to'xtatildi.", vim.log.levels.INFO)
end

function M.reload()
  if server_job_id and reload_pipe_path and vim.fn.filereadable(reload_pipe_path) == 1 then
    vim.fn.jobstart({ "bash", "-c", "echo reload > " .. vim.fn.shellescape(reload_pipe_path) }, { detach = true })
  end
end

function M.setup()
  vim.api.nvim_create_user_command("GoLive", function()
    M.start()
  end, { desc = "Start Live Server" })

  vim.api.nvim_create_user_command("GoLiveStop", function()
    M.stop()
  end, { desc = "Stop Live Server" })

  local live_group = vim.api.nvim_create_augroup("LiveServerAutoReload", { clear = true })

  vim.api.nvim_create_autocmd("BufWritePost", {
    group = live_group,
    pattern = { "*.html", "*.htm", "*.css", "*.js", "*.jsx", "*.ts", "*.tsx", "*.svg" },
    callback = function()
      M.reload()
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = live_group,
    callback = function()
      if server_job_id then
        pcall(vim.fn.jobstop, server_job_id)
      end
    end,
  })
end

return M
