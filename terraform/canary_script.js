const synthetics = require('Synthetics');
const log = require('SyntheticsLogger');

const pageLoadBlueprint = async function () {

    const URL = 'https://project1.sergipratmerin.com';

    let page = await synthetics.getPage();

    const response = await synthetics.executeStep('navigate', async function () {
        return await page.goto(URL, {
            waitUntil: 'domcontentloaded',
            timeout: 30000
        });
    });

    if (!response) {
        throw new Error('Failed to load page: no response received');
    }

    const status = response.status();
    log.info(`HTTP status: ${status}`);

    if (status < 200 || status > 299) {
        throw new Error(`Page returned non-2xx status: ${status}`);
    }

    await synthetics.executeStep('verify-content', async function () {
        const bodyText = await page.evaluate(() => document.body.innerText);
        if (!bodyText || bodyText.length < 10) {
            throw new Error('Page body is empty or too short');
        }
        log.info(`Body length: ${bodyText.length} chars`);
    });

    await synthetics.takeScreenshot('loaded', 'success');
    log.info('Canary completed successfully');
};

exports.handler = async () => {
    return await pageLoadBlueprint();
};