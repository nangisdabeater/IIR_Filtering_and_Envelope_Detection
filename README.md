# 📡 IR Remote Control Signal Detection (Phát hiện tín hiệu điều khiển từ xa)

🌎 **[English Version Below](#-english-version)**

## 🇻🇳 Tiếng Việt

### 📖 Giới thiệu
Dự án này tập trung vào việc mô phỏng toàn bộ chu trình truyền, nhận và xử lý tín hiệu hồng ngoại (IR) từ điều khiển từ xa. Tín hiệu điều khiển thực chất là các chuỗi dữ liệu số được điều chế trên sóng mang tần số 38kHz để tránh nhiễu từ môi trường. Bằng việc ứng dụng các thuật toán Xử lý tín hiệu số (DSP) trên MATLAB, hệ thống có thể trích xuất thành công mã lệnh từ một tín hiệu thô đã bị can nhiễu nặng nề.

### ⚙️ Thông số hệ thống
- **Tần số lấy mẫu (fs):** 1 MHz
- **Tần số sóng mang (fc):** 38 kHz
- **Thời gian 1 bit (Tb):** 1 ms
- **Định dạng dữ liệu:** Chuỗi 32 bit ngẫu nhiên (OOK Modulation)
- **Mô phỏng nhiễu:** Nhiễu AWGN (SNR 8dB) & Nhiễu ánh sáng môi trường (50Hz/120Hz)

### 🚀 Luồng xử lý tín hiệu (Workflow)
1. **Baseband:** Tạo chuỗi 32 bit ngẫu nhiên thành tín hiệu xung vuông lý tưởng.
2. **Điều chế OOK:** Trộn xung vuông với sóng mang 38 kHz.
3. **Kênh truyền:** Thêm nhiễu AWGN và nhiễu đèn huỳnh quang 50/120Hz.
4. **Lọc thông dải (Band-pass Filter):** Dùng bộ lọc IIR Chebyshev Loại 1 (bậc 4, băng thông 6kHz) kết hợp lọc triệt tiêu trễ pha (zero-phase) để tách sóng mang.
5. **Tách biên bao (Envelope Detection):** Chỉnh lưu toàn sóng (abs) và dùng bộ lọc thông thấp (Low-pass Filter 5kHz) để khôi phục xung vuông.
6. **Khôi phục dữ liệu:** Sử dụng ngưỡng quyết định động (50% biên độ đỉnh) để tính trung bình năng lượng và chốt mức logic, tính toán BER.

### 💻 Hướng dẫn chạy mô phỏng

**Yêu cầu hệ thống:**
- MATLAB 2025a (hoặc các phiên bản tương thích).
- Signal Processing Toolbox (Cần thiết cho các hàm `cheby1`, `filtfilt`).

**Các bước thực hiện:**
1. Clone repository này về máy:
   ```bash
   git clone [https://github.com/your-username/ir-remote-dsp.git](https://github.com/your-username/ir-remote-dsp.git)
Mở MATLAB và trỏ thư mục hiện tại (Current Folder) về thư mục vừa clone.

Mở và chạy file code_matlab.m:

Gõ lệnh run('code_matlab.m') trong Command Window hoặc nhấn nút Run trên giao diện.

Quan sát kết quả trên Command Window (Bit gốc, Bit thu, BER) và phân tích biểu đồ 6 bước xử lý tín hiệu.

🇬🇧 English Version
📖 Introduction
This project is an academic simulation of the transmission, reception, and digital signal processing (DSP) of an infrared (IR) remote control signal. Remote commands are digital data streams modulated onto a 38kHz carrier wave to mitigate environmental optical interference. Using MATLAB, this system applies core DSP techniques to successfully extract the original command sequence from a heavily distorted, noisy signal.

⚙️ System Parameters
Sampling Rate (fs): 1 MHz

Carrier Frequency (fc): 38 kHz

Bit Duration (Tb): 1 ms

Data Format: 32-bit random sequence (OOK Modulation)

Noise Simulation: AWGN (8dB SNR) & Ambient Light Noise (50Hz/120Hz)

🚀 Signal Processing Pipeline
Baseband Generation: A 32-bit random binary sequence is converted into an ideal rectangular pulse wave.

OOK Modulation: The baseband signal is multiplied by a 38kHz carrier wave.

Noisy Channel: Additive White Gaussian Noise (AWGN) and low-frequency ambient light noise are introduced.

Band-pass Filtering: A 4th-order Chebyshev Type I IIR filter (6kHz bandwidth) with zero-phase filtering is applied to isolate the 38kHz carrier.

Envelope Detection: Full-wave rectification followed by a 5kHz low-pass filter is used to smooth out the carrier ripples.

Data Recovery: A dynamic decision threshold (50% of the maximum envelope amplitude) is used to evaluate the average energy per bit, determining the logic level and calculating the Bit Error Rate (BER).

💻 Getting Started
Prerequisites:

MATLAB 2025a (or compatible versions).

Signal Processing Toolbox (Required for cheby1 and filtfilt functions).

Installation & Usage:

Clone this repository:

Bash
git clone [https://github.com/your-username/ir-remote-dsp.git](https://github.com/your-username/ir-remote-dsp.git)
Open MATLAB and navigate to the cloned directory.

Run the main script code_matlab.m:

Type run('code_matlab.m') in the Command Window or click the Run button.

Check the Command Window for terminal outputs (Original bits, Recovered bits, BER) and analyze the generated 6-subplot figure detailing the signal at each DSP stage.
