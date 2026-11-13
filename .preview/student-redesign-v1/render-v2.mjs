import { createRequire } from 'node:module';
const req = createRequire('A:/business/gb/server/package.json');
const puppeteer = req('puppeteer');

const url = 'file:///A:/business/sudaxam/.preview/student-redesign-v1/question-session-v2.html';
const out = 'A:/business/sudaxam/.preview/student-redesign-v1/';

const browser = await puppeteer.launch({ headless: 'new', executablePath: 'C:/Program Files/Google/Chrome/Application/chrome.exe', args: ['--no-sandbox', '--disable-setuid-sandbox', '--font-render-hinting=none'] });
try {
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 900, deviceScaleFactor: 2 });
  await page.goto(url, { waitUntil: 'networkidle0' });
  await page.screenshot({ path: out + 'question-session-v2.png', fullPage: true });
  console.log('desktop PNG written');

  await page.setViewport({ width: 430, height: 900, deviceScaleFactor: 2 });
  await page.goto(url, { waitUntil: 'networkidle0' });
  await page.screenshot({ path: out + 'question-session-v2-430.png', fullPage: true });
  console.log('narrow PNG written');
} finally {
  await browser.close();
}