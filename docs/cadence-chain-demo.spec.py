from pathlib import Path
from playwright.sync_api import sync_playwright

html = Path("/Users/samuel/Documents/The Final Journal AI.nosync/docs/cadence-chain-demo.html").resolve()
shot = Path("/tmp/cadence-chain-demo.png")

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page(viewport={"width": 780, "height": 1100})
    page.goto(html.as_uri())
    page.wait_for_selector(".chip.front")
    front = page.locator(".chip.front").inner_text().lower()
    assert "hoes know" in front, front
    assert "chain" in front, front
    page.screenshot(path=str(shot), full_page=True)
    page.fill("#setup", "i dont need a bitch,")
    page.wait_for_timeout(80)
    page.screenshot(path="/tmp/cadence-chain-demo-bitch.png", full_page=True)
    browser.close()
print("ok", shot)
