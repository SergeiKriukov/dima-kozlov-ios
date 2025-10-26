#!/bin/bash

# Скрипт оптимизации изображений для iOS приложения Димы Козлова
# Уменьшает размер файлов в 5-10 раз при сохранении качества

echo "🚀 Начинаем оптимизацию изображений..."
echo "📁 Рабочая директория: $(pwd)"
echo "📊 Количество изображений: $(ls dima-kozlov-ios/stories/*.jpg 2>/dev/null | wc -l)"

# Создаем папку для оптимизированных изображений
mkdir -p dima-kozlov-ios/stories/optimized

# Проверяем наличие ImageMagick
if ! command -v convert &> /dev/null; then
    echo "❌ ImageMagick не установлен. Установите командой:"
    echo "   brew install imagemagick"
    exit 1
fi

echo "✅ ImageMagick найден. Начинаем обработку..."

# Статистика до оптимизации
echo "📈 СТАТИСТИКА ДО ОПТИМИЗАЦИИ:"
du -sh dima-kozlov-ios/stories/*.jpg 2>/dev/null | tail -1

# Оптимизируем каждое изображение
for img in dima-kozlov-ios/stories/*.jpg; do
    if [[ -f "$img" ]]; then
        filename=$(basename "$img")
        output="dima-kozlov-ios/stories/optimized/$filename"

        echo "🔄 Обрабатываем: $filename"

        # Получаем размеры оригинального изображения
        original_size=$(stat -f%z "$img")
        dimensions=$(identify -format "%wx%h" "$img" 2>/dev/null || echo "unknown")

        echo "   📏 Размеры: $dimensions, Размер: $original_size bytes"

        # Оптимизируем изображение:
        # -resize "1200x1200>" - уменьшаем до 1200px по большей стороне
        # -quality 85 - устанавливаем качество JPEG 85%
        # -strip - удаляем метаданные EXIF
        convert "$img" \
            -resize "1200x1200>" \
            -quality 85 \
            -strip \
            "$output"

        # Показываем результат
        new_size=$(stat -f%z "$output")
        compression_ratio=$((original_size / new_size))
        echo "   ✅ Оптимизировано: $new_size bytes (сжатие ${compression_ratio}x)"
        echo ""
    fi
done

# Статистика после оптимизации
echo "📈 СТАТИСТИКА ПОСЛЕ ОПТИМИЗАЦИИ:"
du -sh dima-kozlov-ios/stories/optimized/*.jpg 2>/dev/null | tail -1

# Показываем экономию места
original_total=$(du -sc dima-kozlov-ios/stories/*.jpg 2>/dev/null | tail -1 | awk '{print $1}')
optimized_total=$(du -sc dima-kozlov-ios/stories/optimized/*.jpg 2>/dev/null | tail -1 | awk '{print $1}')

if [[ -n "$original_total" && -n "$optimized_total" ]]; then
    savings=$((original_total - optimized_total))
    percentage=$((savings * 100 / original_total))
    echo "💰 ЭКОНОМИЯ: $savings KB (${percentage}%)"
fi

echo ""
echo "🎉 Оптимизация завершена!"
echo "📂 Оптимизированные изображения в папке: dima-kozlov-ios/stories/optimized/"
echo ""
echo "📋 ДАЛЬНЕЙШИЕ ШАГИ:"
echo "1. Проверьте качество изображений в папке optimized/"
echo "2. Замените оригиналы: cp optimized/* stories/"
echo "3. Удалите папку optimized: rm -rf optimized/"
echo "4. Пересоберите приложение и проверьте размер бандла"