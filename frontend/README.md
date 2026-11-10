# VKU Student Management — Flutter

Frontend Material 3 dùng chung cho Web và Android. Backend Express và MongoDB
được cấu hình ở thư mục `../backend`. Hướng dẫn đầy đủ: [README dự án](../README.md).

```powershell
flutter pub get
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:3000/api
```

Android Emulator dùng `--dart-define=API_BASE_URL=http://10.0.2.2:3000/api`.
Điện thoại thật dùng địa chỉ IPv4 LAN của máy chạy backend. Backend phải kết nối
MongoDB và seed dữ liệu trước khi đăng nhập; frontend không dùng dữ liệu giả.

```powershell
flutter analyze
flutter test
```
