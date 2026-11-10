# VKU Student Management System

Source code: [Thanhau1105/mditerm_dnt](https://github.com/Thanhau1105/mditerm_dnt), nhánh `main`.

Ứng dụng quản lý sinh viên cho bài giữa kỳ môn **Lập trình Đa nền tảng**. Sinh viên thực hiện: **Trần Thành Hậu**.

Flutter dùng chung mã nguồn cho Web và Android. Backend Express xác thực, kiểm tra quyền và đọc/ghi MongoDB qua Mongoose. Compass dùng để kiểm tra dữ liệu trên Atlas; frontend chỉ gọi REST API.

## Chức năng

- Đăng nhập bằng email/mật khẩu, ẩn/hiện mật khẩu và đăng xuất.
- Dashboard quản trị, tổng số hồ sơ, tìm kiếm họ tên/email và sắp xếp tên.
- Thêm, xem, sửa và xóa sinh viên; xác nhận trước khi xóa.
- Chọn ảnh bằng `image_picker`, xem trước và lưu Base64 trong MongoDB.
- Giao diện Material 3 tiếng Việt; bảng có sidebar trên màn hình rộng, thẻ trên điện thoại.
- Loading, thông báo lỗi, thông báo lưu/xóa và trạng thái danh sách trống.
- Quyền quản trị đối chiếu `ADMIN_EMAIL` ở backend; không thêm `role` vào collection.

## Cấu trúc

```text
vku_student_management/
├── backend/                 # API Express, Mongoose, JWT, seed/export và kiểm thử
│   ├── config/
│   ├── controllers/
│   ├── middleware/
│   ├── models/
│   ├── routes/
│   ├── scripts/
│   ├── tests/
│   ├── .env.example
│   ├── package.json
│   └── server.js
├── frontend/                # Flutter Android + Web
│   ├── android/
│   ├── web/
│   ├── lib/
│   │   ├── models/
│   │   ├── services/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── main.dart
│   └── pubspec.yaml
├── database/
│   └── users.json           # 5 hồ sơ mẫu, mật khẩu đã hash, import được bằng Compass
├── scripts/                 # Các lệnh chạy nhanh bằng PowerShell
├── .vscode/                 # Tasks cho VS Code
└── docs/
    ├── ATLAS_COMPASS.md
    ├── BAO_CAO.md
    ├── DEMO.md
    └── CHECKLIST_NOP_BAI.md
```

## Chạy trên Windows bằng PowerShell

Các lệnh dưới đây dùng thư mục dự án `D:\HK7\DNT\Midterm\vku_student_management`. Nếu đặt source ở nơi khác, thay đường dẫn tương ứng. Flutter, Dart, Node.js và Compass đã có sẵn; không cần cài lại.

### 1. Điền kết nối Atlas trên máy

Mở source trong VS Code:

```powershell
Set-Location -LiteralPath 'D:\HK7\DNT\Midterm\vku_student_management'
code .
```

Nếu chưa có `.env`, tạo từ mẫu:

```powershell
if (-not (Test-Path -LiteralPath '.\backend\.env')) {
    Copy-Item -LiteralPath '.\backend\.env.example' -Destination '.\backend\.env'
}
code .\backend\.env
```

Điền `MONGODB_URI` bằng URI **Drivers / Node.js** của Atlas. Điền mật khẩu database user trực tiếp trong file trên máy. `JWT_SECRET` cần là chuỗi ngẫu nhiên dài; nếu `.env` đã được tạo sẵn với secret ngẫu nhiên thì giữ giá trị đó. Giữ:

```dotenv
ADMIN_EMAIL=hautt.23it@vku.udn.vn
PORT=3000
CORS_ORIGINS=http://localhost:5173,http://127.0.0.1:5173
```

Nếu cần tự sinh JWT secret, chạy lệnh sau và chép kết quả vào `JWT_SECRET` tại máy của bạn:

```powershell
node -e "console.log(require('node:crypto').randomBytes(48).toString('hex'))"
```

Tên database backend sử dụng là `vku_student_management`. Cách tạo database user, cấp IP và kết nối Compass có trong [hướng dẫn Atlas + Compass](docs/ATLAS_COMPASS.md). Tài khoản đăng nhập trang Atlas và database user dùng trong URI là hai tài khoản khác nhau.

`.env` đã nằm trong `.gitignore`. Không gửi nội dung file này, URI có mật khẩu hay JWT secret vào chat, ảnh báo cáo hoặc GitHub.

### 2. Cài thư viện, nạp 5 hồ sơ mẫu và chạy backend

Terminal thứ nhất:

```powershell
Set-Location -LiteralPath 'D:\HK7\DNT\Midterm\vku_student_management\backend'
npm.cmd ci
npm.cmd run seed
npm.cmd run dev
```

Chỉ chạy seed sau khi đã điền URI thật. Seed thêm các email mẫu còn thiếu và giữ hồ sơ đã tồn tại. Chạy lại seed không đặt lại mật khẩu hoặc ghi đè chỉnh sửa của người dùng.

Khi backend chạy thành công, mở terminal khác để kiểm tra:

```powershell
Invoke-RestMethod -Uri 'http://localhost:3000/api/health'
```

Backend phải kết nối được MongoDB mới sẵn sàng phục vụ dữ liệu. Nếu báo lỗi cấu hình hoặc kết nối, xem [bảng xử lý lỗi](#xử-lý-lỗi-thường-gặp).

### 3. Chạy Flutter Web

Terminal thứ hai:

```powershell
Set-Location -LiteralPath 'D:\HK7\DNT\Midterm\vku_student_management\frontend'
flutter pub get
flutter run -d chrome --web-port 5173 --dart-define=API_BASE_URL=http://localhost:3000/api
```

Giữ cả terminal backend và Flutter hoạt động. Sau khi seed, dùng tài khoản mẫu được ghi trong [dữ liệu mẫu và đăng nhập](#dữ-liệu-mẫu-và-đăng-nhập).

### 4. Chạy Android Emulator

Nếu Android SDK còn báo thiếu `cmdline-tools`, bổ sung **Android SDK Command-line Tools (latest)** trong SDK Manager, rồi chạy `flutter doctor --android-licenses` và đọc/chấp nhận các giấy phép cần thiết.

Máy đã có máy ảo `Pixel_9_API_36`:

```powershell
flutter emulators --launch Pixel_9_API_36
```

Đợi Android khởi động xong rồi chạy:

```powershell
flutter devices
```

Lấy ID thiết bị Android từ kết quả. Ví dụ nếu ID là `emulator-5554`:

```powershell
Set-Location -LiteralPath 'D:\HK7\DNT\Midterm\vku_student_management\frontend'
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

`10.0.2.2` là địa chỉ Android Emulator dùng để truy cập máy host. `localhost` bên trong máy ảo trỏ về chính máy ảo. Cấu hình HTTP chỉ phục vụ phát triển; khi triển khai công khai, dùng backend HTTPS.

### 5. Chạy trên điện thoại Android thật

Điện thoại và máy tính dùng cùng mạng Wi-Fi. Bật USB debugging, kết nối USB và chấp nhận yêu cầu cho phép debug trên điện thoại. Chạy `flutter devices` để lấy ID.

Trên máy tính, chạy `ipconfig`, tìm IPv4 của adapter Wi-Fi đang dùng. Ví dụ máy tính có IP `192.168.1.10` và ID điện thoại là `YOUR_DEVICE_ID`:

```powershell
flutter run -d YOUR_DEVICE_ID --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
```

Thay hai giá trị ví dụ bằng thông tin trên máy. Cho phép Node.js qua Windows Firewall trong mạng Private nếu firewall hỏi. Backend lắng nghe trên `0.0.0.0` để thiết bị trong LAN có thể kết nối. IP Wi-Fi nội bộ này dùng cho Flutter → backend; IP công khai trong Atlas IP Access List dùng cho backend → Atlas.

### Script chạy nhanh

Chạy từ thư mục gốc dự án, mỗi lệnh trong một terminal riêng:

```powershell
.\scripts\start-backend.ps1
```

```powershell
.\scripts\start-web.ps1
```

Sau khi máy ảo đã bật, thay DeviceId theo `flutter devices`:

```powershell
.\scripts\start-android.ps1 -DeviceId 'emulator-5554'
```

Nếu PowerShell chặn `.ps1`, dùng các lệnh `npm.cmd` và `flutter` trực tiếp ở trên. Các script không cài thư viện hoặc sửa chính sách PowerShell. Có thể chọn **Terminal → Run Task** trong VS Code để chạy backend, Web, backend tests hoặc Flutter analyze.

## Dữ liệu mẫu và đăng nhập

`database/users.json` là bộ dữ liệu học tập gồm 5 hồ sơ. Trường `matkhau` trong file là bcrypt hash; mật khẩu rõ chỉ được dùng làm thông tin đăng nhập thử ở tài liệu. Tài khoản quản trị phải có email trùng với `ADMIN_EMAIL`.

| Email | Mật khẩu thử | Quyền theo cấu hình mặc định |
|---|---|---|
| `hautt.23it@vku.udn.vn` | `Vku@123456` | Quản trị |
| `an.nguyen23@vku.udn.vn` | `Vku@123456` | Xem thông tin cá nhân |
| `binh.tran23@vku.udn.vn` | `Vku@123456` | Xem thông tin cá nhân |
| `chi.le23@vku.udn.vn` | `Vku@123456` | Xem thông tin cá nhân |
| `dung.pham23@vku.udn.vn` | `Vku@123456` | Xem thông tin cá nhân |

Đây là mật khẩu công khai dành cho bài thực hành. Đổi mật khẩu trước khi dùng dữ liệu thật. Nếu email đã tồn tại từ trước, seed giữ mật khẩu cũ; không dùng thông tin mẫu để suy ra mật khẩu của hồ sơ có sẵn.

Trong ứng dụng, các tài khoản khác vẫn có thể đăng nhập để xem thông tin cá nhân. Chỉ tài khoản được backend xác định là quản trị mới truy cập API quản lý sinh viên.

## Database: đúng bốn trường nghiệp vụ

Database: **`vku_student_management`**. Collection: **`users`**.

```json
{
  "email": "student@vku.udn.vn",
  "matkhau": "<bcrypt hash>",
  "hoten": "Nguyễn Văn A",
  "hinhanh": ""
}
```

MongoDB tự thêm `_id`. Schema không thêm `role`, `createdAt`, `updatedAt` hoặc `__v`. Email được chuẩn hóa chữ thường và có unique index. Mật khẩu được hash trước khi lưu; API hồ sơ không trả `matkhau`. Ảnh JPEG/PNG/WebP được lưu dưới dạng chuỗi Base64, tối đa 2 MiB dữ liệu ảnh sau giải mã.

Tổng số trên dashboard đếm tất cả document `users`, gồm cả tài khoản quản trị mẫu. Đây là cách giữ một collection và đúng cấu trúc bốn trường theo đề bài.

## REST API

Base URL: `http://localhost:3000/api`. Các API có xác thực dùng header `Authorization: Bearer <token>`.

| Method | Đường dẫn | Quyền | Kết quả chính |
|---|---|---|---|
| GET | `/health` | Công khai | Trạng thái backend/database |
| POST | `/auth/login` | Công khai | `{ token, user, isAdmin }` |
| GET | `/auth/me` | Đã đăng nhập | `{ user, isAdmin }` |
| GET | `/users?search=&sort=asc` | Quản trị | `{ users, total }` |
| GET | `/users/:id` | Quản trị | `{ user }` |
| POST | `/users` | Quản trị | `201`, `{ user }` |
| PUT | `/users/:id` | Quản trị | `{ user }` |
| DELETE | `/users/:id` | Quản trị | `{ message }` |

Login nhận `email`, `matkhau`. Thêm/sửa nhận `email`, `matkhau`, `hoten`, `hinhanh`. Khi sửa, `matkhau` rỗng giữ mật khẩu cũ. `sort` nhận `asc` hoặc `desc`; `search` tìm trong họ tên/email. Các giá trị do API trả về không chứa hash mật khẩu.

Lỗi dùng JSON `{ "message": "..." }`, có thể kèm thông tin validation. Các mã cần chú ý: `400` dữ liệu không hợp lệ, `401` chưa đăng nhập/phiên hết hạn, `403` thiếu quyền, `404` không tìm thấy, `409` xung đột email hoặc thao tác bảo vệ tài khoản quản trị, `429` quá nhiều yêu cầu đăng nhập.

## Kiểm tra và build

### Kiểm thử Android với backend và Atlas thật

Kịch bản tích hợp đã chạy thành công trên Pixel 9 / Android 16 API 36, sử dụng tài khoản mẫu. Giữ backend đang chạy, seed dữ liệu mẫu trước và thay device ID nếu máy ảo dùng ID khác:

```powershell
Set-Location -LiteralPath 'D:\HK7\DNT\Midterm\vku_student_management\frontend'
flutter drive --driver=test_driver/atlas_driver.dart --target=integration_test/atlas_android_test.dart -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

Kịch bản tạo một hồ sơ thử có email riêng, kiểm tra CRUD/ảnh qua API thật và xóa chính hồ sơ đó; giữ các hồ sơ có sẵn. Ảnh chụp được lưu trong `docs/screenshots/`. Luồng này kiểm tra ảnh đọc từ Atlas; thao tác chọn trong gallery gốc vẫn cần kiểm tra thủ công.

Sau khi chạy integration test, build lại APK mặc định bằng lệnh bên dưới trước khi bàn giao APK, vì bản test dùng entry point riêng.

Backend tests dùng MongoDB tạm thời thật qua `mongodb-memory-server`, không kết nối Atlas và không thay dữ liệu Atlas. Lần đầu chạy có thể cần tải MongoDB binary từ mạng:

```powershell
Set-Location -LiteralPath 'D:\HK7\DNT\Midterm\vku_student_management\backend'
npm.cmd test
```

Flutter:

```powershell
Set-Location -LiteralPath 'D:\HK7\DNT\Midterm\vku_student_management\frontend'
flutter analyze
flutter test
flutter build web --dart-define=API_BASE_URL=http://localhost:3000/api
```

Build APK dùng URL backend mà thiết bị thực sự truy cập được. Ví dụ phát triển trong Wi-Fi:

```powershell
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.1.10:3000/api
```

Thay IP mẫu trước khi build. Cần Android SDK hợp lệ để build APK. Xem [ma trận kiểm thử trong báo cáo](docs/BAO_CAO.md) và [checklist nộp bài](docs/CHECKLIST_NOP_BAI.md) để ghi nhận lần chạy thực tế. Việc build thành công không thay cho kiểm tra thêm/sửa/xóa và ảnh trên Atlas.

## Xuất JSON và import bằng Compass

Sau khi chạy demo và kiểm tra dữ liệu thật:

```powershell
Set-Location -LiteralPath 'D:\HK7\DNT\Midterm\vku_student_management\backend'
npm.cmd run export
```

Lệnh xuất ra `database/users.export.json`, đã được Git bỏ qua vì có thể chứa dữ liệu riêng. File giữ hash mật khẩu để có thể import và đăng nhập lại. Giữ bộ mẫu `database/users.json` để import học tập. Có thể chạy `npm.cmd run fixture` ở backend để tạo lại bộ mẫu; lệnh fixture tạo file JSON, không nạp dữ liệu vào Atlas.

Trong Compass, chọn `vku_student_management` → `users` → **Add Data → Import JSON or CSV file**, chọn JSON. Import vào collection trống nếu muốn dùng bộ mẫu; seed là cách thuận tiện hơn khi database đã có dữ liệu. Để xuất qua Compass, dùng **Export Data**, chọn toàn bộ collection và định dạng JSON. Chi tiết có trong [hướng dẫn Atlas + Compass](docs/ATLAS_COMPASS.md).

## Đưa source lên GitHub

Repository của dự án: [https://github.com/Thanhau1105/mditerm_dnt](https://github.com/Thanhau1105/mditerm_dnt). Chạy tại thư mục gốc dự án nếu cần khởi tạo lại Git từ bản ZIP:

```powershell
git init
git add .
git status --short
git diff --cached --name-only
```

Kiểm tra danh sách staging không có `.env`, `node_modules`, bản xuất chứa thông tin thật hoặc ảnh riêng tư. Tiếp tục:

```powershell
git commit -m "Build VKU student management with Flutter and MongoDB"
git branch -M main
git remote add origin https://github.com/Thanhau1105/mditerm_dnt.git
git push -u origin main
```

Nếu đã có `origin`, dùng `git remote -v` để xem và chỉ đổi URL khi cần. Khi tải source mới, có thể dùng `git clone https://github.com/Thanhau1105/mditerm_dnt.git vku_student_management` để giữ tên thư mục như các ví dụ trong tài liệu. Link video được bổ sung sau khi quay và tải lên.

## Xử lý lỗi thường gặp

| Biểu hiện | Cách xử lý |
|---|---|
| Backend báo thiếu URI hoặc secret | Điền `backend/.env`; chạy lại backend. |
| Atlas authentication failed | Dùng database user, không dùng mật khẩu tài khoản web Atlas; kiểm tra percent-encoding của mật khẩu. |
| Atlas server selection timeout | Kiểm tra cluster hoạt động, IP công khai hiện tại có trong Access List, kết nối mạng/DNS và URI đúng cluster. |
| Compass kết nối được nhưng backend không được | So sánh host/database user trên máy; kiểm tra URI `.env`, database và quyền của user. Không chụp/chia sẻ phần mật khẩu. |
| Web báo lỗi kết nối/CORS | Giữ backend chạy, dùng port Web `5173`, đối chiếu `CORS_ORIGINS`, khởi động lại backend sau khi sửa `.env`. |
| Emulator không gọi được API | Dùng `http://10.0.2.2:3000/api`, kiểm tra backend đang chạy. |
| Điện thoại không gọi được API | Dùng IPv4 Wi-Fi của máy tính, chung LAN, kiểm tra firewall hoặc mạng chặn giao tiếp giữa thiết bị. |
| Đăng nhập được nhưng không thấy quản trị | Email tài khoản phải trùng `ADMIN_EMAIL`; khởi động lại backend nếu vừa sửa `.env`. |
| Đăng nhập sai sau khi seed lại | Seed giữ mật khẩu hồ sơ có sẵn; dùng mật khẩu đã đặt trước đó. |
| Ảnh bị từ chối | Chọn JPEG/PNG/WebP, giảm ảnh xuống dưới 2 MiB sau khi chọn/nén. |
| Thiếu Android cmdline-tools | Bổ sung **Command-line Tools (latest)**, chạy lại licenses và `flutter doctor`. |
| Cảnh báo Visual Studio C++ | Chỉ ảnh hưởng Windows desktop; Web/Android dùng toolchain riêng. |
| Script `.ps1` bị chặn | Dùng lệnh terminal tương đương trong README. |

## Tài liệu nộp bài

- [Báo cáo thực hiện](docs/BAO_CAO.md)
- [Atlas, Compass, import/export](docs/ATLAS_COMPASS.md)
- [Kịch bản quay video và câu hỏi bảo vệ](docs/DEMO.md)
- [Checklist kết quả và ảnh minh họa](docs/CHECKLIST_NOP_BAI.md)
- [Kết quả kiểm tra và phần cần xác nhận](docs/VALIDATION.md)

Bộ source, dữ liệu mẫu, kết nối Atlas và ảnh Android đã được chuẩn bị/kiểm tra theo `docs/VALIDATION.md`. Video demo, ảnh Web/Compass và kiểm tra gallery Android cần được hoàn tất bằng tài khoản và thiết bị thực tế của sinh viên. Cấu hình `.env` và bản xuất dữ liệu Atlas riêng được giữ trên máy, không đưa vào repository.
