function [H_out, S_out, V_out] = RGBtoHSV(R, G, B)
%#codegen
% Bu fonksiyon, 270x372 uint8 tipindeki ayrı RGB girişlerini sabit nokta
% aritmetiği kullanarak HSV’ye dönüştürür. Çıktılar,
% H_out: [0 255] aralığında Hue değeri (360°'yi 255’e ölçekler)
% S_out, V_out: [0 1] aralığından [0 255]'e ölçeklenmiş değerlerdir.
%
% Tüm sabit nokta işlemleri ufix32, En15 formatında gerçekleştirilir.
% HDL Coder uyumluluğu göz önünde bulundurulmuştur.

%% Sabit Görüntü Boyutları
nRows = 270;
nCols = 372;

%% Sabit Nokta Ayarları: fimath
fm = fimath('RoundingMethod', 'Nearest', ...
            'OverflowAction', 'Saturate', ...
            'ProductMode', 'SpecifyPrecision', ...
            'ProductWordLength', 32, ...
            'ProductFractionLength', 15, ...
            'SumMode', 'SpecifyPrecision', ...
            'SumWordLength', 32, ...
            'SumFractionLength', 15);

%% Sabit Nokta Sabitleri (Tümü ufix32, En15 ile)
inv255   = fi(1/255,  0, 32, 15, 'fimath', fm);       % Normalizasyon için 1/255
scaleH   = fi(255/360, 0, 32, 15, 'fimath', fm);       % Hue: [0,360] -> [0,255]
scale255 = fi(255,     0, 32, 0,  'fimath', fm);        % S ve V: [0,1] -> [0,255]
const60  = fi(60,      0, 32, 15, 'fimath', fm);
const2   = fi(2,       0, 32, 15, 'fimath', fm);
const4   = fi(4,       0, 32, 15, 'fimath', fm);
const360 = fi(360,     0, 32, 15, 'fimath', fm);
const6   = fi(6,       0, 32, 15, 'fimath', fm);
zeroFP   = fi(0,       0, 32, 15, 'fimath', fm);

%% Çıktı Dizilerinin Başlatılması (uint8)
H_out = zeros(nRows, nCols, 'uint8');
S_out = zeros(nRows, nCols, 'uint8');
V_out = zeros(nRows, nCols, 'uint8');

%% Giriş R, G, B Kanallarının Normalize Edilmesi ([0,1] aralığına)
R_norm = fi(zeros(nRows, nCols), 0, 32, 15, 'fimath', fm);
G_norm = fi(zeros(nRows, nCols), 0, 32, 15, 'fimath', fm);
B_norm = fi(zeros(nRows, nCols), 0, 32, 15, 'fimath', fm);

for i = 1:nRows
    for j = 1:nCols
        R_norm(i, j) = fi(R(i, j), 0, 32, 15, 'fimath', fm) * inv255;
        G_norm(i, j) = fi(G(i, j), 0, 32, 15, 'fimath', fm) * inv255;
        B_norm(i, j) = fi(B(i, j), 0, 32, 15, 'fimath', fm) * inv255;
    end
end

%% HSV Hesaplamalarının Yapılması (piksel bazında)
H_fp = fi(zeros(nRows, nCols), 0, 32, 15, 'fimath', fm);
S_fp = fi(zeros(nRows, nCols), 0, 32, 15, 'fimath', fm);
V_fp = fi(zeros(nRows, nCols), 0, 32, 15, 'fimath', fm);

for i = 1:nRows
    for j = 1:nCols
        % Normalize edilmiş renk değerlerini al
        r_val = R_norm(i, j);
        g_val = G_norm(i, j);
        b_val = B_norm(i, j);
        
        % Cmax (en büyük) ve Cmin (en küçük) değerlerini belirle
        if (r_val >= g_val) && (r_val >= b_val)
            Cmax = r_val;
        elseif (g_val >= r_val) && (g_val >= b_val)
            Cmax = g_val;
        else
            Cmax = b_val;
        end
        
        if (r_val <= g_val) && (r_val <= b_val)
            Cmin = r_val;
        elseif (g_val <= r_val) && (g_val <= b_val)
            Cmin = g_val;
        else
            Cmin = b_val;
        end
        
        Delta = Cmax - Cmin;
        
        % Value değeri, Cmax'e eşittir
        V_val = Cmax;
        H_val = zeroFP;
        S_val = zeroFP;
        
        if (Delta == zeroFP)
            % Delta sıfırsa H ve S sıfır kabul edilir.
            H_val = zeroFP;
            S_val = zeroFP;
        else
            % Bölme sonucu için tip zorlaması yapılarak S_val atanıyor.
            S_val = fi(Delta / Cmax, 0, 32, 15, 'fimath', fm);
            if r_val == Cmax
                % Hue hesabı: H = 60 * ( (g-b)/Delta mod 6 )
                temp = fi((g_val - b_val) / Delta, 0, 32, 15, 'fimath', fm);
                if (temp < zeroFP)
                    temp = temp + const6;
                end
                H_val = const60 * temp;
            elseif g_val == Cmax
                H_val = const60 * (fi(((b_val - r_val) / Delta), 0, 32, 15, 'fimath', fm) + const2);
            else
                H_val = const60 * (fi(((r_val - g_val) / Delta), 0, 32, 15, 'fimath', fm) + const4);
            end
            
            if (H_val < zeroFP)
                H_val = H_val + const360;
            end
            if (H_val >= const360)
                H_val = H_val - const360;
            end
        end
        
        H_fp(i, j) = H_val;
        S_fp(i, j) = S_val;
        V_fp(i, j) = V_val;
    end
end

%% Ölçeklendirme ve Çıktıya Dönüştürme (uint8)
for i = 1:nRows
    for j = 1:nCols
        H_scaled = H_fp(i, j) * scaleH;
        S_scaled = S_fp(i, j) * scale255;
        V_scaled = V_fp(i, j) * scale255;
        
        H_out(i, j) = uint8(H_scaled);
        S_out(i, j) = uint8(S_scaled);
        V_out(i, j) = uint8(V_scaled);
    end
end

end
