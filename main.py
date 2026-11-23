import os
from pathlib import Path
import shutil


ROOT = Path(__file__).resolve().parent
OUTPUT = Path(os.environ.get("MAKEFUN_OUTPUT_DIR", "/output"))

OUTPUT.mkdir(parents=True, exist_ok=True)
shutil.copyfile(ROOT / "entry.png", OUTPUT / "entry.png")
