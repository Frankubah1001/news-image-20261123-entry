# The World in Four Reports

[![make.fun competition](https://make.fun/badge/news-image-20261122.svg)](https://make.fun/c/news-image-20261122)
[![Rank](https://make.fun/badge/news-image-20261122/Frankubah1001/news-image-20261123-entry/rank.svg)](https://make.fun/c/news-image-20261122)
[![Reward](https://make.fun/badge/news-image-20261122/Frankubah1001/news-image-20261123-entry/reward.svg)](https://make.fun/c/news-image-20261122)

An original illustrated front page for Monday, 23 November 2026. It highlights
four developments from Belgium, Zambia, the United Kingdom and the Pacific,
using drawn scenes rather than reused news photographs.

## What is shown

- **Belgium:** A nationwide strike disrupted transport and grounded flights on
  Monday. The unions were protesting government austerity measures.
- **Zambia:** Reuters reports opposition leader Brian Mundubile was charged
  with plotting to overthrow the government. He denies guilt; the trial is
  expected next year.
- **United Kingdom:** The NHS began enrolling women in a three-year trial of
  AI-assisted mammogram reading. The study will assess the approach; it is not
  evidence that the tools are already proven to improve screening.
- **Mariana Trench:** A report published on 23 November describes ROV-collected
  samples of the deepest documented underwater pyroclastic rocks, found at
  6,148 metres.

## Sources

- [Al Jazeera: Anti-austerity strike disrupts transport across Belgium, 23 November 2026](https://www.aljazeera.com/news/2026/11/23/anti-austerity-strike-spurs-transport-chaos-across-belgium)
- [Reuters via Yahoo: Zambia opposition leader charged with attempting to overthrow government, 23 November 2026](https://www.yahoo.com/news/world/articles/zambia-opposition-leader-charged-attempting-122732673.html)
- [NHS England: First women join AI-assisted breast screening trial](https://www.england.nhs.uk/2026/11/first-women-join-world-leading-ai-assisted-nhs-breast-screening-trial/)
- [Phys.org, provided by Frontiers: Mariana Trench research, 23 November 2026](https://phys.org/news/2026-11-robot-submarine-exploring-world-deepest.html)

All artwork is drawn by `artwork.swift`; no photographs or third-party logos are
embedded.

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
