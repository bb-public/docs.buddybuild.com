#!/usr/bin/env node
'use strict';

const csv = require('csv-parser');
const fs = require('fs');
const path = require('path');

const sourceFolder = '.'
const host = 'docs.buddybuild.com'

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
    console.log("writing rewrite", data)
    const destination = `http://${host}/${data.docs}`;
    const source = data.source.endsWith('.html') ? data.source : `${data.source}/index.html`;
    const sourcePath = `${sourceFolder}/_book/${source}`;
    mkdirp(sourcePath);
    fs.writeFileSync(sourcePath, `<meta http-equiv='refresh' content='0; url=${destination}'>`);
  });

