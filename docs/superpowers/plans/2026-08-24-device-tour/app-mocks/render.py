#!/usr/bin/env python3
from pathlib import Path
from playwright.sync_api import sync_playwright

HERE = Path(__file__).resolve().parent
HTML = HERE / "mocks.html"
IDS = [
    "play", "clock", "syllables", "tap", "spark",
    "error", "ghost", "island", "suggest", "advanced",
]

def main():
    url = HTML.as_uri()
    chrome = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    with sync_playwright() as p:
        browser = p.chromium.launch(executable_path=chrome, headless=True)
        page = browser.new_page(
            viewport={"width": 420, "height": 900},
            device_scale_factor=3,
        )
        page.goto(url, wait_until="networkidle")
        page.wait_for_timeout(400)
        for sid in IDS:
            loc = page.locator(f"#{sid}")
            loc.scroll_into_view_if_needed()
            out = HERE / f"{sid}.png"
            loc.screenshot(path=str(out))
            print(f"wrote {out.name}")
        browser.close()

if __name__ == "__main__":
    main()
