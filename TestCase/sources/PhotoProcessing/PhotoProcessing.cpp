#include "include/PhotoProcessing/PhotoProcessing.h"

PhotoProcessing::PhotoProcessing(QObject* parent)
    : QObject { parent }
{
}

///
/// \brief PhotoProcessing::processIncreaseScaling - Функция увеличивает изображение в 2 раза используя метод ближайшего соседа.
/// \param imagePath - Путь к изображению.
///
void PhotoProcessing::processIncreaseScaling(const QString& imagePath)
{
    const QString localFilePath = QUrl(imagePath).toLocalFile();

    if (!localFilePath.isEmpty()) {
        /* Так как scale трудоемкая операция, запускаем ее в другом потоке. */
        QtConcurrent::run([=]() {
            /* Передаем сигнал о начале операции в qml */
            emit loadingStartedChanged();

            QImage image(localFilePath);
            QImage newImage(image.width() * 2, image.height() * 2, image.format());

            int newImagePixelY = 0;
            for (int y = 0; y < image.height(); ++y) {
                int newImagePixelX = 0;

                for (int x = 0; x < image.width(); ++x) {
                    /* Дублируем пиксель через один */
                    newImage.setPixelColor(newImagePixelX, newImagePixelY, image.pixelColor(x, y));
                    newImage.setPixelColor(newImagePixelX + 1, newImagePixelY, image.pixelColor(x, y));

                    /* Доблируем предыдущий ряд пискелей */
                    newImage.setPixelColor(newImagePixelX, newImagePixelY + 1, image.pixelColor(x, y));
                    newImage.setPixelColor(newImagePixelX + 1, newImagePixelY + 1, image.pixelColor(x, y));

                    newImagePixelX += 2;
                }

                /* Пропускаем однин ряд в матрице исходного изображения */
                newImagePixelY += 2;
            }

            /* Отправляем новое изображение в qml */
            setUpNewImage(newImage, imagePath);
        });
    }
}

///
/// \brief PhotoProcessing::processDecreaseScaling - Функция уменьшает изображение в 2 раза используя метод ближайшего соседа.
/// \param imagePath - Путь к изображению.
///
void PhotoProcessing::processDecreaseScaling(const QString& imagePath)
{
    const QString localFilePath = QUrl(imagePath).toLocalFile();

    if (!localFilePath.isEmpty()) {
        /* Так как scale трудоемкая операция, запускаем ее в другом потоке. */
        QtConcurrent::run([=]() {
            /* Передаем сигнал о начале операции в qml */
            emit loadingStartedChanged();

            QImage image(localFilePath);
            QImage newImage(image.width() / 2, image.height() / 2, image.format());

            /* Удаляем не масштабированную копию изображения */
            for (int y = 0; y < newImage.height(); ++y) {
                for (int x = 0; x < newImage.width(); ++x) {
                    newImage.setPixelColor(x, y, QColor(0, 0, 0, 0));
                }
            }

            /* Вставляем каждый третий пиксель (начиная с 0) в новое изображение  */
            int newImagePixelY = 0;
            for (int y = 0; y < newImage.height(); ++y) {
                int newImagePixelX = 0;

                for (int x = 0; x < newImage.width(); ++x) {
                    newImage.setPixelColor(x, y, image.pixelColor(newImagePixelX, newImagePixelY));
                    newImagePixelX += 2;
                }

                /* Пропускаем однин ряд в матрице исходного изображения */
                newImagePixelY += 2;
            }

            /* Отправляем новое изображение в qml */
            setUpNewImage(newImage, imagePath);
        });
    }
}

///
/// \brief PhotoProcessing::processBoxBlur - Функция обрабатывает блюрит изображение с помощью BoxBlur.
/// \param imagePath - Путь к изображению.
///
void PhotoProcessing::processBoxBlur(const QString& imagePath, const int samples)
{
    const QString localFilePath = QUrl(imagePath).toLocalFile();

    if (!localFilePath.isEmpty()) {
        /* Так как BoxBlur трудоемкая операция, запускаем ее в другом потоке. */
        QtConcurrent::run([=]() {
            /* Передаем сигнал о начале операции в qml */
            emit loadingStartedChanged();

            QImage image(localFilePath);
            QImage newImage = image;

            /* Прогоняем операцию столько раз, сколько захотел пользователь */
            for (int k = 0; k < samples; k++) {
                for (int y = 0; y < newImage.height(); ++y) {
                    for (int x = 0; x < newImage.width(); ++x) {
                        /* Проверяем на прозрачный пиксель */
                        if (newImage.pixelColor(x, y).red() != 0 && newImage.pixelColor(x, y).green() != 0 && newImage.pixelColor(x, y).blue() != 0 && newImage.pixelColor(x, y).alpha() != 0) {
                            int redTotal = 0;
                            int greenTotal = 0;
                            int blueTotal = 0;
                            int alphaTotal = 0;

                            /* Подсчитываем общее кол-во RGB пикселей вокруг x, y */
                            for (int i = -1; i <= 1; i++) {
                                for (int j = -1; j <= 1; j++) {
                                    int currentX = x + j;
                                    int currentY = y + j;

                                    if (currentX >= 0 && currentY >= 0 && currentX < newImage.width() && currentY < newImage.height()) {
                                        QColor pixel = newImage.pixel(currentX, currentY);

                                        redTotal += pixel.red();
                                        greenTotal += pixel.green();
                                        blueTotal += pixel.blue();
                                        alphaTotal += pixel.alpha();
                                    }
                                }
                            }

                            /* Применяем эффект блюра на пиксель */
                            newImage.setPixelColor(x, y, QColor(redTotal / blurMatrixLength, greenTotal / blurMatrixLength, blueTotal / blurMatrixLength, alphaTotal / blurMatrixLength));
                        }
                    }
                }
            }

            /* Отправляем новое изображение в qml */
            setUpNewImage(newImage, imagePath);
        });
    }
}

///
/// \brief PhotoProcessing::procesRgbToGray - Функция переводит изображение в grayScale.
/// \param imagePath - Путь к изображению.
///
void PhotoProcessing::processRgbToGray(const QString& imagePath)
{
    const QString localFilePath = QUrl(imagePath).toLocalFile();

    if (!localFilePath.isEmpty()) {
        QtConcurrent::run([=]() {
            /* Передаем сигнал о начале операции в qml */
            emit loadingStartedChanged();

            QImage image(localFilePath);

            for (int i = 0; i < image.width(); i++) {
                for (int j = 0; j < image.height(); j++) {
                    QColor pixelColor = image.pixelColor(i, j);

                    /* Проверяем на прозрачный пиксель */
                    if (pixelColor.alpha() != 0) {
                        int gray = (pixelColor.red() * 11 + pixelColor.green() * 16 + pixelColor.blue() * 5) / 32;

                        image.setPixel(i, j, QColor(gray, gray, gray, pixelColor.alpha()).rgb());
                    }
                }
            }

            setUpNewImage(image, localFilePath);
        });
    }
}

///
/// \brief PhotoProcessing::processHue - Устанавливает новый тон изображению.
/// \param imagePath - Путь к изображению.
/// \param hue - Ноывй тон изображения.
///
void PhotoProcessing::processHue(const QString& imagePath, const quint8 hue)
{
    const QString localFilePath = QUrl(imagePath).toLocalFile();

    if (!localFilePath.isEmpty()) {
        QImage image(localFilePath);

        for (int i = 0; i < image.width(); i++) {
            for (int j = 0; j < image.height(); j++) {
                QColor pixelColor = image.pixelColor(i, j);

                pixelColor.setHsv(hue, pixelColor.saturation(), pixelColor.value(), pixelColor.alpha());
                image.setPixelColor(i, j, pixelColor);
            }
        }

        setUpNewImage(image, localFilePath);
    }
}

///
/// \brief PhotoProcessing::processContrast - Функция изменяет контраст изображение.
/// \param tmpImagePath - Путь к изображению, которое будет изменено.
/// \param savePath - Путь по которому будет сохранено изменное изображение
/// \param contrast - Параметр контрастности, на которое будет увеличена сама яркость. От -127 до 127.
///
void PhotoProcessing::processContrast(const QString& tmpImagePath, const QString& savePath, const qint8 contrast)
{
    if (!tmpImagePath.isEmpty()) {
        QImage image(tmpImagePath);

        /*
         * Высчитываем коэффициент коррекции контраста по формуле: (259 * (C + 255)) / (255 * (259 - C))
         * Где C - введеное пользователем значение.
         */
        float factor = (259.0 * (contrast + 255.0)) / (255.0 * (259.0 - contrast));

        for (int i = 0; i < image.width(); i++) {
            for (int j = 0; j < image.height(); j++) {
                QColor pixelColor = image.pixelColor(i, j);

                /* Проверяем на прозрачный пиксель */
                if (pixelColor.alpha() != 0) {
                    /*
                     * Высчитываем новый цвет по формуле: C' = F * (C - 128) + 128
                     * Где C - цвет, а F - коэффициент коррекции контраста.
                     */
                    QRgb red = truncatePixelValue(factor * (pixelColor.red() - 128) + 128);
                    QRgb green = truncatePixelValue(factor * (pixelColor.green() - 128) + 128);
                    QRgb blue = truncatePixelValue(factor * (pixelColor.blue() - 128) + 128);

                    image.setPixel(i, j, QColor(red, green, blue, pixelColor.alpha()).rgba());
                }
            }
        }

        setUpNewImage(image, savePath);
    }
}

///
/// \brief PhotoProcessing::processBrightness - Функция изменяет яркость изображение.
/// \param tmpImagePath - Путь к изображению, которое будет изменено.
/// \param savePath - Путь по которому будет сохранено изменное изображение
/// \param brightness - Параметр яркости, на которое будет увеличена сама яркость. От 0.0 до 2.0.
///
void PhotoProcessing::processBrightness(const QString& tmpImagePath, const QString& savePath, const float brightness)
{
    if (!tmpImagePath.isEmpty()) {
        QImage image(tmpImagePath);

        for (int i = 0; i < image.width(); i++) {
            for (int j = 0; j < image.height(); j++) {
                QColor pixelColor = image.pixelColor(i, j);

                /* Проверяем на прозрачный пиксель */
                if (pixelColor.red() != 0 && pixelColor.green() != 0 && pixelColor.blue() != 0 && pixelColor.alpha() != 0) {
                    QRgb red = truncatePixelValue(pixelColor.red() * brightness);
                    QRgb green = truncatePixelValue(pixelColor.green() * brightness);
                    QRgb blue = truncatePixelValue(pixelColor.blue() * brightness);

                    image.setPixel(i, j, QColor(red, green, blue, pixelColor.alpha()).rgba());
                }
            }
        }

        setUpNewImage(image, savePath);
    }
}

///
/// \brief PhotoProcessing::processRotate - Функция делает разворот изображения на 90 градусов.
/// \param imagePath - Путь к изображению.
///
void PhotoProcessing::processRotate(const QString& imagePath)
{
    const QString localFilePath = QUrl(imagePath).toLocalFile();

    if (!localFilePath.isEmpty()) {
        QtConcurrent::run([=]() {
            /* Передаем сигнал о начале операции в qml */
            emit loadingStartedChanged();

            QImage image(localFilePath);
            QImage newImage(image.height(), image.width(), image.format());

            for (int i = 0; i < image.width(); i++) {
                for (int j = 0; j < image.height(); j++) {
                    QRgb pixel = image.pixel(i, j);
                    newImage.setPixel(j, image.width() - i - 1, pixel);
                }
            }

            setUpNewImage(newImage, localFilePath);
        });
    }
}

///
/// \brief PhotoProcessing::setUpNewImage - Функция сохранять новое изображение в tmp папке и устанавливает новое изображение в UI.
/// \param image - Новое изображение.
/// \param imagePath - Путь к новому изображению.
///
void PhotoProcessing::setUpNewImage(const QImage& image, const QString& imagePath)
{
    if (temporaryDir.isValid()) {
        QFileInfo imageInfo(imagePath);
        const QString fileName = temporaryDir.path() % "/" % imageInfo.fileName();

        image.save(fileName);
        emit imageEditChanged(QUrl::fromLocalFile(fileName).toString());
    }
}
