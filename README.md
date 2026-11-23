# The World in Four Fronts

[![make.fun competition](https://make.fun/badge/news-image-20261123.svg)](https://make.fun/c/news-image-20261123)
[![Rank](https://make.fun/badge/news-image-20261123/Frankubah1001/news-image-20261123-entry/rank.svg)](https://make.fun/c/news-image-20261123)
[![Reward](https://make.fun/badge/news-image-20261123/Frankubah1001/news-image-20261123-entry/reward.svg)](https://make.fun/c/news-image-20261123)

An original illustrated front page for Monday, 23 November 2026. It brings
together four reports across conflict, markets and science, with the claims
attributed to their sources and no reused news photographs.

## What is shown

- **Ukraine:** The Guardian reports at least 11 killed in the strike on an
  apartment building in Dymer and a continuing rescue search.
- **Sudan:** The UN reported a drone attack on a residential area in Khartoum
  and damage to a UN building. The report did not identify an attacker or
  provide casualty details.
- **Markets:** The Associated Press reports Asian shares mostly lower amid an
  AI-stock sell-off, while US futures rose.
- **Science:** A remotely operated vehicle's Mariana Trench samples included
  the deepest documented underwater pyroclastic rocks, found at 6,148 metres.
- **Also Monday:** The Associated Press reports CrowdStrike's planned $44
  billion all-stock acquisition of Zscaler.

## Sources

- [The Guardian: Ukraine war briefing, 23 November 2026](https://www.theguardian.com/world/2026/nov/23/ukraine-war-briefing-race-to-find-survivors-after-russian-attack-on-apartment-block-kills-at-least-nine)
- [Bernama / dpa: UN reports attack in Khartoum, 23 November 2026](https://www.bernama.com/en/news.php?id=2638032)
- [Associated Press: Markets and CrowdStrike-Zscaler deal](https://apnews.com/article/stocks-markets-rates-technology-ai-anthropic-49ba1beba78fa4ed2bd5898029f79c91)
- [Phys.org, provided by Frontiers: Mariana Trench research, 23 November 2026](https://phys.org/news/2026-11-robot-submarine-exploring-world-deepest.html)

All artwork is drawn by `artwork.swift`; no photographs or logos are embedded.

## Build and run

Regenerate the image on macOS with Swift:

```sh
swift artwork.swift entry.png
```

Run the entry with Python 3.13 or later and the standard library:

```sh
mkdir -p out
MAKEFUN_OUTPUT_DIR=out python3 main.py
```

The program copies `entry.png` to the output directory without network access.
For a GitHub submission, set the repository About website to
`https://make.fun/c/news-image-20261123` and add the `makefun` topic.
