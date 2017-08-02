#!/usr/bin/env node
'use strict';

const csv = require('csv-parser');
const fs = require('fs');
const path = require('path');

const sourceFolder = process.argv[2];

function mkdirp(filepath) {
  const dirname = path.dirname(filepath);

  if (!fs.existsSync(dirname)) {
    mkdirp(dirname);
    fs.mkdirSync(dirname);
  }
}

fs.createReadStream(`${sourceFolder}/rewrites.csv`)
  .pipe(csv())
  .on('data', data => {
    const host = data.docs ? 'docs.buddybuild.com' : 'apidocs.buddybuild.com';
    const destination = `https://${host}/${data.docs || data.apidocs}`;
    const source = data.source.endsWith('.html') ? data.source : `${data.source}/index.html`;

    const sourcePath = `${sourceFolder}/_book/${source}`;
    mkdirp(sourcePath);
    fs.writeFileSync(sourcePath, `<meta http-equiv='refresh' content='0; url=${destination}'>`);
  });

