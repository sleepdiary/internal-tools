#!/usr/bin/env node

// Server imports:
import http from 'http';

// Renderer imports:
import fs from 'fs';
import { remark } from 'remark';
import remarkPresetLintMarkdownStyleGuide from 'remark-preset-lint-markdown-style-guide';
import remarkLintMaximumLineLength from 'remark-lint-maximum-line-length';
import remarkHtml from 'remark-html';
import remarkGithub from 'remark-github';
import escape from 'escape-html';

const renderer = remark()
      .use(remarkPresetLintMarkdownStyleGuide)
      .use(remarkHtml)
      .use(remarkGithub, { repository: 'https://github.com/sleepdiary/some-project.git' } )
      .use(remarkLintMaximumLineLength,false)
;

const header = `<!DOCTYPE html>
<html>
<head>
<title>Markdown document</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
	.markdown-body {
		box-sizing: border-box;
		min-width: 200px;
		max-width: 980px;
		margin: 0 auto;
		padding: 45px;
	}

	@media (max-width: 767px) {
		.markdown-body {
			padding: 15px;
		}
	}
` + fs.readFileSync("node_modules/github-markdown-css/github-markdown.css") + `
</style>
</title>
<body>
<article class="markdown-body">
`;

const messages_header = `
<hr/>
<table>
<caption>Please fix the following issues</caption>
<thead>
<tr><td>Line</td><td>Column</td><td>ID</td><td>Reason</td></tr>
</thead>
<tbody>
`;

const messages_footer = `
</tbody>
</table>
`;

const footer = `
</article>
</body>
<script>
function refresh_if_changed() {
  var xhr = new XMLHttpRequest();
  xhr.addEventListener("load", () => {
    if ( xhr.status == 200 ) {
      location.reload();
    } else {
      refresh_if_changed();
    }
  });
  xhr.open("GET", window.location + '?watch=1');
  xhr.send();
}
refresh_if_changed();
</script>
</html>
`;

const server = http.createServer( (req,res) => {

    const watch = req.url.search(/[?&]watch=[^0&]/) != -1;
    const filename = [ '.md', '/README.md' ]
          .map( filename => `/app${req.url.replace(/\?.*/,'')}${filename}` )
          .find( fs.existsSync )
    ;

    if ( filename ) {
        if ( watch ) {
            let success = false,
                watcher = fs.watch(filename, { encoding: 'buffer' }, () => {
                    res.writeHead(200);
                    res.end("<xml>Changed</xml>\n");
                    success = true;
                });
            setTimeout(
                () => {
                    if ( !success ) {
                        res.writeHead(504);
                        res.end("<xml>Not changed</xml>\n");
                    }
                    watcher.close();
                },
                60000
            );
        } else {
            fs.readFile(filename, (err, data) => {
                if ( err ) {
                    res.writeHead(500);
                    res.end("Read error\n");
                } else {
                    renderer.process(data.toString()).then( file => {
                        let messages = file.messages.map( msg =>
                            `<tr><td>${msg.line}</td><td>${msg.column}</td><td>${msg.ruleId}</td><td>${escape(msg.reason)}</td></tr>`
                        );
                        if ( messages.length ) {
                            messages = messages_header + messages.join("\n") + messages_footer;
                        }
                        res.setHeader("Content-Type", "text/html; charset=utf-8");
                        res.writeHead(200);
                        res.end(
                            header
                                + String(file)
                                + messages
                                + footer
                        );
                    })
                }
            });
        }
    } else {
        res.writeHead(404);
        res.end("Not found\n");
    }

});

server.on('clientError', (err, socket) => socket.end('HTTP/1.1 400 Bad Request\r\n\r\n') );
server.listen(8082);
