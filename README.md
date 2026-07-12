# ZQM PQC Readiness Toolkit
NIST/ETSI/CNSA 2.0 post-quantum cryptography readiness methodology for Windows fleets.

SKU: `ZQM-PQC-READINESS-001`
License: Apache-2.0 (tooling); commercial deliverables sold separately.

## What this is
- Methodology: 11-standard map covering NIST FIPS 203/204/205/206, SP 800-131A Rev.3, SP 800-57 Part 1, SP 800-52 Rev.2, SP 800-204, SP 800-161, NSA CNSA 2.0, and ETSI TS 103 712.
- PowerShell discovery module: CNG certs, Schannel/TLS, BitLocker, smart-card logon, code-signing, CA trust stores.
- Evidence pack: JSON + text artifacts with SHA-256 ledger.
- Deliverable template: CMS-signed readiness report + migration roadmap.

## Sellable SKU tiers
- `PQC-ASSESS` $350/endpoint: discovery + CMS-signed readiness report
- `PQC-PILOT` $800/endpoint: assessment + 1 staged hybrid profile
- `PQC-RETAINER` $500–$2000/mo: quarterly reassessment + roadmap updates

## Repo shape
- `templates/standards_matrix.md`
- `templates/attestation_report.md`
- `scripts/pqc_discovery.ps1`
- `scripts/pqc_report.py`
- `sku-bundle.md`

## Commercial contact
zqmcomputing@gmail.com

## Native Windows build
Build OpenQuantumSafe/liboqs on Windows via MSVC/CMake:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_liboqs_windows.ps1
```
See `docs/liboqs-windows-build.md`.
