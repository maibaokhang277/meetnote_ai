# MeetNote AI - Smart AI Meeting Note & Task Automation

Ứng dụng di động hỗ trợ ghi âm cuộc họp/bài giảng, tự động chuyển đổi giọng nói thành văn bản (Speech-to-Text), tóm tắt ý chính và trích xuất danh sách công việc (Action Items) bằng trí tuệ nhân tạo.

## 1. Thành viên thực hiện

| Họ và tên | MSSV | Vai trò | Phụ trách chính |
| :--- | :--- | :--- | :--- |
| **Mai Bảo Khang** | 524H0016 | Frontend Mobile & UI/UX | Thiết kế giao diện Flutter, luồng màn hình, ghi âm/phát âm thanh, quản lý trạng thái UI, thông báo cục bộ. |
| **Võ Tấn Tài** | 524H0126 | Backend & AI Integration | Xây dựng Python FastAPI, cơ sở dữ liệu Supabase, tích hợp STT (Whisper) & LLM (Gemini), bảo mật & API. |

---

## 2. Trạng thái hiện tại của dự án (Frontend MVP)

Hiện tại, toàn bộ phần **Frontend UI/UX** đã hoạt động hoàn chỉnh với **Mock Data (dữ liệu giả lập)**:
- Hoàn thiện 8 màn hình chức năng và luồng điều hướng (Navigation) mượt mà.
- Xây dựng đầy đủ các Data Models bám sát thiết kế cơ sở dữ liệu.
- Tích hợp sẵn bộ chuyển đổi kiểm thử 3 trạng thái giao diện: `Loading`, `Empty`, `Error`.
- Đã tách riêng lớp giao tiếp mạng tại `lib/services/api_service.dart` với các hàm chờ (`// TODO: Backend API Integration`) để sẵn sàng ghép nối với FastAPI.

---

## 3. Yêu cầu môi trường (Dành cho máy tính chạy dự án lần đầu)

Trước khi chạy dự án, hãy đảm bảo máy tính đã cài đặt:
1. **Git**: Để kéo mã nguồn về máy.
2. **Flutter SDK** (phiên bản 3.x trở lên):
   - Tải tại trang chủ Flutter dành cho Windows/macOS.
   - Giải nén vào thư mục cố định (ví dụ: `C:\src\flutter`) và thêm đường dẫn `C:\src\flutter\bin` vào biến môi trường **Path** của máy.
3. **Android Studio**:
   - Đã cài đặt 2 plugin: **Flutter** và **Dart** (trong mục *Settings -> Plugins*).
   - Đã tải **Android SDK** và tạo sẵn ít nhất 1 máy ảo Android (**AVD Manager** -> Pixel API 34 trở lên).

---

## 4. Hướng dẫn cài đặt và chạy ứng dụng

### Bước 1: Clone dự án về máy
Mở Terminal / Command Prompt tại thư mục muốn lưu dự án và chạy lệnh:
```bash
git clone <ĐƯỜNG_DẪN_GITHUB_REPO_CỦA_NHÓM>
cd meetnote_ai
```

### Bước 2: Mở dự án trên Android Studio và cấu hình Flutter SDK
1. Mở **Android Studio** -> chọn **Open** -> trỏ đến thư mục `meetnote_ai` vừa clone về.
2. Kiểm tra đường dẫn Flutter SDK:
   - Vào **File** -> **Settings** (hoặc **Preferences** trên macOS) -> **Languages & Frameworks** -> **Flutter**.
   - Tại ô **Flutter SDK path**, chọn đúng thư mục giải nén Flutter trên máy của bạn (ví dụ: `C:\src\flutter`), sau đó nhấn **Apply** -> **OK**.

### Bước 3: Tải các gói thư viện (Dependencies)
Mở tệp `pubspec.yaml` và bấm nút **Pub get** ở góc trên bên phải (hoặc vào menu **Tools -> Flutter -> Flutter Pub Get**).
Nếu đã cấu hình biến môi trường Path, bạn cũng có thể chạy lệnh trong Terminal:
```bash
flutter clean
flutter pub get
```

### Bước 4: Khởi động máy ảo và chạy ứng dụng
1. Mở **Device Manager** ở thanh công cụ bên phải của Android Studio, bấm nút **Play** để bật máy ảo Android.
2. Đảm bảo trên thanh công cụ phía trên đã chọn đúng thiết bị máy ảo và tệp chạy là `main.dart`.
3. Nhấn nút **Run** (biểu tượng tam giác màu xanh lá) hoặc nhấn `Shift + F10`.
   *(Lưu ý: Lần chạy đầu tiên Gradle sẽ tải NDK và biên dịch mất khoảng 3 - 5 phút, các lần sau dùng Hot Reload sẽ cập nhật ngay lập tức).*

---

## 5. Cấu trúc thư mục mã nguồn (`lib/`)

```text
lib/
├── main.dart                      # Điểm khởi chạy ứng dụng, cấu hình Theme Material 3
├── models/                        # Chứa 6 Data Models (User, Meeting, Transcript, Summary, Task, Reminder)
├── mock_data/                     # Dữ liệu giả lập tiếng Việt phục vụ chạy thử UI
├── services/                      # KHU VỰC TÍCH HỢP BACKEND API
│   └── api_service.dart           # Chứa 8 hàm stub tương ứng với 8 REST API endpoints
├── widgets/                       # Các thành phần giao diện dùng chung
└── screens/                       # 8 màn hình chính của ứng dụng
    ├── auth_screen.dart           # Đăng nhập / Đăng ký
    ├── home_screen.dart           # Trang chủ & Thanh điều hướng dưới cùng
    ├── record_import_screen.dart  # Ghi âm & Chọn tệp âm thanh
    ├── processing_screen.dart     # Hiển thị tiến trình xử lý 4 bước của AI
    ├── meeting_detail_screen.dart # Nghe lại, xem/sửa Transcript, Summary và duyệt Action Items
    ├── task_list_screen.dart      # Quản lý danh sách công việc (To-Do) & Hẹn giờ nhắc
    ├── history_search_screen.dart # Lịch sử cuộc họp & Tìm kiếm/Bộ lọc
    └── profile_settings_screen.dart # Cài đặt ngôn ngữ, quyền truy cập & Đăng xuất
```

---

## 6. Hướng dẫn tích hợp Backend (Dành cho Võ Tấn Tài)

Để ghép nối Backend **Python FastAPI + Supabase** vào ứng dụng mà không làm ảnh hưởng đến giao diện hiện tại, bạn chỉ cần tập trung vào 2 khu vực sau:

### 6.1. Kiểm tra cấu trúc JSON tại `lib/models/`
Các lớp dữ liệu đã được thiết kế sẵn hàm `fromJson` và `toJson` khớp với Database Schema:
- Trường `assignee_name` và `due_at` trong bảng `tasks` cho phép nhận giá trị `null` (khi AI không tìm thấy thông tin trong cuộc họp, giao diện sẽ tự động hiện nhãn vàng yêu cầu người dùng nhập thủ công).
- Trường `source_text` lưu câu trích dẫn gốc từ bản chép lời để người dùng đối chiếu.

### 6.2. Thay thế các hàm gọi API tại `lib/services/api_service.dart`
Mở tệp `lib/services/api_service.dart`, tìm các chú thích `// TODO: Backend API Integration` và thay thế phần dữ liệu giả lập bằng lệnh gọi HTTP thực tế tới FastAPI cho 8 endpoints:

| Hàm trong `ApiService` | Phương thức & Endpoint | Mô tả nghiệp vụ |
| :--- | :--- | :--- |
| `login()` | `POST /auth/login` | Xác thực người dùng và lưu JWT/Session token. |
| `createMeeting()` | `POST /meetings` | Khởi tạo bản ghi cuộc họp mới. |
| `uploadAudio()` | `POST /meetings/{id}/audio` | Tải tệp âm thanh lên Storage và kích hoạt luồng STT + AI. |
| `getMeetingDetail()` | `GET /meetings/{id}` | Lấy trạng thái xử lý, transcript, summary và tasks đề xuất. |
| `analyzeMeeting()` | `POST /meetings/{id}/analyze` | Yêu cầu AI phân tích lại bản tóm tắt và trích xuất công việc. |
| `getTasks()` | `GET /tasks` | Lấy danh sách công việc của người dùng hiện tại. |
| `updateTask()` | `PATCH /tasks/{id}` | Cập nhật người phụ trách, hạn hoàn thành hoặc trạng thái To-Do. |
| `deleteMeeting()` | `DELETE /meetings/{id}` | Xóa bản ghi chú cuộc họp theo quyền sở hữu. |

### 6.3. Lưu ý quan trọng khi kết nối FastAPI dưới máy cục bộ (Localhost)
- Khi chạy ứng dụng trên **Máy ảo Android (Android Emulator)**, địa chỉ `localhost` hoặc `127.0.0.1` sẽ trỏ vào chính chiếc điện thoại ảo chứ không phải máy tính chạy FastAPI.
- Do đó, khi cấu hình `baseUrl` trong Flutter để gọi tới server FastAPI đang chạy ở cổng `8000` trên máy tính, hãy sử dụng địa chỉ IP đặc biệt:
  ```text
  http://10.0.2.2:8000
  ```
- **Bảo mật:** Tuyệt đối không đưa trực tiếp các khóa bí mật (`GEMINI_API_KEY`, `SUPABASE_SERVICE_ROLE_KEY`...) vào mã nguồn Flutter hoặc đẩy lên GitHub. Hãy sử dụng tệp `.env` ở phía Backend và chỉ đẩy tệp `.env.example` lên kho lưu trữ.

---

## 7. Quy trình làm việc nhóm với Git

Để tránh xung đột mã nguồn (Merge Conflict) khi hai thành viên cùng làm việc:
1. Trước khi bắt đầu code mỗi ngày, luôn kéo bản cập nhật mới nhất về máy:
   ```bash
   git pull origin main
   ```
2. Khuyến khích tạo nhánh riêng khi phát triển tính năng mới (ví dụ nhánh `backend-api` hoặc `feature/integration`):
   ```bash
   git checkout -b feature/ten-tinh-nang
   ```
3. Kiểm tra ứng dụng chạy không lỗi trước khi `commit` và `push` lên GitHub.
