# liboqs Windows build

Script: `scripts/build_liboqs_windows.ps1`

Prerequisites:
- Visual Studio 2022 Build Tools or VS 2022
- CMake >= 3.20
- Git
- Optional: vcpkg, Ninja

Commands:
```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_liboqs_windows.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File scripts/build_liboqs_windows.ps1 -WithOpenSSLProvider
```

Outputs:
- `dist/liboqs/*.lib`
- `dist/liboqs/*.dll`
