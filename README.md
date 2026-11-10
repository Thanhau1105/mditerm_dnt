# VKU Student Management

Ứng dụng quản lý sinh viên của **Trần Thành Hậu**, xây dựng bằng Flutter Web/Android, Express và MongoDB Atlas.

Source: [Thanhau1105/mditerm_dnt](https://github.com/Thanhau1105/mditerm_dnt), nhánh `main`.

## Chức năng

- Đăng nhập, đăng xuất; quyền quản trị xác định bằng `ADMIN_EMAIL` trên server.
- Thêm, xem, sửa, xóa hồ sơ; tìm kiếm theo họ tên/email và sắp xếp họ tên.
- Chọn ảnh bằng `image_picker`, preview và lưu Base64 trực tiếp trong MongoDB.
- Giao diện tiếng Việt responsive: bảng/sidebar trên Web, card/FAB trên Android.
- Validation, loading, thông báo lỗi và xác nhận trước khi xóa.

Database `vku_student_management`, collection `users`, chỉ có bốn trường nghiệp vụ `email`, `matkhau`, `hoten`, `hinhanh` và `_id` hệ thống. Mật khẩu lưu dạng bcrypt; API không trả mật khẩu. Ảnh JPEG/PNG/WebP tối đa 2 MiB.

## Cấu trúc

```text
backend/     API Express, Mongoose, xác thực, seed/export và tests
frontend/    Flutter Web/Android, widget tests và integration test
database/    users.json gồm 5 tài khoản mẫu đã hash mật khẩu
scripts/     Các script PowerShell chạy backend, Web và Android
```

## Chuẩn bị

Cần Flutter/Dart, Node.js từ phiên bản 22, Chrome và Android SDK nếu chạy Android. Dự án hiện dùng Flutter 3.47.2 và Dart 3.13.2.

Tải source mới:

```powershell
git clone https://github.com/Thanhau1105/mditerm_dnt.git vku_student_management
cd vku_student_management
```

Tạo `backend/.env` từ `backend/.env.example`, điền URI Atlas bằng database user đã cấp quyền và IP Access List phù hợp. Compass là công cụ quản lý, còn backend kết nối Atlas trực tiếp qua URI.

```powershell
Copy-Item .\backend\.env.example .\backend\.env
```

Chỉ chạy lệnh sao chép nếu chưa có `.env`. Các biến cần cấu hình:

```dotenv
MONGODB_URI=<URI Atlas điền trực tiếp trên máy>
JWT_SECRET=<chuỗi ngẫu nhiên riêng dài ít nhất 32 byte>
ADMIN_EMAIL=hautt.23it@vku.udn.vn
PORT=3000
HOST=0.0.0.0
CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
```

Có thể sinh JWT secret trên máy bằng lệnh sau và chép kết quả vào `.env`:

```powershell
node -e "console.log(require('node:crypto').randomBytes(48).toString('hex'))"
```

Giữ URI, mật khẩu Atlas và JWT secret trong `.env`; tệp này được Git bỏ qua.

## Chạy backend

Terminal thứ nhất, từ thư mục gốc dự án:

```powershell
cd backend
npm.cmd ci
npm.cmd run seed
npm.cmd run dev
```

Seed thêm 5 email mẫu còn thiếu và giữ nguyên hồ sơ đã tồn tại. Khi backend sẵn sàng, `http://localhost:3000/api/health` trả trạng thái database đã kết nối.

Tài khoản quản trị mẫu sau khi seed:

- Email: `hautt.23it@vku.udn.vn`
- Mật khẩu: `Vku@123456`

Tài khoản sinh viên mẫu: `an.nguyen23@vku.udn.vn`, `binh.tran23@vku.udn.vn`, `chi.le23@vku.udn.vn`, `dung.pham23@vku.udn.vn`; cùng mật khẩu mẫu trên. Đây là dữ liệu học tập, cần đổi mật khẩu trước khi sử dụng dữ liệu thật.

## Chạy Flutter Web

Terminal thứ hai, từ thư mục gốc dự án:

```powershell
cd frontend
flutter pub get
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:3000/api
```

Giữ backend hoạt động trong khi dùng ứng dụng.

## Chạy Android

Từ thư mục `frontend`, mở máy ảo đã có sẵn rồi đợi Android khởi động:

```powershell
flutter emulators --launch Pixel_9_API_36
flutter devices
```

Nếu thiết bị có ID `emulator-5554`:

```powershell
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

Thay ID theo kết quả trên máy. Nếu máy ảo đã mở, bỏ qua lệnh `--launch`. `10.0.2.2` trỏ về máy tính host từ Android Emulator. Điện thoại thật dùng IPv4 Wi-Fi của máy chạy backend, ví dụ `http://192.168.1.10:3000/api`; hai thiết bị cần cùng LAN và firewall cho phép kết nối.

HTTP được bật trong bản debug/profile để phát triển cục bộ. Bản triển khai công khai cần backend HTTPS.

## Kiểm tra và build

```powershell
# Trong backend
npm.cmd test

# Trong frontend
flutter analyze
flutter test
flutter build web --dart-define=API_BASE_URL=http://localhost:3000/api
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

Backend tests dùng MongoDB tạm thật, tách biệt Atlas; lần chạy đầu có thể cần tải binary. Đã ghi nhận 14 backend tests và 17 Flutter tests đạt, analyzer sạch và build Web/APK thành công.

Kiểm thử tích hợp Android với backend/Atlas thật, chạy từ `frontend` sau khi backend và máy ảo đã sẵn sàng:

```powershell
flutter drive --driver=test_driver/atlas_driver.dart --target=integration_test/atlas_android_test.dart -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

Kịch bản dùng tài khoản mẫu, tạo một hồ sơ có email riêng và xóa chính hồ sơ đó sau kiểm tra; giữ các hồ sơ có sẵn. Ảnh chụp được lưu vào `frontend/build/integration_screenshots/`, được Git bỏ qua. Luồng này kiểm tra ảnh đọc từ Atlas; thao tác chọn trong gallery gốc là phần kiểm tra thủ công.

Sau integration test, build lại APK mặc định trước khi bàn giao vì bản test dùng entry point riêng.

## JSON database

`database/users.json` là bộ mẫu có thể import bằng Compass. Để xuất collection hiện tại từ Atlas, chạy trong `backend`:

```powershell
npm.cmd run export
```

Kết quả ở `database/users.export.json`, dùng Extended JSON để giữ ObjectId và bcrypt hash. Bản xuất riêng này được Git bỏ qua; nộp riêng khi môn học yêu cầu.

## API

Base URL: `http://localhost:3000/api`. API có xác thực dùng `Authorization: Bearer <token>`.

| Method | Đường dẫn | Quyền |
|---|---|---|
| GET | `/health` | Công khai |
| POST | `/auth/login` | Công khai |
| GET | `/auth/me` | Đã đăng nhập |
| GET | `/users?search=&sort=asc` | Quản trị |
| GET | `/users/:id` | Quản trị |
| POST | `/users` | Quản trị |
| PUT | `/users/:id` | Quản trị |
| DELETE | `/users/:id` | Quản trị |

Login nhận `email`, `matkhau`. Thêm/sửa nhận bốn trường nghiệp vụ. Khi sửa, mật khẩu rỗng giữ mật khẩu cũ. `sort` nhận `asc` hoặc `desc`. Backend kiểm tra quyền quản trị ở mỗi yêu cầu và bảo vệ tài khoản quản trị hiện tại khỏi tự xóa hoặc đổi email.
