% THÔNG SỐ
SAMPLE_RATE = 1000000;  % Tần số lấy mẫu fs (1 GHz)
CARRIER_FREQ = 38000;   % Tần số sóng mang fc (38 kHz)
BIT_DURATION = 0.001;   % Thời gian 1 bit Tb (1 ms)
NUM_BITS = 32;          % 32 bit được tạo ra để gửi đi

% 1. TẠO BIT (generate_binary_sequence)
bits = randi([0, 1], 1, NUM_BITS);

% 2. ĐIỀU CHẾ OOK (modulate_signal)
% CÔNG THỨC: N_s = fs * Tb (Số lượng mẫu trong 1 bit)
samples_per_bit = round(SAMPLE_RATE * BIT_DURATION); 
total_samples = length(bits) * samples_per_bit;

% Tạo vector thời gian t (bước nhảy delta_t = 1/fs)
t = linspace(0, total_samples / SAMPLE_RATE, total_samples + 1);
t(end) = []; 

% CÔNG THỨC: c(t) = sin(2*pi*fc*t)
carrier = sin(2 * pi * CARRIER_FREQ * t);

% Trải dài các bit thành chuỗi xung vuông baseband b(t)
baseband = repelem(bits, samples_per_bit); 

% CÔNG THỨC ĐIỀU CHẾ: s(t) = b(t) * c(t)
modulated = baseband .* carrier;

% 3. THÊM NHIỄU (add_noise)
    
% CÔNG THỨC CÔNG SUẤT: Ps = Trung bình bình phương các mẫu tín hiệu
signal_power = mean(modulated.^2);

% CÔNG THỨC TÍNH NHIỄU: Pn = Ps / (10^(SNR/10))
noise_power = signal_power / (10^(snr_db/10));

% Nhiễu AWGN 
awgn = sqrt(noise_power) * randn(1, length(modulated));

% Nhiễu tần số thấp (Mô phỏng ánh sáng đèn huỳnh quang 50Hz/120Hz)
low_freq_noise = 0.3 * (0.5 * sin(2 * pi * 50 * t) + 0.3 * sin(2 * pi * 120 * t));
noisy = modulated + awgn + low_freq_noise;

% 4. BANDPASS (design_bandpass & filter)
bw = 6000; % Băng thông 6kHz
% CÔNG THỨC NYQUIST: f_nyq = fs / 2
nyq = SAMPLE_RATE / 2;

% CÔNG THỨC CHUẨN HÓA TẦN SỐ: Wn = f / f_nyq
low = (CARRIER_FREQ - bw/2) / nyq;
high = (CARRIER_FREQ + bw/2) / nyq;
[b_bp, a_bp] = cheby1(4, 1, [low, high], 'bandpass');
filtered = filtfilt(b_bp, a_bp, noisy);

% 5. ENVELOPE (envelope_detector)
% CÔNG THỨC TÁCH BIÊN BAO (Chỉnh lưu toàn sóng): e(t) = |y(t)|
rectified = abs(filtered);
cutoff = 5000 / nyq; % Chuẩn hóa tần số cắt lowpass filter (5kHz)
[b_lp, a_lp] = cheby1(4, 0.5, cutoff, 'low');
env = filtfilt(b_lp, a_lp, rectified);

% Đặt ngưỡng Threshold (ngưỡng quyết định mức 0 và mức 1)
threshold = max(env) * 0.5;

% 6. RECOVER (recover_bits)
recovered = zeros(1, NUM_BITS);
for i = 1:NUM_BITS
    % Indexing trong MATLAB bắt đầu từ 1
    start_idx = (i-1)*samples_per_bit + 1;
    end_idx = i*samples_per_bit;
    seg = env(start_idx:end_idx);
    
    % CÔNG THỨC QUYẾT ĐỊNH: Nếu trung bình năng lượng biên bao của 1 bit > V_th thì là mức 1
    if mean(seg) > threshold
        recovered(i) = 1;
    end
end

% 7. IN KẾT QUẢ, VẼ ĐỒ THỊ

% CÔNG THỨC TÍNH BER: (Số bit lỗi / Tổng số bit) * 100%
ber = mean(bits ~= recovered) * 100;

% In kết quả
fprintf('Bit gốc: %s\n', sprintf('%d', bits));
fprintf('Bit thu: %s\n', sprintf('%d', recovered));
fprintf('BER: %.2f%%\n', ber);

t_ms = t * 1000; % Chuyển đổi thời gian sang mili-giây để dễ vẽ đồ thị

figure('Name', 'DSP IR OOK 38kHz (Dark Mode Optimized)', 'Position', [100, 50, 900, 900]);

% 7.1. Baseband
subplot(6,1,1);
plot(t_ms, baseband, 'Color', '#FF9900', 'LineWidth', 1.5); % Màu Cam sáng
title('1. Tín hiệu xung vuông (baseband)');
grid on;

% 7.2. Modulated 
subplot(6,1,2);
plot(t_ms, modulated, 'g'); % Xanh lá
title('2. Tín hiệu OOK điều chế');
grid on;

% 7.3. Noisy
subplot(6,1,3);
plot(t_ms, noisy, 'r'); % Đỏ
title('3. Tín hiệu nhận (có nhiễu AWGN + 50/120Hz)');
grid on;

% 7.4. Filtered
subplot(6,1,4);
plot(t_ms, filtered, 'b'); % Xanh dương
title('4. Sau lọc thông dải (Bandpass 38kHz)');
grid on;

% 7.5. Rectified 
subplot(6,1,5);
plot(t_ms, rectified, 'c', 'LineWidth', 1); % Xanh lơ (Cyan) rất sáng trên nền đen
title('5. Tín hiệu sau chỉnh lưu toàn sóng (abs)');
grid on;

% 7.6. Envelope + Bits
subplot(6,1,6);
plot(t_ms, env, 'y', 'LineWidth', 1.5, 'DisplayName', 'Envelope'); % Vàng sáng
hold on;
rec = repelem(recovered, samples_per_bit);
plot(t_ms, rec * max(env), 'm', 'LineWidth', 1.5, 'DisplayName', 'Recovered bits'); % Đỏ tím
title('6. Tách biên bao & khôi phục dữ liệu');
legend('Location', 'best');
grid on;