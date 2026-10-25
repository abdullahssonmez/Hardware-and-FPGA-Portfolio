function [part1, part2, part3, part4] = splitVideo(video)
    % Girişlerin boyutlarını ve türlerini al
    [rows, cols, ~] = size(video);
    
    % Görüntüyü dört eşit parçaya böl
    rows_half = floor(rows / 2);
    cols_half = floor(cols / 2);
    
    % Girişin ilk yarısını parçalara ata
    part1 = video(1:rows_half, 1:cols_half, :);
    part2 = video(1:rows_half, cols_half+1:end, :);
    part3 = video(rows_half+1:end, 1:cols_half, :);
    part4 = video(rows_half+1:end, cols_half+1:end, :);
end
