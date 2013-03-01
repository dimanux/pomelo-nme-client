pomelo-nme-client
====================

Pomelo NME client extension.

###API:

Create and initialize a new Pomelo client:

```bat
import com.gemioli.pomelo.Pomelo;

// Somewhere in class code
var pomelo = new Pomelo();
pomelo.init({host : "localhost", port : "8080"}, function() : Void {
  trace("Pomelo connected");
});
```

Send request to the server and process data in callback:

```bat
pomelo.request(route, message, function(data : Dynamic) : Void {
  trace(data);
});
```

Notify the server:

```bat
pomelo.notify(route, message);
```

Receive a broadcast event:

```bat
import com.gemioli.pomelo.events.PomeloEvent;

pomelo.addEventListener(route, function(event : PomeloEvent) : Void {
  trace(event.data);
});
```

Disconnect from the server:

```bat
pomelo.disconnect();
```

###ToDo:
<ul>
<li>Optimizations</li>
</ul>

###Tested with HaXe 2.10, NME 3.5.5, HXCPP 2.10.3, nodejs 0.8.18 (or dotcloud) on platforms:
<ul>
<li>Flash 11</li>
<li>HTML5</li>
<li>Windows</li>
<li>Android</li>
<li>iOS (not tested)</li>
<li>Blackberry (not tested)</li>
</ul>

###Folders:
<ul>
<li>Extension - extension code</li>
<li>Project - example project files</li>
<li>Server - simple Pomelo server code (see [readme](https://github.com/dimanux/pomelo-nme-client/tree/master/Server))</li>
</ul>

###Example:
See [example](https://github.com/dimanux/pomelo-nme-client/blob/master/Project/Source/com/gemioli/ExtensionTest.hx)

###License:

(The MIT License)

Copyright (c) 2013, Dmitriy Kapustin (dimanux), gemioli.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
