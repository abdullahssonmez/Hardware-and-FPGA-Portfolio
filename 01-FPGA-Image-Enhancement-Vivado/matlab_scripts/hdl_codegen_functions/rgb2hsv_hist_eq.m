function [H, S, V_eq] = rgb2hsv_hist_eq(R, G, B)
%#codegen
% Bu fonksiyon, girişteki R, G, B kanallarını kullanarak RGB -> HSV
% dönüşümü gerçekleştirir. Ardından hesaplanan Value (V) kanalına 
% histogram equalization uygular.
%
% Girişler:
%   R, G, B - [270x372] uint8 matrisler. (Her biri 0-255 aralığında değer içerir)
%
% Çıkışlar:
%   H    - [270x372] double matris, hue değeri (0 ile 360 derece arasında)
%   S    - [270x372] double matris, saturation (0 ile 1 aralığında)
%   V_eq - [270x372] double matris, histogram equalize edilmiş value (0 ile 1 aralığında)

% Sabit boyutlar
rows = 270;
cols = 372;

%% 1. AŞAMA: RGB -> HSV DÖNÜŞÜMÜ
H = zeros(rows, cols);
S = zeros(rows, cols);
V = zeros(rows, cols);

for i = 1:rows
    for j = 1:cols
        % RGB değerlerini normalize et (0-255'ten 0-1'e)
        r_val = double(R(i, j)) / 255;
        g_val = double(G(i, j)) / 255;
        b_val = double(B(i, j)) / 255;
        
        % Maksimum ve minimum değeri belirle
        max_val = r_val;
        if g_val > max_val
            max_val = g_val;
        end
        if b_val > max_val
            max_val = b_val;
        end
        
        min_val = r_val;
        if g_val < min_val
            min_val = g_val;
        end
        if b_val < min_val
            min_val = b_val;
        end
        
        delta = max_val - min_val;
        
        % Hesaplanan Value değeri
        V(i, j) = max_val;
        
        % Saturation hesaplaması
        if max_val == 0  
            S(i, j) = 0;
        else
            S(i, j) = delta / max_val;
        end
        
        % Hue hesaplaması
        if delta == 0
            H(i, j) = 0;
        else
            if r_val == max_val
                h_val = (g_val - b_val) / delta;
            elseif g_val == max_val
                h_val = 2 + (b_val - r_val) / delta;
            else  % b_val == max_val
                h_val = 4 + (r_val - g_val) / delta;
            end
            
            h_val = h_val * 60;  % Dereceye çevirme
            if h_val < 0
                h_val = h_val + 360;
            end
            H(i, j) = h_val;
        end
    end
end

%% 2. AŞAMA: Histogram Equalization - Value (V) Kanalı
% Histogram equalization için standart 256 seviye kullanıyoruz.
levels = 256;
totalPixels = rows * cols;

% Adım 2.1: V kanalındaki değerleri [0, levels-1] aralığına ölçeklendir.
V_int = zeros(rows, cols, 'uint8');
for i = 1:rows
    for j = 1:cols
        % V değeri [0,1] aralığında olduğundan, *255 işlemi ile 0-255 aralığına
        % dönüşüm yapılır; burada yuvarlama işlemi floor ile yapılıyor.
        V_int(i,j) = uint8(floor(V(i, j)*(levels-1) + 0.5));
    end
end

% Adım 2.2: Histogram hesaplama (256 adet seviye için)
histogram = zeros(levels,1);
for i = 1:rows
    for j = 1:cols
         bin = double(V_int(i,j));  % 0'dan 255'e kadar
         % MATLAB dizinleme 1'den başladığı için: bin+1
         histogram(bin+1) = histogram(bin+1) + 1;
    end
end

% Adım 2.3: Kümülatif dağılım fonksiyonunu (CDF) hesapla.
cdf = zeros(levels,1);
cdf(1) = histogram(1);
for k = 2:levels
    cdf(k) = cdf(k-1) + histogram(k);
end

% Adım 2.4: cdf_min değerini belirle (ilk sıfırdan farklı değeri)
cdf_min = 0;
for k = 1:levels
    if cdf(k) > 0
        cdf_min = cdf(k);
        break;
    end
end

% Adım 2.5: Eşitleme dönüşümünü uygula.
V_eq = zeros(rows, cols);
for i = 1:rows
    for j = 1:cols
         bin = double(V_int(i,j));
         % Yeni pixel değeri hesaplanıyor (0-1 aralığında)
         V_eq(i,j) = (cdf(bin+1) - cdf_min) / (totalPixels - cdf_min);
    end
end

end
