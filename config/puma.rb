# Single-process threaded mode — ActionCable async adapter requires all
# WebSocket connections and broadcasts to share the same process memory.
# Cluster/forked workers each get their own in-memory pub/sub queue,
# so cross-worker broadcasts silently disappear.
max_threads = ENV.fetch("RAILS_MAX_THREADS") { 8 }
threads max_threads, max_threads

port        ENV.fetch("PORT") { 3000 }
environment ENV.fetch("RAILS_ENV") { "development" }
pidfile     ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

plugin :tmp_restart
