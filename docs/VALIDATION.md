# Kết quả kiểm tra dự án

Ngày cập nhật: **10/11/2026**. Tệp này phân biệt kiểm tra source tự động với các thao tác cần tài khoản Atlas và thiết bị của sinh viên.

## Kết quả đã ghi nhận trong quá trình xây dựng

| Kiểm tra | Kết quả | Phạm vi |
|---|---|---|
| `npm.cmd test` | **14/14 đạt**, không fail/skip | REST API với MongoDB `8.2.6` tạm thời thật, tách biệt Atlas |
| `flutter test --no-pub` | **17/17 đạt**, không fail/skip | Service/session, Login, form, card và Dashboard sau các sửa UI cuối |
| `flutter analyze --no-pub` | **No issues found** | Mã nguồn ứng dụng và toàn bộ tests |
| `flutter build web` | **Thành công** | `frontend/build/web`, API mặc định `http://localhost:3000/api`, renderer/font cục bộ |
| Script PowerShell | **3/3 parse thành công** | `start-backend.ps1`, `start-web.ps1`, `start-android.ps1` |
| VS Code JSON | **2/2 đọc thành công** | `tasks.json`, `extensions.json` |
| Git ignore | **Đúng** | `.env`, bản export riêng và Android `local.properties` được bỏ qua |
| Kết nối Atlas của sinh viên | **Thành công** | Backend dùng URI trong `.env`; seed thêm 5 tài khoản, giữ nguyên hồ sơ nếu đã tồn tại |
| Kiểm tra REST API trên Atlas | **9/9 nhóm kiểm tra đạt** | Health, admin login, danh sách, ảnh Base64, sửa giữ mật khẩu, phân quyền, email duy nhất, tìm kiếm, xóa |
| Android tích hợp Atlas | **All tests passed** | Pixel 9 / Android 16 API 36; một kịch bản tích hợp chạy app thật, không mock HTTP |

Các tests API bao gồm schema đúng trường, login/hash, Bearer token, quyền admin, token giả/hết hạn, CRUD với Base64, email trùng, đổi mật khẩu vô hiệu token cũ, bảo vệ admin hiện tại, tìm kiếm/sắp xếp, validation/JSON, ảnh/request quá lớn, CORS, seed không ghi đè và tên database cố định.

Các tests Flutter gồm form Login ở nhiều độ rộng, lỗi đăng nhập, form thêm trên màn hình hẹp, card có tên/email dài, token/session, lỗi email trùng và lỗi kết nối. Dashboard được kiểm tra ở 320, 390, 960 và 1440 px; tests kiểm tra thử lại sau lỗi 503, tìm kiếm qua API, hủy xóa không gửi DELETE và phiên hết hạn 401 quay về Login. Phạm vi test cụ thể nằm trong `frontend/test/`.

Đã sửa lỗi logo tràn ngang trên màn hình nhỏ, khoảng cuộn để FAB không che nút Thử lại và lỗi cache Kotlin khi source ở ổ D: còn Pub cache ở ổ C:. Cấu hình `kotlin.incremental=false` nằm trong `frontend/android/gradle.properties`.

Bản QA Web riêng ở `build/qa-web` đã trả HTTP 200; API QA với MongoDB tạm trả `ok / connected`. Hai server QA đã dừng sau khi kiểm tra. Đây là kiểm tra HTTP và tự động, chưa thay thế kiểm tra thao tác bằng tay trên Chrome.

Lần đầu chạy backend tests cần tải MongoDB binary; lượng tải có thể lớn. Các lần sau dùng cache. MongoDB tạm chỉ phục vụ kiểm thử và không được dùng làm dữ liệu giả khi chạy ứng dụng.

## Cần xác nhận trước khi nộp

| Kiểm tra | Trạng thái tại thời điểm chuẩn bị tài liệu |
|---|---|
| QA giao diện Chrome bằng thao tác trực tiếp | Chưa xác nhận: công cụ tự dừng vì không xác định chắc URL hiện tại để áp dụng chính sách; không tiếp tục thao tác UI |
| Build/run APK | **Đã build, cài và chạy trên Pixel 9 Emulator / Android 16 API 36** |
| Kết nối URI Atlas riêng | **Đã kết nối thành công** |
| CRUD/ảnh trên Atlas | **Đạt qua REST API và đối chiếu trực tiếp MongoDB**; thao tác trong Compass vẫn cần chụp ảnh báo cáo |
| Chọn ảnh bằng thư viện ảnh Android | Chưa kiểm tra thao tác trên gallery gốc; đã xác nhận Android đọc, preview, lưu lại và hiển thị ảnh từ Atlas |
| Repository GitHub | **Đã push** lên https://github.com/Thanhau1105/mditerm_dnt, nhánh `main`; commit source ban đầu `517d63b`. Cấu hình riêng và JSON export được loại khỏi source |
| Video demo và ảnh báo cáo cuối | Chờ quay/chụp thực tế |

Cập nhật các ô trên bằng log và ảnh đúng của lần chạy cuối. Các trạng thái đang chờ không phải lỗi được xác nhận; chúng cho biết phần chưa có bằng chứng thực nghiệm trong tài liệu này.

## Lần chạy với Atlas thật

Backend đã chạy tại `http://localhost:3000`; bản Flutter Web đã build được phục vụ tại `http://localhost:5173`. Origin Web được kiểm tra trong các yêu cầu API. Đăng nhập bằng tài khoản quản trị mẫu thành công, API danh sách không trả `matkhau`.

Kiểm tra tạo một hồ sơ riêng, lưu ảnh PNG dạng Base64, đọc lại, sửa tên và giữ mật khẩu cũ khi gửi mật khẩu rỗng. Đối chiếu trực tiếp document MongoDB xác nhận đúng `_id` và bốn trường nghiệp vụ, mật khẩu bcrypt còn dùng được. Tài khoản thường bị từ chối API quản trị với 403; email trùng bị từ chối với 409; tìm kiếm trả đúng hồ sơ.

Hồ sơ thử do quy trình kiểm tra tạo đã được xóa bằng chính ID của hồ sơ đó và xác nhận không còn trong MongoDB. Năm tài khoản mẫu được giữ nguyên. Nội dung URI, JWT và mật khẩu Atlas không được ghi vào báo cáo hay log.

Đã chạy `npm.cmd run export` để xuất 5 hồ sơ thật từ Atlas ra `database/users.export.json` (Extended JSON, hash mật khẩu được giữ nguyên). Tệp này được Git bỏ qua theo cấu hình dự án.

## Android với Atlas thật

Đã chạy `frontend/integration_test/atlas_android_test.dart` bằng `flutter drive` trên máy ảo `Pixel_9_API_36` (`emulator-5554`, Android 16 API 36). Ứng dụng gọi backend qua `http://10.0.2.2:3000/api`; backend kết nối Atlas bằng cấu hình cục bộ.

Kịch bản thao tác trên widget thật: đăng nhập admin, tải danh sách, mở form và tạo hồ sơ riêng, tìm kiếm, sửa tên để trống mật khẩu, hủy xóa, xác nhận xóa, đăng xuất, đăng nhập sinh viên và xem hồ sơ cá nhân. Ảnh PNG được đưa vào hồ sơ thử qua API thật, sau đó Android tải và hiển thị trong card/form. Việc này chứng minh luồng đọc/hiển thị/lưu ảnh, chưa thay thế kiểm tra thao tác chọn trong gallery Android.

Kịch bản đạt, hồ sơ thử đã được xóa và số hồ sơ trở lại giá trị ban đầu. Ảnh chụp do Flutter integration test ghi từ ứng dụng đang chạy được lưu tại:

- [Login Android](screenshots/android-login.png)
- [Dashboard đọc 5 hồ sơ trên Atlas](screenshots/android-dashboard-atlas.png)
- [Form sửa và preview ảnh đọc từ Atlas](screenshots/android-edit-image-from-atlas.png)
- [Hồ sơ tài khoản sinh viên](screenshots/android-student-profile.png)

## Lệnh build cuối

```powershell
flutter build web --no-pub --no-web-resources-cdn --no-wasm-dry-run --dart-define=API_BASE_URL=http://localhost:3000/api
flutter build apk --debug --no-pub --dart-define=API_BASE_URL=http://10.0.2.2:3000/api
```

APK debug dành cho Android Emulator truy cập backend trên máy host. Điện thoại thật cần build với URL LAN phù hợp. Các tệp build nằm ngoài bộ source ZIP và được Git bỏ qua.
