/*
 * Copyright (c) 2013, Dmitriy Kapustin (dimanux), gemioli.com
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package com.gemioli.pomelo;

import com.gemioli.io.events.SocketEvent;
import com.gemioli.pomelo.events.PomeloEvent;
import haxe.Json;
import nme.events.EventDispatcher;
import com.gemioli.io.Socket;

class Pomelo extends nme.events.EventDispatcher
{
	public function new()
	{
		super();
		
		_requestId = 1;
		_callbacks = new Hash < Dynamic->Void > ();
	}

	public function init(options : Dynamic, ?callbackFunction : Void->Void = null) : Void
	{
		if (_socket != null)
		{
			dispatchEvent(new PomeloEvent(PomeloEvent.ERROR, "Pomelo client already inited."));
			return;
		}
		
		if (options.host == null)
		{
			dispatchEvent(new PomeloEvent(PomeloEvent.ERROR, "Set 'host' option to init Pomelo client."));
			return;
		}
		
		var url = options.host + (options.port == null ? "" : ":" + options.port);
		if (url.indexOf("://") == -1)
			url = "http://" + url;
			
		_socket = new Socket(url, options);
		
		_socket.addEventListener(SocketEvent.CONNECT, function(event : SocketEvent) : Void {
			dispatchEvent(new PomeloEvent(PomeloEvent.CONNECT));
			if (callbackFunction != null)
				callbackFunction();
		});
		
		_socket.addEventListener(SocketEvent.ERROR, function(event : SocketEvent) : Void {
			dispatchEvent(new PomeloEvent(PomeloEvent.ERROR, event.args.reason + " " + event.args.advice));
		});
		
		_socket.addEventListener(SocketEvent.DISCONNECT, function(event : SocketEvent) : Void {
			dispatchEvent(new PomeloEvent(PomeloEvent.DISCONNECT));
		});
		
		_socket.addEventListener(SocketEvent.MESSAGE, function(event : SocketEvent) : Void {
			var data : Dynamic;
			if (Std.is(event.args, String))
				data = Json.parse(event.args);
			else
				data = event.args;
			if (Std.is(data, Array))
				processMessageBatch(data);
			else
				processMessage(data);
		});
		
		_socket.connect();
	}
	
	public function disconnect() : Void
	{
		if (_socket != null)
		{
			_socket.disconnect();
			_socket = null;
		}
	}
	
	public function request(route : String, message : Dynamic, ?callbackFunction : Dynamic->Void = null) : Void
	{
		if (_socket == null)
		{
			dispatchEvent(new PomeloEvent(PomeloEvent.ERROR, "Can't send request - Pomelo client not connected."));
			return;
		}
		if (message == null)
			message = {}
		message = filter(message, route);
		var requestId = _requestId++;
		var messageString : String;
		try
		{
			messageString = PomeloProtocol.encode(requestId, route, message);
		}
		catch (e : Dynamic)
		{
			if (Std.is(e, String))
				dispatchEvent(new PomeloEvent(PomeloEvent.ERROR, e));
			return;
		}
		if (callbackFunction != null)
			_callbacks.set(Std.string(requestId), callbackFunction);
		_socket.send(messageString);
	}
	
	public function notify(route : String, message : Dynamic) : Void
	{
		request(route, message, null);
	}
	
	private function processMessage(message : Dynamic) : Void
	{
		if (message.id != null)
		{
			var id = Std.string(message.id);
			if (_callbacks.exists(id))
			{
				var func = _callbacks.get(id);
				_callbacks.remove(id);
				func(message.body);
			}
			return;
		}
		if (message.route != null)
		{
			if (message.body != null)
				dispatchEvent(new PomeloEvent(message.route, message.body.body == null ? message.body : message.body.body));
			else
				dispatchEvent(new PomeloEvent(message.route, message));
		}
		else
			dispatchEvent(new PomeloEvent(message.body.route, message.body));
	}
	
	private function processMessageBatch(messages : Dynamic) : Void
	{
		for (i in 0...messages.length)
			processMessage(messages[i]);
	}
	
	private function filter(message : Dynamic, route : String) : Dynamic
	{
		message.timestamp = Date.now().getTime();
		return message;
	}
	
	private var _socket : Socket;
	private var _requestId : Int;
	private var _callbacks : Hash < Dynamic->Void > ;
}

private class PomeloProtocol
{
	public static function encode(id : Int, route : String, message : Dynamic) : String
	{
		if (route.length > 255)
			throw "Route maxlength is overflow";
		
		var array = new Array<Int>();
		array.push((id >> 24) & 0xFF);
		array.push((id >> 16) & 0xFF);
		array.push((id >> 8) & 0xFF);
		array.push(id & 0xFF);
		array.push(route.length & 0xFF);
		for (i in 0...route.length)
			array.push(route.charCodeAt(i));
		var messageString = Json.stringify(message);
		for (i in 0...messageString.length)
			array.push(messageString.charCodeAt(i));
		return bt2Str(array, 0, array.length);
	}
	
	public static function decode(message : String) : PomeloMessage
	{
		var array = new Array<Int>();
		for (i in 0...message.length)
			array.push(message.charCodeAt(i));
		var id = (((array[0] & 0xFF) << 24) | ((array[1] & 0xFF) << 16) | ((array[2] & 0xFF) << 8) | (array[3] & 0xFF));
		var routeLength = array[4] & 0xFF;
		var route = bt2Str(array, 5, 5 + routeLength);
		var body = bt2Str(array, 5 + routeLength, array.length);
		return new PomeloMessage(id, route, body);
	}
	
	private static function bt2Str(array : Array<Int>, start : Int, end : Int) : String
	{
		var result = "";
		if (end > Std.int(array.length))
			end = Std.int(array.length);
		for (i in start...end)
			result += String.fromCharCode(array[i]);
		return result;
	}
}

private class PomeloMessage
{
	public var id : Int;
	public var route : String;
	public var body : String;
	
	public function new(id : Int, route : String, body : String)
	{
		this.id = id;
		this.route = route;
		this.body = body;
	}
}