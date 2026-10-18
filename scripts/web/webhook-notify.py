#!/usr/bin/env python3

import base64
import hmac
import json
import os
import subprocess
import sys
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

import dbus
import dbus.mainloop.glib
from gi.repository import GLib

AUTH_PATH = os.path.expanduser("~/.config/webhook-notify/auth")
MAX_BODY = 16 * 1024
PORT = int(os.environ.get("WEBHOOK_NOTIFY_PORT", "8787"))


def load_auth():
    user = os.environ.get("WEBHOOK_NOTIFY_USER")
    password = os.environ.get("WEBHOOK_NOTIFY_PASS")
    if user and password:
        return user, password
    if not os.path.exists(AUTH_PATH):
        sys.stderr.write(f"webhook-notify: missing auth config at {AUTH_PATH}\n")
        sys.exit(1)
    raw = open(AUTH_PATH).read().strip()
    if ":" not in raw:
        sys.stderr.write(f"webhook-notify: auth config must be 'user:password'\n")
        sys.exit(1)
    u, p = raw.split(":", 1)
    return u, p


AUTH_USER, AUTH_PASS = load_auth()

URGENCIES = {"low", "normal", "critical"}
URGENCY_LEVELS = {"low": 0, "normal": 1, "critical": 2}


def notify_async(title, body, urgency, icon, expire_ms, url):
    def run():
        dbus.mainloop.glib.DBusGMainLoop(set_as_default=True)
        bus = dbus.SessionBus()
        proxy = bus.get_object("org.freedesktop.Notifications", "/org/freedesktop/Notifications")
        iface = dbus.Interface(proxy, "org.freedesktop.Notifications")
        actions = ["default", "Open URL"] if url else []
        hints = {
            "urgency": dbus.Byte(URGENCY_LEVELS[urgency]),
            "desktop-entry": dbus.String("webhook-notify"),
        }
        timeout = int(expire_ms) if isinstance(expire_ms, int) and expire_ms > 0 else 0

        loop = GLib.MainLoop()
        nid_box = {"id": None}
        clicked = {"yes": False}

        def on_action(nid, key):
            if nid == nid_box["id"] and key == "default":
                clicked["yes"] = True
                loop.quit()

        def on_closed(nid, reason):
            if nid == nid_box["id"]:
                loop.quit()

        nid_box["id"] = iface.Notify("Webhook", 0, icon or "", title, body, actions, hints, timeout)
        bus.add_signal_receiver(on_action, signal_name="ActionInvoked",
                                dbus_interface="org.freedesktop.Notifications")
        bus.add_signal_receiver(on_closed, signal_name="NotificationClosed",
                                dbus_interface="org.freedesktop.Notifications")

        try:
            loop.run()
        except Exception:
            pass

        if clicked["yes"] and url:
            subprocess.Popen(["xdg-open", url])

    t = threading.Thread(target=run, daemon=True)
    t.start()


class Handler(BaseHTTPRequestHandler):
    server_version = "webhook-notify"

    def log_message(self, fmt, *args):
        sys.stderr.write(f"{self.address_string()} - {fmt % args}\n")

    def _check_auth(self):
        header = self.headers.get("Authorization", "")
        if not header.startswith("Basic "):
            return False
        try:
            decoded = base64.b64decode(header[6:]).decode("utf-8", "replace")
        except Exception:
            return False
        if ":" not in decoded:
            return False
        u, p = decoded.split(":", 1)
        return hmac.compare_digest(u, AUTH_USER) and hmac.compare_digest(p, AUTH_PASS)

    def _deny(self):
        self.send_response(401)
        self.send_header("WWW-Authenticate", 'Basic realm="webhook-notify"')
        self.send_header("Content-Type", "text/plain")
        self.end_headers()
        self.wfile.write(b"unauthorized\n")

    def do_GET(self):
        if self.path.split("?", 1)[0] == "/health":
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(b"ok\n")
            return
        self.send_error(404)

    def do_POST(self):
        if self.path.split("?", 1)[0] != "/notify":
            self.send_error(404)
            return
        if not self._check_auth():
            self._deny()
            return
        try:
            length = int(self.headers.get("Content-Length") or 0)
        except ValueError:
            self.send_error(400, "bad Content-Length")
            return
        if length <= 0 or length > MAX_BODY:
            self.send_error(413 if length > MAX_BODY else 400)
            return
        try:
            payload = json.loads(self.rfile.read(length))
        except json.JSONDecodeError:
            self.send_error(400, "invalid JSON")
            return
        if not isinstance(payload, dict):
            self.send_error(400, "JSON must be an object")
            return
        title = str(payload.get("title", "")).strip()
        body = str(payload.get("body", "")).strip()
        urgency = str(payload.get("urgency", "normal")).strip()
        icon = payload.get("icon")
        expire_ms = payload.get("expire_ms")
        url = payload.get("url")
        if isinstance(url, str):
            url = url.strip() or None
        else:
            url = None
        if not title and not body:
            self.send_error(400, "title or body required")
            return
        if urgency not in URGENCIES:
            urgency = "normal"
        notify_async(
            title or "Notification",
            body or title,
            urgency,
            icon if isinstance(icon, str) else "",
            expire_ms,
            url,
        )
        self.send_response(204)
        self.end_headers()


def main():
    server = ThreadingHTTPServer(("0.0.0.0", PORT), Handler)
    sys.stderr.write(f"webhook-notify listening on 0.0.0.0:{PORT} as user '{AUTH_USER}'\n")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
