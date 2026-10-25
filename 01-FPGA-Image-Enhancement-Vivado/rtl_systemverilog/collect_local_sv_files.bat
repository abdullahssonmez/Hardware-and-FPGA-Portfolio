@echo off
echo ============================================================================
echo  Otomatik SystemVerilog (.sv) ve Test Vektor (.dat) Kopyalama Betigi
echo  Vivado .xpr projenizdeki OneDrive kaynak yolundan .sv dosyalarini toplar
echo ============================================================================

set "CLAHE_SRC=C:\Users\snmz4\OneDrive\Belgeler\MATLAB\Examples\R2024b\visionhdl\CLAHEHDLExample\hdlsrc\CLAHEExample"
set "HIST_SRC=C:\Users\snmz4\OneDrive\Belgeler\MATLAB\Examples\R2024b\visionhdl\HistogramEqualizationHDLExample\hdlsrc\HistogramEqualizationHDL"

if exist "%CLAHE_SRC%" (
    echo [OK] CLAHE SystemVerilog dosyalari bulundu, kopyalaniyor...
    xcopy /Y /Q "%CLAHE_SRC%\*.sv" "CLAHE_HDL_SystemVerilog\"
    xcopy /Y /Q "%CLAHE_SRC%\*.dat" "CLAHE_HDL_SystemVerilog\"
) else (
    echo [UYARI] "%CLAHE_SRC%" bulunamadi. Lutfen .sv dosyalarinizi CLAHE_HDL_SystemVerilog klasorune manuel kopyalayin.
)

if exist "%HIST_SRC%" (
    echo [OK] HistogramEqualization SystemVerilog dosyalari bulundu, kopyalaniyor...
    xcopy /Y /Q "%HIST_SRC%\*.sv" "HistogramEqualization_HDL_SystemVerilog\"
    xcopy /Y /Q "%HIST_SRC%\*.dat" "HistogramEqualization_HDL_SystemVerilog\"
) else (
    echo [UYARI] "%HIST_SRC%" bulunamadi. Lutfen .sv dosyalarinizi HistogramEqualization_HDL_SystemVerilog klasorune manuel kopyalayin.
)

echo Islem tamamlandi!
pause
