Pomelo server
====================

Simple Pomelo server for tests.

### To run locally:

1. Execute npm-install.bat
2. Execute run-game-server.bat
3. Execute run-web-server.bat
4. Open http://localhost:80/ and click "Test Game Server" button. You'll see "Hello from Pomelo server!" alert.

### To run on dotcloud.com:

1. Register on http://www.dotcloud.com and create new application via dashboard. For example, it will have a 'pomeloserver' name.
2. Follow instructions on dotcloud website to install CLI.
3. Open cygwin:

```bat
cd game-server
dotcloud connect pomeloserver
dotcloud push
```

Game server will start automatically and you can view logs via 'dotcloud logs' command.

4. Then create new application for web server. For example, it will have a 'pomeloclient' name.
5. Open web-server/index.html file and edit host of the game server to your game server host. In our example, it's pomeloserver-dimanux.dotcloud.com (pomeloserver-YOURNAME.dotcloud.com).
6. Open cygwin:

```bat
cd web-server
dotcloud connect pomeloclient
dotcloud env set NODE_ENV=production
dotcloud push
```

Visit you web server path like this http://pomeloclient-dimanux.dotcloud.com/

### License

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
