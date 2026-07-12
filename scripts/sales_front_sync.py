#!/usr/bin/env python3
"""PQC sales-front sync: consume upstream SKU manifest, localize to PQC SKUs."""
from pathlib import Path
import json

ART = Path(__file__).resolve().parents[1]/'.github'/'sales-front-sync.json'
ART.parent.mkdir(parents=True, exist_ok=True)
ART.write_text(json.dumps({'repo':'pqc-readiness-toolkit','sku_root':'ZQM-PQC-READINESS-001','tiers':['PQC-ASSESS','PQC-PILOT','PQC-RETAINER'],'price_usd':[350,800,500]},indent=2),encoding='utf-8')
print('Wrote',ART)
