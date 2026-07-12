# PQC Readiness Toolkit build commands

## Windows liboqs build
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_liboqs_windows.ps1
```

## Evidence generation
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/pqc_discovery.ps1
```

## Manifest build
```powershell
python scripts/pqc_report.py
```
