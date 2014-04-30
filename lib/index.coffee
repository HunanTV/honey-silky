_express = require 'express'
_http = require 'http'
_path = require 'path'
_app = _express()
_server = require('http').createServer _app
_io = require('socket.io').listen(_server, log: false)
_proxy = require('json-proxy')
_ = require 'underscore'
require 'colors'

_common = require './common'
_config = require SILKY.config

require('./router')(_app)    #设置路由

_app.set 'port', SILKY.port

try
    #集成代理
    cfgProxy = _config.proxy || {}
    cfgProxy.headers = _.extend cfgProxy.headers || {}, headers: 'X-Forwarded-User': 'Silky'

    _app.use _proxy.initialize(proxy: cfgProxy)
    _server.listen  _app.get('port')
catch e
    console.log "出错了 #{e.message}"
    process.exit 1

#监听socket的事件
_io.sockets.on 'connection', (socket)->
    event = 'page:change'
    #收到页面变更的事件后，通知客户端
    _common.addListener event, ()->
        socket.emit event, null

console.log '警告：80端口需要su权限'.red if _app.get('port') is '80'
console.log "请访问 http://localhost:#{_app.get 'port'}"